FROM python:3.11-slim

WORKDIR /app

RUN pip install poetry

COPY pyproject.toml poetry.lock poetry.toml ./

RUN poetry config virtualenvs.create false \
    && poetry install --only main  --no-interaction --no-ansi

COPY prima-tech-challenge/ .

EXPOSE 5000

CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]