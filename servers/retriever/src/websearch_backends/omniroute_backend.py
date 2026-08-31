from __future__ import annotations

import asyncio
import os
from typing import Any, Dict, List, Optional, Sequence

import aiohttp
from fastmcp.exceptions import ToolError

from .base import BaseWebSearchBackend


class OmnirouteWebSearchBackend(BaseWebSearchBackend):
    """Web search backend for Omniroute.

    Использует Omniroute API как унифицированный шлюз для web-поиска.
    Конфигурация по умолчанию берётся из переменных окружения:
    - OMNIROUTE_API_KEY
    - OMNIROUTE_HOST
    - OMNIROUTE_API_PATH
    - OMNIROUTE_MODEL
    """

    def __init__(self, config: Optional[Dict[str, Any]], logger, **kwargs: Any) -> None:
        super().__init__(config=config, logger=logger, **kwargs)
        api_key = self.config.get("api_key") or os.environ.get("OMNIROUTE_API_KEY", "")
        if not api_key:
            err_msg = (
                "OMNIROUTE_API_KEY environment variable is not set. "
                "Please set it to use Omniroute."
            )
            self.logger.error(err_msg)
            raise ToolError(err_msg)

        self._api_key = api_key
        host = self.config.get("host") or os.environ.get(
            "OMNIROUTE_HOST", "http://147.45.125.8:20128"
        )
        api_path = self.config.get("api_path") or os.environ.get(
            "OMNIROUTE_API_PATH", "/api/v1"
        )
        self._base_url = f"{host.rstrip('/')}{api_path if api_path.startswith('/') else '/' + api_path}/websearch"
        self._model = self.config.get("model") or os.environ.get(
            "OMNIROUTE_MODEL", "free-stack"
        )
        self._retries = int(self.config.get("retries", 3))
        self._base_delay = float(self.config.get("base_delay", 1.0))
        self._timeout = self.config.get("timeout", None)

    async def search(
        self,
        query_list: Sequence[str],
        top_k: Optional[int] = 5,
        retrieve_thread_num: Optional[int] = 1,
    ) -> List[List[str]]:
        queries = [str(q) for q in query_list]
        if not queries:
            return []

        result_key = self.config.get("result_key", "results")
        content_key = self.config.get("content_key", "content")
        desc = self.config.get("progress_desc", "Omniroute Searching:")
        effective_top_k = None if top_k is None else int(top_k)

        headers = {
            "Authorization": f"Bearer {self._api_key}",
            "Content-Type": "application/json",
        }

        timeout_cfg = (
            aiohttp.ClientTimeout(total=float(self._timeout))
            if self._timeout
            else None
        )

        async with aiohttp.ClientSession(timeout=timeout_cfg) as session:

            async def worker_factory(idx: int, q: str):
                delay = self._base_delay
                for attempt in range(self._retries):
                    try:
                        payload = {
                            "model": self._model,
                            "query": q,
                        }
                        if effective_top_k is not None:
                            payload["top_k"] = effective_top_k

                        async with session.post(
                            self._base_url, json=payload, headers=headers
                        ) as resp:
                            resp.raise_for_status()
                            data = await resp.json()
                            results: List[Dict[str, Any]] = (
                                data.get(result_key, []) or []
                            )
                            psg_ls: List[str] = [
                                (r.get(content_key) or "") for r in results
                            ]
                            if effective_top_k is not None:
                                psg_ls = psg_ls[:effective_top_k]
                            return idx, psg_ls
                    except (aiohttp.ClientError, Exception) as e:
                        warn_msg = (
                            f"[omniroute][retry {attempt+1}] failed (idx={idx}): {e}"
                        )
                        self.logger.warning(warn_msg)
                        await asyncio.sleep(delay)
                        delay *= 2
                return idx, []

            return await self._parallel_search(
                query_list=queries,
                retrieve_thread_num=retrieve_thread_num or 1,
                desc=desc,
                worker_factory=worker_factory,
            )