main:
    li x10, 0x10000000   # v
    li x11, 0            # k
    li x12, 0            # temp

    # Initialize test numbers in memory before swapping
    li x5, 55            # Load number 55
    sw x5, 0(x10)        # Put 55 into v[0] (Address 0x10000000)
    li x5, 99            # Load number 99
    sw x5, 4(x10)        # Put 99 into v[1] (Address 0x10000004)

    jal x1, SWAP
    j exit

SWAP:
    slli x13, x11, 2       
    add  x14, x13, x10     # x14 = v[k] address
    lw   x15, 0(x14)       # x15 = v[k] (temp)
    lw   x17, 4(x14)      
    sw   x17, 0(x14)       # v[k] = v[k+1]
    sw   x15, 4(x14)       # v[k+1] = temp
    jalr x0, 0(x1)         

exit:
