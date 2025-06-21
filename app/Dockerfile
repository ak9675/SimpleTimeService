#Dockerfile
# Use a lightweight official Python Debian based image as the base significantly reducing image size
FROM python:3.9-slim-buster

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements.txt file first.
COPY requirements.txt .

# Install any Python dependencies specified in requirements.txt.
RUN pip install --no-cache-dir -r requirements.txt

# Create a non-root user and group named 'pythonuser'.
RUN addgroup --system pythonuser && adduser --system --ingroup pythonuser pythonuser

# Switch to the newly created non-root user.
USER pythonuser

# Copy the Python application code into the container.
COPY app.py .

# Expose the port that the Flask application will listen on.
EXPOSE 8080

# Define the command to run the application when the container starts.
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app", "--workers", "4"]
# the 'gunicorn' WSGI HTTP Server to serve the Flask application, which is more robust for production than Flask's built-in server.
# '--bind 0.0.0.0:8080' tells gunicorn to listen on all network interfaces on port 8080.
# 'app:app' refers to the 'app' Flask application instance found in 'app.py'.
# '--workers 4' specifies 4 worker processes for handling requests, which is a good default.
