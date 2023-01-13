.altmacro
.macro SAVE_GP n
    sd x\n, \n*8(sp)
.endm
.macro LOAD_GP n
    ld x\n, \n*8(sp)
.endm
    .section .text
    .globl __alltraps
    .globl __restore
    .align 2
__all_traps:
    # 从用户态触发Trap，因此，当前寄存器的环境是用户态的，所以sp是用户态sp
    # 为啥 sscartch 是内核态的 sp ？ 因为，在下面的__restore中初始化的。
    csrrw sp, sscratch, sp
    # now sp->kernel stack, sscratch->user stack

    # 在内核态的栈空间中开辟 34*8个字节，用于保存用户态环境
    # allocate a TrapContext on kernel stack
    addi sp, sp, -34*8


    # 保存用户态通用寄器的值。
    # save general-purpose registers
    sd x1, 1*8(sp)
    # skip sp(x2), we will save it later
    sd x3, 3*8(sp)
    # skip tp(x4), application does not use it
    # save x5~x31
    .set n, 5
    .rept 27
        SAVE_GP %n
        .set n, n+1
    .endr
    # we can use t0/t1/t2 freely, because they were saved on kernel stack


    # 保存csr（Trap相关信息）
    csrr t0, sstatus
    csrr t1, sepc
    sd t0, 32*8(sp)
    sd t1, 33*8(sp)
    # 由于用户态sp保存于sscratch csr中，取出来存到TrapContext中。
    # read user stack from sscratch and save it on the kernel stack
    csrr t2, sscratch
    sd t2, 2*8(sp)

    # 调用 trap_handler 函数，通过设置参数0=ao为内核态sp，内核态sp最近放入的对象是TrapContext，ao就是TrapContext的地址。
    # set input argument of trap_handler(cx: &mut TrapContext)
    mv a0, sp
    call trap_handler

__restore:
    # __restore 有两种使用情况：第一次执行的是case1，初始化了sscratch为内核态sp
    # case1: start running app by __restore
    #        启动app时，run_next_app函数中调用。
    #        设定a0为内核态sp
    # case2: back to U after handling trap；
    #        用户态触发Trap，内核态完成trap_handler后，继续向下执行。最后的sret返回到用户态。
    #        a0为trap_handler返回了TrapContext的地址（内核态的sp）

    # sp 置为内核态的
    # mv sp, a0
    # now sp->kernel stack(after allocated), sscratch->user stack

    # 恢复用户态环境：通用寄存器
    # restore sstatus/sepc
    ld t0, 32*8(sp) # sstatus
    ld t1, 33*8(sp) # sepc
    ld t2, 2*8(sp) # 用户态sp
    csrw sstatus, t0
    csrw sepc, t1
    # 将 sscratch 置为用户态sp
    csrw sscratch, t2
    # restore general-purpuse registers except sp/tp
    ld x1, 1*8(sp)
    ld x3, 3*8(sp)
    .set n, 5
    .rept 27
        LOAD_GP %n
        .set n, n+1
    .endr

    # TrapContext 对象已经没有作用，释放
    # release TrapContext on kernel stack
    addi sp, sp, 34*8


    # 交换前：now sp->kernel stack, sscratch->user stack
    csrrw sp, sscratch, sp
    # 交换后：sscratch -> kernel stack，sp -> user stack;
    sret
