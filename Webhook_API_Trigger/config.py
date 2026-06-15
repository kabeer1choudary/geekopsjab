import os
import logging
from dotenv import load_dotenv

load_dotenv()

# Security Configuration
WEBHOOK_SECRET = os.getenv("WEBHOOK_SECRET")
if not WEBHOOK_SECRET:
    raise ValueError("CRITICAL: WEBHOOK_SECRET environment variable is not set!")

SCRIPTS_DIR = os.getenv("SCRIPTS_DIR", "./scripts")

# Core Logging Configuration
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler("api_server.log")
    ]
)
logger = logging.getLogger("webhook_runner")