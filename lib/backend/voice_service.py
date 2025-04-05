from fastapi import FastAPI, UploadFile, File
from fastapi.responses import FileResponse
import vosk
import json
import wave
from gtts import gTTS
import os

app = FastAPI()

# Load Vosk model
MODEL_PATH = "backend/vosk_model"
model = vosk.Model(MODEL_PATH)

@app.post("/recognize_speech/")
async def recognize_speech(audio: UploadFile = File(...)):
    with wave.open(audio.file, "rb") as wf:
        rec = vosk.KaldiRecognizer(model, wf.getframerate())
        while True:
            data = wf.readframes(4000)
            if len(data) == 0:
                break
            rec.AcceptWaveform(data)
        result = json.loads(rec.Result())

    return {"recognized_text": result.get("text", "")}

@app.post("/text_to_speech/")
async def text_to_speech(text: str):
    tts = gTTS(text)
    file_path = "output.mp3"
    tts.save(file_path)
    return FileResponse(file_path, media_type="audio/mpeg", filename="output.mp3")
