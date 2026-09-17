from fastapi import APIRouter
from app.models.schemas import Product, ProductCreate
from app.database import get_collection

router = APIRouter(prefix="/products", tags=["products"])

@router.post("/", response_model=Product)
async def add_product(product: ProductCreate):
    coll = get_collection("products")
    doc = product.dict()
    result = await coll.insert_one(doc)
    doc["_id"] = str(result.inserted_id)
    return doc

@router.get("/")
async def list_products():
    coll = get_collection("products")
    cursor = coll.find()
    results = []
    async for doc in cursor:
        doc["_id"] = str(doc["_id"])
        results.append(doc)
    return results
