FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install Chromium + libraries (no chromedriver; we install that in Python at runtime)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      chromium \
      wget \
      unzip \
      libnss3 libgconf-2-4 libxi6 libatk1.0-0 \
      libcairo2 libdbus-1-3 libgtk-3-0 libxss1 \
      fonts-liberation libappindicator3-1 libxtst6 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python deps (including selenium, chromedriver-autoinstaller, uvicorn, etc.)
COPY requirements.txt .
RUN pip install --upgrade pip \
 && pip install --no-cache-dir -r requirements.txt

# Copy your code
COPY . .

# Let Render tell us the port at runtime
ENV PORT=10000

# Start with shell form so $PORT gets expanded
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port $PORT"]
