# Base para instalação do Flutter
FROM ubuntu:20.04-slim AS builder

# Configurar o ambiente
ENV DEBIAN_FRONTEND=noninteractive \
    PUB_HOSTED_URL=https://pub.flutter-io.cn \
    FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# Instalar dependências e ferramentas necessárias
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    libgconf-2-4 \
    gdb \
    libstdc++6 \
    libglu1-mesa \
    fonts-droid-fallback \
    python3 \
    && apt-get clean

# Clonar o repositório do Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Adicionar o Flutter ao PATH
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Executar o Flutter Doctor para inicializar o cache
RUN flutter doctor

# Usar o canal stable e habilitar suporte para web
RUN flutter channel stable && flutter upgrade && flutter config --enable-web

# Copiar os arquivos do projeto e compilar para web
WORKDIR /app

COPY pubspec.* ./

RUN flutter pub get

COPY . .

RUN flutter build web

# Fase final: Servir os arquivos compilados com Nginx
FROM nginx:alpine

# Copiar os arquivos compilados para o diretório de conteúdo do Nginx
COPY --from=builder /app/build/web /usr/share/nginx/html

# Expor a porta onde o Nginx servirá os arquivos
EXPOSE 80

# Iniciar o Nginx
CMD ["nginx", "-g", "daemon off;"]
