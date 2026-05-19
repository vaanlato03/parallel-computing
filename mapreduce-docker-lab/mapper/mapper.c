/* mapper.c — Etapa MAP del pipeline MapReduce
 * Lee stdin (chunk de texto), emite pares (palabra\t1) por stdout.
 * Convierte a minúsculas e ignora tokens no alfabéticos.
 */
#include <stdio.h>
#include <string.h>
#include <ctype.h>

int main() {
    char word[256];
    int  c, i = 0;

    while ((c = getchar()) != EOF) {
        if (isalpha(c)) {
            word[i++] = tolower(c);
            if (i >= 255) {          /* protección de buffer */
                word[i] = '\0';
                printf("%s\t1\n", word);
                i = 0;
            }
        } else if (i > 0) {
            word[i] = '\0';
            printf("%s\t1\n", word);
            i = 0;
        }
    }
    if (i > 0) {
        word[i] = '\0';
        printf("%s\t1\n", word);
    }
    return 0;
}
