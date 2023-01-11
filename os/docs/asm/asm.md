---
marp: true
_class: lead
theme: gaia
paginate: true
backgroundImage: url(../images/hero-background.svg)
---

# RISC-V 汇编

---

# RISC-V 汇编环境

- 基本 ubuntu环境

```bash
sudo apt install clang lld
```

- 编译汇编代码

```bash
 clang --target=riscv32 -march=rv32gc -mabi=ilp32d -mno-relax hello.s -c -o hello.o
 ld.lld hello.o -o hello.x
```

---

# 汇编工具

- objdump 反汇编代码

```bash
riscv64-unknown-elf-objdump -D hello.x
```

- readelf 查看ELF文件头信息

```bash
riscv64-unknown-elf-readelf -h hello.x
```

---

# 举例

- 代码

    ```asm
    .equ UART_BASE, 0x40003F80
    lui a0, %hi(UART_BASE)
    addi a0, a0, %lo(UART_BASE)
    ```

- 反汇编

    ```bash
    000110b4 <.text>:
       110b4:       40004537                lui     a0,0x40004
       110b8:       f8050513                addi    a0,a0,-128 # 40003f80 <UART_BASE>
    ```

- [lui/auipc和addi结合加载立即数时的补值问题](https://zhuanlan.zhihu.com/p/374235855)

---
