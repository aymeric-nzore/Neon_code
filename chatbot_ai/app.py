from fastapi import FastAPI
from pydantic import BaseModel

from chat import chat

app = FastAPI()


class ChatRequest(BaseModel):
    message: str


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