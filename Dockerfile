ARG PYTHON_VERSION=3.11.2

# Build application from source.
FROM python:${PYTHON_VERSION}-alpine3.17 as build-stage

WORKDIR /tmp

# Upgrade pip, install pipenv and importlib_metadata
RUN pip install --upgrade pip importlib_metadata pipenv

# Copy Pipfile and Pipfile.lock to /tmp/
COPY ./Pipfile ./Pipfile.lock* /tmp/

# Generate a requirements.txt from Pipfile.lock
RUN pipenv requirements > requirements.txt

# Deploy application to a lean image
FROM python:${PYTHON_VERSION}-alpine3.17

WORKDIR /code

# Default environment (read from .yaml file)
ARG ENVIRONMENT

# Assign default environemnt to an ENV variable
ENV ENVIRONMENT=$ENVIRONMENT

# Prevents Python from writing pyc files.
ENV PYTHONDONTWRITEBYTECODE=1

# Keeps Python from buffering stdout and stderr to avoid situations where
# the application crashes without emitting any logs due to buffering.
ENV PYTHONUNBUFFERED=1

# Create a non-privileged user that the app will run under.
# See https://docs.docker.com/go/dockerfile-user-best-practices/
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

COPY --from=build-stage /tmp/requirements.txt /code/requirements.txt

RUN apk update && apk add musl-dev curl

# Download dependencies as a separate step to take advantage of Docker's caching.
# Leverage a cache mount to /root/.cache/pip to speed up subsequent builds.
# Leverage a bind mount to requirements.txt to avoid having to copy them into
# into this layer.
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m pip install -U pip psycopg2-binary pymysql && \
    python -m pip install -r /code/requirements.txt

# Switch to the non-privileged user to run the application.
USER appuser

# Copy the source code into the container.
COPY . .

# Run the application
ENTRYPOINT /bin/sh /code/entrypoint.sh $ENVIRONMENT