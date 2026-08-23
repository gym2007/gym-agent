#!/usr/bin/env bash
set -e

echo "🚀 开始初始化 gym-agent 独立双子工程结构..."

# 1. 创建子工程目录
mkdir -p gym_agent_server/src/gym_server/{core,api} gym_agent_server/tests
mkdir -p gym_agent_client/src/gym_client/tools gym_agent_client/tests

# ----------------------------------------------------
# 2. 配置后端子项目 (gym_agent_server)
# ----------------------------------------------------
cat <<'EOF' > gym_agent_server/pyproject.toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "gym-agent-server"
version = "0.1.0"
description = "Gym-Agent Backend Service (Brain)"
readme = "README.md"
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.110.0",
    "uvicorn>=0.29.0",
    "pydantic>=2.7.0",
    "openai>=1.25.0",
    "python-dotenv>=1.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "ruff>=0.4.0",
]

[project.scripts]
gym-server = "gym_server.main:start"

[tool.pytest.ini_options]
testpaths = ["tests"]
pythonpath = ["src"]
EOF

cat <<'EOF' > gym_agent_server/src/gym_server/schemas.py
from typing import Any, Dict, List, Optional
from pydantic import BaseModel

class ChatMessage(BaseModel):
    role: str
    content: Optional[str] = None
    tool_call_id: Optional[str] = None
    tool_calls: Optional[List[Dict[str, Any]]] = None

class AgentChatRequest(BaseModel):
    messages: List[ChatMessage]
    tools: Optional[List[Dict[str, Any]]] = None

class AgentChatResponse(BaseModel):
    type: str  # "text" | "tool_call"
    content: Optional[str] = None
    tool_call_id: Optional[str] = None
    tool_name: Optional[str] = None
    tool_args: Optional[str] = None
    raw_message: Optional[Dict[str, Any]] = None
EOF

cat <<'EOF' > gym_agent_server/src/gym_server/main.py
from fastapi import FastAPI
from gym_server.schemas import AgentChatRequest, AgentChatResponse

app = FastAPI(title="Gym-Agent Server (Brain)")

@app.get("/health")
def health_check():
    return {"status": "ok", "service": "gym-agent-server"}

@app.post("/v1/agent/chat", response_model=AgentChatResponse)
def agent_chat(req: AgentChatRequest):
    return AgentChatResponse(
        type="text",
        content="服务端运行正常，等待接入真实大模型。"
    )

def start():
    import uvicorn
    uvicorn.run("gym_server.main:app", host="127.0.0.1", port=8000, reload=True)

if __name__ == "__main__":
    start()
EOF

touch gym_agent_server/src/gym_server/__init__.py
touch gym_agent_server/tests/__init__.py

cat <<'EOF' > gym_agent_server/.env.example
OPENAI_API_KEY=your_openai_api_key
OPENAI_BASE_URL=https://api.openai.com/v1
MODEL_NAME=gpt-4o
EOF

# ----------------------------------------------------
# 3. 配置前端子项目 (gym_agent_client)
# ----------------------------------------------------
cat <<'EOF' > gym_agent_client/pyproject.toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "gym-agent-client"
version = "0.1.0"
description = "Gym-Agent CLI Client (Hands & Eyes)"
readme = "README.md"
requires-python = ">=3.11"
dependencies = [
    "typer>=0.12.0",
    "rich>=13.7.0",
    "requests>=2.31.0",
    "pydantic>=2.7.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "ruff>=0.4.0",
]

[project.scripts]
gym-cli = "gym_client.cli:app"

[tool.pytest.ini_options]
testpaths = ["tests"]
pythonpath = ["src"]
EOF

cat <<'EOF' > gym_agent_client/src/gym_client/cli.py
import typer
import requests
from rich.console import Console

app = typer.Typer(help="Gym-Agent CLI 客户端")
console = Console()
SERVER_URL = "http://127.0.0.1:8000"

@app.command()
def check():
    """检测与服务端的连通性"""
    try:
        resp = requests.get(f"{SERVER_URL}/health", timeout=3)
        if resp.status_code == 200:
            console.print("[bold green]✅ 服务端连接正常！[/bold green]", resp.json())
        else:
            console.print(f"[bold red]❌ 服务端异常，状态码: {resp.status_code}[/bold red]")
    except Exception as e:
        console.print(f"[bold red]❌ 无法连接到服务端: {str(e)}[/bold red]")

@app.command()
def run(query: str):
    """向 Agent 发送指令并由本地接管执行"""
    console.print(f"[cyan]用户指令:[/cyan] {query}")
    console.print("[yellow]客户端已就绪，等待联调服务端决策。[/yellow]")

if __name__ == "__main__":
    app()
EOF

touch gym_agent_client/src/gym_client/__init__.py
touch gym_agent_client/tests/__init__.py

# ----------------------------------------------------
# 4. 全局 .gitignore 与 README.md
# ----------------------------------------------------
cat <<'EOF' > .gitignore
.venv/
venv/
__pycache__/
*.py[cod]
.pytest_cache/
.ruff_cache/
dist/
build/
*.egg-info/
.env
.env.local
.idea/
.vscode/
EOF

cat <<'EOF' > README.md
# Gym-Agent

物理隔离的双子工程：
- `gym_agent_server/`: 后端服务（大脑）
- `gym_agent_client/`: 终端 CLI 客户端（手脚）
EOF

echo "✅ 独立双工程结构初始化完毕！"
