<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="./docs/ultrarag_dark.svg">
    <source media="(prefers-color-scheme: light)" srcset="./docs/ultrarag.svg">
    <img alt="UltraRAG" src="./docs/ultrarag.svg" width="55%">
  </picture>
</p>

<h3 align="center">
Меньше кода, ниже порог входа, быстрее развёртывание
</h3>

<p align="center">
<a href="https://trendshift.io/repositories/18747" target="_blank"><img src="https://trendshift.io/api/badge/repositories/18747" alt="OpenBMB%2FUltraRAG | Trendshift" style="width: 250px; height: 55px;" width="250" height="55"/></a>
</p>

<p align="center">
  <a href="https://ultrarag.github.io/"><img src="https://img.shields.io/badge/Homepage-6ABED8?style=for-the-badge&logoColor=white" alt="Главная"/></a>&nbsp;
  <a href="https://ultrarag.openbmb.cn/pages/en/getting_started/introduction"><img src="https://img.shields.io/badge/Documentation-66B89E?style=for-the-badge&logo=bookstack&logoColor=white" alt="Документация"/></a>&nbsp;
  <a href="https://modelscope.cn/datasets/UltraRAG/UltraRAG_Benchmark"><img src="https://img.shields.io/badge/Dataset-DE8EA6?style=for-the-badge&logo=databricks&logoColor=white" alt="Набор данных"/></a>&nbsp;
  <a href="https://github.com/OpenBMB/UltraRAG/tree/rag-paper-daily/rag-paper-daily"><img src="https://img.shields.io/badge/Paper_Daily-A48BC8?style=for-the-badge&logo=arxiv&logoColor=white" alt="Дайджест статей"/></a>
</p>

---

**Последние новости** 🔥

- **[2026.01.23]** 🎉 Релиз UltraRAG 3.0: скажите «нет» чёрному ящику в разработке — сделайте видимой каждую строку логики рассуждений 👉 [📖 Блог](https://github.com/OpenBMB/UltraRAG/blob/page/project/blog/en/ultrarag3_0.md)
- **[2026.01.20]** 🎉 Релиз модели AgentCPM-Report! DeepResearch наконец-то локализован: 8B on-device агент для написания отчётов AgentCPM-Report с открытым исходным кодом 👉 [🤗 Модель](https://huggingface.co/openbmb/AgentCPM-Report)

<details>
<summary><b>Предыдущие новости</b></summary>
<br>

- **[2025.11.11]** 🎉 Релиз UltraRAG 2.1: улучшенный приём знаний и мультимодальная поддержка, более полная унифицированная система оценки!
- **[2025.09.23]** Новый ежедневный дайджест RAG-статей, обновляется каждый день 👉 [📖 Статьи](https://github.com/OpenBMB/UltraRAG/tree/rag-paper-daily/rag-paper-daily)
- **[2025.09.09]** Выпущено руководство по локальной настройке Lightweight DeepResearch Pipeline 👉 [📺 bilibili](https://www.bilibili.com/video/BV1p8JfziEwM) · [📖 Блог](https://github.com/OpenBMB/UltraRAG/blob/page/project/blog/en/01_build_light_deepresearch.md)
- **[2025.09.01]** Выпущено пошаговое видео по установке UltraRAG и полному RAG-туру 👉 [📺 bilibili](https://www.bilibili.com/video/BV1B9apz4E7K/?share_source=copy_web&vd_source=7035ae721e76c8149fb74ea7a2432710) · [📖 Блог](https://github.com/OpenBMB/UltraRAG/blob/page/project/blog/en/00_Installing_and_Running_RAG.md)
- **[2025.08.28]** 🎉 Релиз UltraRAG 2.0! UltraRAG 2.0 полностью обновлён: создайте высокопроизводительный RAG всего парой десятков строк кода, предоставьте исследователям возможность сосредоточиться на идеях и инновациях! Код UltraRAG v2 сохранён и доступен в [v2](https://github.com/OpenBMB/UltraRAG/tree/v2).
- **[2025.01.23]** Релиз UltraRAG! Позволяет большим моделям лучше понимать и использовать базы знаний. Код UltraRAG 1.0 всё ещё доступен в [v1](https://github.com/OpenBMB/UltraRAG/tree/v1).

</details>

---

## 💡 О UltraRAG

UltraRAG — это первый лёгкий фреймворк для разработки RAG на основе архитектуры [Model Context Protocol (MCP)](https://modelcontextprotocol.io/docs/getting-started/intro), совместно запущенный [THUNLP](https://nlp.csai.tsinghua.edu.cn/) Университета Цинхуа, [NEUIR](https://neuir.github.io) Северо-Восточного университета, [OpenBMB](https://www.openbmb.cn/home) и [AI9stars](https://github.com/AI9Stars).

Разработанный для исследовательских экспериментов и промышленного прототипирования, UltraRAG стандартизирует основные компоненты RAG (Retriever, Generation и т.д.) как независимые **MCP-серверы**, объединённые с мощными возможностями оркестрации рабочих процессов **MCP Client**. Разработчики могут достичь точной оркестрации сложных управляющих структур, таких как условные ветвления и циклы, просто через конфигурацию YAML.

<p align="center">
  <picture>
    <img alt="Архитектура UltraRAG" src="./docs/architecture.png" width=90%>
  </picture>
</p>

### 🖥️ UltraRAG UI

UltraRAG UI выходит за рамки традиционных интерфейсов чата, превращаясь в визуальную интегрированную среду разработки RAG (IDE), объединяющую оркестрацию, отладку и демонстрацию.

Система включает мощный встроенный конструктор Pipeline с поддержкой двунаправленной синхронизации в реальном времени между «конструированием на холсте» и «редактированием кода», позволяющий детально настраивать параметры pipeline и промпты онлайн. Кроме того, она представляет интеллектуального AI-ассистента для поддержки всего жизненного цикла разработки — от проектирования структуры pipeline до настройки параметров и генерации промптов. Готовые логические потоки можно одним кликом преобразовать в интерактивные диалоговые системы. Система легко интегрирует компоненты управления базой знаний, позволяя пользователям создавать собственные базы знаний для вопросно-ответной системы по документам. Это по-настоящему реализует замкнутый цикл — от построения базовой логики и управления данными до финального развёртывания приложения.

<!-- <p align="center">
  <picture>
    <img alt="UltraRAG_UI" src="./docs/chat_menu.png" width=80%>
  </picture>
</p> -->


https://github.com/user-attachments/assets/fcf437b7-8b79-42f2-bf4e-e3b7c2a896b9


### ✨ Ключевые особенности

<table>
<tr>
<td width="50%" valign="top">

**🚀 Low-Code оркестрация сложных рабочих процессов**

**Оркестрация вывода**: нативная поддержка управляющих структур, таких как последовательное выполнение, циклы и условные ветвления. Разработчикам нужно только написать YAML-конфигурацию для реализации сложной итеративной RAG-логики десятками строк кода.

</td>
<td width="50%" valign="top">

**⚡ Модульное расширение и воспроизводимость**

**Атомарные серверы**: на основе архитектуры MCP функции декомпозированы в независимые серверы. Новые функции достаточно зарегистрировать как Tools уровня функций для бесшовной интеграции в рабочие процессы, обеспечивая чрезвычайно высокую переиспользуемость.

</td>
</tr>
<tr>
<td width="50%" valign="top">

**📊 Унифицированная оценка и сравнение бенчмарков**

**Эффективность исследований**: встроенные стандартизированные рабочие процессы оценки, готовые к использованию основные исследовательские бенчмарки. Через унифицированное управление метриками и интеграцию базовых показателей значительно повышается воспроизводимость экспериментов и эффективность сравнения.

</td>
<td width="50%" valign="top">

**🎯 Быстрая генерация интерактивных прототипов**

**Один клик для развёртывания**: прощайте утомительную разработку UI. Одной командой логика Pipeline мгновенно преобразуется в интерактивный веб-интерфейс чата, сокращая путь от алгоритма до демонстрации.

</td>
</tr>
</table>

## 📦 Установка

Мы предоставляем два способа установки: установка из исходного кода (рекомендуется использовать `uv` для управления пакетами) и развёртывание в Docker-контейнере.

### Способ 1: Установка из исходного кода

Мы настоятельно рекомендуем использовать [uv](https://github.com/astral-sh/uv) для управления Python-средой и зависимостями, так как это значительно ускоряет установку.

**Подготовка окружения**

Если uv ещё не установлен, выполните:

```shell
## Прямая установка
pip install uv==0.12.0
## Скачивание
curl -LsSf https://astral.sh/uv/0.12.0/install.sh | sh
```

**Скачивание исходного кода**

```shell
git clone https://github.com/OpenBMB/UltraRAG.git --depth 1
cd UltraRAG
```

**Установка зависимостей**

Выберите один из режимов установки зависимостей в соответствии с вашим случаем использования:

**A: Создать новое окружение** Используйте `uv sync` для автоматического создания виртуального окружения и синхронизации зависимостей:

- Основные зависимости: если вам нужно только запустить базовые функции, например, только UltraRAG UI:
  ```shell
  uv sync
  ```

- Полная установка: если вы хотите полностью использовать функции извлечения, генерации, обработки корпуса и оценки UltraRAG:
  ```shell
  uv sync --all-extras
  ```
  Это рекомендуемая командная настройка: каждый MCP-сервер использует одно общее `.venv` и `uv.lock`. Зависимости GPU для Linux привязаны к CUDA 12.9, включая официальное vLLM cu129 колесо.

- Установка по требованию: если вам нужно запускать только определённые модули, добавьте соответствующий `--extra` по необходимости, например:

  ```shell
  uv sync --extra retriever   # Только модуль извлечения
  uv sync --extra generation  # Только модуль генерации
  ```

После установки активируйте виртуальное окружение:

```shell
# Windows CMD
.venv\Scripts\activate.bat

# Windows Powershell
.venv\Scripts\Activate.ps1

# macOS / Linux
source .venv/bin/activate
```

**B: Установить в существующее окружение** Для установки UltraRAG в текущее активное Python-окружение используйте `uv pip`:

```shell
# Основные зависимости
uv pip install -e .

# Полная установка
uv pip install -e ".[all]"

# Установка по требованию
uv pip install -e ".[retriever]"
```

### Способ 2: Развёртывание в Docker-контейнере

Если вы предпочитаете не настраивать локальное Python-окружение, можете развернуть с помощью Docker.

**Получение кода и образов**

```shell
# 1. Клонирование репозитория
git clone https://github.com/OpenBMB/UltraRAG.git --depth 1
cd UltraRAG

# 2. Подготовка образа (выберите один)
# Вариант A: Загрузить с Docker Hub
docker pull hdxin2002/ultrarag:v0.3.0-base-cpu # Базовая версия (CPU)
docker pull hdxin2002/ultrarag:v0.3.0-base-gpu # Базовая версия (GPU)
docker pull hdxin2002/ultrarag:v0.3.0          # Полная версия (GPU)

# Вариант B: Собрать локально
docker build -t ultrarag:v0.3.0 .
```

**Запуск контейнера**

```shell
# Запуск контейнера (порт 5050 маппится по умолчанию)
docker run -it --gpus all -p 5050:5050 <docker_image_name>
```

Примечание: после запуска контейнера UltraRAG UI запустится автоматически. Вы можете напрямую открыть в браузере `http://localhost:5050`.

### Проверка установки

После установки выполните следующую команду для проверки корректности окружения:

```shell
ultrarag run examples/experiments/sayhello.yaml
```

Если вы увидите следующий вывод, установка прошла успешно:

```
Hello, UltraRAG v3!
```


## 🚀 Быстрый старт

Мы предоставляем полные примеры учебных руководств от начинающего до продвинутого уровня. Независимо от того, проводите ли вы академические исследования или создаёте промышленные приложения, здесь вы найдёте руководство. Добро пожаловать в [Документацию](https://ultrarag.openbmb.cn/pages/en/getting_started/introduction) для получения более подробной информации.

### 🔬 Исследовательские эксперименты
Разработано для исследователей, предоставляет данные, экспериментальные рабочие процессы и инструменты визуального анализа.
- [Быстрый старт](https://ultrarag.openbmb.cn/pages/en/getting_started/quick_start): узнайте, как быстро запустить стандартные RAG-экспериментальные рабочие процессы на основе UltraRAG.
- [Данные для оценки](https://ultrarag.openbmb.cn/pages/en/develop_guide/dataset): скачайте наиболее часто используемые публичные наборы данных для оценки в области RAG и крупномасштабные корпуса для извлечения, непосредственно для тестирования исследовательских бенчмарков.
- [Анализ кейсов](https://ultrarag.openbmb.cn/pages/en/develop_guide/case_study): предоставляет визуальный интерфейс Case Study для глубокого отслеживания каждого промежуточного вывода рабочего процесса, помогая в анализе и атрибуции ошибок.
- [Структурированное руководство по отладке](./docs/debug_rag_workflows.md): когда ответы выглядят подозрительными, результаты извлечения нестабильны, цепочка рассуждений дрейфует, или поведение после развёртывания ненормальное, диагностируйте на четырёх уровнях — ввод и извлечение, рассуждение и планирование, состояние и контекст, развёртывание и выполнение.
- [Интеграция с кодом](https://ultrarag.openbmb.cn/pages/en/develop_guide/code_integration): узнайте, как напрямую вызывать компоненты UltraRAG в Python-коде для достижения более гибкой пользовательской разработки.

### 🛠️ Демо-системы
Разработано для разработчиков и конечных пользователей, предоставляет полный UI-интерфейс и сложные прикладные кейсы.
- [Быстрый старт](https://ultrarag.openbmb.cn/pages/en/ui/start): узнайте, как запустить UltraRAG UI и ознакомьтесь с различными расширенными конфигурациями в режиме администратора.
- [Руководство по развёртыванию](https://ultrarag.openbmb.cn/pages/en/ui/prepare): подробные руководства по развёртыванию в производственном окружении, охватывающие настройку Retriever, моделей генерации (LLM) и векторной базы данных Milvus.
- [Deep Research](https://ultrarag.openbmb.cn/pages/en/demo/deepresearch): флагманский кейс, развёртывание Deep Research Pipeline. В сочетании с моделью AgentCPM-Report может автоматически выполнять многоэтапное извлечение и интеграцию для генерации обзорных отчётов десятками тысяч слов.

## 🤝 Вклад

Благодарим следующих контрибьюторов за их коммиты и тестирование. Мы также приветствуем новых участников присоединиться к нам в коллективном построении комплексной RAG-экосистемы!

Вы можете внести вклад, следуя стандартному процессу: **Fork этого репозитория → Создайте Issues → Создайте Pull Requests (PRs)**.

<a href="https://github.com/OpenBMB/UltraRAG/contributors">
  <img src="https://contrib.rocks/image?repo=OpenBMB/UltraRAG&nocache=true" />
</a>

## ⭐ Поддержите нас

Если этот репозиторий полезен для ваших исследований, пожалуйста, поставьте нам ⭐, чтобы показать свою поддержку.

<a href="https://star-history.dera.page/#OpenBMB/UltraRAG&type=Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://star-history.dera.page/svg?repos=OpenBMB/UltraRAG&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://star-history.dera.page/svg?repos=OpenBMB/UltraRAG&type=Date" />
   <img alt="История звёзд" src="https://star-history.derea.page/svg?repos=OpenBMB/UltraRAG&type=Date" />
 </picture>
</a>

## 💬 Свяжитесь с нами

- По техническим вопросам и запросам функций, пожалуйста, используйте [GitHub Issues](https://github.com/OpenBMB/UltraRAG/issues).
- По вопросам использования, обратной связи или любых дискуссий, связанных с RAG-технологиями, вы можете присоединиться к нашим [WeChat группе](https://github.com/OpenBMB/UltraRAG/blob/main/docs/wechat_qr.png), [Feishu группе](https://github.com/OpenBMB/UltraRAG/blob/main/docs/feishu_qr.png) и [Discord](https://discord.gg/yRFFjjJnnS) для обмена идеями.
- Если у вас есть вопросы, отзывы или вы хотите связаться с нами, пожалуйста, напишите нам на yanyk.thu@gmail.com

<table>
  <tr>
    <td align="center">
      <img src="./docs/wechat_qr.png" alt="QR-код WeChat группы" width="220"/><br/>
      <b>WeChat группа</b>
    </td>
    <td align="center">
      <img src="./docs/feishu_qr.png" alt="QR-код Feishu группы" width="220"/><br/>
      <b>Feishu группа</b>
    </td>
    <td align="center">
      <a href="https://discord.gg/yRFFjjJnnS">
        <img src="https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="Присоединиться к Discord"/>
      </a><br/>
      <b>Discord</b>
  </td>
  </tr>
</table>

## 📖 Публикации

### Статьи

1. Shi Yu, Chaoyue Tang, Bokai Xu, Junbo Cui, Junhao Ran, Yukun Yan, Zhenghao Liu, Shuo Wang, Xu Han, Zhiyuan Liu, Maosong Sun. (2025) VisRAG: Vision-based Retrieval-augmented Generation on Multi-modality Documents. [arXiv:2410.10594](https://arxiv.org/abs/2410.10594) и [In Proceedings of the Thirteenth International Conference on Learning Representations (ICLR 2025)](https://openreview.net/forum?id=zG459X3Xge).

2. Xinze Li, Sen Mei, Zhenghao Liu, Yukun Yan, Shuo Wang, Shi Yu, Zheni Zeng, Hao Chen, Ge Yu, Zhiyuan Liu, Maosong Sun, Chenyan Xiong. (2025) RAG-DDR: Optimizing Retrieval-Augmented Generation Using Differentiable Data Rewards. [arXiv:2410.13509](https://arxiv.org/abs/2410.13509) и [In Proceedings of the Thirteenth International Conference on Learning Representations (ICLR 2025)](https://openreview.net/forum?id=Pnktu2PBXD).

3. Kunlun Zhu, Yifan Luo, Dingling Xu, Yukun Yan, Zhenghao Liu, Shi Yu, Ruobing Wang, Shuo Wang, Yishan Li, Nan Zhang, Xu Han, Zhiyuan Liu, Maosong Sun. (2025) RAGEval: Scenario Specific RAG Evaluation Dataset Generation Framework. [arXiv:2408.01262](https://arxiv.org/abs/2408.01262) и [In Proceedings of the 63rd Annual Meeting of the Association for Computational Linguistics (ACL 2025)](https://aclanthology.org/2025.acl-long.418/).

4. Ruobing Wang, Qingfei Zhao, Yukun Yan, Daren Zha, Yuxuan Chen, Shi Yu, Zhenghao Liu, Yixuan Wang, Shuo Wang, Xu Han, Zhiyuan Liu, Maosong Sun. (2025) DeepNote: Note-Centric Deep Retrieval-Augmented Generation. [arXiv:2410.08821](https://arxiv.org/abs/2410.08821) и [In Findings of the Association for Computational Linguistics: EMNLP 2025](https://aclanthology.org/2025.findings-emnlp.1073/).

### Модели

1. Yishan Li, Wentong Chen, Yukun Yan, Mingwei Li, Sen Mei, Xiaorong Wang, Kunpeng Liu, Xin Cong, Shuo Wang, Zhong Zhang, Yaxi Lu, Zhenghao Liu, Yankai Lin, Zhiyuan Liu, Maosong Sun. (2026) AgentCPM-Report: Interleaving Drafting and Deepening for Open-Ended Deep Research. [arXiv:2602.06540](https://arxiv.org/abs/2602.06540).

2. OpenBMB. MiniCPM-Embedding-Light. [Hugging Face Model Card](https://huggingface.co/openbmb/MiniCPM-Embedding-Light).