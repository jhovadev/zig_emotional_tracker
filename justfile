build-small:
    zig build -Doptimize=ReleaseSmall 
build-phone:
    zig build -Doptimize=ReleaseSmall -Dtarget=aarch64-linux-musl
