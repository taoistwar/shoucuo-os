use riscv::register::sstatus::{self, Sstatus, SPP};
/// Trap Context
#[repr(C)]
pub struct TrapContext {
    /// general regs[0..31]
    pub x: [usize; 32],

    /// 切换回应用时，sret 使用并修改了 sstatus 寄存器
    ///     设置权限模式为 CSRs[sstatus].SPP，
    ///     CSRs[sstatus].SIE 为 CSRs[sstatus].SPIE，
    ///     CSRs[sstatus].SPIE 为 1，
    ///     CSRs[sstatus].spp 为 0。
    /// CSR sstatus
    pub sstatus: Sstatus,
    /// 切换回应用时，sret 会设置 pc 为 CSRs[spec]
    /// CSR sepc
    pub sepc: usize,
}

impl TrapContext {
    /// set stack pointer to x_2 reg (sp)
    pub fn set_sp(&mut self, sp: usize) {
        self.x[2] = sp;
    }
    /// init app context
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
