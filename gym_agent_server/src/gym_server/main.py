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
