# app.py
from flask import Flask, request, jsonify
import datetime
import os

app = Flask(__name__)

# Define the port to listen on. Using 8080 as it's a common non-privileged port.
PORT = int(os.environ.get("PORT", 8080))

@app.route('/')
def get_time_and_ip():
    """
    Returns a response in JSON format containing the current timestamp and the IP address of the visitor.
    """
    # Get current timestamp in ISO format
    current_time = datetime.datetime.now(datetime.timezone.utc).isoformat() + "Z"

    # Attempt to get the client's real IP address
    # X-Forwarded-For is common when behind a proxy/load balancer
    # Fallback to remote_addr if X-Forwarded-For is not available
    visitor_ip = request.headers.get('X-Forwarded-For', request.remote_addr)

    response_data = {
        "timestamp": current_time,
        "ip": visitor_ip
    }

    return jsonify(response_data)

if __name__ == '__main__':
    # Run the Flask application
    # host='0.0.0.0' makes the server accessible from any IP address (essential for Docker)
    # port=PORT uses the defined port or default 8080
    app.run(host='0.0.0.0', port=PORT)

