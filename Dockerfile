# Origem Leads: dedicated Chromium worker for Railway
FROM python:3.12-slim
RUN apt-get update \
 && apt-get install -y --no-install-recommends chromium \
 && rm -rf /var/lib/apt/lists/* \
 && useradd --create-home --uid 10001 gmskit
WORKDIR /kit
COPY engine/ engine/
RUN mkdir -p .engine/data && chown -R gmskit:gmskit .engine
# Railway seccomp prevents Chromium's user namespace sandbox in this worker.
# Restrict network access to the private gateway; do not publish this service.
RUN printf '#!/bin/sh\nexec /usr/bin/chromium --no-sandbox "$@"\n' > /usr/local/bin/origem-chromium \
 && chmod 755 /usr/local/bin/origem-chromium
USER gmskit
ENV CHROME=/usr/local/bin/origem-chromium PYTHONUNBUFFERED=1
EXPOSE 8080
CMD ["python", "engine/serve.py", "--host", "0.0.0.0", "--port", "8080"]
