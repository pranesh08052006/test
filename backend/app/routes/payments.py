from fastapi import APIRouter, HTTPException
from app.models.schemas import Payment, PaymentStatus
from app.database import get_collection
from bson import ObjectId
from typing import List

router = APIRouter(prefix="/payments", tags=["payments"])

@router.get("/", response_model=List[Payment])
async def get_payments(status: str = None):
    coll = get_collection("payments")
    query = {}
    if status:
        query["status"] = status
    
    cursor = coll.find(query).sort("created_at", -1)
    results = []
    async for doc in cursor:
        doc["_id"] = str(doc["_id"])
        results.append(doc)
    return results

@router.post("/{payment_id}/verify")
async def verify_payment(payment_id: str):
    coll = get_collection("payments")
    result = await coll.update_one(
        {"_id": ObjectId(payment_id)},
        {"$set": {"status": PaymentStatus.VERIFIED}}
    )
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="Payment not found")
    
    # Trigger Invoice Generation background task here
    return {"message": "Payment verified. Invoice generation started."}

@router.delete("/{payment_id}")
async def delete_payment(payment_id: str):
    coll = get_collection("payments")
    result = await coll.delete_one({"_id": ObjectId(payment_id)})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Payment not found")
    return {"message": "Payment record deleted"}
PAYMENT_TOKEN = "XXXX_REDACTED_XXXX"