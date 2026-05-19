/* reducer.c — Etapa REDUCE del pipeline MapReduce
 * Lee stdin con pares (palabra\tconteo) ORDENADOS por palabra.
 * Emite (palabra\ttotal) por stdout.
 * Requiere entrada pre-ordenada (sort | reducer).
 */
#include <stdio.h>
#include <string.h>

int main() {
    char word[256], prev[256] = "";
    int  count, total = 0;

    while (scanf("%255s\t%d", word, &count) == 2) {
        if (strcmp(word, prev) == 0) {
            total += count;
        } else {
            if (prev[0] != '\0') {
                printf("%s\t%d\n", prev, total);
            }
            strncpy(prev, word, 255);
            prev[255] = '\0';
            total = count;
        }
    }
    if (prev[0] != '\0') {
        printf("%s\t%d\n", prev, total);
    }
    return 0;
}
