# 1) Base image
FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive

# 2) Install prerequisites
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      wget \
      xvfb \
      unzip \
      gnupg \
      ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# 3) Add Google Chrome’s repo & install Chrome
RUN wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub \
     | apt-key add - \
 && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" \
     > /etc/apt/sources.list.d/google-chrome.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends google-chrome-stable \
 && rm -rf /var/lib/apt/lists/*

# 4) Auto-detect Chrome’s version and install matching Chromedriver
RUN CHROME_VER="$(google-chrome-stable --version \
                  | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')" \
 && CHROME_MAJOR="$(echo $CHROME_VER | cut -d. -f1)" \
 && DRIVER_VER="$(wget -qO- \
      https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_MAJOR})" \
 && wget -qO /tmp/chromedriver.zip \
      "https://chromedriver.storage.googleapis.com/${DRIVER_VER}/chromedriver_linux64.zip" \
 && unzip /tmp/chromedriver.zip -d /usr/local/bin/ \
 && chmod +x /usr/local/bin/chromedriver \
 && rm /tmp/chromedriver.zip

# 5) Install Python dependencies
WORKDIR /app
COPY requirements.txt .
RUN pip install --upgrade pip \
 && pip install --no-cache-dir -r requirements.txt

# 6) Copy application code
COPY . .

# 7) Let Render inject the port
ENV PORT=10000

# 8) Start the app on $PORT (wrapped in xvfb-run for safety)
CMD ["sh", "-c", "xvfb-run -s '-screen 0 1920x1080x24' uvicorn main:app --host 0.0.0.0 --port $PORT"]
