# deploy_app.py
import sys

print("Hello from the triggered script!")

# Retrieve the payload passed from the server
if len(sys.argv) > 1:
    payload_received = sys.argv[1]
    print(f"Received payload data: {payload_received}")