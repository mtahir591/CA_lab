main:
li x10,0   #v
li x11,0   #k
li x12,0   #temp01
li x13,9   #temp02

jal x1,SWAP

SWAP:
sw 
slli x11,x11,2
add x12,x10,x11

