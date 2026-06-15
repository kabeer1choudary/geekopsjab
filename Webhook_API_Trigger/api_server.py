import subprocess
import sys
import logging
from fastapi import FastAPI, BackgroundTasks, HTTPException, Request

# 1. Configure Logging to a File
logging.basicConfig(
    filename="api_server.log",
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)

app = FastAPI()

def run_local_script(script_name: str, payload: dict):
    """
    Worker function to execute the local script and log its output.
    """
    logging.info(f"Triggering script '{script_name}' with payload: {payload}")
    try:
        # Execute the script
        result = subprocess.run(
            [sys.executable, script_name, str(payload)],
            capture_output=True,
            text=True,
            check=True
        )
        # Log successful execution and stdout
        logging.info(f"Successfully executed {script_name}")
        if result.stdout.strip():
            logging.info(f"[{script_name} STDOUT]:\n{result.stdout.strip()}")
            
    except subprocess.CalledProcessError as e:
        # Log failures and stderr
        logging.error(f"Failed to execute {script_name}. Return code: {e.returncode}")
        if e.stderr.strip():
            logging.error(f"[{script_name} STDERR]:\n{e.stderr.strip()}")
    except Exception as ex:
        logging.error(f"Unexpected error running {script_name}: {str(ex)}")

@app.post("/webhook")
async def receive_webhook(request: Request, background_tasks: BackgroundTasks):
    try:
        payload = await request.json()
    except Exception:
        logging.warning("Received a request with invalid JSON payload.")
        raise HTTPException(status_code=400, detail="Invalid JSON payload")

    event_type = payload.get("event")
    logging.info(f"Received webhook event: '{event_type}'")
    
    # Simple routing logic based on the event type
    if event_type == "deploy":
        script_to_run = "deploy_app.py"
    elif event_type == "backup":
        script_to_run = "run_backup.py"
    else:
        logging.warning(f"Unsupported event type received: '{event_type}'")
        raise HTTPException(status_code=400, detail="Unknown event trigger")

    # Dispatch to background worker
    background_tasks.add_task(run_local_script, script_to_run, payload)

    return {"status": "accepted", "message": f"Script {script_to_run} dispatched."}