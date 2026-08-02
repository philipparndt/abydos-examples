/* Small enough to read, with something worth stepping through: a struct, a
 * loop, and a pointer that is easy to get wrong. */
#include <stdio.h>
#include <string.h>

typedef struct {
	char name[16];
	int celsius;
} Reading;

static Reading readings[] = {
	{"kitchen", 21},
	{"bedroom", 18},
	{"garage", 9},
};

static const Reading *coldest(const Reading *list, size_t count) {
	if (count == 0) {
		return NULL;
	}
	const Reading *found = &list[0];
	for (size_t i = 1; i < count; i++) {
		if (list[i].celsius < found->celsius) {
			found = &list[i];
		}
	}
	return found;
}

int main(void) {
	size_t count = sizeof(readings) / sizeof(readings[0]);
	for (size_t i = 0; i < count; i++) {
		printf("%-8s %3d C\n", readings[i].name, readings[i].celsius);
	}

	const Reading *cold = coldest(readings, count);
	printf("coldest: %s\n", cold ? cold->name : "nothing");
	return 0;
}
