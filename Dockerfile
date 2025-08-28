# Dockerfile
# Use a imagem oficial do Node.js como base.
FROM node:18-alpine

WORKDIR /app

# Copia os arquivos de definição do projeto e instala as dependências.
# Usa o cache do Docker para agilizar builds futuros.
COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["node", "index.js"]
