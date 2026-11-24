# Lab 10: FSM Implementation
# I/O mapping: s0 is the base address for the memory-mapped I/O

.text
_start:
    addi sp, zero, 1024         # init stack pointer to 0x400
    lui s0, 0x20000             # s0 = 0x2000_0000 (I/O base address)

WAIT_STATE:
    sw zero, 0(s0)              # make sure LEDs are off at the start
    
WAIT_LOOP:
    lw t0, 8(s0)                # read the reset button
    bne t0, zero, WAIT_STATE    # if reset is pressed, stay in wait state
    
    lw a0, 4(s0)                # read switches
    beq a0, zero, WAIT_LOOP     # keep polling if no switches are up
    
    sw a0, 0(s0)                # light up LEDs with the switch value
    jal ra, COUNTDOWN           # jump to countdown subroutine
    jal zero, WAIT_STATE        # go back to start when countdown finishes

# ---------------------------------------------
# Countdown Subroutine
# ---------------------------------------------
COUNTDOWN:
    addi sp, sp, -16            # allocate stack frame
    sw ra, 12(sp)               # save return address since we call another subroutine
    sw s1, 8(sp)                # save s1 (callee saved)
    
    addi s1, a0, 0              # copy initial count to s1
    
CD_LOOP:
    sw s1, 0(s0)                # update LEDs with current count
    beq s1, zero, CD_DONE       # if we hit 0, we are done
    
    jal ra, DELAY               # wait 1 second
    bne a0, zero, CD_EXIT       # if delay returns 1 (reset pressed), exit early
    
    addi s1, s1, -1             # decrement counter
    jal zero, CD_LOOP
    
CD_DONE:
    addi a0, zero, 0            # return 0 for normal completion
    
CD_EXIT:
    lw s1, 8(sp)                # restore registers
    lw ra, 12(sp)
    addi sp, sp, 16             # pop stack
    jalr zero, 0(ra)            # return to main loop

# ---------------------------------------------
# 1 Second Delay loop (for 10MHz clock)
# ---------------------------------------------
DELAY:
    lui t0, 0x262
    addi t0, t0, 0x5A0          # t0 = 2,500,000 iterations
    
DLY_LOOP:
    lw t1, 8(s0)                # poll reset button during the delay
    bne t1, zero, DLY_RST       # break loop immediately if pressed
    
    addi t0, t0, -1
    bne t0, zero, DLY_LOOP
    
    addi a0, zero, 0            # return 0 (no reset)
    jalr zero, 0(ra)
    
DLY_RST:
    addi a0, zero, 1            # return 1 (reset was triggered)
    jalr zero, 0(ra)