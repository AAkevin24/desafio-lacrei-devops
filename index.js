// index.js
const express = require('express');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 3000;

// Configuração de CORS para este desafio.
// Em produção, você deve restringir as origens.
// Por exemplo: cors({ origin: 'https://seusite.com.br' })
app.use(cors());

// Rota de status da aplicação.
// Útil para health checks e para indicar que a aplicação está ativa.
app.get('/status', (req, res) => {
  res.status(200).json({ status: 'ok', message: 'API is running' });
});

// Outras rotas da aplicação fictícia iriam aqui.
// app.get('/', (req, res) => {
//   res.send('Welcome to the Lacrei Saúde API!');
// });

// Inicia o servidor.
app.listen(port, () => {
  console.log(`Lacrei API listening on port ${port}`);
});
