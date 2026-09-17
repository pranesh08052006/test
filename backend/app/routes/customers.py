from fastapi import APIRouter
from app.models.schemas import Customer, CustomerCreate
from app.database import get_collection
from bson import ObjectId

router = APIRouter(prefix="/customers", tags=["customers"])

@router.post("/", response_model=Customer)
async def create_customer(customer: CustomerCreate):
    coll = get_collection("customers")
    new_doc = customer.dict()
    result = await coll.insert_one(new_doc)
    new_doc["_id"] = str(result.inserted_id)
    return new_doc

@router.get("/{phone}", response_model=Customer)
async def get_customer(phone: str):
    coll = get_collection("customers")
    doc = await coll.find_one({"phone": phone})
    if doc:
        doc["_id"] = str(doc["_id"])
        return doc
    return None
