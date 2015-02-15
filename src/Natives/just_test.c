#include <stdio.h>
#include "SandBox_pri.h"
#include "MEM.h"
#include "DBG.h"

Loopr_Value *
proc_hello_world(ExeEnvironment *env, int argc, Loopr_Value **argv)
{
	printf("hello, world!\n");
	return NULL;
}

Loopr_Value *
proc_print(ExeEnvironment *env, int argc, Loopr_Value **argv)
{
	printf("%ls", argv[0]->u.string_value);
	return NULL;
}

Loopr_Value *
proc_getc(ExeEnvironment *env, int argc, Loopr_Value **argv)
{
	Loopr_Value *ret;

	ret = Loopr_alloc_value(LPR_CHAR);
	ret->u.char_value = getchar();
	
	return ret;
}

void
Natives_load_all()
{
	Native_load_function("hello", 0x01010101, proc_hello_world);
	Native_load_function("print", 0x01010102, proc_print);
	Native_load_function("getc", 0x01010103, proc_getc);
	return;
}
