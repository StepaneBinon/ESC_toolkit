# Common GCC Compilation Flags for C++

This document summarizes the most relevant GCC flags for C++ compilation.  
A complete explanation can be found in [GCC Manual][1] and an overview in [Medium Article][2].

### 🧠 Static Analysis

To be explored further — GCC offers several flags for static code analysis that can help detect potential issues at compile time.

### 🪲 Debugging Flags

`-g0`, `-g1`, `-g2`, `-g3`, `-ggdb0`, `-ggdb1`, `-ggdb2`, `-ggdb3`, `-D`

These flags control how much debugging information is included in the generated binary.  
Higher levels provide more detailed debug information. The default is `-g2`.

For typical debugging, use **`-O0`** (no optimization) to prevent the compiler from rearranging or removing code, which can make debugging more reliable. Avoid `-Og` unless you specifically want a balance between optimization and debuggability. See [3] for discussion.

### ⚙️ Optimization Flags

`-O0`, `-O1`, `-O2`, `-O3`, `-Os`, `-Ofast`, `-Og`, `-Oz`, `-finline-functions`, `-funroll-loops`, `-ffunction-sections`, `-fdata-sections`

These control trade-offs between runtime speed, compile-time duration, code size, and debuggability.

- **`-O0`** — No optimization, fastest to compile, ideal for debugging.  
- **`-O1`** — Basic optimizations, minimal increase in compile time.  
- **`-O2`** — Standard optimization level for release builds.  
- **`-O3`** — Aggressive optimization, may increase binary size.  
- **`-Os`** — Optimize for size.  
- **`-Ofast`** — Breaks strict compliance with standards to achieve maximum speed.  
- **`-Og`** — Optimize while keeping debugging reasonable.  
- **`-Oz`** — Optimize for the smallest possible size (Clang extension).  
- **`-ffunction-sections`, `-fdata-sections`** — Places each function/data item in its own section, enabling the linker to discard unused code when combined with `--gc-sections`.

### 🧩 Program Instrumentation

GCC offers options for profiling and coverage analysis (e.g., `-pg`, `--coverage`).  
These can be useful for runtime performance measurement and test coverage evaluation.

### 🧱 Preprocessor Control

`-D`, `-include`

- **`-D`** defines a macro (e.g., `-DDEBUG=1` define macro `DEBUG` as existing).  
  Useful for conditional compilation without needing a dedicated `debug.hpp` file.  
- **`-include`** forces the inclusion of a header before all source files.

### 🔗 Linking Options

`-l`, `-T`

- **`-l<name>`** — Link against library `<name>` (searches system and `-L` paths).  
- **`-T<file>`** — Use a custom linker script (often used in embedded systems).

### 📁 Directory Search Paths

`-I`, `-L`

- **`-I<dir>`** — Add directory `<dir>` to the list of include paths.  
- **`-L<dir>`** — Add directory `<dir>` to the library search path.

### ⚙️ Code Generation

`-fverbose-asm`

Generates additional comments in the assembly output, providing more readable insight into the compiler’s code generation process.

### 🧮 Machine-Dependent Options

Target-specific options such as `-mcpu`, `-mthumb`, or `-march` tune code generation for specific architectures (e.g., ARM Cortex-M).

### ⚡ Precompiled Headers

Large projects often include the same headers in many source files.  
Precompiled headers speed up builds by parsing them once and reusing the result.

## 📚 References

[1] *GNU GCC Manual*: [Link](https://gcc.gnu.org/onlinedocs/gcc/Invoking-GCC.html) <br>
[2] *Mastering Flags in GCC* (Medium): [Link](https://medium.com/@promisevector/c-programming-mastering-flags-in-gcc-32809491f340) <br>
[3] Why use `-O0` instead of `-Og`: [Stack Overflow](https://stackoverflow.com/questions/63386189/)

---
---

Corrected, reformulated and reformated by ChatGPT.
