from pydantic import BaseModel, Field, EmailStr
from typing import List, Optional
from datetime import datetime
from enum import Enum

class PaymentStatus(str, Enum):
    RECEIVED = "received"
    PROCESSING = "processing"
    PENDING_VERIFICATION = "pending_verification"
    VERIFIED = "verified"
    REJECTED = "rejected"
    INVOICE_SENT = "invoice_sent"

# --- Customer Models ---
class CustomerBase(BaseModel):
    name: str
    phone: str
    email: Optional[EmailStr] = None
    address: Optional[str] = None

class CustomerCreate(CustomerBase):
    pass

class Customer(CustomerBase):
    id: str = Field(alias="_id")
    created_at: datetime = Field(default_factory=datetime.utcnow)

# --- Product Models ---
class ProductBase(BaseModel):
    name: str
    price: float
    gst_percent: float = 18.0
    hsn_code: str

class ProductCreate(ProductBase):
    pass

class Product(ProductBase):
    id: str = Field(alias="_id")

# --- Payment Models ---
class PaymentBase(BaseModel):
    phone: str
    amount: float
    utr: str
    screenshot_url: str
    status: PaymentStatus = PaymentStatus.RECEIVED

class PaymentCreate(PaymentBase):
    pass

class Payment(PaymentBase):
    id: str = Field(alias="_id")
    customer_id: Optional[str] = None
    ocr_confidence: float = 0.0
    created_at: datetime = Field(default_factory=datetime.utcnow)

# --- Invoice Models ---
class InvoiceItem(BaseModel):
    product_name: str
    quantity: int
    unit_price: float
    gst_amount: float
    total: float

class InvoiceCreate(BaseModel):
    customer_id: str
    payment_id: str
    items: List[InvoiceItem]
    subtotal: float
    gst_total: float
    grand_total: float

class Invoice(InvoiceCreate):
    id: str = Field(alias="_id")
    pdf_url: str
    date: datetime = Field(default_factory=datetime.utcnow)
