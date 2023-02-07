.altmacro
.macro SAVE_SN n
    sd s\n, (\n+2)*8(a0)
.endm
.macro LOAD_SN n
    ld s\n, (\n+2)*8(a1)
.endm
    .section .text
    .globl __switch
__switch:
    # 從一個程序切換到另一個程序。主要是切換TaskContext
    # __switch(
    #     current_task_cx_ptr: *mut TaskContext,
    #     next_task_cx_ptr: *const TaskContext
    # )


    # 第1步：保存from程序的環境
    # save kernel stack of current task
    # 1.1 a0 是 fromTaskContext 的地址，a0+8 也就是存到fromTaskContext的 sp 字段中。
    # 因為是從內核態執行的，所以是內核態環境，sp為內核態sp。
    sd sp, 8(a0)

    # save ra & s0~s11 of current execution
    # 1.2 a0 是 fromTaskContext 的地址，a0+0 也就是存到fromTaskContext的 ra 字段中。
    sd ra, 0(a0)
    # __switch 后面调用 __restore 切换到用户态了，所以不需要恢复函数上下文。
    # # 1.3 保存s0~s11
    # .set n, 0
    # .rept 12
    #     SAVE_SN %n
    #     .set n, n + 1
    # .endr

    # 第2部：恢復dist程序的環境
    # restore ra & s0~s11 of next execution
    # 2.1 從 distTaskContext 中恢復 ra，時機上就是標籤 __restore 的地址。
    ld ra, 0(a1)
    # 2.2 從 distTaskContext 中恢復 s0~s11寄存器
    # .set n, 0
    # .rept 12
    #     LOAD_SN %n
    #     .set n, n + 1
    # .endr
    # restore kernel stack of next task
    # 2.3 從 distTaskContext 中恢復 sp，注意在步驟1.1中設置的sp是內核態的。
    ld sp, 8(a1)
    # 2.4 返回到 ra(__restore) 繼續執行，當然此時還是在內核態
    ret

