# Usar a imagem oficial do Flutter
FROM cirrusci/flutter:stable

# Configurar o diretório de trabalho
WORKDIR /app

# Copiar os arquivos do frontend para o contêiner
COPY . .

# Compilar o frontend para a web
RUN flutter build web

# Usar uma imagem leve para servir os arquivos estáticos
FROM nginx:alpine
COPY --from=0 /app/build/web /usr/share/nginx/html

# Expor a porta para o frontend
EXPOSE 80

# Iniciar o Nginx para servir o frontend
CMD ["nginx", "-g", "daemon off;"]