FROM python:3.12.2-bookworm
COPY . /src
RUN pip install -r /src/requirements.txt
WORKDIR /src
RUN chown -R 1001 /src
USER 1001
ENTRYPOINT ["flask", "--app", "instalink", "run" , "--host", "0.0.0.0"]