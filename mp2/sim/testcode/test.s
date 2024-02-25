.section .text
.globl _start

_start:
    auipc   x1 , 0
    lui     x2 , 0xAA55A
    addi    x3 , x0, 1
    addi    x4 , x0, -1
    slti    x5 , x3, 2
    slti    x6 , x3, 0
    slti    x7 , x4, 0
    sltiu   x8 , x4, 0
    slli    x9 , x4, 1
    slli    x10, x4, 2
    slli    x11, x4, 4
    slli    x12, x4, 8
    slli    x13, x4, 16
    srai    x14, x2, 1
    srai    x15, x2, 2
    srai    x16, x2, 4
    srai    x17, x2, 8
    srai    x18, x2, 16
    srli    x19, x2, 1
    srli    x20, x2, 2
    srli    x21, x2, 4
    srli    x22, x2, 8
    srli    x23, x2, 16
    sub     x24, x4, x3
    lb      x25, 7(x1)
    lbu     x26, 7(x1)
    lh      x27, 6(x1)
    lhu     x28, 6(x1)
    lw      x29, 4(x1)
    xor     x30, x2, x20
    and     x31, x13, x14
    slti    x0, x0, -256
