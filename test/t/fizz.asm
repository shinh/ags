        BITS    32
        ORG     0

        DB      0x7F                    ; e_ident
entry:
        inc     ebp                     ; e_ident 'E'
        dec     esp                     ; e_ident 'L'
        inc     esi                     ; e_ident 'F'
        inc     EBX
        jmp     short _start
fzbz:	db	"Fizz"
buzz:	db	"B"
        db  "uzz",10
buzz_end:
        dw      2
        dw      3
		db	"0"                         ; e_version
num:	db	"0",10
        db 0
        add     [eax], eax              ; e_entry       ; p_type
        add     [eax], al
        sbb     [eax], al               ; e_phoff       ; p_offset
        add     [eax], al
        sbb     [eax], al               ; e_shoff       ; p_vaddr
        add     [eax], al
 _fizz:	
		mov		CL, fizz_end
		jmp		short _fzbz_last
        DD      0x00210000-0x18         ; e_ehsize      ; p_filesz
                                        ; e_phentsize
        DW      0x0001                  ; e_phnum       ; p_memsz
_buzz_carry:
		inc		byte [EAX]
		mov		byte [ECX], 48
_buzz:
		mov		CL, buzz_end
		cmp     EDI, EDX
		jl		short _out

_fzbz:
		mov		DL, 9
_fzbz_last:
        xor     EDI, EDI
		jmp		short _out

_start:
        mov     CL, 100
_loop:
        push    ECX
        mov     DL, 5

		inc		EDI
		inc		EDI

        mov     CL, num
        mov     AL, num-1

		inc		byte [ECX]

		cmp		byte [ECX], 58
		je      _buzz_carry
		cmp		byte [ECX], 53
		je      _buzz

		cmp     EDI, EDX
		jge		_fizz

        mov     CL, num+2
        mov     DL, byte [EAX]
        dec     EDX
        sar     EDX, 4
_out:
        sub     CL, DL
        mov     AL, 4    ; write = 4
        int     0x80

        pop     ECX
        loop    _loop
fizz:   db      "Fizz",10
fizz_end:
