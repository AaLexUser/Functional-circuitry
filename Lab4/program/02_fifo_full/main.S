# RISC-V Fifo program
#
# Alexey Lapin , 2024
#

#                Past to your favorite python interpreter :D
#                   #|     any    | rs1 | func3 | any  | opcode |
# push(a0) = hex(int('000000000000_01010___010___00000_0100011'.replace('_', ''), 2)) #-->0x52023
#                     
#                   #|-----12-----|--5--|---3---|--5--|---7----|

#                   #|       any      | func3 | rd  | opcode |
# pop(a1) = hex(int('00000000000000000___010___01011_0000011'.replace('_', ''), 2)) #-->0x2583
#
#                   #|--------17------|---3---|--5--|---7----|

.macro push %s
    sw zero, 0(%s)
.end_macro

.macro pop %d
    lw %d, 0(zero)
.end_macro
            .text
start:      mv    a0, zero
fifo:       addi  a0, a0, 8
            push  a0
            addi  a0, a0, 7
            push  a0
            addi  a0, a0, 6
            push  a0
            addi  a0, a0, 5
            push  a0
            addi  a0, a0, 4
            push  a0
            addi  a0, a0, 3
            push  a0
            addi  a0, a0, 2
            push  a0
            addi  a0, a0, 1
            push  a0
            pop   a1
            pop   a1
            pop   a1
            pop   a1
            pop   a1
            pop   a1
            pop   a1
            pop   a1



#               #|     imm    | rs1 | func3 | rd  | opcode |
# mv  a0, zero -> 000000000000_00000___000___01010__0110011 --> 0x00000513
# mv  t0, zero -> 000000000000_00000___000___00101__0110011 --> 0x000002b3
#               #|-----12-----|--5--|---3---|--5--|---7----|
# mv a0, zero equals to addi a0, zero, 0
# a0 adress is 10 (01010)
# t0 adress is 5 (00101)
# see more in schoolRISCV/doc/riscv-card.pdf 


# bin(int('abc', 16))[2:].zfill(32) -- hex to bin

