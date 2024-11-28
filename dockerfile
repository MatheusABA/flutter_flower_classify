# Usar a imagem base Flutter
FROM cirrusci/flutter:stable

# Sincronizar o repositório do Flutter e alternar para o canal 'stable'
RUN git remote set-url origin https://github.com/flutter/flutter.git && \
    git fetch origin stable && \
    git reset --hard origin/stable && \
    flutter channel stable && \
    flutter upgrade && \
    flutter doctor

# Definir o diretório de trabalho
WORKDIR /app

# Copiar os arquivos do projeto para o contêiner
COPY . .

# Instalar dependências do Flutter e compilar para a web
RUN flutter pub get && \
    flutter build web

# Usar Nginx para servir os arquivos compilados
FROM nginx:alpine
COPY --from=0 /app/build/web /usr/share/nginx/html

# Expor a porta do frontend
EXPOSE 80

# Comando para iniciar o servidor Nginx
CMD ["nginx", "-g", "daemon off;"]