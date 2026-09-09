main:
li x2,0x100
li x3,0x200
li x4,0x300


li x5,0   #i
li x6,4
li x11,2
li x12,1
FOR:
bge x5,x6,END  #i>4

mul x8,x5,x6
add x9,x0,x8
add x7,x9,x4   
lw x10,0(x7)    #x10=c[i]

mul x13,x5,x11
add x14,x0,x13
add x15,x14,x3
lh x16,0(x15)    #x16=b[i]

mul x17,x5,x12
add x14,x0,x17
add x18,x14,x2  
lb x19,0(x18)    #x19=a[i]

add x10,x19,x16 
sw x10,0(x7)
addi x5,x5,1   #i++
beq x0,x0,FOR



END:
end:
j end