# example-libc-ffi
Example for a custom std build failing after https://github.com/rust-lang/rust/commit/c50d3e28ab0bfaedd1f0f90a376e6f93e4e83c62.

To reproduce: `./run-in-docker.sh` 

```
+ STD_ENV_ARCH=x86_64
+ RUSTC_BOOTSTRAP=1
+ rustc rust/library/std/src/lib.rs --crate-name=std --crate-type=rlib --error-format=human --codegen=metadata=-649841298 --codegen=extra-filename=-649841298 --out-dir=outdir --codegen=opt-level=3 --codegen=debuginfo=0 '--remap-path-prefix=${pwd}=' --emit=link --color=never --target=x86_64-unknown-linux-gnu --cfg 'feature="panic-unwind"' --cfg 'feature="panic_unwind"' --cap-lints=allow --cfg=backtrace_in_libstd -Zforce-unstable-if-unmarked --edition=2021 --extern=alloc=outdir/liballoc-384047890.rlib --extern=cfg_if=outdir/libcfg_if-578106348.rlib --extern=compiler_builtins=outdir/libcompiler_builtins-1071363765.rlib --extern=core=outdir/libcore-1934803528.rlib --extern=hashbrowfg 'feature="panic_unwind"' --cap-lints=allow --cfg=backtrace_in_libstd -Zforce-unstabn=outdir/libhashbrown-2545358579.rlib --extern=libc=outdir/liblibc-241958726.rlib --extern=panic_abort=outdir/libpanic_abort-1847932942.rlib --extern=panic_unwind=outdir/libpanic_unwind-1458542728.rlib --extern=rustc_demangle=outdir/librustc_demangle-3774576121.rlib --extern=std_detect=outdir/libstd_detect-2775444999.rlib --extern=unwind=outdir/libunwind-380821176.rlib -Ldependency=outdir --cfg=bootstrap -Ccodegen-units=1 -Csymbol-mangling-version=v0
error[E0308]: mismatched types
    --> rust/library/std/src/sys_common/net.rs:291:42
     |
291  |             c::send(self.inner.as_raw(), buf.as_ptr() as *const c_void, len, MSG_NOSIGNAL)
     |             -------                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ expected `libc::c_void`, found `core::ffi::c_void`
     |             |
     |             arguments to this function are incorrect
     |
     = note: `core::ffi::c_void` and `libc::c_void` have similar names, but are actually distinct types
note: `core::ffi::c_void` is defined in crate `core`
    --> /example/rust/library/core/src/ffi/mod.rs:204:1
     |
204  | pub enum c_void {
     | ^^^^^^^^^^^^^^^
note: `libc::c_void` is defined in crate `libc`
    --> /example/libc-0.2.140/src/unix/mod.rs:1607:9
     |
1607 |         pub enum c_void {
     |         ^^^^^^^^^^^^^^^
note: function defined here
    --> /example/libc-0.2.140/src/unix/mod.rs:1303:12
     |
1303 |     pub fn send(socket: ::c_int, buf: *const ::c_void, len: ::size_t, flags: ::c_int) -> ::ssize_t;
     |            ^^^^

error[E0308]: mismatched types
    --> rust/library/std/src/sys_common/net.rs:551:17
     |
549  |             c::sendto(
     |             --------- arguments to this function are incorrect
550  |                 self.inner.as_raw(),
551  |                 buf.as_ptr() as *const c_void,
     |                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ expected `libc::c_void`, found `core::ffi::c_void`
     |
     = note: `core::ffi::c_void` and `libc::c_void` have similar names, but are actually distinct types
note: `core::ffi::c_void` is defined in crate `core`
    --> /example/rust/library/core/src/ffi/mod.rs:204:1
     |
204  | pub enum c_void {
     | ^^^^^^^^^^^^^^^
note: `libc::c_void` is defined in crate `libc`
    --> /example/libc-0.2.140/src/unix/mod.rs:1607:9
     |
1607 |         pub enum c_void {
     |         ^^^^^^^^^^^^^^^
note: function defined here
    --> /example/libc-0.2.140/src/unix/mod.rs:708:12
     |
708  |     pub fn sendto(
     |            ^^^^^^
```
