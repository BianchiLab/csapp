#include <stdio.h>
#include <limits.h>

int main(void) {
    int x = INT_MAX;
    printf("INT_MAX     = %d\n", x);
    printf("INT_MAX + 1 = %d\n", x + 1);
    unsigned int u = 0;
    printf("(unsigned)0 - 1 = %u\n", u - 1);
    return 0;
}
