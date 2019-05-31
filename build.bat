rmdir build
mkdir build

tasm.exe src\main.asm build
tlink.exe build\main.obj
