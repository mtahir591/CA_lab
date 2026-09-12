main:

li x5,4    #a
li x6,3  #b
li x7,0  #i
li x29,0 #j
li x10,0  #base address



LOOP:
blt x7,x5,LOOP01
beq x0,x0,Exit

LOOP01:
addi x29,x0,0
beq x0,x0,LOOP02

LOOP02:
bge x29,x6,INCRMLOOP
slli x3,x29,4
add x4,x10,x3
add x12,x7,x29
sw x12, 0(x4)
addi x29,x29,1
beq x0,x0,LOOP02

INCRMLOOP:
addi x7,x7,1
beq x0,x0,LOOP

Exit:
li a7,10
ecall



