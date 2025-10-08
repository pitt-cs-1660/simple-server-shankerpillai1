
FROM python:3.12 AS builder

# Install uv (modern Python package manager)
RUN pip install --no-cache-dir uv
RUN pip install pytest

# Set working directory
WORKDIR /app

# Copy dependency configuration
COPY pyproject.toml .

# Create and install dependencies into a virtual environment using uv
RUN uv venv /app/venv \
    && . /app/venv/bin/activate \
    && uv pip install -r pyproject.toml

FROM python:3.12-slim AS final

# Set working directory
WORKDIR /app

# Copy the virtual environment from the build stage
COPY --from=builder /app/venv /app/venv

# Copy application source code
COPY . .

RUN chmod -R 777 /app

# Create a non-root user for security
RUN useradd -m appuser
USER appuser

# Expose FastAPI port
EXPOSE 8000

# Set the default command to run the FastAPI app
# (assuming main.py has an app instance named "app")
CMD ["/app/venv/bin/python", "-m", "uvicorn", "cc_simple_server.server:app", "--host", "0.0.0.0", "--port", "8000"]
