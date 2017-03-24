#define __LIBRARY__
#include <unistd.h>
#include <errno.h>
#include <asm/segment.h>
char sys_name[25]={0};

int sys_iam(const char * name){
    int count=0;
    while(*(name+count)!='\0'){
        count++;
    }
    if(count>23){
        errno=ENIVAL;
	printk("string is too long");
        return -1;
    }
    else{
        for(int i=0;i<=count;i++){
            sys_name[i]=*(name+i);
        }
	printk("copy finished");
        return count;
    }
}

int sys_whoami(char* name, unsigned int size){
    int i=0;
    while(sys_name[i]!='\0'){
        i++
    }
    if(size<i){
        errno=-1;
	printk("size is not enough");
        return -1;
    }
    else{
        for(i=0;i<=size;i++){
            *(name+i)=sys_name[i];
        }
	printk("copy finished");
        return size;
    }
}
