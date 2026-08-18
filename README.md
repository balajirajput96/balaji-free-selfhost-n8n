# Balaji Free Self-Hosted n8n

यह package आपके अपने PC/Laptop पर **zero hosting-cost** n8n चलाने के लिए बनाया गया है। इसमें n8n और PostgreSQL Docker containers में चलेंगे। किसी cloud server या paid hosting की आवश्यकता नहीं है, लेकिन PC और internet चालू रहने पर ही schedules चलते रहेंगे।

> **सुरक्षा नियम:** `.env` में passwords, encryption key, OAuth/API credentials और webhook secrets आते हैं। इसे कभी GitHub, Google Drive, Chat, workflow export या किसी public location पर upload न करें।

## Package में क्या है

| Path | उद्देश्य |
|---|---|
| `compose.yaml` | n8n + PostgreSQL का local-only Docker stack |
| `.env.example` | secret-free runtime configuration template |
| `workflows/inactive-import/` | 10 Pharma workflows, जिनका `active=false` रखा गया है |
| `scripts/import-inactive-workflows.sh` | सुरक्षित draft import helper |
| `scripts/backup.sh` | PostgreSQL और workflows का local backup helper |
| `scripts/normalize_workflows.py` | exported workflows को inactive review drafts में convert करने वाला script |

## 1. PC पर prerequisites

Windows या macOS पर **Docker Desktop** install करें। Linux पर Docker Engine और Docker Compose plugin install करें। फिर terminal में यह command सफल होनी चाहिए:

```bash
docker compose version
```

## 2. Package खोलें और secrets बनाएं

```bash
cd balaji-free-selfhost-n8n
cp .env.example .env
```

`.env` को text editor में खोलें और दोनों placeholders बदलें। macOS/Linux पर local secrets बनाने के लिए:

```bash
openssl rand -base64 36
openssl rand -hex 32
```

पहला output `POSTGRES_PASSWORD` और दूसरा `N8N_ENCRYPTION_KEY` में रखें। Windows PowerShell पर आप दो अलग, लंबे random strings बना सकते हैं।

## 3. Local n8n start करें

```bash
docker compose up -d
docker compose ps
```

Browser में `http://localhost:5678` खोलें। पहली बार अपना n8n owner account बनाएं। यह account local n8n का अलग account होता है; Google/GitHub password नहीं।

## 4. Workflows import करें

सभी imported workflows inactive रहेंगे। macOS/Linux:

```bash
chmod +x scripts/import-inactive-workflows.sh scripts/backup.sh
./scripts/import-inactive-workflows.sh
```

Windows PowerShell में Docker command से import करें:

```powershell
docker compose exec -T n8n n8n import:workflow --separate --input=/workflows/inactive-import
```

फिर n8n UI में प्रत्येक workflow खोलें, उसके credentials/referenced resources को connect करें, manual test चलाएं, और केवल सत्यापित होने पर activate करें।

## 5. Integration boundaries

| Integration | सुरक्षित configuration |
|---|---|
| Gmail / Google Sheets / Drive | Target n8n UI में नया OAuth credential बनाएं; exports से credential copy न करें |
| OpenAI / Gemini | API keys केवल n8n Credentials में रखें; workflow JSON, GitHub या logs में नहीं |
| GitHub | Dedicated fine-grained token / OAuth credential दें, केवल required repository permissions के साथ |
| Ollama | Optional local model runtime है; minimum 8 GB system RAM recommended. GPU उपलब्ध न होने पर model responses धीमे हो सकते हैं |
| Gemini Spark | केवल एक narrow header-authenticated webhook या approved MCP workflow expose करें; full n8n admin API expose न करें |

## 6. Schedules और free hosting limitation

Cron workflows local n8n में काम करेंगे, लेकिन केवल तब जब PC चल रहा हो। PC sleep/restart/offline होने पर missed runs और public webhooks काम नहीं करेंगे। Docker's `restart: unless-stopped` service को reboot के बाद फिर से शुरू कर देता है, बशर्ते Docker Desktop login/startup पर चालू हो।

## 7. Local backup

महत्वपूर्ण workflow या credential change से पहले:

```bash
./scripts/backup.sh
```

यह `backup/` में PostgreSQL dump और workflow export लिखेगा। इस folder को encrypted external drive या private backup location में रखें।

## 8. Public HTTPS/webhook migration (optional)

Local package में port केवल `127.0.0.1` पर bound है, इसलिए internet से access नहीं होगा। Public webhooks या Gemini Spark connection के लिए बाद में domain/HTTPS reverse proxy या secure tunnel configure करना होगा। तभी `.env` में `N8N_HOST`, `N8N_PROTOCOL`, `N8N_EDITOR_BASE_URL`, `WEBHOOK_URL` और `N8N_SECURE_COOKIE=true` को domain के अनुसार update करें।

## Operational status

यह package ready है, पर live installation तब ही हो सकती है जब आपका PC chat में connected हो। Import होने वाले 10 Pharma workflows intentionally inactive हैं; उनके external credentials और data-table resources को verify करके activate करना होगा.
