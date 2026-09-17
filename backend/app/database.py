from motor.motor_asyncio import AsyncIOMotorClient
import os

MONGO_URL = os.getenv("MONGO_URL", "mongodb://localhost:27017")
DB_NAME = "zeal_automation"

class Database:
    client: AsyncIOMotorClient = None
    db = None

    @classmethod
    async def connect_db(cls):
        cls.client = AsyncIOMotorClient(MONGO_URL)
        cls.db = cls.client[DB_NAME]
        print(f"Connected to MongoDB at {MONGO_URL}")

    @classmethod
    async def close_db(cls):
        if cls.client:
            cls.client.close()
            print("Closed MongoDB connection")

db = Database()

def get_collection(name: str):
    return db.db[name]
