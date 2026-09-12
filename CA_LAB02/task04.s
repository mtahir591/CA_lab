main:
li x5,4    #a
li x6,3  #b
li x7,0  #i
li x29,0 #j
li x10,0x10000000  # FIX: Valid memory address
addi x31, x10, 0   # Base tracker for the current row

LOOP:
blt x7,x5,LOOP01
beq x0,x0,Exit

LOOP01:
addi x29,x0,0      # Reset j to 0 at the start of the row
beq x0,x0,LOOP02

LOOP02:
bge x29,x6,INCRMLOOP # FIX: Stop LOOP02 when j >= b (3)
slli x3,x29,2        # FIX: Shift by 2 (4 bytes per integer)
add x4,x31,x3        # Base address off current row tracker
add x12,x7,x29
sw x12, 0(x4)
addi x29,x29,1
beq x0,x0,LOOP02

INCRMLOOP:
slli x3,x6,2       # Calculate space taken by 1 row (3 columns * 4 bytes)
add x31,x31,x3     # Move our row tracker forward in memory
addi x7,x7,1       # FIX: Increment i here, after the row finishes
beq x0,x0,LOOP

Exit:
li a7,10
ecall
