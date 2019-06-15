rmdir build
mkdir build

tasm.exe /iinclude src\main.asm build > build\out.txt
tasm.exe /iinclude src\render.asm build >> build\out.txt
tasm.exe /iinclude src\error.asm build >> build\out.txt
tasm.exe /iinclude src\stdio.asm build >> build\out.txt
tasm.exe /iinclude src\fileio.asm build >> build\out.txt
tlink.exe build\main.obj build\render.obj build\error.obj build\stdio.obj build\fileio.obj >> build\out.txt
