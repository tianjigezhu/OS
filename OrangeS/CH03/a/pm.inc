; 描述符类型
DA_32       EQU     4000h         ; 32位段

DA_DPL0     EQU     00h           ; DPL = 0
DA_DPL1     EQU     20h           ; DPL = 1

; 存储段描述符类型
DA_DRW      EQU     92h           ; 存在的可读写数据段属性值
DA_C        EQU     98h           ; 存在的只执行代码段属性值

; 描述符
; usage: Descriptor Base, Limit, Attr
;        Base:  dd
;        Limit: dd (low 20 bits available)
;        Attr:  dw (lower 4 bits of higher byte are always 0)
%macro Descriptor 3
        dw %2 & 0FFFFh                          ; 段界限1
        dw %1 & 0FFFFh                          ; 段基址1
        db (%1 >> 16) & 0FFh                    ; 段基址2
        dw ((%2 >> 8) & 0F00h) | (%3 & 0F0FFh)  ; 属性值1 + 段界限2 + 属性2
        db (%1 >> 24) & 0FFh                    ; 段基址3
%endmacro ; 共8字节
