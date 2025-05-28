FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install Chromium + its driver in one go
RUN apt-get update && apt-get install -y \
      chromium \
      chromium-driver \
      wget \
      unzip \
      # plus any libs you need for headless
      libnss3 libgconf-2-4 libxi6 libatk1.0-0 \
      libcairo2 libdbus-1-3 libgtk-3-0 libxss1 \
      fonts-liberation libappindicator3-1 libxtst6 \
    && rm -rf /var/lib/apt/lists/*

# Now chromium and chromedriver are on PATH as `chromium` / `chromedriver`.

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

ENV PORT=10000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "10000"]