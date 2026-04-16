.section .data
filename:    .asciz "input.txt"
yes_msg:     .asciz "Yes\n"
no_msg:      .asciz "No\n"

.section .bss
.align 2
buffer_left:  .space 4
buffer_right: .space 4

.section .text
.globl main

main:
    # open file
    li a0, -100          # cosnst for AT_FDCWD
    la a1, filename     #address of input.txt
    li a2, 0             # 0(O_RDONLY) to a2
    li a7, 56            # syscall: openat
    ecall
    mv s0, a0            # s0 = the returned file descriptor
    bltz s0, exit_err    # if fd < 0, file didnt open,  exit

    # get file size
    mv a0, s0       #fd to a0
    li a1, 0        #offset 
    li a2, 2             # SEEK_END
    li a7, 62            # syscall: lseek
    ecall           #getting current position
    mv s1, a0            # s1 = file size 
    beqz s1, palindrome # if file size is 0, it's a palindrome  

    li t0, 0             # left index
    addi t1, s1, -1      # right index (size - 1)

loop:
    bge t0, t1, palindrome      # l >= r

    # read left char
    mv a0, s0       #fd 
    mv a1, t0       #fp to left idx
    li a2, 0             # SEEK_SET to 0 
    li a7, 62       #lseek 
    ecall

    mv a0, s0       #fd
    la a1, buffer_left      #storing 
    li a2, 1          #read 1 byte
    li a7, 63            # syscall: read
    ecall

    la t4, buffer_left
    lbu t2, 0(t4)        # Load character into t2

    # read right char
    mv a0, s0
    mv a1, t1
    li a2, 0             # SEEK_SET
    li a7, 62
    ecall

    mv a0, s0
    la a1, buffer_right
    li a2, 1
    li a7, 63            # syscall: read
    ecall

    la t4, buffer_right
    lbu t3, 0(t4)        # Load character into t3

    # compare
    bne t2, t3, not_palindrome

    addi t0, t0, 1      # move left pointer forward
    addi t1, t1, -1
    j loop

palindrome:
    li a0, 1             # stdout
    la a1, yes_msg
    li a2, 4             # length of "Yes\n"
    li a7, 64            # syscall: write
    ecall
    j exit_done

not_palindrome:
    li a0, 1             # stdout
    la a1, no_msg
    li a2, 3             # length of "No\n"
    li a7, 64            # syscall: write
    ecall

exit_done:
    # Close file
    mv a0, s0
    li a7, 57            # syscall: close
    ecall

exit_err:
    li a0, 0
    li a7, 93            # syscall: exit
    ecall