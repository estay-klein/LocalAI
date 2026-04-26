# Project Constitution: Local & Open-Source AI Stack

## 1. Hardware & System Constraints
- **Operating System:** Pop!_OS (Debian/Ubuntu-based).
- **GPU Architecture:** NVIDIA RTX 4060 (8GB VRAM). Prioritize CUDA-accelerated libraries and the NVIDIA Container Toolkit.
- **Package Management Policy:** STRICTLY FORBIDDEN to use `snap` and `flatpak`. Use `apt` for system packages, or direct binaries/custom shell scripts.
- **Docker Infrastructure:** Always use Docker Compose for service orchestration. **All `docker-compose` files must be located strictly within the `/services/` directory.** Every GPU-dependent service must include explicit GPU passthrough configurations.

## 2. Architecture & Execution Strategy
- **Clean Containerization:** Architecture must strictly rely on clean, minimal Docker images orchestrated via Docker Compose.
- **Process Supervision:** All project scripts must be executed within an independent, dedicated Docker container. Inside this container, all script executions must be managed and monitored by `supervisord`, with its Web GUI enabled for visual tracking.
- **Shared Environment:** All scripts running within the `supervisord` container must share a single, unified Python environment.
- **Microservices & Modularity:** Adopt a strict microservices approach for scripting. Minimize the size of individual files by heavily isolating functions, classes, and logic into separate, independent files. This is mandatory to facilitate continuous improvement and targeted debugging.
- **Single-Line Service Selection:** The `.env` variable `COMPOSE_FILE` is the canonical mechanism for selecting which services are part of the active stack. To add or remove services, edit this single line by appending or removing `services/<service>/docker-compose-*.yaml` entries.
- **Documentation-First Explanations:** Keep implementation and compose files free of explanatory comments. All explanations, runbooks, architecture notes, and API behavior must live in MkDocs and OpenAPI documentation.
- **Compose Network Simplification:** Service-level compose files must not declare an explicit shared network. The stack must rely on the default network created by the merged `COMPOSE_FILE` project.

## 3. Data Persistence & Security
- **Project‑Local Docker Folder:** All persistent volumes, private information, git‑ignored files, `.env` variables, secrets, and keys MUST live inside a dedicated `docker` folder at the **project root**. This folder must be listed in `.gitignore` so that large model files and sensitive data never enter version control.
- **Path Standard:** The base path for all persistent data is `./docker/` (relative to the project root). No environment variable is needed – the structure is fixed relative to the repository location.
    - *Examples:* `./docker/models` for LLM weights, `./docker/services/openwebui` for specific service data.
    - *Model storage:* Custom fine‑tuned models for Ollama must be placed in `./docker/models/ollama/` to be shared between CPU and GPU variants.
- **Portability:** The stack is self‑contained; cloning the repository and creating the `docker` directory (or restoring it from a backup) is the only prerequisite. No absolute paths or external environment variables are required for data storage.
- **User‑Specific Customization:** Any configuration, data, or scripts that are specific to the user executing the stack (e.g., supervisord program configurations, service‑specific runtime data, user‑uploaded files) must be placed under `./docker/services/<service‑name>/`. The project directory contains only generic, shareable service definitions (Dockerfiles, docker‑compose files, default configurations). This ensures that the project remains clean and portable across different users and environments.
- **Local Secrets:** Never commit sensitive data to version control. Always maintain `.env.example` templates in the repository for reference. The actual `.env` file resides under `./docker/secrets/`.

## 4. Development Philosophy
- **Data Sovereignty:** Local-first inference. No external API calls for LLM processing (OpenAI, Anthropic, etc.) unless explicitly requested by the user.
- **Spec-Driven Development (SDD):**
    1. Read `.spec/spec.md` before initiating any task.
    2. Update `.spec/tasks.md` before starting and after completing implementations.
    3. **Update `Readme.md`** after each task to reflect the latest changes, ensuring the documentation stays synchronized with the implemented features.
- **Version Control:** Atomic commits following the *Conventional Commits* pattern. One completed task equals one clean Git commit.
- **Unified Documentation:** The project includes a **Swagger UI** service (`docs.localhost`) that aggregates API documentation from all RESTful services. Maintain OpenAPI specifications for any new service that exposes an HTTP API.
- **Centralized Dashboard:** The custom **LocalAI Dashboard** (`dashboard.localhost`) provides real‑time monitoring and quick access to all stack services. When developing new services, ensure they are discoverable by the dashboard (via Docker API or health endpoints).

## 5. Technology Stack & Tooling
- **Default Languages:** **Python** and **Bash**. You MUST ask for explicit permission before implementing solutions in any other programming language.
- **Inference Engine:** Ollama (Preferred models: `llama3`, `qwen2.5-coder`).
- **Logic & Agents:** Pi Agent Framework.
- **Workflow Automation:** n8n (Self-hosted via Docker).
- **Environment:** VS Code with Roo Code / Aider integration.
- **Coding Standards:**
    - Python: PEP 8 compliant, type hints required.
    - Bash: Must include error handling (`set -eou pipefail`).

## 6. Filesystem Organization
- `/.spec/`: All project intelligence, rules, specs, and task tracking.
- `/services/`: **Mandatory directory for all `docker-compose.yml` files** and service-specific container configurations. All Docker-related resources (Dockerfiles, configuration files) must be placed within the corresponding service subdirectory (e.g., `./services/supervisord/` for supervisord).
- `/scripts/`: Maintenance, setup, and automation bash scripts (must include English summary headers).
- `/src/`: Core application logic, strictly modularized per the architecture strategy.
- `/localai/`: **Custom dashboard application** – FastAPI+Jinja2 web app for service monitoring and management (project‑specific code, not a standard image).
- `/docker/`: **Persistent data root (git‑ignored)**. Contains all models, service‑specific runtime data, and secrets.

---

### Implementation Instructions for the Agent:
> Review this Constitution prior to any code generation. Any proposal utilizing `snap`/`flatpak`, external cloud AI APIs, or languages other than Python/Bash without permission is a direct violation. Ensure all `docker-compose` files are placed in `/services/` and all persistent data targets `./docker/...`. For stack composition changes, update `.env` `COMPOSE_FILE` as the authoritative service list. Keep explanatory content in MkDocs/OpenAPI instead of inline comments. Do not proceed until `.spec/tasks.md` accurately reflects the current objective. **After completing a task, update `Readme.md` to reflect the changes and keep the project documentation up‑to‑date.**

### Notes on Portability (Updated 2026‑04‑24)
The project now uses the project‑local `docker/` directory (git‑ignored) for all persistent data. This makes the stack self‑contained and independent of any host‑user home directory.

**Key Principles:**
- All persistent volumes live inside `./docker/` relative to the project root.
- The `docker/` folder must be listed in `.gitignore` to prevent large model files and secrets from being committed.
- The stack is **portable** – clone the repository, create or restore the `docker/` directory, and the same Compose files work without path edits.
- **No giant models should ever be placed inside the repository** – they belong in `./docker/models/`.
- The Docker network is named **`LocalAI`** (capitalized) to maintain consistency across the stack.
