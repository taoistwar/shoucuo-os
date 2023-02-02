# 聲名全局標籤，可以在其它文件中使用
.globl _start
.globl boot_stack
.globl boot_stack_top


# 在 linker.ld 中把 “.text.entry” 設置為0x80200000，也就是OS第一條指令條地址。
.section .text.entry
_start:                         # 根据 linker.ld，我们知道 _start的地址是 0x80200000。
    la sp, boot_stack_top       # 将 symbol(boot_stack_top)的地址加载到 寄存器sp中。也就是OS第一條指令
    call rust_main              # 调用函数，伪指令 call rd, symbol；默認rd=x1=ra


# 在 linker.ld 中把 “.bss.stack” 設置為bss的第一塊指令塊。
.section .bss.stack
boot_stack:                     # 注：我们尝试将其放置到全局数据 .data 段中但最后未能成功，因此才决定将其放置到 .bss 段中。
    # 申請空間，也就是棧空間。語法.space size [,fill]；省略吧fill，使用0值填充，功能類似於.skip。
    # 如果栈的使用超过 64k 后，会出现什么问题？覆盖了.data、.rddata、.text段，最终修改了程序的代码。
    .space 4096 * 16
boot_stack_top:                 # 栈顶，