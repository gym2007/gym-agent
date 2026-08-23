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
