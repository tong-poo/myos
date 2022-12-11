#include <idt.hpp>
#include <screen.hpp>

static IDTR idtr;
static IDTEntry idt[IDT_ENTRY_COUNT];

extern void (*isr_stubs[48])();

InterruptHandler interrupt_handlers[48];

static void set_gate(u8 entry_index, void (*isr)(), u16 cs, u8 flags)
{
    idt[entry_index] = {
        .base_lo = (u16)((u32)isr & 0xffff),
        .cs = cs,
        .flags = flags,
        .base_hi = (u16)(((u32)isr >> 16) & 0xffff),
    };
}

static void set_idt()
{
    for (int i = 0; i < 48; i++)
        set_gate(i, isr_stubs[i], 0x08, IDT_PRESENT | IDT_GATE_TRAP_32);
}

static void init_idtr()
{
    idtr.limit = (u16)sizeof(idt) - 1;
    idtr.base = (u32)&idt;

    asm volatile("lidt %0" ::"m"(idtr));
}

void init_idt()
{
    set_idt();
    init_idtr();
}

void register_interrupt_handler(int no, InterruptHandler handler)
{
    interrupt_handlers[no] = handler;
}

extern "C" void isr_global_handler(ISRContext ctx)
{
    // kprintf("no: %d error code: %d\n", ctx.int_no, ctx.err_code);
    InterruptHandler handler = interrupt_handlers[ctx.int_no];
    if (handler)
        handler(&ctx);
}