rmdir build
mkdir build

tasm.exe src\main.asm build
tasm.exe src\render.asm build
tlink.exe build\main.obj build\render.obj
