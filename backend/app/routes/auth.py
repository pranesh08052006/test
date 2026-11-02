from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, EmailStr
from app.database import get_collection
from datetime import datetime
import hashlib
import traceback

router = APIRouter(prefix="/auth", tags=["auth"])

class UserAuth(BaseModel):
    email: EmailStr
    password: str

def get_password_hash(password: str):
    # Using SHA-256 for maximum compatibility on this system
    return hashlib.sha256(password.encode()).hexdigest()

@router.post("/register")
async def register(user: UserAuth):
    try:
        print(f"DEBUG: Register attempt: {user.email}")
        coll = get_collection("users")
        
        existing_user = await coll.find_one({"email": user.email})
        if existing_user:
            print(f"DEBUG: Register FAILED - User exists")
            raise HTTPException(status_code=400, detail="User already exists")
        
        hashed_password = get_password_hash(user.password)
        
        new_user = {
            "email": user.email,
            "hashed_password": hashed_password,
            "created_at": datetime.utcnow()
        }
        
        result = await coll.insert_one(new_user)
        print(f"DEBUG: SUCCESS - User {user.email} created")
        return {"message": "User registered successfully", "user_id": str(result.inserted_id)}
    except Exception as e:
        print(f"CRITICAL ERROR: {str(e)}")
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/login")
async def login(user: UserAuth):
    try:
        print(f"DEBUG: Login attempt: {user.email}")
        coll = get_collection("users")
        db_user = await coll.find_one({"email": user.email})
        
        if not db_user:
            raise HTTPException(status_code=400, detail="Invalid credentials")
            
        input_hash = get_password_hash(user.password)
        if input_hash != db_user["hashed_password"]:
            raise HTTPException(status_code=400, detail="Invalid credentials")
        
        print(f"DEBUG: SUCCESS - Login for {user.email}")
        return {"message": "Login successful", "email": user.email}
    except Exception as e:
        if isinstance(e, HTTPException): raise e
        print(f"CRITICAL ERROR: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
AUTH_TOKEN="EREGRHFDSERD42355678OYGGDSFDEF"