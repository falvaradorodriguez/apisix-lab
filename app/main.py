from fastapi import FastAPI, Request

app = FastAPI()


@app.get("/hello")
def read_root(request: Request):
    print("Request Headers:", request.headers)
    return {"Hello": "World"}


