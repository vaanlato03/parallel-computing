# MapReduce con contenedores Docker

Laboratorio práctico de computación paralela y distribuida.  
Implementa el modelo **MapReduce** (conteo de palabras) usando contenedores Docker
orquestados desde WSL en Windows 11.

---

## Requisitos

| Herramienta | Versión mínima | Cómo verificar |
|---|---|---|
| Windows 11 | cualquier edición | — |
| Docker Desktop | 4.x | `docker --version` |
| WSL 2 (Ubuntu) | 22.04+ | `wsl --list --verbose` |

Todos los comandos se ejecutan **dentro de WSL**.

---

## Estructura del repositorio

```
mapreduce-docker-lab/
├── mapper/
│   ├── mapper.c               # Mapper base
│   ├── mapper_stopwords.c     # Variante: filtro de stop words
│   ├── mapper_combiner.c      # Variante: combinación local
│   └── Dockerfile
├── reducer/
│   ├── reducer.c              # Reducer base (C)
│   ├── reducer.py             # Variante: reducer en Python
│   ├── Dockerfile
│   └── Dockerfile.python
├── data/
│   └── corpus.txt             # Corpus de texto de prueba
├── docker-compose.yml         # Alternativa declarativa (4 mappers, 2 reducers)
├── split_corpus.sh            # Divide corpus en N chunks
├── shuffle.sh                 # Ordena y particiona salidas de mappers
├── run_pipeline.sh            # Orquesta el pipeline completo
└── benchmark.sh               # Mide speedup para N = 1, 2, 4, 8
```

---

## Ejecución rápida

```bash
# 1. Clonar el repositorio
git clone <url-del-repo>
cd mapreduce-docker-lab

# 2. Construir las imágenes
docker build -t lab-mapper  ./mapper
docker build -t lab-reducer ./reducer

# 3. Ejecutar el pipeline completo (4 mappers, 2 reducers)
bash run_pipeline.sh 4 2

# 4. Ver el resultado
head -20 output/top_words.txt
```

---

## Pipeline paso a paso

### Arquitectura

```
corpus.txt
    │
 [SPLIT]  → N chunks independientes
    │
 [MAP]    → N contenedores en paralelo → pares (palabra, 1)
    │
 [SHUFFLE]→ merge + sort + partición en M grupos
    │
 [REDUCE] → M contenedores en paralelo → (palabra, total)
    │
 [MERGE]  → top_words.txt ordenado por frecuencia
```

### Comandos individuales

```bash
# Dividir corpus en 4 chunks
bash split_corpus.sh 4

# Construir y ejecutar mappers en paralelo (manual)
docker run --rm \
  -v "$(pwd)/data/chunks:/input:ro" \
  -v "$(pwd)/shuffle:/output" \
  lab-mapper sh -c "./mapper < /input/chunk_aa > /output/map_0.txt" &

# ... (repetir para chunk_ab, chunk_ac, chunk_ad)
wait

# Shuffle
bash shuffle.sh 2

# Reducers en paralelo
docker run --rm \
  -v "$(pwd)/shuffle:/data:ro" -v "$(pwd)/output:/output" \
  lab-reducer sh -c "./reducer < /data/part_0.txt > /output/result_0.txt" &

docker run --rm \
  -v "$(pwd)/shuffle:/data:ro" -v "$(pwd)/output:/output" \
  lab-reducer sh -c "./reducer < /data/part_1.txt > /output/result_1.txt" &

wait

# Merge final
cat output/result_*.txt | sort -t$'\t' -k2 -rn > output/top_words.txt
```

---

## Benchmark de speedup

```bash
bash benchmark.sh
```

Mide el tiempo total para N = 1, 2, 4, 8 mappers y calcula el speedup S(N) = T(1)/T(N).

---

## Modificaciones para el laboratorio

### Grupo A — Código

**Stop words** (mapper_stopwords.c):
```bash
# Reemplazar el fuente y reconstruir
cp mapper/mapper_stopwords.c mapper/mapper.c
docker build -t lab-mapper ./mapper
bash run_pipeline.sh 4 2
```

**Combiner local** (mapper_combiner.c):
```bash
cp mapper/mapper_combiner.c mapper/mapper.c
docker build -t lab-mapper ./mapper
bash run_pipeline.sh 4 2
# Comparar tamaño de shuffle/map_*.txt vs versión base
```

### Grupo B — Parámetros

```bash
# Variar número de mappers (M reducers fijo en 2)
for N in 1 2 4 8; do
    echo "--- N=$N ---"
    time bash run_pipeline.sh $N 2
done

# Variar número de reducers (N mappers fijo en 4)
for M in 1 2 4; do
    echo "--- M=$M ---"
    time bash run_pipeline.sh 4 $M
done
```

### Grupo C — Arquitectura

**Reducer en Python**:
```bash
docker build -t lab-reducer-py -f reducer/Dockerfile.python ./reducer
# Luego editar run_pipeline.sh para usar lab-reducer-py
# Comparar tiempo de startup: docker run lab-reducer vs lab-reducer-py
```

---

## Preguntas a posteriori

1. Calcule S(N) = T(1)/T(N). ¿Dónde deja de ser rentable agregar mappers?
2. ¿Qué pasa con el shuffle si el corpus es 100 GB?
3. Reescriba el reducer en Python. ¿Cambia el tiempo de startup del contenedor?
4. Modifique el mapper para emitir `(palabra, chunk_id, 1)`. ¿Cómo cambia el reducer?
5. ¿Cómo se compartiría el sistema de archivos si los contenedores estuvieran en máquinas distintas?
6. Identifique los equivalentes a JobTracker, TaskTracker, HDFS y DAG en su implementación.
7. **Bonus:** Implemente detección de fallo de mapper usando el código de salida de Docker.

---

## Corpus recomendado para pruebas reales

Para resultados más interesantes, reemplaza `data/corpus.txt` con un libro completo
del Proyecto Gutenberg (formato `.txt`, ~1 MB):

```bash
# Ejemplo: Don Quijote completo
curl -o data/corpus.txt "https://www.gutenberg.org/cache/epub/2000/pg2000.txt"
```

---

## Licencia

Material de uso educativo libre. Sin restricciones de distribución.
