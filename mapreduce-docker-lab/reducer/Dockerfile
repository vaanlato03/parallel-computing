# --- Etapa de compilación ---
FROM gcc:13-bookworm AS builder
WORKDIR /app
COPY reducer.c .
RUN gcc -O2 -Wall -o reducer reducer.c

# --- Imagen final mínima ---
FROM debian:bookworm-slim
WORKDIR /app
COPY --from=builder /app/reducer .
ENTRYPOINT ["./reducer"]
