# --- Etapa 1: Build da aplicação ---
# Use uma imagem do Node.js com ferramentas de build.
FROM node:18-alpine AS build

WORKDIR /app

# Copia os arquivos de definição do projeto.
COPY package*.json ./

# Instala todas as dependências da aplicação.
RUN npm install

# Copia o restante do código da aplicação.
COPY . .


# --- Etapa 2: Imagem final de produção ---
# Use uma imagem do Node.js mais leve para produção.
FROM node:18-alpine

WORKDIR /app

# Copia apenas o que é necessário da etapa de build.
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package*.json ./
COPY --from=build /app/index.js .

EXPOSE 3000

CMD ["node", "index.js"]