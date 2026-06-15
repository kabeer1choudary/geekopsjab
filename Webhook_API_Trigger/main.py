import os
import subprocess
import asyncio
from fastapi import FastAPI, Depends, HTTPException, BackgroundTasks
from config import SCRIPTS_DIR, logger
from security import verify_webhook_signature

app = FastAPI(title="DevOps Webhook Runner", version="1.0.0")

def execute_script(script_path: str):
    """Executes the script and logs output."""
    logger.info(f"Starting execution of: {script_path}")
    try:
        # Run the script and capture output safely
        result = subprocess.run(
            [script_path],
            capture_output=True,
            text=True,
            check=True
        )
        logger.info(f"Script successfully executed [{script_path}]. Output:\n{result.stdout}")
    except subprocess.CalledProcessError as e:
        logger.error(f"Script failed [{script_path}] with exit code {e.returncode}. Error:\n{e.stderr}")
    except Exception as e:
        logger.error(f"Unexpected error executing {script_path}: {str(e)}")

@app.post("/trigger/{script_name}", dependencies=[Depends(verify_webhook_signature)])
async def trigger_webhook(script_name: str, background_tasks: BackgroundTasks):
    # 1. Prevent Directory Traversal Attacks (e.g., script_name="../../etc/passwd")
    sanitized_name = os.path.basename(script_name)
    script_path = os.path.join(SCRIPTS_DIR, sanitized_name)
    
    # 2. Validate script existence and executability
    if not os.path.exists(script_path):
        logger.error(f"Target script not found: {script_path}")
        raise HTTPException(status_code=404, detail="Script not found.")
        
    if not os.access(script_path, os.X_OK):
        logger.error(f"Target script is not executable: {script_path}")
        raise HTTPException(status_code=500, detail="Script is not executable.")

    # 3. Offload execution to a background task so the webhook provider doesn't timeout
    background_tasks.add_task(execute_script, script_path)
    
    logger.info(f"Webhook accepted. Queued background task for: {sanitized_name}")
    return {"status": "accepted", "message": f"Script {sanitized_name} queued for execution."}