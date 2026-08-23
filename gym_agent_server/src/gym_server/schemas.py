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
