from fastapi import APIRouter, Request, BackgroundTasks, HTTPException
import logging

router = APIRouter(prefix="/webhook", tags=["whatsapp"])

# Verify Token for Meta
WHATSAPP_VERIFY_TOKEN = "ZEAL_SECRET_TOKEN"

@router.get("/whatsapp")
async def verify_webhook(request: Request):
    params = request.query_params
    if params.get("hub.mode") == "subscribe" and params.get("hub.verify_token") == WHATSAPP_VERIFY_TOKEN:
        return int(params.get("hub.challenge"))
    raise HTTPException(status_code=403, detail="Verification failed")

@router.post("/whatsapp")
async def handle_message(request: Request, background_tasks: BackgroundTasks):
    data = await request.json()
    
    # Extract message details (Simplified)
    # real production logic would parse the nested 'entry' and 'changes' list
    try:
        entry = data.get("entry", [])[0]
        changes = entry.get("changes", [])[0]
        value = changes.get("value", {})
        messages = value.get("messages", [])
        
        if messages:
            msg = messages[0]
            if msg.get("type") == "image":
                background_tasks.add_task(process_payment_image, msg)
                return {"status": "processing"}
                
    except Exception as e:
        logging.error(f"Error parsing WhatsApp webhook: {e}")
        
    return {"status": "ignored"}

async def process_payment_image(message_data: dict):
    # 1. Get Image ID
    image_id = message_data["image"]["id"]
    # 2. Download from WhatsApp Cloud API
    # 3. Trigger OCR
    # 4. Save to MongoDB as 'RECEIVED'
    print(f"Began processing image {image_id} in background...")
    pass
