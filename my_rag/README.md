# Медицинский RAG на базе UltraRAG

Документы: `/home/user/MEGA/suvorov_disk/rag_docs/` (36 файлов, ~12 МБ)

## Состав документов

- **МКБ-10** (PDF + DOCX) — Международная классификация болезней
- **ФЗ-323** — Об основах охраны здоровья граждан
- **Приказы Минздрава**: 180н, 203н, 231н, 530н, 1094н
- **Клинические рекомендации, стандарты, методические рекомендации**
- **Системы организма**: ССС, дыхательная, печень, мочевые органы, КОС, свертывающая система, ЖКТ, ЦНС
- **Перечень ЖНВЛП, схемы обследования пациента**

## Запуск (3 шага)

```bash
cd ~/Developer/UltraRAG-rus

# 1. Чанкинг (MinerU парсит PDF, python-docx — DOCX, встроенный — TXT/DOC)
ultrarag run my_rag/chunk.yaml --param my_rag/params.yaml

# 2. Построение эмбеддингов + FAISS
ultrarag run my_rag/build_index.yaml --param my_rag/params.yaml

# 3. Чат
# Вариант A — UI:
ultrarag show ui
# Вариант B — интерактивный REPL:
python my_rag/chat_loop.py
# Вариант C — batch:
ultrarag run my_rag/chat.yaml --param my_rag/params.yaml
```

## ⚠️ Важно про эмбеддер

`MiniCPM-Embedding-Light` (по умолчанию) — английская модель. Для русского **замените** в `params.yaml`:

```yaml
model_name_or_path: ai-forever/sbert_large_nlu_ru   # рекомендую
# или
model_name_or_path: intfloat/multilingual-e5-large  # мультиязычный, требует "query: " префикс
```

## 🔍 Примеры вопросов для теста

```jsonl
{"id": 0, "question": "Какой код МКБ-10 у пневмонии?"}
{"id": 1, "question": "Что входит в обязанности врачебной комиссии по приказу 180н?"}
{"id": 2, "question": "Какие сроки временной нетрудоспособности при ОРВИ?"}
{"id": 3, "question": "Перечисли показатели кислотно-щелочного состояния"}
{"id": 4, "question": "Какие документы нужны для оформления истории болезни?"}
```

## 🩺 Системный промпт для медицины

Уже настроен в `params.yaml` — модель будет:
- ✅ Отвечать только на основе контекста
- ✅ Честно говорить "информации нет" если не нашла
- ✅ Цитировать источник
- ❌ Не давать диагнозы и не назначать лечение

## 🐛 Частые проблемы

| Проблема | Решение |
|---|---|
| `No module: pymupdf` | `uv sync --extra corpus` |
| `CUDA OOM` при индексации | `encode_chunk_size: 32`, `batch_size: 4` |
| `ENOSPC: no space left` | Освободите место; эмбеддинги ~300-500 МБ |
| Ответы не на русском | Проверьте `backend_configs.openai.base_url` и `api_key` |
| Документ не распарсился | `ls my_rag/corpora/text.jsonl` — пусто? Проверьте права на папку |

## 🚀 Альтернативный быстрый путь (без UI)

```bash
# 1) собрать корпус (один скрипт)
python my_rag/build_corpus.py

# 2) построить индекс
python my_rag/build_index.py

# 3) запустить чат
python my_rag/chat_loop.py
```

(Скрипты `build_corpus.py` и `build_index.py` можно создать как обёртки над `ToolCall.*` — спросите, если нужны.)
