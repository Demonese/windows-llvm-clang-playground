# Windows: LLVM Clang + Visual Studio Code + clangd + lldb-dap

## System & Software

- Windows 10 21H2 or newer
- Visual Studio Code 1.100.x or newer
    - Extension: clangd (publish by LLVM)
    - Extension: LLDB DAP (publish by LLVM)
- LLVM Clang 20.1.x
- Python 3.10.x
- Ninja Build 1.13.x or newer
- CMake 3.31.x or newer

> Python 3.10.x is required by LLDB & LLDB DAP

## Environment Variables

- LLDB_USE_NATIVE_PDB_READER=1
