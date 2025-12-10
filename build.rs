
fn main() {
    #[cfg(target_os = "linux")]
    {
        panic!("BL: I'm linux!");
    }

    #[cfg(target_os = "macos")]
    {
        panic!("BL: I'm macOS!");
    }
}
