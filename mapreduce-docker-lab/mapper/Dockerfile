# --- Etapa de compilación ---
FROM gcc:13-bookworm AS builder
WORKDIR /app
COPY mapper.c .
RUN gcc -O2 -Wall -o mapper mapper.c

# --- Imagen final mínima ---
FROM debian:bookworm-slim
WORKDIR /app
COPY --from=builder /app/mapper .
ENTRYPOINT ["./mapper"]
