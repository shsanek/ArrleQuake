//
//  CustomMalloc.c
//  
//
//  Created by Alex Shipin on 9/28/23.
//

#include "CustomMalloc.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int isInitMemory = 0;
char memory_container[MAX_MEM];

void init_memory() {
    if (!isInitMemory) {
        memset(memory_container, 0, MAX_MEM);
        isInitMemory = 1;
    }
}

void* const_malloc(int targetSize) {
    init_memory();
    char* mem = memory_container;
    while (1) {
        unsigned char t = *mem;
        unsigned short size = *((unsigned short*)(mem + 1));
        if (targetSize <= (size - 3) && t == 0) {
            *((unsigned short*)(mem)) = 2 + size;
            return mem + 2;
        } else {
            if (size == 0) {
                return NULL;
            }
            mem += size;
        }
    }
}

void const_free(void *ptr) {
    init_memory();
    *((unsigned short*)(((char*)ptr)-3)) = 0;
}
