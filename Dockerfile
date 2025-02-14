FROM python:3.12-slim
ARG APP_HOME=/app
WORKDIR ${APP_HOME}
COPY requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 8000 
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]