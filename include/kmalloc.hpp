#pragma once
#include <int.hpp>

struct SLOBHeader {
    SLOBHeader* ptr;
    u32 size;
};

void kfree(void* ap);
void* kmalloc(u32 nbytes);

static_assert(sizeof(SLOBHeader) == 8, "");

void* operator new(size_t size);
void* operator new[](size_t size);
void operator delete(void* p) noexcept;
void operator delete[](void* p) noexcept;