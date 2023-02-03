use std::fs::{read_dir, File};
use std::io::{Result, Write};

fn main() {
    println!("cargo:rerun-if-changed=../user/src/");
    println!("cargo:rerun-if-changed={TARGET_PATH}");
    insert_app_data().unwrap();
}

static TARGET_PATH: &str = "../user/target/riscv64gc-unknown-none-elf/release/";

fn insert_app_data() -> Result<()> {
    let mut f = File::create("src/link_app.S").unwrap();
    let mut apps: Vec<_> = read_dir("../user/src/bin")
        .unwrap()
        .into_iter()
        .map(|dir_entry| {
            let mut name_with_ext = dir_entry.unwrap().file_name().into_string().unwrap();
            name_with_ext.drain(name_with_ext.find('.').unwrap()..name_with_ext.len());
            name_with_ext
        })
        .collect();
    apps.sort();

    for (idx, app) in apps.iter().enumerate() {
        println!("app_{idx}: {app}");
        writeln!(f, ".global app_{idx}_start\n.global app_{idx}_end")?;
    }
    writeln!(f, ".global _num_app\n")?;

    writeln!(
        f,
        r#"
# 数据段，代码亦是数据
.section .data
.align 3 # 8 bit(2的3次方)对齐
_num_app: # 标签, 链接是转为符号, 其值位内存地址。
    .quad {} # 类型大小 64 bit"#,
        apps.len()
    )?;

    for i in 0..apps.len() {
        writeln!(f, r#"    .quad app_{i}_start"#)?;
    }
    writeln!(f, r#"    .quad app_{}_end"#, apps.len() - 1)?;

    for (idx, app) in apps.iter().enumerate() {
        println!("app_{idx}: {app}");
        writeln!(
            f,
            r#"
app_{idx}_start:
    # 将二进制文件导入到当前位置
    .incbin "{TARGET_PATH}{app}.bin"
app_{idx}_end:"#
        )?;
    }
    Ok(())
}
