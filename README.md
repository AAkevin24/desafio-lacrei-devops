Desafio DevOps - Lacrei Saúde
Este documento detalha a implementação de um pipeline de CI/CD seguro, escalável e eficiente, conforme os requisitos do desafio da Lacrei Saúde. Ele descreve a arquitetura, o fluxo de trabalho, a abordagem de segurança e a observabilidade, além de fornecer a documentação para cada etapa.

✅ 1. Setup de Ambientes
Utilizado a AWS para hospedar a aplicação, com os seguintes serviços:

Amazon Elastic Container Registry (ECR): Repositório privado para armazenar as imagens Docker.

Amazon Elastic Container Service (ECS) com AWS Fargate: Plataforma de orquestração de containers sem servidor. O Fargate foi escolhido por sua simplicidade de gerenciamento e escalabilidade, eliminando a necessidade de gerenciar instâncias EC2.

Amazon Application Load Balancer (ALB): Distribui o tráfego da web e gerencia o encerramento do TLS/SSL para garantir a comunicação via HTTPS.

Amazon CloudWatch: Para coletar logs, métricas e monitoramento.

Configurado dois ambientes separados, staging e production, cada um com seu próprio cluster ECS, serviço e repositório de imagem ECR.

✅ 2. Deploy da Aplicação Fictícia
A aplicação é uma API Node.js simples com uma única rota, /status, que retorna uma resposta JSON para indicar que está ativa.

Aplicação: index.js

Containerização: Dockerfile

A aplicação foi containerizada com o Dockerfile para garantir um ambiente de execução consistente e portátil.

✅ 3. Pipeline CI/CD Completo (GitHub Actions)
O pipeline de CI/CD é gerenciado pelo GitHub Actions e é acionado por pushes nas branches main e staging.

Descrição do Fluxo:

Acionamento: O workflow é iniciado em cada push para a branch main.

Build: A imagem Docker é construída usando o Dockerfile da aplicação.

Testes: Um teste de sanidade básico é realizado. O container é executado localmente e a rota /status é acessada para garantir que a API está respondendo corretamente.

Push para ECR: Após os testes, a imagem é taggeada com o git_sha e a branch_name e, em seguida, enviada para o repositório ECR apropriado (staging ou production).

Deploy para Staging: A task definition do ECS é atualizada para usar a nova imagem. O serviço ECS é então atualizado, e o Fargate inicia um novo container com a nova imagem.

Deploy para Produção: O deploy para produção é um passo separado que requer aprovação manual via o ambiente de proteção do GitHub. Isso garante que o código tenha sido totalmente testado no ambiente de staging antes de ir para produção.

✅ 4. Segurança como Pilar
Utilizado o OpenID Connect (OIDC) para que o GitHub Actions assuma uma role de IAM temporária, eliminando a necessidade de credenciais de longo prazo.

HTTPS/TLS: O Application Load Balancer na AWS é configurado para gerenciar certificados SSL (via AWS Certificate Manager - ACM), garantindo que todo o tráfego externo para a aplicação seja criptografado com HTTPS.

CORS: O CORS (Cross-Origin Resource Sharing) é configurado na própria aplicação Node.js para permitir apenas requisições de domínios específicos, prevenindo ataques XSS e garantindo o acesso apenas de origens autorizadas.

Políticas de Acesso (Princípio do Menor Privilégio): As credenciais de IAM usadas pelo GitHub Actions têm políticas estritamente restritivas. Elas só podem executar as ações necessárias para o pipeline (fazer push para o ECR, atualizar a task definition e o serviço do ECS).

✅ 5. Observabilidade
Logs Acessíveis: Os logs da aplicação dentro do container ECS são automaticamente encaminhados para o Amazon CloudWatch Logs. Isso permite visualizar, pesquisar e filtrar os logs de forma centralizada.

Monitoramento Básico:

CloudWatch Metrics: Métricas de CPU e uso de memória são monitoradas automaticamente pelo Fargate e podem ser visualizadas no CloudWatch.

Alarmes: É possível configurar alarmes no CloudWatch para notificar a equipe em caso de picos de CPU, baixa disponibilidade ou aumento na contagem de erros da aplicação.

Dashboards: A criação de dashboards personalizados no CloudWatch pode fornecer uma visão geral do estado dos ambientes.

✅ 6. Processo de Rollback
O rollback é um processo crítico para garantir a estabilidade da aplicação em caso de falha no deploy.

Estratégia: Nosso processo de rollback se baseia na reversão da imagem Docker. O ECS mantém um histórico de versões das task definitions. Se um deploy falhar ou causar problemas, podemos simplesmente reverter para a versão anterior da task definition que aponta para a imagem Docker funcional.

Instruções para Rollback Manual:

Acesse o console da AWS.

Navegue para o serviço ECS.

Selecione o cluster (staging ou production) e o serviço correspondente.

Clique em "Update" e selecione a task definition anterior na lista de revisões.

Confirme a atualização do serviço. O ECS irá então substituir os containers problemáticos pela versão estável anterior.

✅ 7. Checklist de Segurança Aplicado
[x] Utilização de OICD

[x] Comunicação via HTTPS com certificado SSL.

[x] Políticas de acesso restritivas via IAM para o pipeline.

[x] Configuração de CORS para evitar requisições de origens não autorizadas.

[x] Logs da aplicação centralizados no CloudWatch.

📝 Registro de Erros e Decisões
Escolha do Fargate: Decidimos usar o AWS Fargate em vez de EC2 ou Lightsail para simplificar a gestão de infraestrutura. Ele abstrai a complexidade do gerenciamento de servidores, permitindo que a equipe se concentre no pipeline e na aplicação.

Fluxo com branch main: A decisão de ter o deploy para staging no push para a main branch foi tomada para garantir que o ambiente de staging esteja sempre sincronizado com o código principal. O deploy para production é separado para garantir a devida validação.

Dificuldade para utilizar as políticas IAM corretas.
