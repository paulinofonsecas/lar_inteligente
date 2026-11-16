# A2UI VGV Smart Home — Demo e Notas de Palestra (GenUI)

> Material de estudo e setup do projeto `VGVentures/a2ui_vgv_smart_home`, preparado
> para demonstração em palestra sobre **GenUI / A2UI 1.0**.

---

## 1. Setup e execução (Windows)

### O que foi configurado

| Item | Estado |
|---|---|
| Clone do repo | `C:\Users\pauli\devin\flutter\genui_proto` (branch `main`, commit `9ecfe12`) |
| Flutter | 3.44.8 global (funcional) / 3.44.9 via `fvm` (pinado no `mise.toml`) |
| Dependências | `flutter pub get` no root, `app_ui`, `home_frontend` + `dart pub get` nos 5 pacotes Dart puros |
| `config.json` | Criado a partir de `config.example.json` → `GENUI_BACKEND_URL: http://localhost:8080` |
| `packages/home_backend/.env` | Criado → `HOME_CORS_ALLOWED_ORIGINS=http://localhost:3000` |
| Backend | Dart Frog em `http://localhost:8080` |
| App web | `flutter build web` servido em `http://localhost:3000` |
| Chrome + REA | Chrome com CDP na porta `:9222`; página "A2UI VGV Smart Home" inspecionada |

### Comandos para reproduzir

```powershell
# Dependências (root e cada pacote)
flutter pub get
flutter pub get (em packages\app_ui e packages\home_frontend)
dart pub get (em packages\home_catalog, home_timeline, home_api_client, home_repository, home_backend)

# Configurações
Copy-Item config.example.json config.json -Force
Set-Content packages\home_backend\.env "HOME_CORS_ALLOWED_ORIGINS=http://localhost:3000"

# Backend (Windows: dart_frog dev trava sem TTY — use o server gerado)
cd packages\home_backend
dart run .dart_frog/server.dart

# App web
flutter run -d chrome --web-port 3000 --dart-define-from-file=config.json
# ou: flutter build web --dart-define-from-file=config.json
#     python -m http.server 3000 --bind 127.0.0.1  (dentro de build\web)

# Chrome com CDP para o REA
& "C:\Program Files\Google\Chrome\Application\chrome.exe" `
  --remote-debugging-port=9222 --user-data-dir="$env:TEMP\rea-chrome" `
  http://localhost:3000
```

### Verificações de API confirmadas

- `GET /health` → `{"status":"ok"}`
- `GET /users` (header `X-Session-Id`) → Palmira e Paulino com fotos em base64
- `GET /clock` → `{"now":"2026-10-10T07:30:00","start":"...","end":"...","timeZone":"America/Chicago"}`

> ⚠️ O id de sessão precisa casar com `^[A-Za-z0-9_-]{16,64}$` (ex.: `demo-session-000001`).
> Sem ele, rotas com mundo retornam `400 "Missing session id"`.

> ⚠️ Único passo manual restante: informar a **chave de API do Gemini** no diálogo ao
> abrir `http://localhost:3000` (o demo é *bring your own key* — o backend nunca armazena).

> ⚠️ Nota de ambiente: o download do Flutter 3.44.9 via `mise` falhou por rede lenta
> (`storage.googleapis.com` a ~20 kB/s, timeout de 1800 s). Alternativa que funcionou:
> Flutter global 3.44.8 / fvm 3.44.9, ambos com Dart 3.12.2 igual ao pinado.

### Observação do REA na página em execução

- `flutter.js` (dart2js, renderer **canvaskit**), `main.dart.js` de **3.57 MB**
- Service worker registrado; `flutter.js.map` disponível
- Árvore de acessibilidade exibiu o diálogo de API key (textbox + botão "Enviar")

---

## 2. Como o projeto funciona

O modelo **nunca desenha pixels** — ele escreve JSON (mensagens A2UI 1.0). O app Flutter
já sabe desenhar um catálogo fixo de cards. *"O modelo é o designer que pede do catálogo;
o Flutter é o construtor que monta."*

### As três mensagens A2UI

| Mensagem | Significado |
|---|---|
| `createSurface` | Nova tela com componentes + data model |
| `updateComponents` | Muda o layout |
| `updateDataModel` | Muda um valor → cards com `@path` atualizam no lugar, sem rebuild |

**Separação chave: estrutura vs. dados.** Um card não contém `oven: 180°C`; contém
"mostre o que está em `/devices/oven/temp`". Mudar um número nunca significa rebuildar a tela.

### Os três canais

```
POST /generate, /action   buffered JSON {messages, reply}, validado (turno do modelo)
WS   /live                server push: clock, a2ui, inbox, changed (dados)
WS   /transcribe          áudio ↑ texto ↓ via Gemini Live (voz)
```

### Validação em camadas (a resposta do modelo é *untrusted*)

1. O prompt é construído do catálogo → só o que existe é oferecido
2. `parseResponse` rejeita A2UI inválido, componente desconhecido, filho órfão
3. `LayoutValidator` rejeita qualquer layout fora da grade 12×2
4. Um retry com os erros de volta para o modelo; se falhar, `422`
5. O app aplica tudo em uma chamada — **ou nada**

### Fluxo de exemplo: "preheat the oven for dinner"

1. Usuário fala → `VoiceCubit` transcreve → vai ao LLM como turno digitado
2. `TurnQueue` executa um turno por vez
3. `POST /generate` com `metadata.a2uiRendererDataModel`
4. Modelo chama tools sobre os dados mock → responde A2UI JSON
5. Validação (1 retry)
6. `HttpGenUIAgent` aplica todas as mensagens em um `processMessages`
7. Sem modelo: mudanças de dispositivo chegam via `/live` e atualizam o card no lugar

---

## 3. Features para a apresentação

### A. Componentes do catálogo (12 cards que o modelo pode compor)

| Componente | O que faz |
|---|---|
| `Column`, `Row` | Layout — grades que o modelo pode compor |
| `DeviceCard` | Estado de um dispositivo + 1 slot de controle (toggle, stepper, botão) — props ligadas ao data model |
| `HeadsUpCard` | Card urgente no topo — sempre *half tall* |
| `ChangeSummary` | Resumo do que a pessoa pediu |
| `PlanTimeline` | Itinerário — `density: detailed` (full height) ou `compact` (half tall) |
| `TripCard` | Viagem do Paulino — até 3 stops, *leave by* |
| `ChargeCard` | Carga do carro EV |
| `SceneCard` | Cena "Dinner party" — botão Start quando `ready` |
| `CountdownCard` | Contagem regressiva para 19:00 |
| `ShoppingList` | Lista de compras — sempre full height |
| `ActionChips` | Chips de próxima ação (1–3), sempre abaixo da grade |

### B. Segurança / Validação

- **Prompt derivado do catálogo** — só componentes que existem
- **Schema rígido** — cada componente declara sua forma
- **1 retry** com erros de volta para o modelo
- **Apply all-or-nothing** — o painel nunca mostra grid pela metade
- **Statuses deliberados**: `400` bad body, `401` no key, `422` validation exhausted, `502` model failed

### C. Grid de layout (a "1 declaração, 3 usos")

- **12 colunas × 2 rows** — o card declara seu tamanho em `CardFit` uma vez
- **Mesma fonte de verdade em 3 lugares**: prompt do modelo, validador do backend, grid do frontend
- `LayoutComposer` + `DeviceFiller` completam células vazias automaticamente

### D. Ações (o modelo escolhe targets, o código constrói o evento)

- `toggle_device` {deviceId, on}
- `adjust_device` {deviceId, direction}
- `run_device_action` {deviceId, command} — 13 comandos
- `run_scene` {sceneId}
- `toggle_todo` {listId, itemId, checked}
- `share_list` {listId}
- `undo_change` — desfaz a última mudança
- `ask` {text} — chip que vira texto digitado (não ação de backend)

### E. Voz (`/transcribe`)

- **Push-to-talk** — tap no mic abre o card de escuta
- **2 s de silêncio** → envia o texto ao modelo
- **10 s sem falar** → cancela
- **Cancel pill** para descartar manualmente
- **Visualização de níveis de áudio** em barras (RMS + sqrt)
- **WebSocket duplex** para streaming de áudio/texto

### F. Timeline / Cenário roteirizado (Sábado)

- **Relógio controlável** — mover o dia para frente/trás
- **4 fases**: Manhã (07:30), Dia (16:30), Sunset (17:40), Evening (20:40)
- **Auto-play** do tempo quando ninguém mexe
- **Cena roteirizada**: jantar 19:00, forno preaquecendo, bolo na padaria, visitas
- **Reconciliação real-time** — mover o relógio reescreve o mundo (forno, rota, pedido, porteira)

### G. Streaming / Live updates (`/live`)

- **Dados mudam sem pedir ao modelo** — a temperatura do forno sobe em tempo real
- **`updateDataModel` sem rebuild** — card ligado ao `@path` atualiza o número no lugar
- **Inbox items** empurrados para a pessoa certa quando o outro muda o plano
- **Refresh hints** — o backend avisa quando os dados de um usuário mudaram

### H. Multi-usuário (o grande insight!)

- **2 perfis: Palmira (Host) e Paulino (Logistics)** — cada um vê seu dashboard
- **Mundo demo por visitante** — sessões isoladas por `X-Session-Id`
- **`dashboardLeadsWith`** — o perfil diz ao modelo o que priorizar
- **Troca de perfil rebuilda o dashboard** de outro ponto de vista

### I. Roteiro de demonstração ao vivo

1. **Digitar** "preheat the oven for dinner" → modelo chama tool → dashboard muda
2. **Falar** no mic → transcrição → mesmo resultado
3. **Tap no DeviceCard** (toggle) → state machine → dashboard reflete
4. **Mover o relógio** → ver o mundo reconciliar (forno, rota, bolo)
5. **Trocar perfil** Palmira ↔ Paulino → dashboards diferentes da mesma casa
6. **Chips de sugestão** → modelo lê o inbox e propõe ação ("Have the bakery deliver the cake")
7. **Undo** → reverte a última mudança

### J. Extensões possíveis para a demo

- 🔊 **TTS** — o modelo fala a resposta de volta
- 📸 **Câmera/doorbell** — foto da porta quando alguém chega
- 🌐 **Mais idiomas** — `l10n` já estruturado; adicionar `pt` em `supportedLocales`
- 🎨 **Temas** — trocar `AppTheme` em runtime (light/dark)
- 📱 **Companion mobile** — Flutter compila iOS/Android com o mesmo código
- ⏱️ **Multi-surface** — mais de um dashboard na tela ao mesmo tempo
- 🧩 **Novos componentes** — `packages/home_catalog/AGENTS.md` documenta os 6 passos
- 🛠️ **Novos tools** — `lib/tools/` + `buildAgentTools` + `system-prompt.prompt`

---

## 4. Frases de efeito para a fala

- *"O modelo nunca desenha pixels"* — conceito central de GenUI
- *"Estrutura vs. dados"* — cards ligados a `@path`, não a valores
- *"3 canais"* — generate (lento/validado), live (rápido/sem modelo), transcribe (voz)
- *"Layout em 3 lugares"* — 1 declaração de tamanho no prompt, no validador e no frontend
- *"Bring your own key"* — a chave vive no request, nunca é logada nem armazenada
- *"1 mundo demo por visitante"* — sessões isoladas; recarregar = mundo novo
