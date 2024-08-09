FROM python:3.10-slim-buster

RUN apt update -y && \
    apt install -y build-essential libpq-dev && \
    pip install --upgrade pip setuptools wheel

WORKDIR /usr/src/app

COPY ./analytics .

RUN pip install -r requirements.txt

EXPOSE 5153

CMD python app.py