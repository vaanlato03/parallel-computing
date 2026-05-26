#include <stdio.h>
#include <string.h>
#include <ctype.h>

int main() {
    char line[1024];
    int is_first_line = 1;

    while (fgets(line, sizeof(line), stdin)) {
        line[strcspn(line, "\n")] = '\0';

	if (is_first_line) {
	    is_first_line = 0;
	    continue;
	}

	char *token = strtok(line, ",");
	int column = 0;
	char *genero = NULL;
	char *minutos = NULL;

	while (token != NULL) {
	    if (column == 1) {
		genero = token;
	    } else if (column == 2) {
		minutos = token;
	    }
	    token = strtok(NULL, ",");
	    column++;
	}

	if (genero != NULL && minutos != NULL) {
	    printf("%s\t%s\n", genero, minutos);
	}
    }
    return 0;
}
