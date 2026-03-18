from fastapi import FastAPI

app = FastAPI()

@app.get('/')
def root():
    return {'message':'fastapi PGL Astana 2026 site is started!'}

