main:
    li   x10, 4          # Set input n = 4
    jal  x1, fact_iter   # Call factorial function
    li   x17, 10         # Load exit code
          ecall                # Stop the simulator

fact_iter:
    li   x5, 1           # acc = 1

loop:
    bge  x0, x10, done   # If 0 >= n (n <= 0), exit loop
    mul  x5, x5, x10     # acc = acc * n
    addi x10, x10, -1    # n = n - 1
    j    loop            # Repeat loop

done:
    mv   x10, x5         # Put final answer in x10
    jalr x0, 0(x1)       # Return to main
