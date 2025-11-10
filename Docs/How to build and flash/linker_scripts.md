# Linker Scripts

All the documentation concerning Linker Script is available in [1]. A good sum-up is presented by McYoung in [2].

The linker scripts incorporate several .o (objects) and .a (static library previously computed) files to produce to produce an executable. McYoung sum-up the steps:

1. Pare all objects and static libraries and put their symbols into a database. Symbols are named addresses of functions and global variables.
2. Search for all unresolved symbol references in .o files and match them up with a symbol from the database, recursively doing this for any code in a .a referenced during this process. This step is called the *symbol resolution*.
3. Throw out any code that isn't referenced by the input files by tracing the dependency graph from entry-point symbols (e.g., _start on Linux). This step is called the *garbadge collection*.
4. Execute the Liker Script to figure out how to stitch the final binary together. This include discovering the offsets at which evrything will go.
5. Resolving *relocations*, "holes" in the binary that require knowing the final runtime address of the section. Relocations are instructions placed in the object file for the linker to execute.
6. Write out the complete binary.

Command to show all object in an object file (.o/.out)
```bash
objdump -x a.out
```
The part oresult is illustrated bellow
![alt text](.\Images\LinkerScript\result_objdump.png)

An object (file) is divided in sections, which are named blocked of data with different parameter like files in an OS. The parameters are the followings [3]:
 - ALLOC: means that the section occupies memory (e.g. memory pages are actually allocated to hold the section content when a process is created), indicated by the `SHF_ALLOC` tag Some sections, e.g. those containing debug information, are not read into memory during normal program execution and are not marked as ALLOC to save memory.
 - LOAD: for ALLOC section; means that the allocated space must be filled with the content section, this process in called *loading* (or dynamic linker, hence the .ld). These can be read from the file into the memory when a pocess is created
 - CODE: means that the section contains executable code; it is indicated by `SHF_EXECINSTR` flag in the section header
 - DATA: means that the section is not executable but is writable, indicate the presence of the `SHF_WRITE`tag
 - READONLY: means that the section is neither executable nor writtable and should be placed in read-only memory pages

Sections of type `SHT_PROGBITS`have corresponding content in the file, and are shown as CONTENTS Some sections does not have the corresponding content in the file which is of type `SHT_NOBITS`.

The .text section contains the program executable code. It is show as CONTENTS since it is of type SHT_PROGBITS. Memory should be reserved for this section since it is ALLOC and its contents should be loaded from the file since it is placed in a LOAD-able segment. Program code is generally non-modifiable and hence the section is placed in read-only memory. It contains instructions that are to be executed and hence the CODE flag.

## Ressources

[1] https://sourceware.org/binutils/docs/ld/index.html <br>
[2] https://mcyoung.xyz/2021/06/01/linker-script/ <br>
[3] https://stackoverflow.com/questions/11196048/flags-in-objdump-output-of-object-file <br>