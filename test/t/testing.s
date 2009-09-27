.globl main
main:   push $.d
        call puts
        pop %eax
        ret
.d: .ascii "pong"
        .byte 0

