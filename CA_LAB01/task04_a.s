main:
li x10, 0x78786464
li x11, 0xA8A81919

addi x13,x0,0x100
sw x10,0(x13)

addi x14,x0,0x1F0
sw x11,0(x14)

li x5,0x100
lhu x12,0(x5)

li x6,0x1F0
lh x13,0(x6)

li x7,0x1F0
lb x14,0(x7)

