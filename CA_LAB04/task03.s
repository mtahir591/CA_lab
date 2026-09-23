.data
my_array: .word 3, 1, 4, 1, 5, 9
len: .word 6

.text
.globl main
main:
    la x10, my_array       # Load base address of array into x10
    lw x11, len            # Load length of array into x11
    jal x1, bubble         # Call bubble sort function
    
    li a7, 10              # System call for exit
    ecall                  # Stop simulator

bubble:
    beq x10, x0, ret_b     # if a == NULL, return
    beq x11, x0, ret_b     # if len == 0, return
    addi x5, x0, 0         # i = 0

outer:
    bge x5, x11, ret_b     # if i >= len, end sorting
    addi x6, x5, 0         # j = i

inner:
    bge x6, x11, next_i    # if j >= len, loop to next i
    
    slli x7, x5, 2         # Calculate i * 4 (byte offset)
    add x7, x10, x7        # Address of a[i]
    lw x28, 0(x7)          # Load a[i] into x28
    
    slli x29, x6, 2        # Calculate j * 4 (byte offset)
    add x29, x10, x29      # Address of a[j]
    lw x30, 0(x29)         # Load a[j] into x30
    
    bge x28, x30, dont_swap  # if a[i] >= a[j], skip the swap
    
    sw x30, 0(x7)          # Store a[j] into a[i]'s address
    sw x28, 0(x29)         # Store original a[i] into a[j]'s address

dont_swap:
    addi x6, x6, 1         # j++
    jal x0, inner          # Repeat inner loop

next_i:
    addi x5, x5, 1         # i++
    jal x0, outer          # Repeat outer loop

ret_b:
    jalr x0, 0(x1)         # Return to main caller