FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies for Selenium & Chrome
RUN apt-get update && apt-get install -y \
    curl unzip gnupg wget \
    chromium chromium-driver \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory to root of the repo
WORKDIR /

# Copy entire repo content
COPY . .

# Install Python dependencies
RUN pip install --upgrade pip && pip install -r requirements.txt

# Expose dynamic port (Render sets PORT env var)
EXPOSE 8000

# Run FastAPI with dynamic port
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port $PORT"]
