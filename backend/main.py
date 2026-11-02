from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel, EmailStr
from motor.motor_asyncio import AsyncIOMotorClient
from passlib.context import CryptContext
import os

app = FastAPI()

# API Key Configuration
API_TOKEN = 'XXXX_REDACTED_XXXX'

# MongoDB Configuration
MONGO_DETAILS = os.getenv("MONGO_URL", "mongodb://localhost:27017")
client = AsyncIOMotorClient(MONGO_DETAILS)
database = client.zeal_db
user_collection = database.get_collection("users")

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserCreate(BaseModel):
    email: EmailStr
    password: str

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

@app.post("/login")
async def login(user: UserLogin):
    db_user = await user_collection.find_one({"email": user.email})
    if not db_user:
        raise HTTPException(status_code=400, detail="Incorrect email or password")
    
    if not verify_password(user.password, db_user["hashed_password"]):
        raise HTTPException(status_code=400, detail="Incorrect email or password")
    
    return {"message": "Login successful", "email": user.email}

@app.post("/register")
async def register(user: UserCreate):
    existing_user = await user_collection.find_one({"email": user.email})
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    hashed_password = get_password_hash(user.password)
    new_user = await user_collection.insert_one({
        "email": user.email,
        "hashed_password": hashed_password
    })
    return {"message": "User created successfully"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
