rmdir build
mkdir build

tasm.exe /m2 /iinclude src\* build\ > build\out.txt
tlib.exe build\mlib -+build\mouse  >> build\out.txt
tlib.exe build\mlib -+build\test  >> build\out.txt
tlib.exe build\mlib -+build\render  >> build\out.txt
tlib.exe build\mlib -+build\error  >> build\out.txt
tlib.exe build\mlib -+build\stdio  >> build\out.txt
tlib.exe build\mlib -+build\fileio  >> build\out.txt
tlib.exe build\mlib -+build\tileset  >> build\out.txt
tlib.exe build\mlib -+build\board  >> build\out.txt
tlib.exe build\mlib -+build\state  >> build\out.txt
tlib.exe build\mlib -+build\util  >> build\out.txt
tlink.exe build\main.obj build\mlib.lib >> build\out.txt
