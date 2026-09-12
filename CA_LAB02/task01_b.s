main:
li x22,0    #i
li x23,0   #j
li x20,2    #a
li x21,3    #b

loop: 
slli x10,x22,2
add x10,x10,x25
lw x9,0(x10)
bne x9,x24,Exit
addi x22,x22,1
beq x0,x0,loop
Exit:
