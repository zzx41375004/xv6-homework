#include "types.h"
#include "stat.h"
#include "user.h"
int main(int argc, char const *argv[])
{
	/* code */
	int a;
	printf(1,"This is my own app\n");
	a=fork();
	a=fork();
	while(1)
		a++;
	return 0;
}