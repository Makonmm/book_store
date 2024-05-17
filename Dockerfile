# Define a base image com Python 3.12.3 slim
FROM python:3.12.3-slim as python-base

# Configurações de ambiente
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    VENV_PATH="/opt/venv" \
    PATH="$VENV_PATH/bin:$PATH"

# Instala dependências do sistema, incluindo git
RUN apt-get update && apt-get install --no-install-recommends -y \
    curl build-essential libpq-dev gcc git \
    && rm -rf /var/lib/apt/lists/*

# Verifica a instalação do Git
RUN git --version

# Cria e ativa um ambiente virtual
RUN python -m venv $VENV_PATH

# Atualiza o pip e instala dependências
RUN pip install --upgrade pip

# Define o diretório de trabalho para instalação das dependências Python
WORKDIR /app

# Copia os arquivos de requisitos e setup.py
COPY setup.py .

# Instala as dependências do Python
RUN pip install .

# Copia o restante do código da aplicação
COPY . /app/

EXPOSE 8000

# Comando para iniciar o servidor Gunicorn
CMD ["gunicorn", "bookstore.wsgi:application", "--bind", "0.0.0.0:$PORT"]
