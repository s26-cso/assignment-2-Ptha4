.section .data
    fmt_digit:    .string "%d "
    newline:      .string "\n"

.section .text
.globl main

#s1 = argc, s2 = argv, s3 = n-1, s4 = loop index, s5 = input_array, s6 = result_array
#s7 = stack_buffer, s10 = current arr[i], s11 = stack offset
main:
    addi sp, sp, -64          # allocate stack space
    sd   ra, 56(sp)     #save ra
    sd   s1, 48(sp)            #caller saved registers
    sd   s2, 40(sp)
    sd   s3, 32(sp)

    mv   s1, a0               # s1 = argc
    mv   s2, a1               # s2 = argv
    
    addi s3, s1, -1           # s3 = args  -1
    ble  s3, zero, finish     # exit if n <= 0

    slli a0, s3, 2            # n * 4
    call malloc
    mv   s5, a0               # s5 = input_array

    slli a0, s3, 2
    call malloc
    mv   s6, a0               # s6 = result_array

    slli a0, s3, 2
    call malloc
    mv   s7, a0               # s7 = stack_buffer (stores indices)

    li   s4, 0                # i = 0

loop:
    bge  s4, s3, start_logic        #if i> n go to logic
    #gettign arv[i+1] first
    addi t0, s4, 1            # index = i + 1
    slli t0, t0, 3            # t0 = index * 8 (pointers - 64 bit)
    add  t0, s2, t0           # Add offset to argv base
    ld   a0, 0(t0)            

    call atoi       #str to int
    
    slli t1, s4, 2            # input_array still uses 4-byte ints
    add  t1, s5, t1
    sw   a0, 0(t1)            # Store 32-bit int

    addi s4, s4, 1      #i++
    j    loop       #loop

start_logic:
    addi s4, s3, -1           # i = n - 1
    li   s11, -4              # s11 = stack offset

nge_loop:
    blt  s4, zero, print_results        #if i < 0, print results
    #load element
    slli t0, s4, 2  
    add  t0, t0, s5   
    lw   s10, 0(t0)           # s10 = current arr[i]

while:
    blt  s11, zero, if_empty

    add  t1, s7, s11          # address of stack top
    lw   t2, 0(t1)            # t2 = index stored at top

    slli t3, t2, 2
    add  t3, t3, s5
    lw   t4, 0(t3)            # t4 = value at that index

    bgt  t4, s10, stack_found_greater 
    
    addi s11, s11, -4         # else pop from stack
    j    while

if_empty:
    li   t5, -1
    j    store_result

stack_found_greater:
    mv   t5, t2               # found index

store_result:
    slli t0, s4, 2
    add  t0, t0, s6
    sw   t5, 0(t0)            # result[i] = t5

    addi s11, s11, 4          # push i
    add  t1, s7, s11
    sw   s4, 0(t1)

    addi s4, s4, -1
    j    nge_loop

print_results:
    li   s4, 0                # i = 0
print_loop:
    bge  s4, s3, finish
    
    slli t0, s4, 2
    add  t0, t0, s6
    lw   a1, 0(t0)            # load result into a1
    la   a0, fmt_digit      #formatting
    call printf

    addi s4, s4, 1
    j    print_loop

finish:
    la   a0, newline
    call printf

    ld   ra, 56(sp)           # Restore 64-bit registers
    ld   s1, 48(sp)
    ld   s2, 40(sp)
    ld   s3, 32(sp)
    addi sp, sp, 64
    li   a0, 0
    ret