LEARN-ASM
=========
nasm -f bin xxx.asm -o xxx.bin -l xxx.lst

AX - 累加器(Accumulator)
BX - 基址寄存器(Base Address Register)
CX - 计数器(Counter)
DX - 数据(Data)寄存器
SI - 源索引寄存器(Source Index)
DI - 目标索引寄存器(Destination Index)

注意, INTEL8086处理器只允许以下几种基址寄存器和变址寄存器的组合：
    [bx+si]
    [bx+di]
    [bp+si]
    [bp+di]

