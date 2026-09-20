main:
    li x10, 0x10000000   # Destination address (String x)
    li x11, 0x10000020   # Source address (String y)
    
    # putting the string "hi\0" into source memory at 0x10000020
    li x5, 0x68          # 'h'
    sb x5, 0(x11)
    li x5, 0x69          # 'i'
    sb x5, 1(x11)
    li x5, 0             # '\0'
    sb x5, 2(x11)

    jal x1, strcpy       
exit:
    li x10, 10           
    ecall


strcpy:
    addi sp, sp, -8      # free 8 bytes on stack
    sw x19, 0(sp)        # Save old x19 register value
    li x19, 0            # i = 0
loop:
    add x5, x11, x19     # Calculate address of y[i]
    lb x6, 0(x5)         # x6 = y[i]
    add x7, x10, x19     # Calculate address of x[i]
    sb x6, 0(x7)         # x[i] = y[i]
    beq x6, x0, done    
    addi x19, x19, 1     # i++
    j loop               
done:
    lw x19, 0(sp)        # Restore old x19 register value
    addi sp, sp, 8       
    jalr x0, 0(x1)       
