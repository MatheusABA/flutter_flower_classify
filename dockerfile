# Usar a imagem com Flutter e Dart atualizados
FROM dart:stable


# Configurar o diretório de trabalho
WORKDIR /app

# Copiar os arquivos do projeto para o contêiner
COPY . .

# Instalar dependências do Flutter e compilar para web
RUN flutter pub get && \
    flutter build web

# Usar uma imagem leve para servir os arquivos estáticos
FROM nginx:alpine
COPY --from=0 /app/build/web /usr/share/nginx/html

# Expor a porta para o frontend
EXPOSE 80

# Iniciar o Nginx para servir o frontend
CMD ["nginx", "-g", "daemon off;"]