

# ====== DATA SEGMENT ====== #
.data
msgTV: .asciiz "Entre com o tamanho dos vetores (máx. = 8):\n"
msgVI: .asciiz "Valor invalido\n"
printVetorA: .asciiz "Vetor_A"
printVetorB: .asciiz "Vetor_B"
enter:  .asciiz "Insira o(s) "
msgNumerosVetorA:  .asciiz " numeros do primeiro array:\n"
msgNumerosVetorB: .asciiz " numeros do segundo array:\n"
open:   .asciiz "["
close:  .asciiz "] = "
comma:  .asciiz ", "
lf: .asciiz "\n"
Vetor_A: .word   0,0,0,0,0,0,0,0   # first array
Vetor_B: .word   0,0,0,0,0,0,0,0   # second array

#  syscall variables
printi: .word   1   # print_int
printf: .word   2   # print_float
prints: .word   4   # print_string
readi:  .word   5   # read_int
readf:  .word   6   # read_float
sbrk:   .word   9
exit:   .word   10

# ====== TEXT SEGMENT ====== #
.text
main:
    # initializing and describing the registers
    li $s0, 8       # vector size
    li $s6, 0       # tracks which array is being requested for data
    li $s5, 0       # temporarily stores arrays
    li $s7, 0       # temporarily stores arrays
    li $t9, 0       # loop iterator
    li $t6, 0        # temporarily stores jump address
    li $s4 , 0      # temporarily stores values
    li $s3 , 0      # temporarily stores values

      #  message to request vector size
    la $a0, msgTV #loads the address
    lw $v0, prints   #loads the text
    syscall #displays

    # request the size while it is less than 2 or greater than 8
    loop:
    lw $v0, readi  # gets the vector size to store in $s0
    syscall
    bltu $v0,2, mensagem_erro # if value entered is less than 2 = error message
    bgtu $v0,8,mensagem_erro # if value entered is greater than 8 = error message
    j continua_loop #if it passes the conditions, end the loop

    mensagem_erro:
    la $a0, msgVI
    lw $v0, prints
    syscall
    j loop # returns to the start of the loop

    continua_loop:
    add $s0, $zero, $v0     # stores the array size value in $s0

    # dynamically allocates vector_A
    mul $t1, $s0, 4     # puts size * 4 in $t1
    add $a0, $zero, $t1 # puts the multiplication result in $a0
    lw $v0, sbrk        # allocates size * 4 bytes in memory
    syscall
    sw $v0, Vetor_A      # stores the value returned by sbrk in Vetor_A

    # dynamically allocates vector_B
    lw $v0, sbrk        # allocates another size * 4 bytes in memory
    syscall
    sw $v0, Vetor_B      # stores the value returned by sbrk in Vetor_B

    # fills vector_A with 0
    lw $s7, Vetor_A
    jal inicializa_array


     # fills vector_B with 0
    lw $s7, Vetor_B
    jal inicializa_array

    # requests data input for vector_A
    jal print_enter
    la $a0, msgNumerosVetorA
    lw $v0, prints
    syscall

    # fills vector_A
    addu $s6, $zero, 0 #Adds 0 to s6 to mark that it is vector A
    lw $s7, Vetor_A
    jal preencher_array

    # requests data input for vector_B
    jal print_enter
    la $a0, msgNumerosVetorB
    lw $v0, prints
    syscall

    # fills vector_B
    addu $s6, $zero, 1 #Adds 1 to s6 to mark that it is vector B
    lw $s7, Vetor_B
    jal preencher_array

    # swaps the values of the vectors
    lw $s7, Vetor_A
    lw $s5, Vetor_B
    jal inverter_array

    # shows the values of vector_A
    addu $s6, $zero, 0 #Adds 0 to s6 to mark that it is vector A
    lw $s7, Vetor_A
    jal print_array

    # shows the values of vector_B
    addu $s6, $zero, 1 #Adds 1 to s6 to mark that it is vector B
    lw $s7, Vetor_B
    jal print_array
    
    b end
    
inicializa_array:
    la $t9, ($zero)     # sets iterator to 0
    inicializa_array_for:
    bge $t9, $s0, end_inicializa_array

    sw $zero, ($s7)       # puts 0 at the current index

    add $s7, $s7, 4     # gets the address of the next element
    add $t9, $t9, 1     # increments the iterator
    b inicializa_array_for
end_inicializa_array:
jr $ra
    
print_enter:
    # displays "Insira o(os) "
    la $a0, enter
    lw $v0, prints
    syscall
    # displays the number of elements to be inserted
    add $a0, $zero, $s0
    lw $v0, printi
    syscall
    jr $ra
    
inverter_array:
    la $t9, ($zero)     # sets iterator to 0
    inverter_array_for:
    bge $t9, $s0, end_inverter_array #Ends the loop after iterating through all array slots

    lw $s4,($s5)    # Temporarily saves the value of vector B in $s4
    lw $s3,($s7)    # Temporarily saves the value of vector A in $s3
    sw $s4 , ($s7)      # Moves the value from vector B to vector A
    sw $s3, ($s5)       # Moves the value from vector A to vector B

    add $s7, $s7, 4     # gets the address of the next element of the vector
    add $s5, $s5, 4     # gets the address of the next element of the vector
    add $t9, $t9, 1     # increments the iterator
    b inverter_array_for
end_inverter_array:
    jr $ra

preencher_array:
    la $t9, ($zero)     # sets iterator to 0
    preencher_array_for:
    bge $t9, $s0, end_preencher_array #Ends the loop after filling all array slots

    # gets the user's value
    add $t6, $zero, $ra # temporarily stores the return address of the jump
    jal exibeTextoVetor
    add $ra, $zero, $t6 # restores the jump return address to register $ra
    lw $v0, readi
    syscall

    sw $v0, ($s7)       # stores the value at the current index

    add $s7, $s7, 4     # gets the address of the next element of the array
    add $t9, $t9, 1     # increments the iterator
    b preencher_array_for
end_preencher_array:
    jr $ra

exibeTextoVetor: # Displays Vetor_A[] = or Vetor_B[] =
    beq $s6, 1, printArrayB
    la $a0, printVetorA
    lw $v0, prints
    syscall
    j continuaExibeTextoVetor
    printArrayB:
    la $a0, printVetorB
    lw $v0, prints
    syscall
    continuaExibeTextoVetor:
    la $a0, open
    lw $v0, prints
    syscall
    la $a0, ($t9)
    lw $v0, printi
    syscall
    la $a0, close
    lw $v0, prints
    syscall
    jr $ra
    
print_array:
    la $t9, ($zero)     # sets iterator to 0
print_array_for:
bge $t9, $s0, end_print_array # iterates through to the penultimate element of the array
    la $a0, lf
    lw $v0, prints
    syscall
    add $t6, $zero, $ra # temporarily stores the return address of the jump
    jal exibeTextoVetor
    add $ra, $zero, $t6 # restores the address to register $ra
    # displays the element at the current index
    lw $a0, ($s7)
    lw $v0, printi
    syscall

    add $s7, $s7, 4     # gets the address of the next element of the array
    add $t9, $t9, 1     # increments the iterator
    b print_array_for
end_print_array:
    jr $ra

end:
    lw $v0, exit
    syscall
