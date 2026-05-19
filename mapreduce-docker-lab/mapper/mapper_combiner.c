/* mapper_combiner.c — Variante con combinación local (mini-reduce en el mapper).
 * MODIFICACIÓN C (Fase 6): acumular conteos localmente antes de emitir.
 * Reduce el volumen de datos que viaja al shuffle.
 * Limitación: tabla hash simple, máximo MAX_WORDS palabras distintas por chunk.
 */
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

#define MAX_WORDS  8192
#define WORD_LEN   256

typedef struct {
    char word[WORD_LEN];
    int  count;
} Entry;

static Entry table[MAX_WORDS];
static int   table_size = 0;

static int find_or_insert(const char *w) {
    for (int i = 0; i < table_size; i++) {
        if (strcmp(table[i].word, w) == 0) return i;
    }
    if (table_size < MAX_WORDS) {
        strncpy(table[table_size].word, w, WORD_LEN - 1);
        table[table_size].count = 0;
        return table_size++;
    }
    return -1; /* tabla llena: ignorar (o emitir de inmediato) */
}

int main() {
    char word[WORD_LEN];
    int  c, i = 0;

    while ((c = getchar()) != EOF) {
        if (isalpha(c)) {
            word[i++] = tolower(c);
            if (i >= WORD_LEN - 1) {
                word[i] = '\0';
                int idx = find_or_insert(word);
                if (idx >= 0) table[idx].count++;
                i = 0;
            }
        } else if (i > 0) {
            word[i] = '\0';
            int idx = find_or_insert(word);
            if (idx >= 0) table[idx].count++;
            i = 0;
        }
    }
    if (i > 0) {
        word[i] = '\0';
        int idx = find_or_insert(word);
        if (idx >= 0) table[idx].count++;
    }

    /* Emitir tabla local (ya combinada) */
    for (int k = 0; k < table_size; k++) {
        printf("%s\t%d\n", table[k].word, table[k].count);
    }
    return 0;
}
