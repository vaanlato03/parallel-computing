/* mapper_stopwords.c — Variante del mapper con filtrado de stop words.
 * MODIFICACIÓN A (Fase 6): ignorar palabras funcionales comunes en español.
 * Compilar: gcc -O2 -Wall -o mapper mapper_stopwords.c
 */
#include <stdio.h>
#include <string.h>
#include <ctype.h>

/* Lista de stop words — ampliar según necesidad */
static const char *STOP_WORDS[] = {
    "el", "la", "los", "las", "un", "una", "unos", "unas",
    "de", "del", "en", "y", "a", "que", "se", "no", "con",
    "por", "su", "al", "lo", "le", "es", "son", "fue",
    "para", "como", "más", "pero", "sus", "me", "te",
    NULL
};

static int is_stop_word(const char *w) {
    for (int i = 0; STOP_WORDS[i] != NULL; i++) {
        if (strcmp(w, STOP_WORDS[i]) == 0) return 1;
    }
    return 0;
}

int main() {
    char word[256];
    int  c, i = 0;

    while ((c = getchar()) != EOF) {
        if (isalpha(c)) {
            word[i++] = tolower(c);
            if (i >= 255) {
                word[i] = '\0';
                if (!is_stop_word(word)) printf("%s\t1\n", word);
                i = 0;
            }
        } else if (i > 0) {
            word[i] = '\0';
            if (!is_stop_word(word)) printf("%s\t1\n", word);
            i = 0;
        }
    }
    if (i > 0) {
        word[i] = '\0';
        if (!is_stop_word(word)) printf("%s\t1\n", word);
    }
    return 0;
}
