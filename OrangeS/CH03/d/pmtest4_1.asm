; ==========================================
; pmtest1.asm
; ï¿½ï¿½ï¿½ë·½ï¿½ï¿½ï¿½ï¿½nasm pmtest1.asm -o pmtest1.bin
; ==========================================

%include	"pm.inc"	; ï¿½ï¿½ï¿½ï¿½, ï¿½ï¿½, ï¿½Ô¼ï¿½Ò»Ð©Ëµï¿½ï¿½

org	0100h
	jmp	LABEL_BEGIN

[SECTION .gdt]
; GDT
;                                 ï¿½Î»ï¿½Ö·,       ï¿½Î½ï¿½ï¿½ï¿½     , ï¿½ï¿½ï¿½ï¿½
LABEL_GDT:	          Descriptor          0,                0, 0             ; ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
LABEL_DESC_NORMAL:    Descriptor          0,           0ffffh, DA_DRW        ; Normalï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
LABEL_DESC_CODE32:    Descriptor          0,   SegCode32Len-1, DA_C+DA_32    ; ï¿½ï¿½Ò»ï¿½Â´ï¿½ï¿½ï¿½Î£ï¿?32
LABEL_DESC_CODE16:    Descriptor          0,           0ffffh, DA_C          ; ï¿½ï¿½Ò»ï¿½Â´ï¿½ï¿½ï¿½Î£ï¿?16
LABEL_DESC_CODE_DEST: Descriptor          0, SegCodeDestLen-1, DA_C+DA_32    ; ·ÇÒ»ÖÂ´úÂë¶Î£¬32
LABEL_DESC_DATA:      Descriptor          0,      DataLen - 1, DA_DRW        ; Data
LABEL_DESC_STACK:     Descriptor          0,       TopOfStack, DA_DRWA+DA_32 ; Stackï¿½ï¿½32Î»
LABEL_DESC_LDT:       Descriptor          0,       LDTLen - 1, DA_LDT ; LDT
LABEL_DESC_VIDEO:     Descriptor    0B8000h,           0ffffh, DA_DRW	       ; ï¿½Ô´ï¿½ï¿½×µï¿½Ö·

; ÃÅ
LABEL_CALL_GATE_TEST: Gate SelectorCodeDest, 0,  0, DA_386CGate+DA_DPL0
; GDT ï¿½ï¿½ï¿½ï¿½

GdtLen		equ	$ - LABEL_GDT	; GDTï¿½ï¿½ï¿½ï¿½
GdtPtr		dw	GdtLen - 1	; GDTï¿½ï¿½ï¿½ï¿½
		dd	0		; GDTï¿½ï¿½ï¿½ï¿½Ö·

; GDT Ñ¡ï¿½ï¿½ï¿½ï¿½
SelectorNormal      equ LABEL_DESC_NORMAL   - LABEL_GDT
SelectorCode32		equ	LABEL_DESC_CODE32	- LABEL_GDT
SelectorCode16      equ LABEL_DESC_CODE16   - LABEL_GDT
SelectorCodeDest    equ LABEL_DESC_CODE_DEST- LABEL_GDT
SelectorData        equ LABEL_DESC_DATA     - LABEL_GDT
SelectorStack       equ LABEL_DESC_STACK    - LABEL_GDT
SelectorLDT         equ LABEL_DESC_LDT      - LABEL_GDT
SelectorVideo		equ	LABEL_DESC_VIDEO	- LABEL_GDT

SelectorCallGateTest equ LABEL_CALL_GATE_TEST - LABEL_GDT
; END of [SECTION .gdt]

[SECTION .data1]       ; ï¿½ï¿½ï¿½Ý¶ï¿½
ALIGN    32
[BITS    32]
LABEL_DATA:
SPValueInRealMode           dw       0
; ï¿½Ö·ï¿½ï¿½ï¿½
PMMessage:                  db       "In Protect Mode now. ^_^", 0        ; ï¿½Ú±ï¿½ï¿½ï¿½Ä£Ê½ï¿½ï¿½ï¿½ï¿½Ê¾
OffsetPMMessage             equ      PMMessage - $$
StrTest:                    db       "ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0
OffsetStrTest               equ      StrTest - $$
DataLen                     equ      $ - LABEL_DATA
; END of [SECTION .data1]


; È«¾Ö¶ÑÕ»¶Î
[SECTION  .gs]
ALIGN    32
[BITS    32]
LABEL_STACK:
        times     512     db      0

TopOfStack        equ     $ - LABEL_STACK - 1

; END of [SECTION .gs]


[SECTION .s16]
[BITS	16]
LABEL_BEGIN:
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, 0100h

    mov [LABEL_GO_BACK_TO_REAL+3], ax
	mov [SPValueInRealMode], sp

	;  ³õÊ¼»¯ 16 Î»´úÂë¶ÎÃèÊö·û
	mov ax, cs
	movzx eax, ax
	shl eax, 4
	add eax, LABEL_SEG_CODE16
	mov word [LABEL_DESC_CODE16 + 2], ax
	shr eax, 16
	mov byte [LABEL_DESC_CODE16 + 4], al
	mov byte [LABEL_DESC_CODE16 + 7], ah

	;  ³õÊ¼»¯ 32 Î»´úÂë¶ÎÃèÊö·û
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_SEG_CODE32
	mov	word [LABEL_DESC_CODE32 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_CODE32 + 4], al
	mov	byte [LABEL_DESC_CODE32 + 7], ah

	; ³õÊ¼»¯²âÊÔµ÷ÓÃÃÅµÄ´úÂë¶ÎÃèÊö·û
	xor eax, eax
	mov ax, cs
	shl eax, 4 
	add eax, LABEL_SEG_CODE_DEST
	mov word [LABEL_DESC_CODE_DEST + 2], ax
	shr eax, 16
	mov byte [LABEL_DESC_CODE_DEST + 4], al
	mov byte [LABEL_DESC_CODE_DEST + 7], ah

    ; ³õÊ¼»¯Êý¾Ý¶ÎÃèÊö·û
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_DATA
	mov	word [LABEL_DESC_DATA + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_DATA + 4], al
	mov	byte [LABEL_DESC_DATA + 7], ah

	; ³õÊ¼»¯¶ÑÕ»¶ÎÃèÊö·û
	xor	eax, eax
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_STACK
	mov	word [LABEL_DESC_STACK + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_STACK + 4], al
	mov	byte [LABEL_DESC_STACK + 7], ah

	; ³õÊ¼»¯LDTÔÚGDTÖÐµÄÃèÊö·û
	xor eax, eax 
	mov ax, ds
	shl eax, 4 
	add eax, LABEL_LDT 
	mov word [LABEL_DESC_LDT + 2], ax 
	shr eax, 16
	mov byte [LABEL_DESC_LDT + 4], al 
	mov byte [LABEL_DESC_LDT + 7], ah 

	; ³õÊ¼»¯LDTÖÐµÄÃèÊö·û
	xor eax, eax 
	mov ax, ds 
	shl eax, 4 
	add eax, LABEL_CODE_A
	mov word [LABEL_LDT_DESC_CODEA + 2], ax 
	shr eax, 16
	mov byte [LABEL_LDT_DESC_CODEA + 4], al 
	mov byte [LABEL_LDT_DESC_CODEA + 7], ah 

	; Îª¼ÓÔØ GDTR ×÷×¼±¸
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_GDT		; eax <- gdt »ùµØÖ·
	mov	dword [GdtPtr + 2], eax	; [GdtPtr + 2] <- gdt »ùµØÖ·

	; ï¿½ï¿½ï¿½ï¿½ GDTR
	lgdt	[GdtPtr]

	; ï¿½ï¿½ï¿½Ð¶ï¿½
	cli

	; ï¿½ò¿ªµï¿½Ö·ï¿½ï¿½A20
	in	al, 92h
	or	al, 00000010b
	out	92h, al

	; ×¼ï¿½ï¿½ï¿½Ð»ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ä£Ê½
	mov	eax, cr0
	or	eax, 1
	mov	cr0, eax

	; ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ë±£ï¿½ï¿½Ä£Ê½
	jmp	dword SelectorCode32:0	; Ö´ï¿½ï¿½ï¿½ï¿½Ò»ï¿½ï¿½ï¿½ï¿½ SelectorCode32 ×°ï¿½ï¿½ cs, ï¿½ï¿½ï¿½ï¿½×ªï¿½ï¿½ Code32Selector:0  ï¿½ï¿½

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LABEL_REAL_ENTRY:               ; ï¿½Ó±ï¿½ï¿½ï¿½Ä£Ê½ï¿½ï¿½ï¿½Øµï¿½ÊµÄ£Ê½ï¿½Íµï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
    mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax

	mov sp, [SPValueInRealMode]

	in al, 92h
	and al, 11111101b   ; ï¿½Ø±ï¿½A20ï¿½ï¿½Ö·ï¿½ï¿½
	out 92h, al

	sti  ; ï¿½ï¿½ï¿½Ð¶ï¿½

	mov ax, 4c00h
	int 21h
; END of [SECTION .s16]


[SECTION .s32]; 32 Î»ï¿½ï¿½ï¿½ï¿½ï¿?. ï¿½ï¿½ÊµÄ£Ê½ï¿½ï¿½ï¿½ï¿½.
[BITS	32]

LABEL_SEG_CODE32:
    mov ax, SelectorData
	mov ds, ax          ; ï¿½ï¿½ï¿½Ý¶ï¿½Ñ¡ï¿½ï¿½ï¿½ï¿½
	mov	ax, SelectorVideo
	mov	gs, ax			; ï¿½ï¿½Æµï¿½ï¿½Ñ¡ï¿½ï¿½ï¿½ï¿½(Ä¿ï¿½ï¿½)

	mov ax, SelectorStack
	mov ss, ax          ; ï¿½ï¿½Õ»ï¿½ï¿½Ñ¡ï¿½ï¿½ï¿½ï¿½

	mov esp, TopOfStack


	; ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Ê¾Ò»ï¿½ï¿½ï¿½Ö·ï¿½ï¿½ï¿½
	mov ah, 0Ch         ; 0000:ï¿½Úµï¿½ 1100:ï¿½ï¿½ï¿½ï¿½
	xor esi, esi
	xor edi, edi
	mov esi, OffsetPMMessage    ; Ô´ï¿½ï¿½ï¿½ï¿½Æ«ï¿½ï¿½
	mov	edi, (80 * 10 + 0) * 2	; ï¿½ï¿½Ä»ï¿½ï¿½ 10 ï¿½ï¿½, ï¿½ï¿½ 0 ï¿½Ð¡ï¿½
	cld 
.1:
	lodsb
	test al, al
	jz .2
	mov [gs:edi], ax
	add edi, 2
	jmp .1
.2: ; ï¿½ï¿½Ê¾ï¿½ï¿½ï¿?

	call DispReturn

	; ²âÊÔµ÷ÓÃÃÅ£¨ÎÞÌØÈ¨¼¶±ä»»£©£¬½«´òÓ¡×ÖÄ¸'C'
	call SelectorCallGateTest:0
	;call SelectorCodeDest:0

	; Load LDT
	mov ax, SelectorLDT 
	lldt ax

	jmp SelectorLDTCodeA:0    ; ÌøÈë¾Ö²¿ÈÎÎñ
	
;--------------------------------------------------------------------
DispReturn:
	push eax
	push ebx
	mov eax, edi
	mov bl, 160
	div bl
	and eax, 0FFH 
	inc eax
	mov bl, 160 
	mul bl 
	mov edi, eax 
	pop ebx
	pop eax 

	ret
; DispReturnï¿½ï¿½ï¿½ï¿½---------------------------------------------------------------

SegCode32Len	equ	$ - LABEL_SEG_CODE32
; END of [SECTION .s32]


[SECTION .sdest]; µ÷ÓÃÃÅÄ¿±ê¶Î
[BITS 32]

LABEL_SEG_CODE_DEST:
	; jmp $
	mov ax, SelectorVideo
	mov gs, ax

	mov edi, (80 * 12 + 0) * 2
	mov ah, 0Ch
	mov al, 'C'
	mov [gs:edi], ax

	retf

SegCodeDestLen equ $ - LABEL_SEG_CODE_DEST
; END of [SECTION .sdest]


; 16Î»ï¿½ï¿½ï¿½ï¿½Î£ï¿½ï¿½ï¿?32Î»ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ë£?ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ÊµÄ£??
[SECTION .s16code]
ALIGN 32
[BITS 16]
LABEL_SEG_CODE16:
	; ï¿½ï¿½ï¿½ï¿½ÊµÄ£Ê½
	mov ax, SelectorNormal 
	mov ds, ax 
	mov es, ax 
	mov fs, ax
	mov gs, ax  
	mov ss, ax 

	mov eax, cr0 
	and al, 11111110b 
	mov cr0, eax 

LABEL_GO_BACK_TO_REAL:
	jmp 0:LABEL_REAL_ENTRY

Code16Len equ $ - LABEL_SEG_CODE16

; END of [SECTION .s16code]


; LDT
[SECTION .ldt]
ALIGN 32
LABEL_LDT:       
;                       ¶Î»ùÖ·      ¶Î½çÏÞ       ÊôÐÔ
LABEL_LDT_DESC_CODEA: Descriptor 0, CodeALen - 1, DA_C + DA_32 ; Code, 32Î»

LDTLen equ $ - LABEL_LDT

; LDT Ñ¡Ôñ×Ó
SelectorLDTCodeA equ LABEL_LDT_DESC_CODEA - LABEL_LDT + SA_TIL
; END of [SECTION .16]


; CodeA (LDT, 32 Î»´úÂë¶Î)
[SECTION .la]
ALIGN	32
[BITS	32]
LABEL_CODE_A:
	mov	ax, SelectorVideo
	mov	gs, ax			; ÊÓÆµ¶ÎÑ¡Ôñ×Ó(Ä¿µÄ)

	mov	edi, (80 * 13 + 0) * 2	; ÆÁÄ»µÚ 10 ÐÐ, µÚ 0 ÁÐ¡£
	mov	ah, 0Ch			; 0000: ºÚµ×    1100: ºì×Ö
	mov	al, 'L'
	mov	[gs:edi], ax

	; ×¼±¸¾­ÓÉ16Î»´úÂë¶ÎÌø»ØÊµÄ£Ê½
	jmp	SelectorCode16:0
CodeALen	equ	$ - LABEL_CODE_A
; END of [SECTION .la]


;-----------------------------------------------------------------------
; ï¿½ï¿½Ê¾ALï¿½Ðµï¿½ï¿½ï¿½ï¿½ï¿½
; Ä¬ï¿½ÏµÄ£ï¿½
; ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ALï¿½ï¿½
; ediÊ¼ï¿½ï¿½Ö¸ï¿½ï¿½Òªï¿½ï¿½Ê¾ï¿½ï¿½ï¿½ï¿½Ò»ï¿½ï¿½ï¿½Ö·ï¿½ï¿½ï¿½Î»ï¿½ï¿½
; ï¿½ï¿½ï¿½Ä±ï¿½Ä¼Ä´ï¿½ï¿½ï¿?
; ax, edi
; -----------------------------------------------------------------------
DispAL:
	push ecx
	push edx

	mov ah, 0Ch
	mov dl, al
	shr al, 4
	mov ecx, 2
.begin:
	and al, 01111b
	cmp al, 9
	ja .1
	add al, '0'
	jmp .2
.1:
	sub al, 0Ah
	add al, 'A'
.2:
	mov [gs:edi], ax
	add edi, 2

	mov al, dl
	loop .begin
	add edi, 2

	pop edx
	pop ecx

	ret 
; DispALï¿½ï¿½ï¿½ï¿½--------------------------------------------------------------------







