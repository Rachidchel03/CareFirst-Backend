FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install Chrome and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg wget curl unzip \
    fonts-liberation libatk-bridge2.0-0 libgtk-3-0 \
    libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 \
    libxext6 libxi6 libxtst6 libnss3 libnspr4 libxss1 libasound2 \
    && wget -q -O /etc/apt/trusted.gpg.d/google.gpg https://dl.google.com/linux/linux_signing_key.pub \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list \
    && apt-get update && apt-get install -y --no-install-recommends google-chrome-stable \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Download matching ChromeDriver
RUN CHROME_VERSION=$(google-chrome --product-version | cut -d '.' -f 1-3) && \
    DRIVER_VERSION=$(curl -s "https://googlechromelabs.github.io/chrome-for-testing/LATEST_RELEASE_${CHROME_VERSION}") && \
    wget -q -O /tmp/chromedriver.zip "https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/${DRIVER_VERSION}/linux64/chromedriver-linux64.zip" && \
    unzip /tmp/chromedriver.zip -d /usr/local/bin/ && rm /tmp/chromedriver.zip

# Set work directory
WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port (optional)
EXPOSE 10000

# Launch the FastAPI app with Uvicorn
CMD uvicorn main:app --host 0.0.0.0 --port $PORT
