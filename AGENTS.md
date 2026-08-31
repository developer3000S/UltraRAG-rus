# AGENTS.md

Документ является основным инженерным руководством для автономных агентов-кодеров, работающих с репозиторием `UltraRAG`.

Используйте этот файл как источник истины об архитектуре, соглашениях, рабочих процессах и безопасных шаблонах изменений.
Если существует `CLAUDE.md`, он должен лишь указывать на этот файл.

---

## 1) Идентификация проекта

`UltraRAG` — это лёгкий RAG-фреймворк, построенный вокруг Model Context Protocol (MCP).
Ключевое архитектурное решение — строгая модульность: извлечение, формирование промптов, генерация, маршрутизация, память и оценка реализованы как независимые MCP-серверы, оркестрируемые YAML-pipeline'ами.

Текущие метаданные ядра:

- Пакет: `ultrarag`
- Версия: `0.3.0`
- Python: `>=3.11, <3.13`
- Точка входа CLI: `ultrarag = ultrarag.client:main`
- Менеджер пакетов: `uv` (`[tool.uv] package = true`)

---

## 2) Карта репозитория (что важнее всего)

```text
UltraRAG/
├── src/ultrarag/                    # Устанавливаемое ядро пакета
│   ├── client.py                    # CLI + движок pipeline + оркестрация run/build
│   ├── server.py                    # UltraRAG_MCP_Server (расширение FastMCP)
│   ├── api.py                       # Python-API обёртки (ToolCall, PipelineCall)
│   ├── cli.py                       # Rich-баннер и CLI-визуал
│   ├── mcp_logging.py               # Централизованная настройка логирования
│   ├── mcp_exceptions.py            # Проверки Node.js для удалённого MCP
│   └── utils.py                     # Хелперы жизненного цикла подпроцессов
│
├── servers/                         # MCP-микросервисы (каждый сервер независим)
│   ├── retriever/
│   ├── generation/
│   ├── prompt/
│   ├── reranker/
│   ├── benchmark/
│   ├── evaluation/
│   ├── corpus/
│   ├── memory/
│   ├── router/
│   ├── custom/
│   ├── pageindex/
│   └── sayhello/
│
├── examples/
│   ├── demos/                       # Демо-pipeline, готовые для UI
│   └── experiments/                 # Экспериментальные/исследовательские pipeline
│
├── ui/
│   ├── backend/                     # Flask-бэкенд + менеджер pipeline'ов
│   └── frontend/                    # Vite + React + TypeScript
│
├── docs/                            # Документация и ассеты
├── script/                          # Утилитарные скрипты (deploy, case study и т.п.)
├── pyproject.toml                   # Зависимости + метаданные пакета
├── uv.lock                          # Зафиксированный граф зависимостей
├── Dockerfile*                      # Варианты контейнеров
└── .gitignore
```

Важные генерируемые/производные файлы:

- `servers/*/server.yaml` (генерируется инструментом `build` каждого сервера)
- `examples/**/parameter/*_parameter.yaml` (параметры, объединённые из pipeline)
- `examples/**/server/*_server.yaml` (конфиги серверов, объединённые из pipeline)
- `output/memory_*.json` (снимки памяти по каждому запуску)

---

## 3) Ментальная модель системы

Думайте об UltraRAG как о трёхуровневой системе:

1. **Интерфейсный уровень**: CLI (`ultrarag ...`), UI (`ultrarag show ui`) и Python API (`ToolCall`, `PipelineCall`)
2. **Уровень оркестрации**: `src/ultrarag/client.py` (`build`, `load_pipeline_context`, `execute_pipeline`)
3. **Уровень исполнения**: MCP-серверы в `servers/*`, каждый экспонирует tools/prompts через stdio (или прокси удалённого MCP)

Контракт времени исполнения:

- YAML-pipeline объявляет **какие серверы** использовать и **какие шаги** выполнить.
- Клиент разрешает зависимости ввода-вывода между шагами.
- Каждый шаг вызывает ровно один MCP tool или prompt.
- Выходы сохраняются в общий пул переменных и могут подаваться в downstream-шаги.

---

## 4) Двухфазный жизненный цикл выполнения

### Фаза A: Build

Команда:

```bash
ultrarag build <pipeline.yaml>
```

Что происходит:

- Читает секцию `servers:` из YAML-pipeline.
- Для каждого указанного сервера вызывает инструмент `build` этого сервера.
- Создаёт:
  - `<pipeline_dir>/parameter/<pipeline_name>_parameter.yaml`
  - `<pipeline_dir>/server/<pipeline_name>_server.yaml`

Почему это важно:

- `build` материализует точные метаданные I/O tool/prompt перед выполнением.
- UI и runner полагаются на эти сгенерированные артефакты для детерминированного выполнения.

### Фаза B: Run

Команда:

```bash
ultrarag run <pipeline.yaml> [--param path] [--is_demo]
```

Что происходит:

- Загружает сгенерированный server-конфиг + parameter-конфиг.
- Создаёт конфигурацию транспорта `fastmcp.Client` для каждого сервера.
- Выполняет шаги pipeline по порядку, включая `loop` и `branch`.
- Сохраняет промежуточные снимки памяти и пишет `output/memory_*.json`.
- Вызывает инструменты очистки (например, tools с суффиксом `vllm_shutdown`) при наличии.

---

## 5) Справочник DSL Pipeline

UltraRAG принимает смешанные формы шагов:

### 5.1 Простой шаг

```yaml
- retriever.retriever_search
```

### 5.2 Шаг с переназначением ввода/вывода

```yaml
- generation.generate:
    input:
      prompt_ls: custom_prompt_ls
    output:
      ans_ls: final_answer_ls
```

### 5.3 Блок loop

```yaml
- loop:
    times: 3
    steps:
    - retriever.retriever_search
    - generation.generate
```

### 5.4 Блок branch

```yaml
- branch:
    router:
    - router.route_query
    branches:
      need_retrieval:
      - retriever.retriever_search
      direct_answer:
      - generation.generate
```

### 5.5 Семантика Prompt vs Tool

- Шаги под сервером `prompt` вызывают `client.get_prompt(...)`.
- Шаги под не-prompt серверами вызывают `client.call_tool(...)`.

---

## 6) Разрешение переменных и правила потоков данных

В `UltraData` каждое значение ввода инструмента интерпретируется по соглашению:

- `"$foo"` -> загрузить из локальных параметров сервера (`parameter.yaml`)
- `"bar"`  -> прочитать из глобального пула переменных (`global_vars["bar"]`)
- `"memory_xxx"` -> читать/писать списки памяти

Обработка вывода:

- Tool возвращает JSON-payload -> ключи мапятся на объявленные выходы
- Переназначение вывода (`output:` в шаге pipeline) применяется при сохранении
- Выходы prompt обычно дают `prompt_ls`

Обработка branch:

- Значения с поддержкой веток используют обёрнутые list-записи с ключами состояния ветки.
- Внутренний sentinel (`UNSET`) используется, чтобы отличить «ещё не заполнено» от `None`.

Обработка памяти:

- Движок автоматически отслеживает истории `memory_*`.
- Финальные снимки сериализуются в `output/memory_<...>.json`.
- При обнаружении сервера памяти может срабатывать автосохранение памяти по ходам.

---

## 7) Основные модули Python (авторитетный гид)

### `src/ultrarag/client.py`

Оркестрационное сердце проекта.

Ключевые обязанности:

- Точка входа CLI (`main`)
- Запуск UI (`launch_ui`) и case-study (`launch_case_study`)
- Загрузка конфигурации (`Configuration`)
- Граф данных pipeline и состояние (`UltraData`)
- Сборка конфигов pipeline (`build`)
- Загрузка контекста выполнения (`load_pipeline_context`)
- Движок шагов (`execute_pipeline`)
- Запуск полного pipeline (`run`)

Важные поведения времени выполнения:

- Поддерживает локальные Python MCP-серверы (`path.endswith(".py")`) и удалённые MCP-эндпоинты (`http(s)`).
- Для удалённого MCP требует Node.js >= 20 и использует `npx -y mcp-remote <url>`.
- Хранит состояние завершения цикла в `ContextVar` для безопасности корутин.
- Эмитирует структурированные stream-события в demo/UI потоках (`step_start`, `step_end`, `token`, `sources`).

### `src/ultrarag/server.py`

Определяет `UltraRAG_MCP_Server`, обёртку совместимости над FastMCP.

Ключевые обязанности:

- Расширенная регистрация `tool()` и `prompt()` с поддержкой метаданных `output`
- Захват метаданных для автогенерации конфигов
- `build(parameter_file)` для генерации `server.yaml` каждого сервера
- Фильтрация совместимости для различий в сигнатурах FastMCP

### `src/ultrarag/api.py`

Эргономичные Python-обёртки:

- `initialize(servers, server_root, log_level)`
- `ToolCall.server_name.tool_name(...)`
- `PipelineCall(pipeline_file, parameter_file, log_level)`

### `src/ultrarag/mcp_logging.py`

- Инициализирует корневой логгер `UltraRAG`
- Rich-логирование в консоль + логирование в файл (`logs/<timestamp>.log`)
- Уровень логирования управляется аргументом `log_level` и окружением

### `src/ultrarag/mcp_exceptions.py`

- Валидирует наличие/версию локального Node.js
- Выбрасывает `NodeNotInstalledError` / `NodeVersionTooLowError`

### `src/ultrarag/utils.py`

- Хелперы жизненного цикла подпроцессов
- Поддержка сигнала parent-death в POSIX
- Поддержка job-объектов Windows для очистки дочерних процессов

---

## 8) Контракт авторинга MCP-сервера

Каждый сервер имеет такую структуру:

```text
servers/<name>/
├── parameter.yaml
├── server.yaml            # генерируется
└── src/<name>.py
```

### 8.1 Стили регистрации

Допустимы оба:

1. Стиль декоратора
2. Стиль регистрации методов на классе

Оба валидны в этом репозитории.

### 8.2 Грамматика `output=`

Каноническая форма:

```text
input1,input2,$param_a -> output1,output2
```

Правила:

- Левая часть мапит аргументы функции на входы pipeline.
- Правая часть определяет ожидаемые ключи вывода из возвращённого dict/JSON.
- `-> None` означает, что выходных переменных нет.
- `$param` означает, что значение берётся из parameter-файла сервера.

### 8.3 Ожидания по payload возврата

- Для tools: возвращают JSON-сериализуемые dict-payload'ы, совпадающие по ключам с объявленными выходами.
- Для prompts: возвращают prompt-сообщения (как правило list-like prompt-payload'ы, потребляемые через `get_prompt`).

### 8.4 Требование к точке входа

Модули серверов должны заканчиваться:

```python
if __name__ == "__main__":
    app.run(transport="stdio")
```

---

## 9) Особенности Retriever/Generation/Prompt

### Retriever (`servers/retriever`)

- Поддерживает несколько режимов извлечения:
  - Плотное извлечение
  - BM25
  - Web-поиск
  - Извлечение проектной памяти
- Бэкенды индекса подключаются через фабрику:
  - `faiss`
  - `milvus`
- Бэкенды web-поиска подключаются через фабрику:
  - `exa`
  - `tavily`
  - `omniroute`

### Generation (`servers/generation`)

- Поддерживает бэкенды генерации: `openai`, `vllm` и hf-workflow'ы.
- Предоставляет явный инструмент очистки `vllm_shutdown`.
- В demo-режиме может использовать локальный сервис потоковой генерации.

### Prompt (`servers/prompt`)

- Использует `SandboxedEnvironment` из Jinja2 для безопасного рендеринга.
- Валидирует пути шаблонов для снижения риска traversal.
- Экранирует строковые входы перед рендерингом шаблона.

---

## 10) Архитектура UI-бэкенда (`ui/backend`)

### `app.py`

- Фабрика Flask-приложения (`create_app`)
- Раздаёт статические ассеты фронтенда
- Экспонирует эндпоинты чата/pipeline/KB/auth
- Читает опциональное переопределение фронтенда через `ULTRARAG_FRONTEND_DIR`

### `pipeline_manager.py`

Большой и центральный модуль для поведения UI.

Основные обязанности:

- Жизненный цикл сессий и управление потоковым чатом
- Управление фоновыми задачами чата
- CRUD pipeline (list/load/save/rename/delete)
- Обёртки загрузки/сохранения/сборки параметров
- Загрузка файлов базы знаний и запуск pipeline
- Синхронизация памяти в коллекции KB пользователя
- Опциональная интроспекция сервера через AST-stub генерацию, если `server.yaml` отсутствует

Заметное поведение:

- Применяет защитные патчи для подавления шумных логов teardown закрытых event-loop.
- Использует queue-bridge для async→sync SSE-event streaming.
- Поддерживает автосинхронизацию memory→KB для pipeline'ов, содержащих компоненты памяти.

---

## 11) Модель хранения и пути

Корень хранилища UI по умолчанию:

- `ui/storage`

Можно переопределить через:

- `ULTRARAG_UI_STORAGE_ROOT`

Ключевые подпути:

- `db/users.sqlite3`
- `chat_sessions/`
- `knowledge_base/raw|corpus|chunks|index`
- `memory/`
- `knowledge_base/_memory_sync`

Выходы времени выполнения:

- `output/memory_*.json`
- `logs/*.log`

---

## 12) Переменные окружения, которые нужно знать

- `ULTRARAG_UI_STORAGE_ROOT`: переопределение корня хранилища UI
- `ULTRARAG_FRONTEND_DIR`: переопределение статической директории фронтенда
- `ULTRARAG_SESSION_TIMEOUT`: таймаут сессии foreground-чата
- `ULTRARAG_BG_SESSION_TIMEOUT`: таймаут фоновой сессии
- `ULTRARAG_LOG_TS`: кастомная временная метка для именования лог-файлов
- `log_level`: потребляется инициализацией корневого логгера

---

## 13) Модель зависимостей

Тир-ы установки из `pyproject.toml`:

- Core install: без extras
- `retriever` extra
- `generation` extra
- `evaluation` extra
- `corpus` extra
- `all` extra (объединение)

Типичные команды:

```bash
uv sync
uv sync --extra retriever
uv sync --extra generation
uv sync --all-extras
```

Зависимости разработки:

- `ruff`
- `ipython`
- `jupyter`
- `pytest`

---

## 14) CLI-команды (канонические)

```bash
ultrarag build <pipeline.yaml>
ultrarag run <pipeline.yaml> [--param <parameter.yaml>] [--log_level info|debug|warn|error] [--is_demo]
ultrarag show ui [--host 127.0.0.1] [--port 5050]
ultrarag show case [--config_path <memory.json>] [--host 127.0.0.1] [--port 8080]
```

Минимальный smoke-чек:

```bash
ultrarag run examples/experiments/sayhello.yaml
```

---

## 15) Варианты Docker

- `Dockerfile`: полный образ (собирает фронтенд, ставит все extras)
- `Dockerfile.base-cpu`: базовый CPU-образ
- `Dockerfile.base-gpu`: базовый GPU-образ

Все варианты запускают UI командой:

```bash
ultrarag show ui --port 5050 --host 0.0.0.0
```

---

## 16) Плейбуки разработки

### 16.1 Добавить новый MCP-сервер

1. Создайте `servers/<name>/parameter.yaml`
2. Реализуйте `servers/<name>/src/<name>.py`
3. Зарегистрируйте tools/prompts через `app.tool` / `app.prompt` (или class-bound регистрацию)
4. Убедитесь, что присутствует `app.run(transport="stdio")`
5. Добавьте сервер в `servers:` в YAML-pipeline
6. Запустите `ultrarag build <pipeline.yaml>`

### 16.2 Добавить новый tool в существующий сервер

1. Реализуйте функцию/метод
2. Зарегистрируйте с явным контрактом `output=...`
3. Убедитесь, что ключи возвращаемого payload совпадают с выходами
4. Обновите соответствующие ключи параметров в `parameter.yaml`, если используется `$...`
5. Добавьте шаг в YAML-pipeline и пересоберите

### 16.3 Добавить retriever index-backend

1. Реализуйте бэкенд в `servers/retriever/src/index_backends/`
2. Следуйте контракту `BaseIndexBackend`
3. Зарегистрируйте в карте `_INDEX_BACKENDS` в `index_backends/__init__.py`

### 16.4 Добавить web-search backend

1. Реализуйте бэкенд в `servers/retriever/src/websearch_backends/`
2. Следуйте контракту `BaseWebSearchBackend`
3. Зарегистрируйте в карте `_WEBSEARCH_BACKENDS`

### 16.5 Изменить поведение UI-pipeline

Основные файлы:

- `ui/backend/app.py`
- `ui/backend/pipeline_manager.py`

При затрагивании семантики build/runtime перекрёстно сверяйтесь с:

- `src/ultrarag/client.py`

---

## 17) Стандарты кодинга (соответствуют репозиторию)

- Используйте type-hint'ы в сигнатурах функций.
- Предпочитайте `pathlib.Path` для путей в файловой системе.
- Используйте `yaml.safe_load` / `yaml.safe_dump`.
- Используйте логгер проекта (`get_logger` или `app.logger`) вместо `print`.
- Сохраняйте выходы tool детерминированными и JSON-сериализуемыми.
- Группируйте импорты: stdlib -> сторонние -> локальные.
- Явно выдерживайте async-границы (`async`/`await`).

---

## 18) Что не редактировать вслепую

Относитесь к ним как к генерируемым/артефактам времени выполнения, если не идёт намеренная регенерация:

- `servers/*/server.yaml`
- `examples/**/parameter/*_parameter.yaml`
- `examples/**/server/*_server.yaml`
- `output/*`
- `logs/*`
- runtime-данные `ui/storage/*`

Также избегайте коммитить секреты:

- `.env`
- любые локальные конфиги с учётными данными

---

## 19) Частые ошибки и исправления

### Ошибка: файл сервера не найден

- Проверьте путь `servers.<name>` в YAML-pipeline.
- Убедитесь, что entry-скрипт существует в `servers/<name>/src/<name>.py` (или обновите путь в конфиге).

### Ошибка: отсутствует переменная в выполнении pipeline

- Проверьте, что имена выходных ключей upstream-tool'а совпадают с именами входов downstream.
- Проверьте корректность переназначения на уровне шага `output:`.
- Проверьте, что ключи `$param` существуют в parameter-конфиге этого сервера.

### Удалённый MCP-сервер не запускается

- Убедитесь, что Node.js >= 20.
- Подтвердите, что `npx` доступен.
- Подтвердите, что удалённый URL в server-path достижим.

### Build успешен, но UI не может перечислить tools

- Убедитесь, что `server.yaml` существует или может быть выведен через AST-парсинг.
- Проверьте нестандартные паттерны динамической регистрации, которые статический анализ не может вывести.

### Нет финального ответа в чате

- Проверьте `output/memory_*.json`.
- Проверьте, отработал ли шаг генерации и произвёл ли `ans_ls`.
- Проверьте stream-события в UI-пути (`step_start`, `step_end`, `sources`, `token`, `final`).

---

## 20) Чек-лист валидации для агентов

Перед финализацией любого нетривиального изменения:

1. Соберите затронутый pipeline:
   - `ultrarag build <pipeline.yaml>`
2. Запустите релевантный smoke-кейс:
   - `ultrarag run <pipeline.yaml>`
3. Если изменено поведение UI:
   - запустите `ultrarag show ui` и проверьте поведение роутов
4. Если изменены бэкенды retriever/generation:
   - валидируйте ключи схемы параметров и имена выходов
5. Сохраняйте сгенерированные артефакты осознанно:
   - случайно не коммитьте транзитные runtime-выходы

---

## 21) Минимальный быстрый старт для новых агентов

```bash
# 1) Установить зависимости
uv sync --all-extras

# 2) Smoke-тест
ultrarag run examples/experiments/sayhello.yaml

# 3) Собрать и запустить демо-pipeline
ultrarag build examples/demos/LLM.yaml
ultrarag run examples/demos/LLM.yaml

# 4) Запустить UI
ultrarag show ui --host 127.0.0.1 --port 5050
```

---

## 22) Финальные замечания

- Репозиторий — orchestration-first: корректность сильно зависит от согласованности имён I/O между tool'ами и шагами pipeline.
- Большинство регрессий происходит из-за несовпадения имён переменных, устаревших сгенерированных конфигов или неполных обновлений параметров.
- В случае сомнений сначала проверяйте `src/ultrarag/client.py`: это истина исполнения.