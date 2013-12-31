	;将段寄存器ES指向文本模式的显示缓冲区0xb800
	mov ax, 0xb800
	mov es, ax

	;以下显示字符串"Label offset"