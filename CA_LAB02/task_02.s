main:
li x20,2    #x
li x21,0    #a
li x22,2    #b
li x23,3    #c
li x24,1   #1
li x25,2   #2
li x26,3   #3
li x27,4   #4


bne x20,x24,ELSE01
add x21,x22,x23
beq x0,x0,Exit

ELSE01:
beq x20,x25,ELSE02
sub x21,x22,x23
beq x0,x0,Exit

ELSE02:
beq x20,x26,ELSE03
slli x20,x21,1
beq x0,x0,Exit

ELSE03:
beq x20,x27,ELSE04
srli x20,x21,1
beq x0,x0,Exit

ELSE04:
addi x21,x20,0
beq x0,x0,Exit


Exit: