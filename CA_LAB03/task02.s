main:

li x10,3    #g
li x11,3    #h
li x12,0    #i
li x13,3    #j

li x20,0    #f

jal x1,PROCESS
addi x11,x10,0
li x10,1
ecall
beq x0,x0,LOADING
j exit


PROCESS:
addi sp,sp,-28
sw x18,0(sp)
sw x19,4(sp)
sw x20,8(sp)
sw x10,12(sp)
sw x11,16(sp)
sw x12,20(sp)
sw x13,24(sp)


add x18,x10,x11
add x19,x12,x13
sub x20,x18,x19
addi x10,x20,0

addi sp,sp,28
jalr x0,0(x1)


LOADING:
lw x18,0(sp)
lw x19,4(sp)
lw x20,8(sp)
lw x10,12(sp)
lw x11,16(sp)
lw x12,20(sp)
lw x13,24(sp)
beq x0,x0,exit

addi sp,sp,28
jalr x0,0(x1)


exit: