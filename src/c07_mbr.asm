        jmp near start

message db '1+2+3+...+100='

start:
        mov ax, 0x7c0                             ;设置数据段DS的段基地址
        mov ds, ax

        mov ax, 0xb800                            ;设置附加段ES的段基地址到显示缓冲区
        mov es, ax

        ;以下显示字符串
        mov si, message
        mov di, 0
        mov cx, start - message

@g:
        mov al, [si]
        mov [es:di], al
        inc di
        mov byte [es:di], 0x07
        inc di
        inc si
        loop @g

        ;以下计算1到100的和
        xor ax, ax
        mov cx, 1                                 ;cx作为计算器，从1递增到100
@f:
        add ax, cx
        inc cx
        cmp cx, 100                               ;将cx寄存器中的内容与100做比较
        jle @f                                    ;如果结果是小于等于100, 则继续执行循环

        ;以下计算累加和的每个数位
        xor cx, cx                                ;设置堆栈段SS的段基地址
        mov ss, cx
        mov sp, cx                                ;SS=0x0000, SP=0x0000

        mov bx, 10                                ;设置除数为10
        xor cx, cx

        ;依次将1到100的和的各数位值从低位向高位依次压入栈中
        ;出栈的顺序相反，从高位到低位
@d:
        inc cx                                    ;计算非0的数位个数
        xor dx, dx                                ;设置被除数高位DX为0, 低位保存在AX中
        div bx
        or dl, 0x30                               ;余数存放在DX的低16位dl中, 转换成ASCII码
                                                  ;or指令对标志寄存器的影响是: OF和CF位清零, SF、ZF、PF为的状态依计算结果而定, AF位的状态未定义
        push dx
        cmp ax, 0
        jne @d

        ;以下显示各个数位
@a:
        pop dx
        mov [es:di], dl                           ;出栈，存放到显示缓冲区中
        inc di                                    ;指向显示缓冲区的下一个地址
        mov byte [es:di], 0x07
        inc di
        loop @a                                   ;循环的次数由cx中的值决定

        jmp near $

times   510 - ($ - $$) db 0
                       db 0x55, 0xaa
