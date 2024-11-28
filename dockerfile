# Usar a imagem com Flutter e Dart atualizados
FROM dart:stable

# Instalar o Flutter manualmente
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    && curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.10.1-stable.tar.xz \
    && tar -xvJf flutter_linux_3.10.1-stable.tar.xz \
    && mv flutter /opt/flutter \
    && ln -s /opt/flutter/bin/flutter /usr/local/bin/flutter

# Configurar o diretório de trabalho
WORKDIR /app

# Copiar os arquivos do projeto para o contêiner
COPY . .

# Instalar dependências do Flutter e compilar para web
RUN flutter pub get && flutter build web

# Usar uma imagem leve para servir os arquivos estáticos
FROM nginx:alpine
COPY --from=0 /app/build/web /usr/share/nginx/html

# Expor a porta para o frontend
EXPOSE 80

# Iniciar o Nginx para servir o frontend
CMD ["nginx", "-g", "daemon off;"]