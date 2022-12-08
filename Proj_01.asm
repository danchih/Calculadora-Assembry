TITLE DANIELA AKEMI HAYASHI                  RA:22001201
TITLE GIOVANA SALAZAR ALARCON                RA:22001138

.model small
.stack 100H
.data
    MENU DB 10,'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'       ;DB = MSG = endereco do primeiro character / DB = define byte
    DB 10,9,9,'CALCULADORA ASSEMBLY',10                                         ;9 = tab / 10 = pular linha / 13= ENTER
    DB '=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'               ;
    DB 10,' Operacoes Matematicas Disponiveis no Sistema:'                      ;
    DB 10,' (+) ADICAO'                                                         ;
    DB 10,' (-) SUBTRACAO'                                                      ;
    DB 10,' (*) MULTIPLICACAO'                                                  ;
    DB 10,' (/) DIVISAO'                                                        ;
    DB 10,'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'            ;
    DB 10,' Escolha o simbolo da operacao que deseja realizar: $'               ;$ = simboliza o termino da frase
    INFO DB 10,' ERRO!!! Digite um dos simbolos acima (+)(-)(*)(/): $'                
    OPERACAO DB 10,10,'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'
    DB 10,' Digite 2 valores para serem utilizados na operacao $'
    DIGITENUMERO DB 10,' (Escolha numeros inteiros de 0 a 9)'
    DB 10,10,10,' OPERACAO: $'
    NUMERO0 DB 10,' (Escolha numeros inteiros de 0 a 9)'
    DB 10,' ATENCAO! Divisor tem que ser diferente de 0 !!!'
    DB 10,10,' OPERACAO: $'
    RESTO DB 9,9,'RESTO: ', '$'
    CONTINUAR DB 10,10,' Deseja continuar a fazer os calculos? '
    DB 10,' (se sim digite s): $'
    OPERADOR DB ?    
    CONTADOR DB 0Dh

.code
main PROC
    MOV AX,@DATA            ;inicializa o DS (segmento de dados) com o endereco do segundo dado
    MOV DS,AX               ;

NOVO_CALCULO:
    CALL CLEAR              ;funcao que limpa a tela

    XOR CX,CX               ;zera o registrador CX
    XOR BX,BX               ;zera o registrador BX
    MOV OPERADOR,00H        ;o OPERADOR nesse caso tambem esta sendo zerado
    MOV CONTADOR,0DH        ;

    MOV AH,09               ;imprime uma string
    LEA DX,MENU             ;LEA tem a mesma funcao do OFFSET (pega o endereco onde comeca a string)
    INT 21H                 ;
    JMP ESCOLHA             ;

REPETE:                     ;faz a repeticao caso o usuario digite um numero diferente de 1 a 4
    MOV AH,09               ;
    LEA DX,INFO             ;
    INT 21H                 ;

ESCOLHA:                    ;faz o pulo para usuario encolher sua primeira opcao / caso o valor esteja errado, ira ocorrer o salto REPETE
    MOV AH,01               ;leitura de um character digitado
    INT 21H                 ;sempre que utilizar essa funcao, a mensagem e lida pelo sistema operacional e retorna no registrador AL 
    MOV CL,AL               ;CL recebe o valor contido em AL (CL <- AL)

    CMP CL,'+'              ;compara se CL e igual a '+'
    JE SOMA                 ;faz o salto caso CL for igual
    CMP CL,'-'              ;
    JE SUBTRAI              ;
    CMP CL,'*'              ;
    JE MULTIPLICA           ;
    CMP CL,'/'              ;
    JE DIVIDE               ; 
    
    ADD CONTADOR, 1
    JMP REPETE              ;faz um salto para REPETE

SOMA:
    PUSH CX                 ;salva o conteudo de CX na pilha
    CALL LEITURA            ;chama o procedimento LEITURA
    CALL ADICAO             ;chama o procedimento ADICAO
    JMP FINAL               ;faz um salto para o FINAL
SUBTRAI:
    PUSH CX                 ;
    CALL LEITURA            ;
    CALL SUBTRACAO          ;
    JMP FINAL               ;
MULTIPLICA:
    PUSH CX                 ;
    CALL LEITURA            ;chama o procedimento LEITURA
    CALL MULTIPLICACAO      ;
    JMP FINAL               ;
DIVIDE:
    MOV OPERADOR,CL         ;OPERADOR recebe o conteudo de CL
    PUSH CX                 ;
    CALL LEITURA            ;chama o procedimento LEITURA
    CALL DIVISAO            ;

FINAL:
    CALL IMPRIME            ;

    MOV AH,09               ;imprime uma string
    LEA DX,CONTINUAR        ;
    INT 21H                 ;

    MOV AH,01               ;leitura de um character digitado
    INT 21H                 ;
    CMP AL,'s'              ;compara se AL e igual a s
    JE NOVO_CALCULO         ;faz o salto se AL for igual a s 

    MOV AH,4CH              ;exit
    INT 21H                 ;

main ENDP

CLEAR PROC
    MOV AX, 0003h           ;funcao que limpa tela
    INT 10h                 ;int 10h - bios do sistema
    RET
CLEAR ENDP 

LEITURA PROC
;faz a leitura de dois numeros inteiros
;entradas: CL
;saida: BX

    POP SI                  ;recupera o endereco do topo da pilha (SI = guarda o topo da pilha)
    POP CX                  ;recupera o conteudo de CX da pilha            

    MOV AH,09               ;imprime uma string
    LEA DX,OPERACAO         ;LEA tem a mesma funcao do OFFSET (pega o endereco onde comeca a string)
    INT 21H                 ;

DIGITENUMERO1:  
    MOV AH, 02h             ;funcao que seta cursor 
    MOV BH, 00h             ;pagina em que o cursor sera setado (sempre 0)
    MOV DH, CONTADOR        ;fileira em que sera setado
    MOV DL,CH               ;coluna em que sera setado
    INT 10h                 ;ira ser setado na parte da insercao da operacao
    MOV AH,09               ;imprime uma string
    LEA DX,DIGITENUMERO     ;
    INT 21H                 ;
    JMP CONTA               ;faz esse salto para a primeira conta que sera digitada sem a necessidade de aparecer o aviso de divisao por 0

IMPRIMEAVISO:               ;funcao que imprimira aviso caso divisor seja 0
    MOV AH, 02h             ;funcao que seta cursor 
    MOV BH, 00h             ;pagina em que o cursor sera setado (sempre 0)
    MOV DH, CONTADOR        ;fileira em que sera setado
    MOV DL,CH               ;coluna em que sera setado
    INT 10h                 ;ira ser setado na parte da insercao da operacao
    MOV AH,09               ;
    LEA DX,NUMERO0          ;imprime mensagem de erro em caso de existencia de divisao por 0
    INT 21H                 ;

CONTA:
    MOV AH,01               ;leitura de um character digitado
    INT 21H                 ;sempre que utilizar essa funcao, a mensagem e lida pelo sistema operacional e retorna no registrador AL 
    CMP AL,39H              ;compara se AL e igual a numero ou nao (AL <= 39H, numero)
    JG DIGITENUMERO1         ;faz o salto caso AL e maior que 39H
    CMP AL,30H              ;compara se AL e igual a numero ou nao (AL >= 30H, numero)
    JL DIGITENUMERO1         ;faz o salto caso AL e menos que 30H
 
    MOV BL,AL               ;BL recebe o valor contido em AL (BL <- AL)

    MOV AH,02               ;
    MOV DL,CL               ;imprime o conteudo de CL (nesse caso seria o simbolo da operacao)
    INT 21H                 ;
 
    MOV AH,01               ;leitura de um character digitado
    INT 21H                 ;
    CMP AL,39H              ;
    JG DIGITENUMERO1        ;
    CMP AL,30H              ;
    JL DIGITENUMERO1        ;
           
    CMP OPERADOR,'/'        ;compara se OPERADOR que foi digitado e uma operacao de divisao
    JNZ NAO_DIV             ;faz o salto caso nao for divisao
    CMP AL,30H              ;verifica se AL é igual a 0
    JZ IMPRIMEAVISO         ;caso AL seja igual a 0, imprime erro

NAO_DIV:
    MOV BH,AL               ;BH recebe o valor contido em AL (BH <- AL)

    MOV AH,02               ;
    MOV DL,'='              ;imprime o igual '='
    INT 21H                 ;

    AND BL,0FH              ;transforma o character (hexadecimal) em numero (decimal)
    AND BH,0FH              ;

    PUSH BX                 ;salva o conteudo de BX na pilha
    PUSH SI                 ;salva o endereco do topo da pilha (SI = guarda o topo da pilha)
    RET                     ;retorno do procedimento

LEITURA ENDP

ADICAO PROC
;faz a soma de dois numeros inteiros
;entrada: BX
;saida: BX = BL+BH (adicao)

    POP SI                  ;recupera o endereco do topo da pilha (SI = guarda o topo da pilha)
    POP BX                  ;recupera o conteudo de BX da pilha

    ADD BL,BH               ;soma o conteudo de BL com o de BH e armazena em BL

    PUSH BX                 ;salva o conteudo de BX na pilha
    PUSH SI                 ;salva o endereco do topo da pilha (SI = guarda o topo da pilha)
    RET                     ;retorno do procedimento

ADICAO ENDP

SUBTRACAO PROC
;faz a subtracao de dois numeros inteiros
;entrada: BX
;saida: BX = BL-BH (subtracao)

    POP SI                  ;recupera o endereco do topo da pilha (SI = guarda o topo da pilha)
    POP BX                  ;recupera o conteudo de BX da pilha

    CMP BL,BH               ;compara se BL e igual a BH 
    JGE MAIORIGUAL          ;faz o salto caso BL for maior ou igual a BH

    SUB BL,BH               ;subtrai BL de BH e guarda o resultado em BL (exemplo: 1-3=2)
    NEG BL                  ;substitui o conteudo de BL pelo seu complemento de 2

    MOV AH,02               ;
    MOV DL,'-'              ;imprime o menos '-'
    INT 21H                 ;
    JMP RESULTADO           ;faz um salto para o RESULTADO

MAIORIGUAL:
    SUB BL,BH               ;subtrai BL de BH e guarda o resultado em BL (exemplo: 3-1=2)

RESULTADO:
    PUSH BX                 ;salva o conteudo de BX na pilha
    PUSH SI                 ;salva o endereco do topo da pilha (SI = guarda o topo da pilha)
    RET                     ;retorno do procedimento

SUBTRACAO ENDP

MULTIPLICACAO PROC
;faz a multiplicacao de dois numeros inteiros por soma e deslocamento
;entrada: BX
;saida: BX = BX*AX (produto)

    POP SI                  ;recupera o endereco do topo da pilha (SI = guarda o topo da pilha)
    POP BX                  ;recupera o conteudo de BX da pilha

    XOR AX,AX               ;zera o registrador AX
    XCHG BL,AL              ;faz a troca do conteúdo do byte baixo de BX com o do byte baixo de de AX

SALTO:
    TEST BH,1               ;faz o teste para ver se o valor contido em BH termina com 1 ou 0 (LSB) / (mesma funcao que o AND porem nao substitui o conteudo de BH)
    JZ PAR                  ;faz o pulo caso BH for igual a 0
    ADD BL,AL               ;BL <- BL + AL

PAR:
    SHL AL,1                ;desloca AL uma casa para a esquerda
    SHR BH,1                ;desloca BH uma casa para a direita
    JNZ SALTO               ;faz o salto enquanto BH for diferente de 0

    PUSH BX                 ;salva o conteudo de BX na pilha
    PUSH SI                 ;salva o endereco do topo da pilha (SI = guarda o topo da pilha)
    RET                     ;retorno do procedimento

MULTIPLICACAO ENDP

DIVISAO PROC
;faz a divisao de dois numeros inteiros 
;entrada: nao ha
;saida: BX = BH/BL (divisao)

    POP SI                  ;recupera o endereco do topo da pilha (SI = guarda o topo da pilha)
    POP BX                  ;recupera o conteudo de BX da pilha
    XCHG BL,BH              ;inverte os conteudos de BL e BH pois a leitura do registradores durante o programa de divisao tem seu conteudo invertido

    XOR CX,CX               ;zera o registador CX
    CMP BL,BH               ;compara se o DIVISOR (BL) e igual ao DIVIDENTO (BH)
    JA FIM_DIVISAO          ;faz um salto para o FIM_DIVISAO caso o BL (DIVISOR) for maior do que BH (DIVIDENTO), pois desse modo nao sera possivel fazer a divisao

    MOV CH,BL               ;servira para guardar o valor de BL (DIVISOR) para ser comparado com ele mesmo porteriormente
    SHL BL,4                ;desloca o valor de BL 4 casas para a esquerda
                            ;posteriormente esse deslocamento servira para que ocorra a subtracao do DIVIDENDO com o DIVISOR (como acorre no processo de divisao)

REPETE2:
    CMP BL,BH               ;compara se o DIVISOR (BL) e igual ao DIVIDENTO (BH)
    JBE COMECO_DIVISAO      ;faz o salto caso BL (DIVISOR) for menor ou igual a BH (DIVIDENDO)
    SHR BL,1                ;desloca BL (DIVISOR) uma casa para a direita
    JMP REPETE2             ;repete ate que ocorra o salto COMECO_DIVISAO

COMECO_DIVISAO:
    SUB BH,BL               ;BH <- BH - BL
    CMP BH,0                ;compara se BH (nesse caso atuando como RESTO) e menor ou igual a 0
    JL RESTO_MENOR_0        ;faz o salto caso BL (nesse caso o RESTO) for menor que zero (para numeros sinalizados)

    SHL CL,1                ;desloca CL uma casa para a esquerda
    INC CL                  ;incrementa CL (QUOCIENTE) em 1 unidade (para mostrar que foi possivel fazer a subtracao da divisao (resto maior ou igual a zero))
    JMP CONTINUA

RESTO_MENOR_0:
    ADD BH,BL               ;adiciona BH (RESTO) com BL (DIVISOR) para restaurar seu valor como RESTO
    SHL CL,1                ;desloca CL uma casa para a esquerda                  

CONTINUA:
    SHR BL,1                ;desloca BL (DIVISOR) uma casa para a direita
    CMP BL,CH               ;compara se BL (DIVISOR) tem o mesmo valor de quando ele foi digitado
    JAE COMECO_DIVISAO      ;faz o salto caso BL (DIVISOR) for maior ou igual ao valor CH (DIVISOR inicialmente digitado sem alteracao no decorrer do programa) 
                            ;(pois nao se pode fazer uma subtracao entre o dividendo e o divisor que da um numero negativo como resultado do resto)

FIM_DIVISAO:
;BL = DIVISOR
;BH = DIVIDENDO (na entrada de seu valor) e RESTO (ao final de todo processo)
;CL = QUOCIENTE

    MOV BL,CL               ;BL (que e DIVISOR) recebe o valor de CL (tornando-o o QUOCIENTE)

    PUSH BX                 ;salva o conteudo de BX na pilha
    PUSH SI                 ;salva o endereco do topo da pilha (SI = guarda o topo da pilha)
    RET                     ;retorno do procedimento

DIVISAO ENDP

IMPRIME PROC
;imprime um numero decimal de ate 2 digitos
;entradas: BX
;saída: nao ha

    POP SI                  ;recupera o endereco do topo da pilha (SI = guarda o topo da pilha)
    POP BX                  ;recupera o conteudo de BX da pilha
    
    CMP BL,9                ;compara se BL e igual a 9
    JA MAIOR_9              ;faz o salto caso BL for maior que 9

    OR BL,30H               ;transforma o numero (decimal) de volta a um character (hexadecimal)
    MOV AH,02               ;
    MOV DL,BL               ;imprime o valor contido em BL
    INT 21H                 ;
    JMP FIM                 ;faz o salto para o FIM

MAIOR_9:
    XOR AX,AX               ;zera o registrador AX
    XOR BH,BH               ;zera o registrador BH
    MOV AX,BX               ;AX recebe o conteudo de BX
    MOV CL,10               ;CL recebe 10
    DIV CL                  ;faz a divisao de AX com CL / o quociente recebe o valor de AL / o resto recebe o valor de AH 

    MOV BL,AL               ;BL recebe o conteudo de AL
    OR BL,30H               ;transforma o numero (decimal) de volta a um character (hexadecimal)
    MOV BH,AH               ;BH recebe o conteudo de AH
    OR BH,30H               ;transforma o numero (decimal) de volta a um character (hexadecimal)

    MOV AH,02               ;
    MOV DL,BL               ;imprime o valor contido em BL
    INT 21H                 ;

    MOV AH,02               ;
    MOV DL,BH               ;imprime o valor contido em BH
    INT 21H                 ;

FIM:
    CMP OPERADOR,'/'        ;compara se OPERADOR e igual ao simbolo de operacao
    JNZ TERMINO             ;faz o salto caso OPERADOR nao for uma operacao de divisao

    MOV AH,09               ;
    LEA DX,RESTO            ;tem funcao de imprimir string 
    INT 21H                 ;

    OR BH,30H               ;transforma o numero (decimal) de volta a um character (hexadecimal)
    MOV AH,02               ;
    MOV DL,BH               ;imprime o valor contido em BH
    INT 21H                 ;

TERMINO:
    PUSH SI                 ;salva o endereco do topo da pilha (SI = guarda o topo da pilha)
    RET                     ;retorno do procedimento

IMPRIME ENDP
END main