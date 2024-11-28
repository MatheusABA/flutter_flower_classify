# Usar uma imagem base leve do Ubuntu
FROM ubuntu:20.04

# Instalar dependências necessárias
RUN apt-get update && apt-get install -y \
    git wget unzip curl xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev && \
    apt-get clean

# Baixar e configurar o Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter && \
    export PATH="$PATH:/usr/local/flutter/bin" && \
    /usr/local/flutter/bin/flutter channel stable && \
    /usr/local/flutter/bin/flutter upgrade && \
    /usr/local/flutter/bin/flutter doctor

# Definir o diretório de trabalho
WORKDIR /app

# Copiar os arquivos do projeto para o contêiner
COPY . .

# Instalar dependências do Flutter e compilar para a web
RUN /usr/local/flutter/bin/flutter pub get && \
    /usr/local/flutter/bin/flutter build web

# Usar Nginx para servir os arquivos compilados
FROM nginx:alpine
COPY --from=0 /app/build/web /usr/share/nginx/html

# Expor a porta do frontend
EXPOSE 80

# Comando para iniciar o servidor Nginx
CMD ["nginx", "-g", "daemon off;"]