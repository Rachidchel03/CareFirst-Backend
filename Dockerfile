# ⚙️ Stap 1: Gebruik een lichte basis die Python ondersteunt
FROM python:3.10-slim

# 📁 Maak werkmap aan
WORKDIR /app

# 🚀 Zet alle bestanden van je backend project in de container
COPY . .

# 📦 Systeem dependencies voor Chrome & Selenium
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    gnupg \
    ca-certificates \
    fonts-liberation \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libgdk-pixbuf2.0-0 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    xdg-utils \
    libu2f-udev \
    libvulkan1 \
    libxss1 \
    libasound2 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# 🧊 Chrome installeren (stabiele release)
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get install -y ./google-chrome-stable_current_amd64.deb && \
    rm google-chrome-stable_current_amd64.deb

# 🧊 ChromeDriver installeren (versie moet matchen met Chrome)
ENV CHROMEDRIVER_VERSION=124.0.6367.91

RUN wget -O /tmp/chromedriver.zip "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip" && \
    unzip /tmp/chromedriver.zip -d /usr/local/bin/ && \
    rm /tmp/chromedriver.zip && \
    chmod +x /usr/local/bin/chromedriver

# 🐍 Python dependencies installeren
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 🌐 Zet de poort variabel voor Render
ENV PORT=10000

# 🏃 Start FastAPI app met Uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "10000"]
