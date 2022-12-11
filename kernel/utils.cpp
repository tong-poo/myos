#include <screen.hpp>
#include <utils.hpp>

void zeromem(void* dst, int n)
{
    for (int i = 0; i < n; i++)
        ((u8*)dst)[i] = 0;
}

void run::push(RunNode* new_node)
{
    new_node->next = head;
    head = new_node;
}

RunNode* run::pop()
{
    RunNode* old_head = head;
    head = head->next;
    return old_head;
}