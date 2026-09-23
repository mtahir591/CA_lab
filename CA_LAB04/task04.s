# Recursive Array Sum: Combines array memory access (Task 3), recursion & stack (Task 2), and addition (Task 1)

.data
my_array: .word 5, 10, 15    # Create an array with 3 numbers in memory
len: .word 3                 # Set the length of the array to 3
.text
.globl main
main:
    la x10, my_array         # Load the base address of the array into x10
    lw x11, len              # Load the length of the array into x11
    jal x1, array_sum        # Jump and link to the recursive function

    addi a7, x0, 1           # Set system call code to 1 (Print Integer)
    ecall                    # Print the final computed sum to the console

    addi a7, x0, 10          # Set system call code to 10 (Exit Program)
    ecall                    # Stop the simulator

array_sum:
    beq x11, x0, base_case   # If length is 0, jump to the base case

    addi sp, sp, -8          # Open 8 bytes of space on the stack
    sw x1, 4(sp)             # Save the return address on the stack
    lw x7, 0(x10)            # Load the current array element into x7
    sw x7, 0(sp)             # Save the current element on the stack

    addi x10, x10, 4         # Move the array pointer forward by 4 bytes (next element)
    addi x11, x11, -1        # Decrease the remaining length by 1
    jal x1, array_sum        # Recursively call the function for the rest of the array

    lw x7, 0(sp)             # Restore the saved array element from the stack
    lw x1, 4(sp)             # Restore the saved return address from the stack
    addi sp, sp, 8           # Close the 8 bytes of space on the stack

    add x10, x10, x7         # Add the current element to the total sum returned
    jalr x0, 0(x1)           # Return to the caller

base_case:
    addi x10, x0, 0          # Set the return value (sum) to 0
    jalr x0, 0(x1)           # Return to the caller