import hmac
import hashlib
from fastapi import Request, HTTPException, Security
from fastapi.security.api_key import APIKeyHeader
from config import WEBHOOK_SECRET, logger

# We look for the signature in this header (Standard for GitHub/GitLab style hooks)
X_SIGNATURE_HEADER = APIKeyHeader(name="X-Hub-Signature-256", auto_error=False)

async def verify_webhook_signature(request: Request, signature: str = Security(X_SIGNATURE_HEADER)):
    if not signature:
        logger.warning("Unauthenticated request attempt: Missing signature header.")
        raise HTTPException(status_code=401, detail="Missing signature header.")
    
    # Read raw body for HMAC calculation
    body = await request.body()
    
    # Expected signature format is usually 'sha256=hex_digest'
    if signature.startswith("sha256="):
        signature = signature.split("sha256=")[1]

    # Compute HMAC hex digest using our local secret
    computed_signature = hmac.new(
        WEBHOOK_SECRET.encode('utf-8'),
        body,
        hashlib.sha256
    ).hexdigest()

    # Use constant-time comparison to prevent timing attacks
    if not hmac.compare_digest(computed_signature, signature):
        logger.warning(f"Unauthorized request attempt: Signature mismatch from IP {request.client.host}")
        raise HTTPException(status_code=403, detail="Invalid signature.")
        
    return True