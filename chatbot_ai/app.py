from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from chat import chat

app = FastAPI(
    title="Cacao AI Chatbot API",
    version="1.0.0"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
@app.get("/")
def index():
    return {
        "status": "online"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }

class ChatRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=1000, description="Le message envoyé par l'utilisateur")


@app.post("/chat")
def chatbot(data: ChatRequest):

    response = chat(
        [
            {
                "role": "user",
                "content": data.message,
            }
        ]
    )

    return {
        "response": response,
    }