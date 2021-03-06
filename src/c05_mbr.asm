    ;将附加段寄存器ES指向文本模式的显示缓冲区0xb800
    mov ax, 0xb800
    mov es, ax

    ;以下显示字符串"Label offset"
    mov byte [es:0x00], 'L'
    mov byte [es:0x01], 0x07     ;字符属性0x07可以解释为黑底白字，无闪烁，无加亮
    mov byte [es:0x02], 'a'
    mov byte [es:0x03], 0x07
    mov byte [es:0x04], 'b'
    mov byte [es:0x05], 0x07
    mov byte [es:0x06], 'e'
    mov byte [es:0x07], 0x07
    mov byte [es:0x08], 'l'
    mov byte [es:0x09], 0x07

    mov byte [es:0x0a], ' '
    mov byte [es:0x0b], 0x07

    mov byte [es:0x0c], 'o'
    mov byte [es:0x0d], 0x07
    mov byte [es:0x0e], 'f'
    mov byte [es:0x0f], 0x07
    mov byte [es:0x10], 'f'
    mov byte [es:0x11], 0x07
    mov byte [es:0x12], 's'
    mov byte [es:0x13], 0x07
    mov byte [es:0x14], 'e'
    mov byte [es:0x15], 0x07
    mov byte [es:0x16], 't'
    mov byte [es:0x17], 0x07
    mov byte [es:0x18], ':'
    mov byte [es:0x19], 0x07

    mov ax, number               ;取得标号number的偏移地址, AX在后面将作为被除数使用
    mov bx, 10                   ;设置除数为10

    ;设置数据段的基地址，数据段和代码段指向同一个段
    mov cx, cs
    mov ds, cx

    ;求个位上的数字
    mov dx, 0
    div bx                       ;32位除以16位，DX:AX作为被除数，高16位是全零，低16位设置为标号number的汇编地址，
                                 ;执行后得到的商在AX中，余数在DX中。因为除数是10，余数自然比10小，余数可以从DL中取得
                                 ;16位除以8位，AX存被除数，商在AL中，余数在AH中

    mov [0x7c00+number+0x00], dl ;因为主引导扇区是被加载到0x0000:0x7c00处，而非0x0000:0x0000，也就是
                                 ;CS=0x0000, IP=0x7c00
                                 ;保存个位上的数字

    ;求十位上的数字
    xor dx, dx                   ;xor dx, dx相比mov dx, 0，操作码较短，因为两个操作数都是通用寄存器，执行速度最快
    div bx
    mov [0x7c00+number+0x01], dl ;保存十位上的数字

    ;求百位上的数字
    xor dx, dx
    div bx
    mov [0x7c00+number+0x02], dl ;保存百位上的数字

    ;求千位上的数字
    xor dx, dx
    div bx
    mov [0x7c00+number+0x03], dl ;保存千位上的数字

    ;求万位上的数字
    xor dx, dx
    div bx
    mov [0x7c00+number+0x04], dl ;保存万位上的数字

    ;以下用十进制显示标号的偏移地址
    ;显示万位上的数字
    mov al, [0x7c00+number+0x04]
    add al, 0x30
    mov [es:0x1a], al
    mov byte [es:0x1b], 0x04     ;字符属性0x04可以解释为黑底红字，无闪烁，无加亮
 
    ;显示千位上的数字
    mov al, [0x7c00+number+0x03]
    add al, 0x30
    mov [es:0x1c], al
    mov byte [es:0x1d], 0x04

    ;显示百位上的数字
    mov al, [0x7c00+number+0x02]
    add al, 0x30
    mov [es:0x1e], al
    mov byte [es:0x1f], 0x04

    ;显示十位上的数字
    mov al, [0x7c00+number+0x01]
    add al, 0x30
    mov [es:0x20], al
    mov byte [es:0x21], 0x04

    ;显示个位上的数字
    mov al, [0x7c00+number+0x00]
    add al, 0x30
    mov [es:0x22], al
    mov byte [es:0x23], 0x04

    ;显示后缀'D'，意思是所显示的数字是十进制的
    mov byte [es:0x24], 'D'
    mov byte [es:0x25], 0x07

infi: jmp near infi             ;无限循环

number db 0,0,0,0,0

times 203 db 0
          db 0x55, 0xaa         ;主引导扇区的有效标志