# --- Etapa de compilación ---
FROM gcc:13-bookworm AS builder
WORKDIR /app
COPY reducer.c .
RUN gcc -O2 -Wall -o reducer reducer.c

# --- Imagen final con sh (necesario para docker-compose) ---
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /app/reducer .
ENTRYPOINT ["./reducer"]
