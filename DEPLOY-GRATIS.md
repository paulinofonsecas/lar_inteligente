# Deploy gratuito — Lar Inteligente

**Arquitetura:** Firebase Hosting (app Flutter web, estático) + Render (backend Dart Frog em Docker).

**Custo total: R$ 0** — sem cartão de crédito em nenhuma das duas plataformas.

> **Por que não tudo no Vercel/Firebase?** O backend é um servidor persistente com
> WebSockets (`/live` e `/transcribe`): não roda em functions serverless. Por isso
> ele vai num container no Render, e o frontend (build estático) no Firebase Hosting.

---

## 1. Suba o projeto para o GitHub

Ambas as plataformas fazem deploy a partir do GitHub.

```powershell
git add -A
git commit -m "feat: versão Lar Inteligente (pt-BR, °C) e setup de deploy gratuito"
git remote add origin https://github.com/SEU-USUARIO/lar-inteligente.git
git push -u origin main
```

> Os arquivos de segredo ficam fora do git: `config.json` e
> `packages/home_backend/.env` já estão no `.gitignore`.

---

## 2. Backend no Render (~10 min)

1. Crie a conta em [render.com](https://render.com) (GitHub login, **sem cartão**).
2. **New +** → **Blueprint** → escolha o repositório. O Render lê o `render.yaml`
   da raiz e propõe o serviço `lar-inteligente-backend`.
3. No campo `HOME_CORS_ALLOWED_ORIGINS` deixe por ora o valor de placeholder
   (você volta aqui no passo 3.4 com a URL final do app).
4. **Apply**. O primeiro build compila o Dart dentro do container (~5–10 min).
5. Quando ficar **Live**, copie a URL do serviço — algo como
   `https://lar-inteligente-backend.onrender.com`.
6. Teste no navegador: `https://SUA-URL.onrender.com/health` → `{"status":"ok"}`.

### ⚠️ A única pegadinha do plano Free

O serviço **dorme** após 15 min sem tráfego e leva **~1 min** para acordar.
Na palestra: abra `https://SUA-URL.onrender.com/health` na aba **2 minutos antes
de começar** — ele fica acordado enquanto você apresenta (o tráfego do demo
mantém o serviço vivo).

---

## 3. Frontend no Firebase Hosting (~10 min)

### 3.1 Configurar a URL do backend

No `config.json` da raiz:

```json
{
  "GENUI_BACKEND_URL": "https://SUA-URL.onrender.com"
}
```

### 3.2 Compilar o app (com recursos web LOCAIS)

O `--no-web-resources-cdn` é importante: sem ele o `flutter.js`/canvaskit são
buscados em `fonts.gstatic.com`, que pode estar bloqueado na sua rede (foi o
caso aqui) — o app ficaria em tela preta no visitante.

```powershell
flutter build web --no-web-resources-cdn --dart-define-from-file=config.json
```

### 3.3 Criar o projeto Firebase

1. [console.firebase.google.com](https://console.firebase.google.com) → **Adicionar
   projeto** → nome `lar-inteligente` (plano Spark, **grátis, sem cartão**).
2. Atualize o `.firebaserc` da raiz com o id do projeto:
   ```json
   { "projects": { "default": "lar-inteligente-xxxxx" } }
   ```

### 3.4 Deploy (CLI)

```powershell
dart pub global activate firebase_cli   # ou: npm i -g firebase-tools
firebase login
firebase use --add                      # escolha o projeto criado
firebase deploy --only hosting
```

O Firebase Hosting imprime a URL final — algo como
`https://lar-inteligente-xxxxx.web.app` ou um domínio `firebaseapp.com`.

### 3.5 Alternativa sem CLI

Console do Firebase → **Hosting** → **Get started** → wizard de upload manual
(envia a pasta `build/web` como zip). A CLI é recomendada porque cada deploy é
um release com rollback.

### 3.6 Fechar o ciclo do CORS

Com a URL final do app (do passo 3.4), volte ao Render:

1. Serviço → **Environment** → `HOME_CORS_ALLOWED_ORIGINS` =
   `https://lar-inteligente-xxxxx.web.app` (a URL real, sem barra final).
2. **Save Changes** → o Render faz redeploy automático.

---

## 4. Teste de ponta a ponta

1. Abra `https://lar-inteligente-xxxxx.web.app` — acorda o backend (~1 min na
   primeira vez).
2. Cole a **sua chave do Gemini** no diálogo (fica só na aba; o servidor não a
   armazena — nada de segredo hospedado).
3. Diga/digite "preaqueça o forno para o jantar" e veja o dashboard reagir.

## 5. Limites do plano gratuito (resumo)

| | Render (backend) | Firebase Hosting (frontend) |
|---|---|---|
| Custo | $0, sem cartão | $0 (Spark), sem cartão |
| Sleep | Dorme após 15 min ocioso; ~1 min para acordar | — (estático, sempre no ar) |
| Horas | 750 h/mês (sobrando: 1 serviço sempre ativo) | 10 GB armazenado, transferência generosa |
| Escala | 1 instância; 200 sessões de demo em memória | CDN global |

## 6. Problemas comuns

| Sintoma | Causa provável | Correção |
|---|---|---|
| Tela preta no app | `flutter.js`/canvaskit vindos da CDN | Compile com `--no-web-resources-cdn` |
| Erros de CORS no console do navegador | `HOME_CORS_ALLOWED_ORIGINS` errado | URL exata do app, sem barra final, protocolo `https` |
| Primeira resposta demora ~1 min | Render acordando do sleep | Ping em `/health` antes da demo |
| `502` ao gerar | Chave do Gemini inválida/ausente | Reabra o diálogo de chave (engrenagem na sidebar) |
