# Usar a imagem base Flutter
FROM cirrusci/flutter:stable

# Definir o canal do Flutter como "stable" e realizar o upgrade
RUN flutter channel stable && \
    flutter upgrade && \
    flutter doctor

# Definir o diretório de trabalho
WORKDIR /app

# Copiar os arquivos do projeto para o contêiner
COPY . .

# Instalar as dependências do Flutter e construir para web
RUN flutter pub get && \
    flutter build web

# Usar Nginx para servir os arquivos compilados
FROM nginx:alpine
COPY --from=0 /app/build/web /usr/share/nginx/html

# Expor a porta do frontend
EXPOSE 80

# Comando para iniciar o servidor Nginx
CMD ["nginx", "-g", "daemon off;"]