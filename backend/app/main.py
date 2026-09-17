from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.database import db
from app.routes import whatsapp, payments, customers, products, auth
import uvicorn

app = FastAPI(title="Zeal Business Automation API")

# API Key Configuration
API_TOKEN = 'XXXX_REDACTED_XXXX'

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Startup & Shutdown
@app.on_event("startup")
async def startup_db_client():
    await db.connect_db()

@app.on_event("shutdown")
async def shutdown_db_client():
    await db.close_db()

# Include Routers
app.include_router(auth.router)
app.include_router(whatsapp.router)
app.include_router(payments.router)
app.include_router(customers.router)
app.include_router(products.router)

@app.get("/")
async def root():
    return {"message": "Zeal Automation API is Online"}

if __name__ == "__main__":
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
