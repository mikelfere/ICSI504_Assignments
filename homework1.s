        .data
newl:   .byte '\n'
list:   .word 8, 9, 3, 4, 7, 2, 5, 6, 1
size:   .word 9
olist:  .space 36
count:  .space 40

msg:   .asciiz "Homework 1\n"

        .text
        .globl main

main:   la $s0, list            # load address of list
        lw $s1, size            # n = sizeof(arr)/sizeof(arr[0])

        jal radix_sort          # call radix_sort
        addi $t1, $zero, 0      # start = 0
        jal print_data          # call print_data
        
exit:   li $v0, 10              # end program
        syscall 

get_max:
        lw $s2, 0($s0)          # mx = arr[0] ($s2 represents mx)
        addi $t1, $zero, 1      # int i = 1
loop1:  slt $t0, $t1, $s1       # i < n ? $t0 = 1 : $t0 = 0
        beq $t0, $zero, ret1    # if i >= n then return (ret1)
        add $t2, $zero, $t1     # $t2 = i
        add $t2, $t2, $t2       # $t2 *= 4
        add $t2, $t2, $t2
        add $t2, $t2, $s0       # get address of arr[i] in $t2
        lw $t3, 0($t2)          # get value of arr[i] in $t3
        slt $t0, $s2, $t3       # $s2 < $t3 ? $t0 = 1 : $t0 = 0
        beq $t0, $zero, no_assign   # if $s2 >= $t3 then continue
        move $s2, $t3           # else $s2 = $t3
no_assign:
        addi $t1, $t1, 1        # i++
        j loop1                 # jump back to loop1 (completes for loop)
ret1:   jr $ra                  # jump to caller (return)

count_sort:
        la $t0, olist           # $t0 -> address of output[]
        la $t1, count           # $t1 -> address of count[]
        addi $t2, $zero, 0      # int i = 0

        # initialize count[] with 0s
        addi $t3, $zero, 0      # $t3 = 0
loop2:  add $t4, $t3, $zero     # $t4 = $t3
        add $t4, $t4, $t4       # $t4 *= 4 (4 bytes in a word)
        add $t4, $t4, $t4       
        add $t4, $t1, $t4       # get address of count[$t4] in $t4
        sw $zero, 0($t4)        # count[$t4] = 0
        addi $t3, $t3, 1        # $t3 += 1
        slti $t4, $t3, 10       # if $t3 < 10
        beq $t4, 1, loop2       # then repeat (jump to loop2)
        
loop3:  bge $t2, $s1, out2      # if i >= n then break out (jump to out2)
        add $t3, $zero, $t2     # $t3 = i
        add $t3, $t3, $t3       # $t3 *= 4
        add $t3, $t3, $t3
        add $t3, $t3, $s0       # get address of arr[i] in $t3
        lw $t4, 0($t3)          # $t4 = arr[i]
        div $t4, $t9           
        mflo $t4                # $t4 /= $t9
        div $t4, $s4            
        mfhi $t4                # $t4 %= exp
        add $t4, $t4, $t4       # $t4 *= 4 
        add $t4, $t4, $t4
        add $t4, $t1, $t4       # get address of count[(arr[i]/exp)%10] in $t4
        lw $t5, 0($t4)          # $t5 = count[(arr[i]/exp)%10]
        addi $t5, $t5, 1        # $t5++
        sw $t5, 0($t4)          # count[(arr[i]/exp)%10] = $t5
        addi $t2, $t2, 1        # i++
        j loop3                 # repeat (jump to loop3)

out2:   addi $t2, $zero, 1      # i = 1
loop4:  bge $t2, $s4, out3      # if i >= 10 then break out (jump to out3)
        add $t3, $zero, $t2     # $t3 = i
        add $t3, $t3, $t3       # $t3 *= 4
        add $t3, $t3, $t3       
        add $t3, $t3, $t1       # get address  of count[i] in $t3
        lw $t4, 0($t3)          # $t4 = count[i]
        lw $t5, -4($t3)         # $t5 = count[i-1]
        add $t4, $t4, $t5       # $t4 += $t5 
        sw $t4, 0($t3)          # count[i] = $t4
        addi $t2, $t2, 1        # i++
        j loop4                 # repeat

out3:   addi $t2, $s1, -1       # i = n - 1
loop5:  blt $t2, $zero, out4    # if i < 0 then break out (jump to out4)
        add $t3, $zero, $t2     # $t3 = $t2
        add $t3, $t3, $t3       # $t3 *= 4
        add $t3, $t3, $t3
        add $t3, $t3, $s0       # get address of arr[i] in $t3
        lw $t4, 0($t3)          # $t4 = arr[i]
        move $t7, $t4           # $t7 = $t4 (we will use the value later)
        div $t4, $t9            
        mflo $t4                # $t4 /= $t9 ($t9 = exp)
        div $t4, $s4            
        mfhi $t4                # $t4 %= 10
        add $t3, $t4, $zero     # $t3 = $t4
        add $t3, $t3, $t3       # $t3 *= 4
        add $t3, $t3, $t3
        add $t3, $t3, $t1       # get address of count[(arr[i]/exp)%10] in $t3
        lw $t5, 0($t3)          # $t5 = count[(arr[i]/exp)%10]
        addi $t6, $t5, -1       # $t6 = $t5 - 1
        add $t6, $t6, $t6       # $t6 *= 4
        add $t6, $t6, $t6
        add $t6, $t6, $t0       # get address of output[count[(arr[i]/exp)%10]-1] in $t6
        sw $t7, 0($t6)          # output[count[(arr[i]/exp)%10]-1] = arr[i]
        addi $t5, $t5, -1       # $t5--
        sw $t5, 0($t3)          # count[(arr[i]/exp)%10] = $t5
        addi $t2, $t2, -1       # i--
        j loop5                 # repeat (jump to loop5)

out4:   addi $t2, $zero, 0      # i = 0
loop6:  bge $t2, $s1, out5      # if i >= n then break out (jump to out5)
        add $t3, $zero, $t2     # $t3 = $t2
        add $t3, $t3, $t3       # $t3 *= 4
        add $t3, $t3, $t3
        add $t4, $t3, $t0       # get address of output[i] in $t4
        lw $t4, 0($t4)          # $t4 = output[i]
        add $t5, $t3, $s0       # get address of arr[i] in $t5
        sw $t4, 0($t5)          # arr[i] = output[i]
        addi $t2, $t2, 1        # i++
        j loop6                 # repeat (jump to loop6)
out5:   
        jr $ra                  # return to caller

radix_sort:
        move $s3, $ra           # save return address to caller in main 
        jal get_max             # call get_max -> result stored in $s2 -> m = getMax(arr, n)
        addi $t9, $zero, 1      # int exp = 1
        add $s4, $zero, 10      # $s4 = 10 (will need for many calculations)
loop:   div $s2, $t9            
        mflo $t8                # $t8 = m / exp
        ble $t8, $zero, out6    # if $t8 <= 0 break out (jump to out6)
        jal count_sort          # call count_sort
        mult $t9, $s4
        mflo $t9                # exp *= 10
        j loop                  # repeat (jump to loop)
out6:   move $ra, $s3           # get return address to caller
        jr $ra                  # return to caller

print_data:
        addiu $sp, $sp, -4      # prepare stack to push register
        sw $ra, 0($sp)          # push current $ra to stack
        bge	$t1, $s1, ret2	    # if start < n then do out1
        add $t2, $zero, $t1     # $t2 = start
        add $t2, $t2, $t2       # $t2 *= 4
        add $t2, $t2, $t2       
        add $t2, $t2, $s0       # get address of arr[start] in $t2
        lw $a0, 0($t2)          # set arr[start] for printing
        li $v0, 1               # set system call to print_int
        syscall   
        lb $a0, newl            # set '\n' for printing
        li $v0, 11              # set system call to print_character
        syscall 
        addi $t1, $t1, 1        # start++
        jal print_data          # call print_data
ret2:   lw $ra, 0($sp)          # pop stack and store result in $ra
        addiu $sp, $sp, 4       # adjust stack pointer
        jr $ra                  # return

