# Define a base image com Python 3.12.3 slim
FROM python:3.12.3-slim as python-base

# Configurações de ambiente
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_VERSION=1.8.3 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv" \
    PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# Instala dependências do sistema
RUN apt-get update && apt-get install --no-install-recommends -y \
    curl build-essential libpq-dev gcc \
    && rm -rf /var/lib/apt/lists/*

# Instala o Poetry
RUN pip install poetry

# Define o diretório de trabalho para instalação das dependências Python
WORKDIR $PYSETUP_PATH

# Copia os arquivos de configuração do Poetry
COPY poetry.lock pyproject.toml ./

# Instala as dependências Python
RUN poetry install --no-dev

# Define o diretório de trabalho para a aplicação
WORKDIR /app

# Copia o código da aplicação para o contêiner
COPY . .

# Exponha a porta 8000
EXPOSE 8000

# Comando para iniciar o servidor Gunicorn
CMD ["gunicorn", "BookStore.wsgi:application", "--bind", "0.0.0.0:$PORT"]
