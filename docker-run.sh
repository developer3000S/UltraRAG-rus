#!/usr/bin/env bash
# =============================================================================
# docker-run.sh — сборка и запуск UltraRAG в Docker
#
# Использование:
#   ./docker-run.sh [ОПЦИИ]
#
# Опции:
#   --gpu            Сборка и запуск с поддержкой GPU (nvidia/cuda base, --gpus all)
#   --cpu            Сборка и запуск только на CPU (ubuntu:24.04 base) [по умолчанию]
#   --full           Полная сборка (GPU full image: Dockerfile, включает все extras)
#   --no-cache       Пересборка без кэша (по умолчанию: с кэшем)
#   --port PORT      Порт на хосте (по умолчанию: 5050)
#   --name NAME      Имя контейнера (по умолчанию: ultrarag)
#   --keep-old       Не удалять старые образы перед сборкой
#   -h, --help       Показать эту справку
#
# Примеры:
#   ./docker-run.sh --cpu                  # CPU, сборка с кэшем
#   ./docker-run.sh --gpu                  # GPU base, сборка с кэшем
#   ./docker-run.sh --full                 # GPU full (все extras), сборка с кэшем
#   ./docker-run.sh --gpu --no-cache       # GPU base, полная пересборка
#   ./docker-run.sh --cpu --port 8080      # CPU на порту 8080
# =============================================================================

set -euo pipefail

# ─── Цвета ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()     { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()   { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()  { echo -e "${RED}[ERROR]${NC} $*" >&2; }
header() {
    echo -e "\n${BOLD}${CYAN}══════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}  $*${NC}"
    echo -e "${BOLD}${CYAN}══════════════════════════════════════════${NC}"
}

# ─── Значения по умолчанию ───────────────────────────────────────────────────
MODE="cpu"
NO_CACHE=false
PORT=5050
CONTAINER_NAME="ultrarag"
KEEP_OLD=false

# ─── Разбор аргументов ───────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --gpu)       MODE="gpu";   shift ;;
        --cpu)       MODE="cpu";   shift ;;
        --full)      MODE="full";  shift ;;
        --no-cache)  NO_CACHE=true; shift ;;
        --port)      PORT="$2";    shift 2 ;;
        --name)      CONTAINER_NAME="$2"; shift 2 ;;
        --keep-old)  KEEP_OLD=true; shift ;;
        -h|--help)
            sed -n '2,25p' "$0" | sed 's/^# \?//'
            exit 0
            ;;
        *)
            error "Неизвестный аргумент: $1"
            echo "Запустите с -h для справки."
            exit 1
            ;;
    esac
done

# ─── Выбор Dockerfile и тега образа ─────────────────────────────────────────
case "$MODE" in
    cpu)
        DOCKERFILE="Dockerfile.base-cpu"
        IMAGE_TAG="ultrarag:cpu"
        GPU_FLAGS=""
        MODE_LABEL="CPU (ubuntu:24.04)"
        ;;
    gpu)
        DOCKERFILE="Dockerfile.base-gpu"
        IMAGE_TAG="ultrarag:gpu"
        GPU_FLAGS="--gpus all"
        MODE_LABEL="GPU base (nvidia/cuda:12.9.1)"
        ;;
    full)
        DOCKERFILE="Dockerfile"
        IMAGE_TAG="ultrarag:v0.3.0"
        GPU_FLAGS="--gpus all"
        MODE_LABEL="GPU full (все extras, nvidia/cuda:12.9.1)"
        ;;
esac

BUILD_CACHE_FLAG=""
if [[ "$NO_CACHE" == "true" ]]; then
    BUILD_CACHE_FLAG="--no-cache"
fi

# ─── Проверка рабочей директории ─────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [[ ! -f "$DOCKERFILE" ]]; then
    error "Файл $DOCKERFILE не найден в $(pwd)"
    exit 1
fi

header "UltraRAG Docker — режим: $MODE_LABEL"

# ─── Шаг 1: Удаление старых образов и контейнеров ───────────────────────────
if [[ "$KEEP_OLD" == "false" ]]; then
    log "Шаг 1: Очистка старых ресурсов Docker..."

    # Остановить и удалить существующий контейнер с таким именем
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        warn "Останавливаем контейнер '${CONTAINER_NAME}'..."
        docker stop "${CONTAINER_NAME}" 2>/dev/null || true
        docker rm   "${CONTAINER_NAME}" 2>/dev/null || true
        ok "Контейнер '${CONTAINER_NAME}' удалён."
    else
        log "Контейнер '${CONTAINER_NAME}' не найден — пропускаем."
    fi

    # Удалить старые образы с таким же тегом
    if docker image inspect "${IMAGE_TAG}" &>/dev/null; then
        warn "Удаляем старый образ '${IMAGE_TAG}'..."
        docker rmi --force "${IMAGE_TAG}" 2>/dev/null || true
        ok "Старый образ '${IMAGE_TAG}' удалён."
    else
        log "Образ '${IMAGE_TAG}' не найден — пропускаем."
    fi

    # Очистка dangling (висячих) образов
    DANGLING=$(docker images -f "dangling=true" -q)
    if [[ -n "$DANGLING" ]]; then
        warn "Удаляем висячие (dangling) образы..."
        # shellcheck disable=SC2086
        docker rmi $DANGLING 2>/dev/null || true
        ok "Висячие образы удалены."
    else
        log "Висячих образов не найдено."
    fi
else
    log "Шаг 1: Пропуск очистки (--keep-old)."
fi

# ─── Шаг 2: Сборка образа ────────────────────────────────────────────────────
header "Шаг 2: Сборка образа ${IMAGE_TAG}"

if [[ "$NO_CACHE" == "true" ]]; then
    warn "Режим: полная пересборка без кэша"
else
    log "Режим: сборка с использованием кэша"
fi

log "Dockerfile: ${DOCKERFILE}"
log "Тег образа: ${IMAGE_TAG}"

BUILD_START=$(date +%s)

# shellcheck disable=SC2086
docker build \
    $BUILD_CACHE_FLAG \
    -f "${DOCKERFILE}" \
    -t "${IMAGE_TAG}" \
    .

BUILD_END=$(date +%s)
BUILD_TIME=$(( BUILD_END - BUILD_START ))
ok "Образ '${IMAGE_TAG}' успешно собран за ${BUILD_TIME}с."

# ─── Шаг 3: Запуск контейнера ────────────────────────────────────────────────
header "Шаг 3: Запуск контейнера '${CONTAINER_NAME}'"

# Проверка доступности GPU если нужно
if [[ -n "$GPU_FLAGS" ]]; then
    if ! docker run --rm --gpus all nvidia/cuda:12.9.1-base-ubuntu24.04 nvidia-smi &>/dev/null; then
        warn "GPU недоступен или nvidia-docker не установлен!"
        warn "Запуск без поддержки GPU..."
        GPU_FLAGS=""
    else
        ok "GPU доступен."
    fi
fi

log "Порт:      ${PORT}:5050"
log "GPU флаги: ${GPU_FLAGS:-<нет>}"
log "Образ:     ${IMAGE_TAG}"
echo ""
log "После старта UI будет доступен по адресу: http://localhost:${PORT}"
echo ""

# shellcheck disable=SC2086
docker run -it \
    $GPU_FLAGS \
    --name "${CONTAINER_NAME}" \
    -p "${PORT}:5050" \
    "${IMAGE_TAG}"

ok "Контейнер завершил работу."
