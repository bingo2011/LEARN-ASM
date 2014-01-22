        app_lba_start equ 100                        ;声明常数(用户程序起始逻辑扇区号)
                                                     ;常数的声明不会占用汇编地址
SECTION mbr align=16 vstart=0x7c00

        ;设置堆栈段和栈指针
        mov ax, 0
        mov ss, ax
        mov sp, ax

        mov ax, [cs:phy_base]                        ;计算用于加载用户程序的逻辑段地址
        mov dx, [cs:phy_base+0x02]
        mov bx, 16
        div bx

        mov ds, ax                                   ;令DS和ES指向该段以进行操作
        mov es, ax

        ;以下读取程序的起始部分
        xor di, di
        mov si, app_lba_start                        ;程序在硬盘上的起始逻辑扇区号
        xor bx, bx                                   ;加载到DS:0x0000处
        call read_hard_disk_0

read_hard_disk_0:                                    ;从硬盘读取一个逻辑扇区
													 ;输入： DI:SI=起始逻辑扇区号
													 ;      DS:BX=目标缓冲区地址
		push ax
		push bx
		push cx
		push dx

		mov dx, 0x1f2
		mov al, 1                                    ;要读取的扇区数
		out dx, al                                   

		inc dx                                       ;0x1f3
		mov ax, si                                   ;起始逻辑扇区号，定义在常量app_lba_start
		out dx, al                                   ;LBA地址7～0

		inc dx                                       ;0x1f4
		mov al, ah
		out dx, al                                   ;LBA地址15～8

		inc dx                                       ;0x1f5
		mov ax, di
		out dx, al                                   ;LBA地址23～16

		inc dx                                       ;0x1f6
		mov al, 0xe0                                 ;LBA28模式，主盘
		or  al, ah                                   ;LBA地址27～24
		out dx, al

		inc dx                                       ;0x1f7
		mov al, 0x20                                 ;读命令
		out dx, al

.waits:
		in al, dx
		and al, 0x88
		cmp al, 0x08
		jnz .waits                                   ;不忙，且硬盘已准备好数据传输

		mov cx, 256                                  ;总共要读取的字数
		mov dx, 0x1f0

.readw:
		in ax, dx
		mov [bx], ax                                 ;硬盘数据被加载到DS:BX中
		add bx, 2
		loop .readw

		pop dx
		pop cx
		pop bx
		pop ax

		ret

        phy_base dd 0x10000                          ;用户程序被加载的物理起始地址






