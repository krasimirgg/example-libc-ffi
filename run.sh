#!/bin/bash
set -eux

rustup default beta-2023-03-07
rustc --version

if [[ ! -d rust ]]; then
  echo "cloning rust"
  git clone https://github.com/rust-lang/rust
  cd rust
  git checkout 516a6d320270f03548c04c0707a00c998787de45
  git submodule update --init --recursive
  python3 x.py build
fi

function get_crate {
  local tag=$1
  local name="$(dirname $tag)"
  for i in {1..3}; do
    name="$(dirname $name)"
  done
  name="$(basename $name)"
  local version="$(basename $tag .tar.gz | tr -d 'v')"
  local outdir="${name}-${version}"
  if [[ ! -d "${outdir}" ]]; then
    echo "getting ${outdir}"
    wget -qO- "${tag}" | tar xzf -
  fi
  echo "${name}-${version}"
}

echo "Checking out vendored deps"
COMPILER_BUILTINS_DIR="$(get_crate https://github.com/rust-lang/compiler-builtins/archive/refs/tags/0.1.90.tar.gz)"
LIBC_DIR="$(get_crate https://github.com/rust-lang/libc/archive/refs/tags/0.2.140.tar.gz)"
CFG_IF_DIR="$(get_crate https://github.com/alexcrichton/cfg-if/archive/refs/tags/1.0.0.tar.gz)"
RUSTC_DEMANGLE_DIR="$(get_crate https://github.com/rust-lang/rustc-demangle/archive/refs/tags/0.1.22.tar.gz)"
HASHBROWN_DIR="$(get_crate https://github.com/rust-lang/hashbrown/archive/refs/tags/v0.12.3.tar.gz)"
UNICODE_WIDTH_DIR="$(get_crate https://github.com/unicode-rs/unicode-width/archive/refs/tags/v0.1.10.tar.gz)"

mkdir outdir || true

build_core () {
  if [[ ! -f "outdir/libcore-1934803528.rlib" ]]; then
    RUSTC_BOOTSTRAP=1 rustc rust/library/core/src/lib.rs '--crate-name=core' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-1934803528' '--codegen=extra-filename=-1934803528' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=' '--emit=link' '--color=always' '--target=x86_64-unknown-linux-gnu' '--cap-lints=allow' '-Cmetadata=rustc_internalYOLO8667' -Zforce-unstable-if-unmarked '--edition=2021' '--cfg=bootstrap' '-Ccodegen-units=1' '-Csymbol-mangling-version=v0'
  fi
}

build_libc () {
  if [[ ! -f "outdir/liblibc-241958726.rlib" ]]; then
    RUSTC_BOOTSTRAP=1 rustc libc-0.2.140/src/lib.rs '--crate-name=libc' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-241958726' '--codegen=extra-filename=-241958726' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=' '--emit=link' '--color=always' '--target=x86_64-unknown-linux-gnu' --cfg 'feature="rustc-dep-of-std"' --cfg 'feature="align"' '--cap-lints=allow' '-Cmetadata=rustc_internalYOLO8667' -Zforce-unstable-if-unmarked '--cfg=libc_align' \
      '--extern=rustc_std_workspace_core=outdir/libcore-1934803528.rlib' '-Ldependency=outdir' \
      '--cfg=bootstrap' '-Ccodegen-units=1' '-Csymbol-mangling-version=v0'
  fi
}

build_compiler_builtins () {
  if [[ ! -f "outdir/libcompiler_builtins-1071363765.rlib" ]]; then
    RUSTC_BOOTSTRAP=1 rustc compiler-builtins-0.1.90/src/lib.rs '--crate-name=compiler_builtins' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-1071363765' '--codegen=extra-filename=-1071363765' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=' '--emit=link' '--color=always' '--target=x86_64-unknown-linux-gnu' --cfg 'feature="compiler-builtins"' '--cap-lints=allow' '-Cmetadata=rustc_internalYOLO8667' -Zforce-unstable-if-unmarked '--cfg=feature="mem-unaligned"' '--cfg=feature="unstable"' \
      '--extern=core=outdir/libcore-1934803528.rlib' '-Ldependency=outdir' \
      '--cfg=bootstrap' '-Ccodegen-units=1' '-Csymbol-mangling-version=v0'
  fi
}

build_rustc_demangle () {
  if [[ ! -f "outdir/librustc_demangle-3774576121.rlib" ]]; then
    RUSTC_BOOTSTRAP=1 rustc rustc-demangle-0.1.22/src/lib.rs '--crate-name=rustc_demangle' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-3774576121' '--codegen=extra-filename=-3774576121' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=' '--emit=link' '--color=always' '--target=x86_64-unknown-linux-gnu' '--cap-lints=allow' '-Cmetadata=rustc_internalYOLO8667' -Zforce-unstable-if-unmarked \
      '--extern=compiler_builtins=outdir/libcompiler_builtins-1071363765.rlib' \
      '--extern=core=outdir/libcore-1934803528.rlib' '-Ldependency=outdir' \
      '--cfg=bootstrap' '-Ccodegen-units=1' '-Csymbol-mangling-version=v0'
  fi
}

build_unicode_width () {
  if [[ ! -f "outdir/libunicode_width-36882269.rlib" ]]; then
    RUSTC_BOOTSTRAP=1 rustc unicode-width-0.1.10/src/lib.rs '--crate-name=unicode_width' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-36882269' '--codegen=extra-filename=-36882269' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=' '--emit=link' '--color=always' '--target=x86_64-unknown-linux-gnu' --cfg 'feature="rustc-dep-of-std"' --cfg 'feature="std"' --cfg 'feature="core"' --cfg 'feature="compiler_builtins"' '--cap-lints=allow' '-Cmetadata=rustc_internalYOLO8667' -Zforce-unstable-if-unmarked \
      '--extern=compiler_builtins=outdir/libcompiler_builtins-1071363765.rlib' \
      '--extern=core=outdir/libcore-1934803528.rlib' '-Ldependency=outdir' \
      '--cfg=bootstrap' '-Ccodegen-units=1' '-Csymbol-mangling-version=v0'
  fi
}

build_alloc () {
  if [[ ! -f "outdir/liballoc-384047890.rlib" ]]; then
    RUSTC_BOOTSTRAP=1 rustc rust/library/alloc/src/lib.rs '--crate-name=alloc' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-384047890' '--codegen=extra-filename=-384047890' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=' '--emit=link' '--color=always' '--target=x86_64-unknown-linux-gnu' '--cap-lints=allow' '--edition=2021' \
      '--extern=compiler_builtins=outdir/libcompiler_builtins-1071363765.rlib' \
      '--extern=core=outdir/libcore-1934803528.rlib' '-Ldependency=outdir' \
      '--cfg=bootstrap' '-Ccodegen-units=1' '-Csymbol-mangling-version=v0'
  fi
}

build_cfg_if () {
  if [[ ! -f "outdir/libcfg_if-578106348.rlib" ]]; then
    RUSTC_BOOTSTRAP=1 rustc cfg-if-1.0.0/src/lib.rs '--crate-name=cfg_if' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-578106348' '--codegen=extra-filename=-578106348' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=' '--emit=link' '--color=always' '--target=x86_64-unknown-linux-gnu' --cfg 'feature="compiler-builtins"' '--cap-lints=allow' '-Cmetadata=rustc_internalYOLO8667' -Zforce-unstable-if-unmarked '--edition=2018' \
      '--extern=compiler_builtins=outdir/libcompiler_builtins-1071363765.rlib' \
      '--extern=core=outdir/libcore-1934803528.rlib' '-Ldependency=outdir' \
      '--cfg=bootstrap' '-Ccodegen-units=1' '-Csymbol-mangling-version=v0'
  fi
}

build_unwind () {
  if [[ ! -f "outdir/libunwind-380821176.rlib" ]]; then
    RUSTC_BOOTSTRAP=1 rustc rust/library/unwind/src/lib.rs '--crate-name=unwind' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-380821176' '--codegen=extra-filename=-380821176' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=' '--emit=link' '--color=always' '--target=x86_64-unknown-linux-gnu' --cfg 'feature="llvm-libunwind"' -Zforce-unstable-if-unmarked '--edition=2021' \
      '--extern=cfg_if=outdir/libcfg_if-578106348.rlib' \
      '--extern=compiler_builtins=outdir/libcompiler_builtins-1071363765.rlib' \
      '--extern=core=outdir/libcore-1934803528.rlib' \
      '--extern=libc=outdir/liblibc-241958726.rlib' \
      '-Ldependency=outdir' \
      '--cfg=bootstrap' '-Ccodegen-units=1' '-Csymbol-mangling-version=v0'
  fi
}

build_std_detect () {
  if [[ ! -f "outdir/libstd_detect-2775444999.rlib" ]]; then
    RUSTC_BOOTSTRAP=1 rustc rust/library/stdarch/crates/std_detect/src/lib.rs '--crate-name=std_detect' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-2775444999' '--codegen=extra-filename=-2775444999' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=' '--emit=link' '--color=always' '--target=x86_64-unknown-linux-gnu' --cfg 'feature="rustc-dep-of-std"' --cfg 'feature="core"' --cfg 'feature="compiler_builtins"' --cfg 'feature="alloc"' '--cap-lints=allow' '-Cmetadata=rustc_internalYOLO8667' -Zforce-unstable-if-unmarked '--edition=2021' \
      '--extern=cfg_if=outdir/libcfg_if-578106348.rlib' \
      '--extern=compiler_builtins=outdir/libcompiler_builtins-1071363765.rlib' \
      '--extern=core=outdir/libcore-1934803528.rlib' \
      '--extern=libc=outdir/liblibc-241958726.rlib' \
      '-Ldependency=outdir' \
      '--cfg=bootstrap' '-Ccodegen-units=1' '-Csymbol-mangling-version=v0'
  fi
}

build_hashbrown () {
  if [[ ! -f "outdir/libhashbrown-2545358579.rlib" ]]; then
    RUSTC_BOOTSTRAP=1 rustc hashbrown-0.12.3/src/lib.rs '--crate-name=hashbrown' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-2545358579' '--codegen=extra-filename=-2545358579' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=' '--emit=link' '--color=always' '--target=x86_64-unknown-linux-gnu' --cfg 'feature="alloc"' --cfg 'feature="compiler_builtins"' --cfg 'feature="core"' --cfg 'feature="nightly"' --cfg 'feature="rustc-dep-of-std"' --cfg 'feature="rustc-internal-api"' '--cap-lints=allow' '-Cmetadata=rustc_internalYOLO8667' -Zforce-unstable-if-unmarked '--edition=2018' \
      '--extern=alloc=outdir/liballoc-384047890.rlib' \
      '--extern=compiler_builtins=outdir/libcompiler_builtins-1071363765.rlib' \
      '--extern=core=outdir/libcore-1934803528.rlib' \
      '-Ldependency=outdir' \
      '--cfg=bootstrap' '-Ccodegen-units=1' '-Csymbol-mangling-version=v0'
  fi
}

build_panic_abort () {
  if [[ ! -f "outdir/libpanic_abort-1847932942.rlib" ]]; then
    RUSTC_BOOTSTRAP=1 rustc rust/library/panic_abort/src/lib.rs '--crate-name=panic_abort' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-1847932942' '--codegen=extra-filename=-1847932942' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=' '--emit=link' '--color=always' '--target=x86_64-unknown-linux-gnu' --cfg 'feature="rustc_private"' '--cap-lints=allow' -Zforce-unstable-if-unmarked '-Cpanic=abort' '--edition=2021' \
      '--extern=alloc=outdir/liballoc-384047890.rlib' \
      '--extern=cfg_if=outdir/libcfg_if-578106348.rlib' \
      '--extern=compiler_builtins=outdir/libcompiler_builtins-1071363765.rlib' \
      '--extern=core=outdir/libcore-1934803528.rlib' \
      '--extern=libc=outdir/liblibc-241958726.rlib' \
      '-Ldependency=outdir' \
      '--cfg=bootstrap' '-Ccodegen-units=1' '-Csymbol-mangling-version=v0'
  fi
}

build_panic_unwind () {
  if [[ ! -f "outdir/libpanic_unwind-1458542728.rlib" ]]; then
    RUSTC_BOOTSTRAP=1 rustc rust/library/panic_unwind/src/lib.rs '--crate-name=panic_unwind' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-1458542728' '--codegen=extra-filename=-1458542728' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=' '--emit=link' '--color=always' '--target=x86_64-unknown-linux-gnu' --cfg 'feature="rustc_private"' '--cap-lints=allow' -Zforce-unstable-if-unmarked '--edition=2021' \
      '--extern=alloc=outdir/liballoc-384047890.rlib' \
      '--extern=cfg_if=outdir/libcfg_if-578106348.rlib' \
      '--extern=compiler_builtins=outdir/libcompiler_builtins-1071363765.rlib' \
      '--extern=core=outdir/libcore-1934803528.rlib' \
      '--extern=libc=outdir/liblibc-241958726.rlib' \
      '--extern=unwind=outdir/libunwind-380821176.rlib' \
      '-Ldependency=outdir' \
      '--cfg=bootstrap' '-Ccodegen-units=1' '-Csymbol-mangling-version=v0'
  fi
}

build_std () {
  if [[ ! -f "outdir/libstd-649841298.rlib" ]]; then
     STD_ENV_ARCH=x86_64 RUSTC_BOOTSTRAP=1 rustc rust/library/std/src/lib.rs '--crate-name=std' '--crate-type=rlib' '--error-format=human' '--codegen=metadata=-649841298' '--codegen=extra-filename=-649841298' '--out-dir=outdir' '--codegen=opt-level=3' '--codegen=debuginfo=0' '--remap-path-prefix=${pwd}=' '--emit=link' '--color=never' '--target=x86_64-unknown-linux-gnu' --cfg 'feature="panic-unwind"' --cfg 'feature="panic_unwind"' '--cap-lints=allow' '--cfg=backtrace_in_libstd' -Zforce-unstable-if-unmarked '--edition=2021' \
      '--extern=alloc=outdir/liballoc-384047890.rlib' \
      '--extern=cfg_if=outdir/libcfg_if-578106348.rlib' \
      '--extern=compiler_builtins=outdir/libcompiler_builtins-1071363765.rlib' \
      '--extern=core=outdir/libcore-1934803528.rlib' \
      '--extern=hashbrown=outdir/libhashbrown-2545358579.rlib' \
      '--extern=libc=outdir/liblibc-241958726.rlib' \
      '--extern=panic_abort=outdir/libpanic_abort-1847932942.rlib' \
      '--extern=panic_unwind=outdir/libpanic_unwind-1458542728.rlib' \
      '--extern=rustc_demangle=outdir/librustc_demangle-3774576121.rlib' \
      '--extern=std_detect=outdir/libstd_detect-2775444999.rlib' \
      '--extern=unwind=outdir/libunwind-380821176.rlib' \
      '-Ldependency=outdir' \
      '--cfg=bootstrap' '-Ccodegen-units=1' '-Csymbol-mangling-version=v0' 2>&1 | tee outdir/std-build-out
  fi
}

build_core
build_libc
build_compiler_builtins
build_rustc_demangle
build_unicode_width
build_alloc
build_cfg_if
build_unwind
build_std_detect
build_hashbrown
build_panic_abort
build_panic_unwind
build_std
