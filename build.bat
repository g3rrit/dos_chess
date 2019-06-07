rmdir build
mkdir build

tasm.exe src\main.asm build
tasm.exe src\render.asm build
tasm.exe src\error.asm build
tasm.exe src\stdio.asm build
tasm.exe src\fileio.asm build
tlink.exe build\main.obj build\render.obj build\error.obj build\stdio.obj build\fileio.obj
