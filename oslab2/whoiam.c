#define __LIBRARY__
#include <unistd.h>
#include <stdio.h>

#include <errno.h>
#include <asm/segment.h>

_syscall2(int,whoami,char*,name,unsigned int,size)

int main(int argc,char* argv[]){
    char name[100]={0};
    if(whoami(name,24)<0)
        return -1;
    else
        printf("%s\n",name);
    return 0;
}
