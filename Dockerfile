FROM python:3.9.19-slim
WORKDIR /app

RUN apt-get update && \
    apt-get install -y netcat-openbsd && \
    apt-get install -y rsync && \
    apt-get install -y python3-dev libpq-dev gcc

COPY project/requirements.txt /app
RUN pip install -r requirements.txt

COPY project /app
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/manage.py && \
    chmod +x /app/entrypoint.sh

EXPOSE ${BIND_PORT}

ENTRYPOINT ["bash", "/app/entrypoint.sh"]