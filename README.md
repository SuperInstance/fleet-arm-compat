# 🦾 fleet-arm-compat

**ARM64 compatibility module for the SuperInstance fleet.**

Ensures all 220+ fleet repos compile and run correctly on ARM64 (aarch64) hardware.
This Oracle ARM instance is the reference platform.

## Verified on ARM64

| Language | Status | Version |
|----------|--------|---------|
| Python | ✅ Native | 3.14.5 |
| JavaScript (Node) | ✅ Native | v26.0.0 |
| Go | ✅ Native | 1.23.4 |
| Rust | ✅ Native | 1.96.0 |
| C (gcc) | ✅ Native | 11.4.0 |
| C++ (g++) | ✅ Native | 11.4.0 |
| WASM | ✅ Cross-compile | clang wasm32 target |

## Run Tests

```bash
bash tests/test_arm.sh
```

All tests verify the invariant:
```
[1,0,-1,1,0,-1,1,1] → [60,64,64,60,64,64,60,64,68]
```

## Multi-Arch Docker

See `multiarch/Dockerfile.arm64` for ARM64-optimized container builds.

## Hardware-Flexible Architecture

```
┌─────────────────────┐
│  Python/JS (any)    │  ← Platform independent
├─────────────────────┤
│  Go/Rust/C/C++      │  ← Compiles natively on ARM64
├─────────────────────┤
│  WASM (any browser) │  ← Universal deployment
├─────────────────────┤
│  CUDA (ProArt)      │  ← Forgemaster on RTX4050
└─────────────────────┘
```
