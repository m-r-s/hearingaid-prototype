#include <stdio.h>
#include <stdint.h>
#include <unistd.h>

const char *bit_rep[16] = {
    [ 0] = "0", [ 1] = "1", [ 2] = "2", [ 3] = "3",
    [ 4] = "4", [ 5] = "5", [ 6] = "6", [ 7] = "7",
    [ 8] = "8", [ 9] = "9", [10] = "a", [11] = "b",
    [12] = "c", [13] = "d", [14] = "e", [15] = "f",
};

void print_byte(uint8_t byte)
{
    printf("%s%s", bit_rep[byte >> 4], bit_rep[byte & 0x0F]);
}

int main()
{
    char ch;
    int count = 0;
    while(read(STDIN_FILENO, &ch, 1) > 0)
    {
        print_byte(ch);
        count++;
	if (count >= 8) {
             printf("\n");
             count = 0;
        }
    }
    return 0;
}

