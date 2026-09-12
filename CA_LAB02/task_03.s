main:
li x22,0    #i
li x23,0   #sum
li x24,10  #10
li x25,0x200  #base address


LOOP:
bge x22,x24,LOOP02
slli x10,x22,2
add x11,x10,x25
lw x12,0(x11)
addi x12,x22,0
addi x22,x22,1
beq x0,x0,LOOP

LOOP02:
bge x22,x24,Exit
slli x10,x22,2
add x11,x10,x25
lw x12,0(x11)
add x23,x23,x12
addi x22,x22,1
beq x0,x0,LOOP02


Exit: