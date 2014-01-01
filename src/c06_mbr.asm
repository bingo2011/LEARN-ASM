       ;跳过时间段，直接从代码段开始执行
       jmp near start

mytext db 'L', 0x07, 'a', 0x07, 'b', 0x07, 'e', 0x07, 'l', 0x07, ' ', 0x07, 'o', 0x07, \
          'f', 0x07, 'f', 0x07, 's', 0x07, 'e', 0x07, 't', 0x07, ':', 0x07

number db 0, 0, 0, 0, 0

start:
       mov ax, 0x7c0                       ;设置数据段DS基地址, DS=0x07c0
       mov ds, ax                          ;这样，我们可以认为BIOS是从0x07c0:0x0000处开始加载主引导扇区

       mov ax, 0xb800                      ;设置附加段ES基地址, ES=0xb800, 指向显示缓冲区
       mov es, ax

       ;段之间的批量数据传送
       cld                                 ;cld, 将DF标志清零, 以指示传送是正方向的
                                           ;std, 将DF标志置位(1), 以指示传送是从高地址到低地址

       mov si, mytext                      ;设置源地址, DS=0x07c0, SI=mytext
       mov di, 0                           ;设置目标地址, ES=0xb800, DI=0x0000
       mov cx, (number - mytext)/2         ;实践上等于13
       rep movsw                           ;movsb和movsw指令执行时, 源地址DS:SI, 目的地址ES:DI, 传送的字节数/字数由CX指定
                                           ;rep, 意思是CX不为0则重复, 每次传送, DI自动加2(movsw)

       ;得到标号所代表的偏移地址
       mov ax, number                      

       ;计算各个数位, 使用循环分解数位
       mov bx, ax                          ;AX存放的number地址，在之后的除法中会改变，所以用BX同时指向该处的偏移地址
       mov cx, 5                           ;循环次数
       mov si, 10                          ;设置除数为10

digit:
       xor dx, dx                          ;DX中的余数清零
       div si                              ;被除数DS:AX, 除数SI, 商AX, 余数DS
       mov [bx], dl                        ;余数存放在number中
       inc bx                              ;指向下一个数位
       loop digit

       ;显示各个数位
       mov bx, number                      ;将保存有各个数位的数据区首地址传送到基址寄存器BX中
       mov si, 4                           ;设置初始索引值是4, 由于要先显示万位上的数字

show:
       mov al, [bx+si]                     
       add al, 0x30                        ;计算出ASCII码
       mov ah, 0x04                        ;设置显示属性0x04, 黑底红字, 无加亮, 无闪烁
       mov [es:di], ax                     ;传送到显示缓冲区
       add di, 2
       dec si                              ;使得BX+SI指向下一位，如千位
       jns show                            ;如果未设置符号位SF(Sign Flag), 也就是SF=0, 则转移到标号"show"所在的位置处执行
                                           ;当SI为负数的时候, SF=1, 条件不满足, 执行后面的指令

       mov word [es:di], 0x0744            ;显示"D"
       jmp near $

times  510 - ($ - $$) db 0
                      db 0x55, 0xaa
