from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from typing import Dict
from profile_service import update_profile

app = FastAPI()
active_users: Dict[str, WebSocket] = {}

@app.websocket("/ws/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: str):
    await websocket.accept()
    active_users[user_id] = websocket  
    print(f"User {user_id} connected")

    try:
        while True:
            data = await websocket.receive_text()
            print(f"Message from {user_id}: {data}")

            message = eval(data)  # Convert text to dictionary
            if message["type"] == "call":
                to_user = message["to"]
                if to_user in active_users:
                    await active_users[to_user].send_text(f"Incoming call from {user_id}")
                else:
                    await websocket.send_text("User not online")
    except WebSocketDisconnect:
        print(f"User {user_id} disconnected")
        active_users.pop(user_id, None)

@app.post("/update_profile")
async def update_user_profile(data: dict):
    user_id = data.get("user_id")
    name = data.get("name")

    return update_profile(user_id, name)
