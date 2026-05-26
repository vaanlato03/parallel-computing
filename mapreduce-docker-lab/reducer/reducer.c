/* reducer.c — Etapa REDUCE del pipeline MapReduce
 * Lee stdin con pares (palabra\tconteo) ORDENADOS por palabra.
 * Emite (palabra\ttotal) por stdout.
 * Requiere entrada pre-ordenada (sort | reducer).
 */
#include <stdio.h>
#include <string.h>

int main() {
    char genero[256], genero_actual[256] = "";
    int minutos, total = 0;

    while (scanf("%255s\t%d", genero, &minutos) == 2) {
        if (strcmp(genero, genero_actual) == 0) {
            total += minutos;
        } else {
            if (genero_actual[0] != '\0') {
                printf("%s\t%d\n", genero_actual, total);
            }
            strncpy(genero_actual, genero, 255);
            genero_actual[255] = '\0';
            total = minutos;
        }
    }
    if (genero_actual[0] != '\0') {
        printf("%s\t%d\n", genero_actual, total);
    }
    return 0;
}
