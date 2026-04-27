# Local & Open-Source AI Stack - Technical Specification

## 1. Project Overview
**Project Name:** LocalAI Stack  
**Version:** 1.0.0  
**Purpose:** A self‑hosted, modular AI inference and automation platform that runs entirely on local hardware, with strict data sovereignty and minimal external dependencies.

## 2. Architecture Principles
- **Container‑First:** All services run inside Docker containers orchestrated by Docker Compose.
- **Micro‑Services:** Each functional unit (LLM inference, UI, database, automation) is a separate, loosely coupled service.
- **Strict Persistent Data Layout:** All persistent data (models, service state, secrets) MUST reside inside the `.localai` directory at the project root. The directory `.localai/data/services/<service‑name>` is the canonical location for any service‑specific runtime data. The `.localai` directory is **git‑ignored** — it must never be committed to the repository.
- **Supervisord Supervision:** All script execution inside the main application container is managed by `supervisord`.
- **Spec‑Driven Development:** Every change follows the SDD cycle (read spec → update tasks → implement → commit).

## 3. Service Matrix
| Service | Role | Image | Port | Data Path | GPU Support | Profile |
|---------|------|-------|------|-----------|-------------|---------|
| traefik | Reverse Proxy & Load Balancer | traefik:v3.3 | 80, 443 | – | No | – |
| ollama‑gpu | LLM Inference Engine (GPU) | ollama/ollama | 11435 | ./.docker/data/services/ollama‑gpu | Yes (NVIDIA) | gpu‑nvidia |
| ollama‑cpu | LLM Inference Engine (CPU) | ollama/ollama | 11434 | ./.docker/data/services/ollama‑cpu | No | cpu |
| openwebui‑gpu | Web UI for LLMs (GPU) | ghcr.io/open‑webui/open‑webui:main | 3031→8080 | ./.docker/data/services/openwebui‑gpu | Yes | gpu‑nvidia |
| openwebui‑cpu | Web UI for LLMs (CPU) | ghcr.io/open‑webui/open‑webui:main | 3030→8080 | ./.docker/data/services/openwebui‑cpu | No | cpu |
| n8n | Workflow Automation | n8nio/n8n:latest | 5678 | ./.docker/data/services/n8n | No | – |
| postgres | Primary Database | postgres:16 | 5432 | ./.docker/data/services/postgres | No | – |
| timescaledb | Time-Series Database | timescale/timescaledb:latest-pg16 | 5433→5432 | ./.docker/data/services/timescaledb | No | – |
| pgvector | Vector-Enabled PostgreSQL | pgvector/pgvector:pg16 | 5434→5432 | ./.docker/data/services/pgvector | No | – |
| redis | In‑Memory Cache | redis:7‑alpine | 6379 | ./.docker/data/services/redis | No | – |
| jaeger | Distributed Tracing | jaegertracing/all‑in‑one:latest | 16686 | – | No | – |
| grafana | Monitoring & Dashboards | grafana/grafana‑oss:latest | 3000 | ./.docker/data/services/grafana | No | – |
| searxng | Privacy‑First Search | searxng/searxng:latest | 8080 | ./.docker/data/services/searxng | No | – |
| flowise | Low‑Code AI Builder | flowiseai/flowise:latest | 3002 | ./.docker/data/services/flowise | No | – |
| langflow | LangChain Visual Editor | langflowai/langflow:latest | 7860 | ./.docker/data/services/langflow | No | – |
| jupyterhub | Jupyter Notebooks | jupyterhub/jupyterhub:latest | 8000 | ./.docker/data/services/jupyterhub | No | – |
| localai | LocalAI Dashboard & Workspace Canvas (FastAPI+Jinja2) | custom build | 8081 | ./.docker/data/services/localai | No | – |
| swagger‑ui | Unified API Documentation | swaggerapi/swagger‑ui | 8082 | – | No | – |
| mkdocs | Documentation Site (Material for MkDocs + embedded Swagger UI) | custom build (`services/mkdocs/Dockerfile`) | 8001→8000 | `./docs`, `./mkdocs.yml` | No | – |
| browseruse | Browser Automation | browseruse/browseruse:latest | 3003 | – | No | – |
| perplexica | Perplexity‑style Search | perplexica/perplexica:latest | 3004 | ./.docker/data/services/perplexica | No | – |
| supervisord | Process Supervision | custom build | 9001 | ./.docker/data/services/supervisord | No | – |
| supervisord‑monitor | Supervisor Monitoring Web UI | dockage/supervisor-web:2.2.0 | 80 | – | No | – |

### 3.1 LocalAI Dashboard
- **LocalAI** is a local dashboard for AI tools. Its main interface is a clean canvas (per user) where you can drag and drop widgets that reflect different aspects of the running stack.
- **Main sections:**  
  - **Home:** dashboard selector – unlimited dashboards (workspaces) per user.  
  - **Observability:** real‑time stack monitoring.  
  - **Services:** quick links (opening in a new tab) to every service web interface reachable on localhost.  
  - **Data:** persistent volumes and external directories/files currently in use by the stack.  
  - **Config:** personalisation settings.  
- The application is built with **FastAPI + Jinja2** and is deployed as a Docker service from a custom `Dockerfile`.

## 4. Network Topology
- **Compose Project Network:** Services rely on the default network created in the core `docker-compose.yaml` file.
- **Traefik** acts as the single entry point; all external traffic routes through it.
- **Internal service‑to‑service communication** uses Docker DNS (`service‑name`) on the shared Compose project network.
- **GPU‑capable services** are placed on the `gpu‑nvidia` Docker profile and require explicit device passthrough.
- **CPU‑only services** use the `cpu` profile. The stack supports only these two profiles (`cpu` and `gpu‑nvidia`).

## 5. Data Persistence Layout
All persistent data lives under `.localai/data/services/` (relative to the project root). The `.localai` directory is **git‑ignored** and never committed.

```
project‑root/
├── .docker/
│   ├── data/
│   │   └── services/
│   │       ├── ollama‑gpu/
│   │       ├── ollama‑cpu/
│   │       ├── openwebui‑gpu/
│   │       ├── openwebui‑cpu/
│   │       ├── n8n/
│   │       ├── postgres/
│   │       ├── timescaledb/
│   │       ├── pgvector/
│   │       ├── redis/
│   │       ├── grafana/
│   │       ├── searxng/
│   │       ├── flowise/
│   │       ├── langflow/
│   │       ├── jupyterhub/
│   │       ├── localai/
│   │       ├── perplexica/
│   │       └── supervisord/
│   └── secrets/
│       ├── .env             # Environment variables (git‑ignored)
│       └── ssl/             # TLS certificates (if any)
└── .repo/
    └── github.com/
        └── <user>/
            └── <project>/   # Future downloaded repositories
```

**Model Storage Note:** All models for Ollama must be placed under `.localai/data/services/ollama-*` to be accessible by both CPU and GPU Ollama services. The `ollama-*` directories are effectively shared between CPU and GPU variants to avoid duplication and ensure models are available regardless of which profile is active.

**User‑Specific Customization:** Any configuration, data, or scripts that are specific to the user executing the stack (e.g., supervisord program configurations, service‑specific runtime data, user‑uploaded files) must be placed under `.localai/data/services/<service‑name>/`. The project directory contains only generic, shareable service definitions (Dockerfiles, docker‑compose files, default configurations). This ensures that the project remains clean and portable across different users and environments.

## 6. Environment Variables
All sensitive configuration is stored in `.env` files outside the repository (in `.localai/secrets/`). Each service’s Docker Compose file references these variables via `${VAR_NAME}`. An `.env.example` is kept in the repository for documentation.

**Key variables:**
- `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD` – credentials for the PostgreSQL service.
- `TIMESCALEDB_DB`, `TIMESCALEDB_USER`, `TIMESCALEDB_PASSWORD` – credentials for the TimescaleDB service.
- `PGVECTOR_DB`, `PGVECTOR_USER`, `PGVECTOR_PASSWORD` – credentials for the pgvector service.
- An so on, every variable for every service must have its own section in the `.env` file

**No variable** is needed for the root persistent path; the stack always places data under `.localai/data/services/`. The `.localai` folder is created automatically when services start and **must be added to `.gitignore`**.

## 7. Supervisord Configuration
- **Container:** `supervisord` (built from `/services/supervisord/Dockerfile.supervisord`)
- **Role:** Hosts all Python/Bash scripts that implement business logic, agent workflows, and automation.
- **Supervisord Web GUI:** Enabled on port 9001 inside the container, exposed via Traefik at `supervisord.localhost`.
- **Unified Python Environment:** All scripts share a single virtual environment managed by `poetry` or `pipenv`. And scripts are configured and runned by supervisord and visible with the monitor.
- **Process Groups:** Each logical unit (e.g., `agent‑llm`, `data‑pipeline`, `monitoring`) is a separate supervisord group.
- **Monitoring companion:** A lightweight web UI (`supervisord‑monitor`) is deployed in the same Compose file (`services/supervisord/docker-compose-supervisord.yaml`) to provide additional oversight of the supervisor process itself.

## 8. Development & Deployment Workflow
1. **Spec‑Driven Development:**
   - Read `.spec/spec.md` for architectural constraints.
   - Update `.spec/tasks.md` with the new task.
   - Implement changes in the appropriate directory.
   - Verify changes work in the local Docker environment.
   - Commit with a conventional‑commit message.
2. **Local Deployment:**
   - Run `docker‑compose up –detach` from the project root.
   - Services start in order defined by dependencies.
   - Traefik dashboard available at `traefik.localhost`.
3. **Production Considerations:**
   - Use Traefik middlewares for authentication, rate limiting, and SSL.
   - Ensure GPU‑capable hosts have the NVIDIA Container Toolkit installed.
   - Backup the `.localai` directory regularly.

## 9. Technology Stack
- **Orchestration:** Docker Compose (v2+)
- **Reverse Proxy:** Traefik v3
- **LLM Engine:** Ollama (primary), LocalAI (alternative)
- **Automation:** n8n (self‑hosted)
- **Agent Framework:** Pi Agent (Python‑based)
- **Vector SQL DB:** PostgreSQL + pgvector
- **Relational DB:** PostgreSQL
- **Time-Series DB:** TimescaleDB
- **Cache:** Redis
- **Monitoring:** Grafana + Jaeger
- **Documentation:** Material for MkDocs + embedded Swagger UI (`mkdocs-swagger-ui-tag`)
- **Scripting:** Python 3.11+ (PEP 8, type‑hinted), Bash (with `set -eou pipefail`)

## 10. Dashboard & Monitoring

### 10.1 LocalAI Dashboard
A custom web application built with **FastAPI + Jinja2** that serves as the primary user interface for the stack. The dashboard is developed as project‑specific code (not a standard Docker image) and resides in a dedicated directory at the project root (`/localai/`).

**Core Features:**
- **Home / Workspace Selector:** Unlimited dashboards (workspaces) per user, each a configurable canvas.
- **Observability:** Real‑time stack monitoring showing resource usage and container status.
- **Services:** Quick links (opening in a new browser tab) to all stack service web interfaces (Open WebUI, Traefik, Supervisord, etc.).
- **Data:** Overview of persistent volumes and external directories currently in use by the stack.
- **Config:** Personalisation settings stored per user.
- **Drag‑and‑drop widgets** that can be arranged freely on each canvas.

**Implementation Notes:**
- The application is packaged as a Docker service built from a custom `Dockerfile` inside the `/localai/` directory.
- It communicates with the Docker daemon via the Docker socket (mounted read‑only) to obtain container status and metrics.
- The dashboard is exposed via Traefik at `dashboard.localhost` (port 8081) and does not require a separate profile.

### 10.2 Swagger UI Integration
Swagger UI is integrated directly into the MkDocs site using the `mkdocs-swagger-ui-tag` plugin. This keeps narrative documentation and interactive API exploration under one documentation portal.

**Purpose:**
- Centralized API documentation for developers and integrators.
- Live testing of endpoints directly from the browser.
- Unified navigation with architecture and operations docs in one site.

**Deployment:**
- Provided by the MkDocs container (`services/mkdocs/docker-compose-mkdocs.yaml`).
- OpenAPI source path: `docs/specs/openapi.yaml`.
- Embedded page: `docs/api-reference.md`.

## 11. Compliance & Constraints
- **No `snap`/`flatpak`** – use `apt` or direct binaries.
- **No external cloud AI APIs** (OpenAI, Anthropic, etc.) unless explicitly requested by the user.
- **All Docker Compose files** must reside under `/services/`.
- **GPU‑dependent services** must include explicit GPU passthrough configuration.
- **Python/Bash** are the default languages; any other language requires explicit permission.
- **Portable paths** – all persistent volumes are bound under `.docker/data/services/`. The project must exist in `/home/$user/LocalAI` while all service data lives solely inside the `.docker` directory (git‑ignored). **No large models or data inside the project directory** – they belong under `.docker/data/services/<service‑name>`.
- **No Inline Explanatory Comments** – Explanations must be kept in MkDocs/OpenAPI documentation, not in service or source files.
- **No Explicit Shared Network Blocks in Service Compose Files** – Service-level compose files must rely on the merged `COMPOSE_FILE` project network.

## 12. Future Repository Downloads (`.repo`)
A `.repo` directory at the project root is reserved for third‑party repository downloads. The canonical layout is:
```
.repo/github.com/<organization>/<repository>
```
This folder is git‑ignored and serves as a staging area for scripted interactions with external repositories.

---

