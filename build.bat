rmdir build
mkdir build

tasm.exe /m2 /iinclude src\main.asm build > build\out.txt
tasm.exe /m2 /iinclude src\render.asm build >> build\out.txt
tasm.exe /m2 /iinclude src\error.asm build >> build\out.txt
tasm.exe /m2 /iinclude src\stdio.asm build >> build\out.txt
tasm.exe /m2 /iinclude src\fileio.asm build >> build\out.txt
tasm.exe /m2 /iinclude src\tileset.asm build >> build\out.txt
tasm.exe /m2 /iinclude src\state.asm build >> build\out.txt
tasm.exe /m2 /iinclude src\util.asm build >> build\out.txt
tlink.exe build\main.obj build\render.obj build\error.obj build\stdio.obj build\fileio.obj build\tileset.obj build\state.obj build\util.obj >> build\out.txt
