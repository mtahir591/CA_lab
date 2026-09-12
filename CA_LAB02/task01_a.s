li x22,0    #i
li x23,0   #j
li x20,2    #a
li x21,3    #b


main:
bne x22,x23,else
add x19,x20,x21
beq x0,x0,Exit
else:
sub x19,x20,x21
Exit: