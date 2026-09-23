main:
    addi x10, x0, 4      # Set input argument (num = 4)
    jal x1, ntri         # Call the recursive function

    addi a7, x0, 1       # System call code 1: Print integer
    ecall                # Prints the final answer to the console

    addi a7, x0, 10      # System call code 10: Exit
    ecall

ntri:
    addi x5, x0, 1       # Load 1 into x5
    ble x10, x5, base    # If num (x10) <= 1, jump to 'base'

    addi sp, sp, -8      # Open 8 bytes of space on the stack
    sw x1, 4(sp)         # Save the return address
    sw x10, 0(sp)        # Save the current 'num'

    addi x10, x10, -1    # Change argument to num - 1
    jal x1, ntri         # Jump back to the top of ntri

    lw x6, 0(sp)         # Load the original 'num' into x6
    lw x1, 4(sp)         # Restore the return address
    addi sp, sp, 8       # Close the stack space

    add x10, x6, x10     # x10 = original num (x6) + returned result (x10)
    jalr x0, 0(x1)       # Return to the caller

base:
    addi x10, x0, 1      # Set return value to 1
    jalr x0, 0(x1)       # Return to the caller