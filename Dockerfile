# Use Python 3.10 slim (Debian-based) as base image
FROM python:3.10-slim

# Prevent prompts during apt installs
ENV DEBIAN_FRONTEND=noninteractive 

# Install Chromium, Chromedriver, and related deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    chromium-driver \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables to help Selenium find Chrome
ENV CHROME_BIN="/usr/bin/chromium" 
ENV CHROMEDRIVER_PATH="/usr/bin/chromedriver"

# Symlink the Chrome binary to a name expected by Selenium (if needed)
RUN ln -s /usr/bin/chromium /usr/bin/google-chrome

# Set working directory and copy application code
WORKDIR /app
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose port (optional, for documentation - Render will detect the port)
EXPOSE 8000

# Command to run the FastAPI app with Uvicorn, using $PORT from environment
CMD uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}
