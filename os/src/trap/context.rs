use riscv::register::sstatus::{self, Sstatus, SPP};
/// Trap Context
#[repr(C)]
pub struct TrapContext {
    /// general registers[0..31]
    // x0和x4(tp)不需要保存？x0是0值寄存器，當然不需要保存。
    pub x: [usize; 32],
    /// 对于 sstatus/sepc 而言，它们会在 Trap 处理的全程有意义（在 Trap 控制流最后 sret 的时候还用到了它们）
    /// CSR sstatus
    pub sstatus: Sstatus,
    /// CSR sepc
    pub sepc: usize,
}

impl TrapContext {
    /// set stack pointer to x_2 reg (sp)
    pub fn set_sp(&mut self, sp: usize) {
        self.x[2] = sp;
    }
    /// init app context，工廠方法
    /// @param entry 用戶態程序的入口地址
    /// @param sp 用戶態程序的棧指針地址
    pub fn app_init_context(entry: usize, sp: usize) -> Self {
        let mut s_status = sstatus::read(); // CSR sstatus
        s_status.set_spp(SPP::User); //previous privilege mode: user mode
        let mut cx = Self {
            x: [0; 32],
            sstatus: s_status,
            sepc: entry, // entry point of app
        };
        cx.set_sp(sp); // app's user stack pointer
        cx // return initial Trap Context of app
    }
}
