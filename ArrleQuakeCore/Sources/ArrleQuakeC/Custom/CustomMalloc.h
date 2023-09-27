//
//  CustomMalloc.h
//  
//
//  Created by Alex Shipin on 9/28/23.
//

#ifndef CustomMalloc_h
#define CustomMalloc_h

#include <stdio.h>

#define MAX_MEM_MB 32
#define MAX_MEM MAX_MEM_MB*1024*1024

extern char memory_container[MAX_MEM];

void init_memory();
void* const_malloc(int size);
void const_free(void *ptr);

#define MALLOC(size) const_malloc(size)
#define FREE(ptr) const_free(ptr)

#endif /* CustomMalloc_h */
