# --- Etapa de compilación ---
FROM gcc:13-bookworm AS builder
WORKDIR /app
COPY mapper.c .
RUN gcc -O2 -Wall -o mapper mapper.c

# --- Imagen final con sh (necesario para docker-compose) ---
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /app/mapper .
ENTRYPOINT ["./mapper"]
