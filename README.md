# SESMT B&M — Controle de Documentação

Sistema web para controle de documentação obrigatória de colaboradores, empresas terceirizadas e máquinas em obras de construção civil, com análise automática por IA (Google Gemini) e disparo de e-mails via webhook (Make.com).

## Arquivos

```
APP - SESMT/
├── sesmt-bm.html          # Aplicação completa (single file)
├── README.md              # Este arquivo
├── supabase/
│   ├── schema.sql         # Schema do banco (PostgreSQL)
│   └── seed.sql           # Dados iniciais (catálogo + funções)
└── .gitignore
```

## Como usar (modo standalone — recomendado para começar)

1. Abra `sesmt-bm.html` no navegador (Chrome, Edge, Firefox).
2. Login inicial: **diretoria@brandaoemarmo.com.br** / **admin**.
3. Vá em **Configurações** e:
   - Faça upload do logo da empresa.
   - Cole sua chave do Gemini (gratuita em https://aistudio.google.com/app/apikey).
   - Cole a URL do webhook Make.com (para envio real de e-mails).
4. Cadastre Obras → Funções (catálogo) → Empresas → Colaboradores → Máquinas.
5. Os dados ficam salvos no navegador (localStorage). Para uso multi-usuário, migre para Supabase (veja abaixo).

## Hospedar no GitHub Pages

1. Crie um repositório no GitHub (público ou privado).
2. Suba todos os arquivos da pasta `APP - SESMT/`.
3. Settings → Pages → Source: `main` branch, pasta `/ (root)`.
4. O app fica disponível em `https://<seu-usuario>.github.io/<repo>/sesmt-bm.html`.

## Migrar para Supabase (multi-usuário, ilimitado)

### 1. Criar projeto Supabase
- Acesse https://supabase.com → New Project (free tier).
- Anote `URL` e `anon key` do painel Settings → API.

### 2. Rodar o schema
- No SQL Editor do Supabase, cole o conteúdo de `supabase/schema.sql` e execute.
- Em seguida, cole `supabase/seed.sql` para popular o catálogo de documentos e funções.

### 3. Configurar Storage
- Storage → New bucket → nome: `documentos` → Private.
- Policies: permita upload e download autenticado (já incluso no schema.sql).

### 4. Ativar autenticação
- Authentication → Providers → Email habilitado.
- Crie o primeiro usuário Diretoria via Authentication → Add User.
- Edite a tabela `usuarios` para vincular tipo = `diretoria`.

### 5. Adaptar o HTML para usar Supabase (opcional - próxima fase)
O HTML atual usa localStorage. Para usar Supabase como backend:
- Adicione `<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>`.
- Substitua funções `load()` e `save()` por chamadas `supabase.from('tabela')...`.
- Substitua upload base64 por `supabase.storage.from('documentos').upload()`.
- Substituir `localStorage` mantendo a interface intacta é trabalho de ~1 dia. Solicite a migração quando estiver pronto.

## Integração Make.com (e-mails reais)

1. Crie um cenário no Make.com.
2. Trigger: **Webhook → Custom webhook** → copie a URL.
3. Cole essa URL em **Configurações → Webhook Make.com**.
4. Adicione módulo Email (Gmail, SMTP, SendGrid, etc.) usando os campos recebidos:
   - `{{1.to}}` → destinatário principal
   - `{{1.cc}}` → array de cópias
   - `{{1.subject}}` → assunto
   - `{{1.html}}` → corpo HTML
5. Teste em Configurações → "🧪 Testar webhook".

## Integração Gemini (análise de IA)

1. Pegue chave gratuita em https://aistudio.google.com/app/apikey.
2. Cole em **Configurações → Análise por IA → Chave Gemini**.
3. Cota gratuita: **~1.500 análises/dia** (suficiente para qualquer construtora).
4. A IA verifica:
   - Tipo do documento (é realmente o que diz ser?)
   - Identidade (nome/CPF do PDF bate com o cadastro?)
   - Checklist específico (definido por documento no Catálogo)
   - Datas, assinaturas, CRMs, ARTs, cargas horárias

## Perfis de usuário

| Perfil | Permissões |
|---|---|
| Diretoria | Tudo. Usuário protegido, não pode ser apagado. |
| SESMT | Tudo (configurar exigências, aprovar, notificar) |
| Coordenador / Engenheiro | Apenas suas obras (não aprova) |
| TST | Suas obras + pode aprovar/recusar |
| Cliente da Obra | Apenas leitura nas obras vinculadas |
| Visualizador | Leitura em todas as obras |
| Empresa (fornecedor) | Apenas envia documentos da sua empresa |

## Suporte

Para customizações: contato com o time de desenvolvimento.


---
Versão: 1.0 • Brandão & Marmo Engenharia
