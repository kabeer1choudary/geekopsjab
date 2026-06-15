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
``` 
source api_server/bin/activate 
```
- Install FastAPI and Uvicorn.
``` 
pip install fastapi uvicorn 
```

## Running and Testing Locally
- Start the server
```
uvicorn server:app --reload --port 8000
```
- Simulate the webhook trigger
```
curl -X POST "http://127.0.0.1:8000/webhook" \
     -H "Content-Type: application/json" \
     -d '{"event": "deploy", "repo": "my-project", "author": "dev_user"}'

curl -X POST "http://127.0.0.1:8000/webhook" \
     -H "Content-Type: application/json" \
     -d '{"event": "backup", "repo": "my-project", "author": "dev_user"}'
```
- Verify the result
```
{"status":"accepted","message":"Script deploy_app.py triggered in background."}
```

## Running in Background
- Create a new service file
```
sudo nano /etc/systemd/system/api_server.service
```
- Add following configuration (ini)
```
[Unit]
Description=FastAPI Webhook Receiver Server
After=network.target

[Service]
User=$USER
WorkingDirectory=$HOME
ExecStart=/path/to/your/venv/bin/uvicorn api_server:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
```
- Start and enable the service
```
sudo systemctl daemon-reload
sudo systemctl start api_server
sudo systemctl enable api_server
```
- Check the status to ensure it is active
```
sudo systemctl status api_server
```
- Monitor the logs
```
tail -f api_server.log
```
## Going to Production: Best Practices
- Security (Authentication): Real webhooks should use HTTPS and sign their payloads using a secret key through header. Always verify this signature in your code before running any scripts to ensure a malicious user is not triggering your scripts.

- Exposing Localhost: To test actual external webhooks on your local machine, use a tool like ngrok (ngrok http 8000) to create a secure public URL that routes to your local FastAPI server.

- Process Management: In production, do not run Uvicorn manually. Use a process manager like Gunicorn or PM2, or wrap your FastAPI app inside a Docker container.