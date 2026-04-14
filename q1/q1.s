# node size is 24 - val(4 + 4 bytes padding) + left(8) + right(8)
.globl make_node
.globl insert
.globl get
.globl getAtMost

make_node:
    addi sp, sp, -16
    sd ra, 8(sp)     # use sd to save return address
    sd s0, 0(sp)     # save s0 - current val
    mv s0, a0        # save val to s0
    li a0, 24        # allocating memory
    call malloc      # a0 = pointer to new node
    sw s0, 0(a0)     # val
    sd zero, 8(a0)   # left = NULL
    sd zero, 16(a0)  # right
    ld s0, 0(sp)     # restore s0
    ld ra, 8(sp)     # restore ra
    addi sp, sp, 16
    ret              # a0 still contains the pointer from malloc

#a0 = root, a1 = val
insert:
    bne a0, x0, insert_rec #base case 
    addi sp, sp, -16   #inserting #sp must be a multiple of 16
    sd ra, 0(sp)       # save ra
    mv a0, a1        # make_node expects val in a0
    call make_node     # create new node
    ld ra, 0(sp)       # restore ra
    addi sp, sp, 16
    ret

#s0 = root, s1 = val
insert_rec:
    addi sp, sp, -32
    sd ra, 0(sp)      # save ra
    sd s0, 8(sp)      # save s0 - current root
    sd s1, 16(sp)     # save s1 - val 
    mv s0, a0         # save root to s0
    mv s1, a1         # save val to s1
    lw t0, 0(s0)      # load root->val('lw' for 4-byte int)
    blt s1, t0, insert_left
    bgt s1, t0, insert_right
    j insert_done

#s0 = root, s1 = val
insert_left:
    ld a0, 8(s0)      # load left child #need to update pointer to 8(s0)
    mv a1, s1         # pass val
    call insert
    sd a0, 8(s0)      # update left child pointer
    j insert_done

insert_right:
    ld a0, 16(s0)     # load right child #need to update pointer to 8(s0)
    mv a1, s1         # pass val
    call insert
    sd a0, 16(s0)     # update right child pointer
    j insert_done

insert_done:
    mv a0, s0         # return the original root
    ld ra, 0(sp)
    ld s0, 8(sp)
    ld s1, 16(sp)
    addi sp, sp, 32
    ret

# a0 = root, a1 = val
get:
    # save ra because we are making recursive calls
    addi sp, sp, -16
    sd ra, 0(sp)
    # Edge Case: root is NULL
    beq a0, x0, get_not_found
    lw t0, 0(a0)       # load root->val
    beq a1, t0, get_found 
    blt a1, t0, left
    # else val is greater, go right
    ld a0, 16(a0)    # load right child (offset 16)
    call get         # recursive call
    j get_finish

left:
    ld a0, 8(a0)     # load left child (offset 8)
    call get         # recursive call
    j get_finish

get_found:
    # a0 holds the pointer to the current node, go to finish
    j get_finish

get_not_found:
    li a0, 0         # return null

get_finish:
    ld ra, 0(sp)
    addi sp, sp, 16
    ret

# int getAtMost(int val, struct Node* root)
# a0 = val (int), a1 = root (pointer)
getAtMost:
    # creating stack frame so all paths can use gam_finish
    addi sp, sp, -32
    sd ra, 0(sp)
    sd s0, 8(sp)         # s0 will store val
    sd s1, 16(sp)        # s1 will store current root pointer
    mv s0, a0
    mv s1, a1
    # Base Case: root == NULL
    bne s1, x0, gam_recurse
    li a0, -1            # return -1
    j gam_finish

gam_recurse:
    lw t0, 0(s1)         # t0 = root->val
    # If root->val == val, we found the perfect match
    beq t0, s0, gam_exact
    # go left
    bgt t0, s0, gam_go_left
    # else root->val < val, go right
    mv a0, s0            # a0 = val
    ld a1, 16(s1)        # a1 = root->right
    call getAtMost
    # if (result != -1) return result
    li t1, -1
    bne a0, t1, gam_finish
    # else right subtree had nothing <= val, fall back to current node
    # root->val < val so it is a valid "at most" answer
    lw a0, 0(s1)
    j gam_finish

gam_go_left:
    # root->val > val, so we must go left to find something <= val
    mv a0, s0            # a0 = val
    ld a1, 8(s1)         # a1 = root->left
    call getAtMost
    j gam_finish

gam_exact:
    # root->val == val, which is the best possible match
    # s0 holds val which equals root->val, so either works;
    # reading from the node is clearer
    lw a0, 0(s1)         # return root->val
    j gam_finish

gam_finish:
    ld ra, 0(sp)
    ld s0, 8(sp)
    ld s1, 16(sp)
    addi sp, sp, 32
    ret