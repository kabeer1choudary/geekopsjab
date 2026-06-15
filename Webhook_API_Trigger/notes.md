## Architecture

When an external service fires a webhook, API server needs to:
- Receive the HTTP POST request.
- Validate that the request is legitimate.
- Trigger the local script in the background so the external service gets a fast 200 OK response.

## Setting Up Environment
- Create a virtual python environment
``` 
python -m venv api_server 
```
- Source the virtual environment
``` source api_server/bin/activate ```
- Install FastAPI and Uvicorn.
``` pip install fastapi uvicorn ```

## Running and Testing Locally
- Start the server
- Simulate the webhook trigger
- Verify the result

## Going to Production: Best Practices
- Security (Authentication): Real webhooks should use HTTPS and sign their payloads using a secret key through header. Always verify this signature in your code before running any scripts to ensure a malicious user isn't triggering your scripts.

- Exposing Localhost: To test actual external webhooks on your local machine, use a tool like ngrok (ngrok http 8000) to create a secure public URL that routes to your local FastAPI server.

- Process Management: In production, do not run Uvicorn manually. Use a process manager like Gunicorn or PM2, or wrap your FastAPI app inside a Docker container.