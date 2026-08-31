#!/bin/bash
# install_minimal.sh — минимальная установка для медицинского RAG
set -e
cd "$(dirname "$0")/.."

echo ">>> Создаю venv..."
/home/user/.local/bin/uv venv .venv --python 3.12
source .venv/bin/activate

echo ">>> Ставлю core..."
/home/user/.local/bin/uv pip install -e .

echo ">>> Ставлю retriever (sentence-transformers + FAISS)..."
/home/user/.local/bin/uv pip install sentence-transformers faiss-cpu pymilvus

echo ">>> Ставлю document parsers..."
/home/user/.local/bin/uv pip install pymupdf python-docx openpyxl jieba chardet

echo ">>> Ставлю HTTP/OpenAI клиент (для OMNIROUTE)..."
/home/user/.local/bin/uv pip install openai httpx[socks] aiohttp

echo ">>> Ставлю UI backend..."
/home/user/.local/bin/uv pip install flask tabulate

echo ""
echo "✅ Готово! Проверка:"
/home/user/Developer/UltraRAG-rus/.venv/bin/ultrarag --help | head -10
