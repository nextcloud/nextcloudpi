# syntax=docker/dockerfile:1
FROM python:alpine3.15 AS python
RUN pip install --no-cache flask flask-executor flask_shell2http; apk add --no-cache bash
COPY app.py /app.py
CMD ["python","/app.py"]
