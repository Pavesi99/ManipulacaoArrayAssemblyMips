

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
Vetor_A: .word   0,0,0,0,0,0,0,0   # primeiro array
Vetor_B: .word   0,0,0,0,0,0,0,0   # segundo array

#  variaveis syscall
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
    # inicializando e descrevendo os registradores
    li $s0, 8       # tamanho do vetor
    li $s6, 0       # para saber qual array esta sendo solicitado os dados
    li $s5, 0       # armazena os arrays temporariamente
    li $s7, 0       # armazena os arrays temporariamente
    li $t9, 0       # loop iterator
    li $t6, 0        # Armezena endereco jump temporario
    li $s4 , 0      # Armazena valores temporariamente
    li $s3 , 0      # Armazena valores temporariamente
    
      #  mensagem para solicitar tamnho do vetor
    la $a0, msgTV #carrega o endereco
    lw $v0, prints   #carrega o texto
    syscall #exibe
    
    # solicita o valor do tamanho enquanto for menor que 2 e maior que 8
    loop:   
    lw $v0, readi  # obtem o tamanho do vetor para guardar em $s0
    syscall
    bltu $v0,2, mensagem_erro # se valor inserido menor que 2 = mensagem de erro
    bgtu $v0,8,mensagem_erro # se valor inserido maior que 8 = mensagem de erro
    j continua_loop #se passar nas codicoes finaliza o loop
    
    mensagem_erro:
    la $a0, msgVI
    lw $v0, prints
    syscall
    j loop # volta para o inicio do loop
    
    continua_loop:
    add $s0, $zero, $v0     # guarda o valor do tamanho dos array em $s0   
    
    # aloca dinamicamente o vetor_A
    mul $t1, $s0, 4     # coloca o tamanho * 4 no $t1
    add $a0, $zero, $t1 # coloca o resultado de mul em $a0
    lw $v0, sbrk        # aloca tamanho * 4 bytes na memoria
    syscall
    sw $v0, Vetor_A      # coloca o valor retornado por sbrk no Vetor_A
    
    # aloca dinamicamente o vetor_B
    lw $v0, sbrk        # aloca outro tamanho * 4 bytes na memoria
    syscall
    sw $v0, Vetor_B      # coloca o valor retornado por sbrk no Vetor_B
    
    # preenche o vetor_A com 0
    lw $s7, Vetor_A
    jal inicializa_array
    
    
     # preenche o vetor_B com 0
    lw $s7, Vetor_B
    jal inicializa_array
    
    # Solicita entrada de dados para vetor_A
    jal print_enter
    la $a0, msgNumerosVetorA
    lw $v0, prints
    syscall
    
    # Preenche o vetor_A
    addu $s6, $zero, 0 #Adiciona 0 a s6 para saber que é o vetor A
    lw $s7, Vetor_A
    jal preencher_array
    
    # Solicita entrada de dados para vetor_B
    jal print_enter
    la $a0, msgNumerosVetorB
    lw $v0, prints
    syscall
    
    # Preenche o vetor_B
    addu $s6, $zero, 1 #Adiciona 1 a s6 para saber que é o vetor B
    lw $s7, Vetor_B
    jal preencher_array
    
    #Inverte os valores dos vetores
    lw $s7, Vetor_A
    lw $s5, Vetor_B
    jal inverter_array
    
    # Mostra os valores do vetor_A
    addu $s6, $zero, 0 #Adiciona 0 a s6 para saber que é o vetor A
    lw $s7, Vetor_A
    jal print_array
  
    # Mostra os valores do vetor_B
    addu $s6, $zero, 1 #Adiciona 1 a s6 para saber que é o vetor B
    lw $s7, Vetor_B
    jal print_array
    
    b end
    
inicializa_array:
    la $t9, ($zero)     # coloca iterator para 0
    inicializa_array_for: 
    bge $t9, $s0, end_inicializa_array
    
    sw $zero, ($s7)       # coloca 0 no atual index
    
    add $s7, $s7, 4     # pega o endereco do proximo elemento
    add $t9, $t9, 1     # incrementa o  iterator
    b inicializa_array_for
end_inicializa_array:
jr $ra
    
print_enter:
    # Exibe "Insira o(os) "
    la $a0, enter
    lw $v0, prints
    syscall
    # Exibe o numero de elementos a ser inserido
    add $a0, $zero, $s0
    lw $v0, printi
    syscall
    jr $ra
    
inverter_array:
    la $t9, ($zero)     # coloca iterator para 0
    inverter_array_for: 
    bge $t9, $s0, end_inverter_array #Finaliza o loop se percorrer todos os slots do array
 
    lw $s4,($s5)    # Salva temporariamente o valor do vetor B em $s4
    lw $s3,($s7)    # Salva temporariamente o valor do vetor A em $s3
    sw $s4 , ($s7)      # Passa o valor do vetor B para o vetor A
    sw $s3, ($s5)       # Passa o valor do vetor A para o vetor B
    
    add $s7, $s7, 4     # pega o endereco do proximo elemento do vetor
    add $s5, $s5, 4     # pega o endereco do proximo elemento do vetor
    add $t9, $t9, 1     # incrementa o iterator
    b inverter_array_for
end_inverter_array:
    jr $ra

preencher_array:
    la $t9, ($zero)     # coloca iterator para 0
    preencher_array_for: 
    bge $t9, $s0, end_preencher_array #Finaliza o loop se preencher todos os slots do array
   
    # obtem o valor do usuario
    add $t6, $zero, $ra # armazena temporariamente o endereco de retorno do jump
    jal exibeTextoVetor
    add $ra, $zero, $t6 # retorna o endereco do jump ao registrador $ra
    lw $v0, readi
    syscall
    
    sw $v0, ($s7)       # guarda o valor no index atual
    
    add $s7, $s7, 4     # pega o endereco do proximo elemento do array
    add $t9, $t9, 1     # incrementa o iterator
    b preencher_array_for
end_preencher_array:
    jr $ra
    
exibeTextoVetor: # Exibe vetor_A[] = ou Vetor_B[] = 
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
    la $t9, ($zero)     # coloca iterator para 0
print_array_for: 
bge $t9, $s0, end_print_array # percorre ate o penultimo elemento do array
    la $a0, lf
    lw $v0, prints
    syscall
    add $t6, $zero, $ra # armazena temporariamente o endereco de retorno do jump
    jal exibeTextoVetor
    add $ra, $zero, $t6 # retorna o endereco ao registrador $ra
    # Exibe o elemento no index atual
    lw $a0, ($s7)
    lw $v0, printi
    syscall

    add $s7, $s7, 4     # obtem o endereco do proximo elemento do array
    add $t9, $t9, 1     # incrementa o iterator
    b print_array_for
end_print_array:
    jr $ra

end:
    lw $v0, exit
    syscall
