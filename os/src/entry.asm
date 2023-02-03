.globl _start
.globl boot_stack
.globl boot_stack_top


    .section .text.entry
_start:
    la sp, boot_stack_top
    call rust_main

    .section .bss.stack
boot_stack:  #我们尝试将其放置到全局数据 .data 段中但最后未能成功，因此才决定将其放置到 .bss 段中。
    .space 4096 * 16
boot_stack_top:              # 栈顶，