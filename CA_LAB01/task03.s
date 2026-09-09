main:
    li x20,5  #a=5
    li x21,0  #b=0
    
    addi x20,x21,32  #a=b+32
    add x24,x20,x21 #a+b
    addi x19,x24,-5     #d=a+b-5

    sub x25,x20,x19  #a-d
    sub x26,x21,x20  #b-a
    add x27,x26,x19  #b-a+d

    add x28,x25,x27  #e=a-d+b-a+d
    add x28,x20,x21
    add x28,x19,x28  #e=a+b+d+e


end:
    j end