## Architecture

When an external service fires a webhook, API server needs to:
- Receive the HTTP POST request.
- Validate that the request is legitimate.
- Trigger the local script in the background so the external service gets a fast 200 OK response.

## Setting Up Environment

Install FastAPI and Uvicorn.