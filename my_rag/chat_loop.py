#!/usr/bin/env python3
"""
Интерактивный чат поверх RAG-индекса UltraRAG.
Использование:
    python my_rag/chat_loop.py
"""
import asyncio
import json
import os
import sys
from pathlib import Path

# добавляем корень репо в PYTHONPATH
ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "src"))

from ultrarag.api import initialize, ToolCall  # noqa: E402

SERVERS = ["retriever", "generation", "prompt", "memory", "custom"]


async def main() -> None:
    initialize(
        servers=SERVERS,
        server_root=str(ROOT / "servers"),
        log_level="INFO",
    )

    # инициализация
    await ToolCall.memory.get_global_memory()
    await ToolCall.retriever.retriever_init()
    await ToolCall.generation.generation_init()

    history: list[dict] = []
    print("=" * 60)
    print("  RAG-чат готов. Введите вопрос (или 'exit').")
    print("=" * 60)

    while True:
        try:
            q = input("\n> ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nПока!")
            break

        if not q or q.lower() in {"exit", "quit", "q"}:
            break

        # сохраняем user-turn в память
        await ToolCall.memory.save_memory(memory_input={"role": "user", "content": q})
        history.append({"role": "user", "content": q})

        # retrieval с учётом истории
        await ToolCall.retriever.retriever_project_memory_search(query=q, top_k=5)
        ctx = await ToolCall.retriever.retriever_search(query=q, top_k=5)
        await ToolCall.custom.assign_citation_ids()
        await ToolCall.prompt.qa_rag_with_memory()

        ans = await ToolCall.generation.generate()
        answer_text = ans[0] if isinstance(ans, list) else str(ans)

        print(f"\n{answer_text}\n")
        print("-" * 60)

        history.append({"role": "assistant", "content": answer_text})
        await ToolCall.memory.save_memory(
            memory_input={"role": "assistant", "content": answer_text}
        )

    # финальный snapshot
    snap_path = ROOT / "my_rag/output/memory.json"
    snap_path.parent.mkdir(parents=True, exist_ok=True)
    snap_path.write_text(json.dumps(history, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"\nЛог сохранён: {snap_path}")


if __name__ == "__main__":
    asyncio.run(main())
