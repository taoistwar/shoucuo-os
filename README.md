# README

## 目录说明

- app：带标准库 Rust 程序，打印"Hello World!"示例
- user: 用户程序
- os：操作系统内核

## 进度说明

### LibOS

### BatchOS

- 内核栈只有一个，在内核堆上分配的一块连续内存。
- 用户栈只有一个，在内核堆上分配的一块连续内存。
- 用户程序放在相同的地址空间，启动另一个程序就是把另一个程序复制到相应地址。

### 多道程序OS

- Trap 处理，内核栈
  - 保存用户态环境——TrapContext
    - x0~x31
    - sstatus
    - sepc
  - Trap处理——trap_handler
    - 系统调用——ecall
    - S模式中断——任务切换
- 任务管理
