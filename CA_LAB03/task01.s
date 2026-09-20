main:
li x10,3   #a
li x11,2   #b

jal x1,SUM
addi x11,x10,0
li x10,1
ecall
j exit


SUM:
add x10,x10,x11
jalr x0,0(x1)

exit: