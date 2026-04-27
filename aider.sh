#!/bin/bash
set -a
[ -f .env ] && source .env
set +a

# Validar que la API KEY exista (opcional pero recomendado)
if [ -z "$DEEPSEEK_API_KEY" ]; then
    echo "Error: DEEPSEEK_API_KEY no está definida en el entorno o en el archivo .env"
    exit 1
fi

# Configuración pura para DeepSeek
# Se utiliza el modelo chat para arquitectura/edición y el flag de caché para optimizar costos
aider --model deepseek/deepseek-v4-pro \
      --api-key deepseek=$DEEPSEEK_API_KEY \
      --no-show-model-warnings \
      --cache-prompts