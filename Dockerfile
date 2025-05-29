# ──────────────────────────────────────────────────────────────────────────────
# 1. Base image
FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive

# 2. Install prerequisites (wget for fetching, xvfb for a virtual framebuffer if you need it,
#    unzip for extracting Chromedriver, gnupg/ca-certificates to add the Chrome PPA)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      wget \
      xvfb \
      unzip \
      gnupg \
      ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# 3. Add Google’s Chrome signing key & repo, then install chrome
RUN wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub \
     | apt-key add - \
 && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" \
     > /etc/apt/sources.list.d/google-chrome.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends google-chrome-stable \
 && rm -rf /var/lib/apt/lists/*

# 4. Download & install the matching Chromedriver
#    (pin the version to match your Chrome release; bump this ARG when you update Chrome)
ARG CHROMEDRIVER_VERSION=115.0.5790.102
RUN wget -qO /tmp/chromedriver.zip \
      "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip" \
 && unzip /tmp/chromedriver.zip -d /usr/local/bin/ \
 && chmod +x /usr/local/bin/chromedriver \
 && rm /tmp/chromedriver.zip

# 5. Set your app directory, install Python deps
WORKDIR /app
COPY requirements.txt .
RUN pip install --upgrade pip \
 && pip install --no-cache-dir -r requirements.txt

# 6. Copy the rest of your code
COPY . .

# 7. Let Render tell us the port at runtime
ENV PORT=10000

# 8. Launch under Uvicorn, wrapped in xvfb-run (optional) so $PORT expands properly
CMD ["sh", "-c", "xvfb-run -s '-screen 0 1920x1080x24' uvicorn main:app --host 0.0.0.0 --port 10000"]
# ──────────────────────────────────────────────────────────────────────────────
