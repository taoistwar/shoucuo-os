#![no_main]
#![no_std]
#![feature(panic_info_message)]

#[macro_use]
mod console;
mod lang_items;
mod logging;
mod sbi;

use log::*;

// use crate::sbi::shutdown;

// start 语义项代表了标准库 std 在执行应用程序之前需要进行的一些初始化工作。
// 由于我们禁用了标准库，编译器也就找不到这项功能的实现了。
// 提供入口函数 _start()
core::arch::global_asm!(include_str!("entry.asm"));

// 标记为 #[no_mangle] 以避免编译器对它的名字进行混淆，
// 不然在链接时， entry.asm 将找不到 main.rs 提供的外部符号 rust_main，导致链接失败。
#[no_mangle]
pub fn rust_main() -> ! {
    extern "C" {
        fn stext();
        fn etext();
        fn srodata();
        fn erodata();
        fn sdata();
        fn edata();
        /// BSS段的起始地址
        fn sbss();
        /// BSS段的結束地址，不包括
        fn ebss();
        fn boot_stack();
        fn boot_stack_top();
    }
    clear_bss();
    println!("hello world");
    logging::init();
    trace!(".text [{:#x}, {:#x})", stext as usize, etext as usize);
    debug!(".rodata [{:#x}, {:#x})", srodata as usize, erodata as usize);
    info!(".data [{:#x}, {:#x})", sdata as usize, edata as usize);
    warn!(
        "boot_stack [{:#x}, {:#x})",
        boot_stack as usize, boot_stack_top as usize
    );
    error!(".bss [{:#x}, {:#x})", sbss as usize, ebss as usize);
    panic!("Shutdown machine!");
    // shutdown();
}

/// 清零 .bss 段
fn clear_bss() {
    extern "C" {
        fn sbss();
        fn ebss();
    }
    (sbss as usize..ebss as usize).for_each(|a| unsafe { (a as *mut u8).write_volatile(0) });
}
