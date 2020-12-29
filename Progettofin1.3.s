#progetto Alberto Biliotti
.data
sostK: .word 34
myplaintext: .string "Ciao Pietro!"
div: .word 0          #serve per dividere le stringhe in memoria che altrimenti quando una e' lunga come un multiplo di 4 verrebbero accorpate insieme
mychyper: .string "ADDA"
div2: .word 0
blocKey: .string "ole"
div3: .word 0
acapo: .byte 13       #byte per andare a capo nella ecall
.text
main_PROGETTO:
la a0 myplaintext
addi a1 a0 0
li a0 4
ecall                  #stampo la stringa originale
addi a2 a1 0
la a1 acapo
ecall                        #vado a capo nella stringa finale per visualizzare meglio il risultato
addi a0 a2 0
la s0 mychyper
li s1 65                  #Valore del carattere "A"
li s2 66                  #Valore del carattere "B"
li s3 67                  #Valore del carattere "C"  
li s4 68                  #Valore del carattere "D"
jal Cifrastringa
addi a1 a0 0
li a0 4
ecall                    #stampo la stringa cifrata
addi a0 a1 0
jal Decifrastringa
addi a2 a0 0
li a0 4
la a1 acapo           
ecall                     #vado di nuovo a capo
addi a0 a2 0
j end


#CIFRATORE STRINGA
Cifrastringa:

cifrastrloop:
lb t0 0(s0)
addi s0 s0 1
beq t0 zero endcifrastringa         #Controllo di non essere arrivato alla fine della stringa mychyper
beq t0 s1 cifraSost                 #Controllo a quale istruzione corrisponde la lettera in input
beq t0 s2 CifraBloc
beq t0 s3 CifraOcc
beq t0 s4 CifraDiz
j cifrastrloop


cifraSost:
lw a1 sostK               #carico in a1 la mia variabile (in questo caso di Sostituzione)
addi sp sp -4
sw ra 0(sp)                      #salvo l'indirizzo di ritorno della funzione per evitare che venga sovrascritto col jal successivo
jal Sostituzione
lw ra 0(sp)
addi sp sp 4                     #riequlibro lo stack
j cifrastrloop

#ripeto la stessa operazine per le altre procedure  

CifraBloc:                          
la a1 blocKey                 
addi sp sp -4
sw ra 0(sp)
jal Cifrbloc
lw ra 0(sp)
addi sp sp 4
j cifrastrloop

#per la cifratura a occorenze e a dizionario non devo caricare nessuna variabile di supporto

CifraOcc:            
addi sp sp -4
sw ra 0(sp)
jal occorenze
lw ra 0(sp)
addi sp sp 4
j cifrastrloop

CifraDiz:
addi sp sp -4
sw ra 0(sp)
jal dizionario
lw ra 0(sp)
addi sp sp 4
j cifrastrloop



endcifrastringa:
jr ra                         #ritorno all'istruzione dopo quella che aveva chiamato la funzione


#DECIFRATORE STRINGA
Decifrastringa:           #per il decifratore uso un metodo simile a quello per cifrare ma parto dalla fine della stringa 
addi s0 s0 -1
Decifrastrloop:
addi s0 s0 -1
lb t0 0(s0)
beq t0 zero enddecifrastringa              #controllo di non essere andato troppo indietro nella stringa
beq t0 s1 DecifraSost
beq t0 s2 DecifraBloc
beq t0 s3 DecifraOcc
beq t0 s4 DecifraDiz
j Decifrastrloop

#come nel cifratore per ogni algoritmo assegno la sua variabile di decifratura in a1 dove serve

DecifraSost:      
lw a1 sostK
addi sp sp -4
sw ra 0(sp)
jal DecodificaSost
lw ra 0(sp)
addi sp sp 4
j Decifrastrloop


DecifraBloc:
la a1 blocKey
addi sp sp -4
sw ra 0(sp)
jal DecCifr
lw ra 0(sp)
addi sp sp 4
j Decifrastrloop


DecifraOcc:
addi sp sp -4
sw ra 0(sp)
jal Deocc
lw ra 0(sp)
addi sp sp 4
j Decifrastrloop

DecifraDiz:
addi sp sp -4
sw ra 0(sp)
jal DECdizionario
lw ra 0(sp)
addi sp sp 4
j Decifrastrloop



enddecifrastringa:
addi s0 s0 1                #resetto s0 al valore iniziale visto che è di 'proprietà' del chiamante
jr ra                     #ritorno al main





#CIFRATORE SOSTITUZIONE 
Sostituzione:                #mi salvo i valori che mi serviranno per l'algoritmo
li t1 65         #carico il carattere dai cui partono le maiuscole in ASCII                   
li t2 26        #carico il numero di lettere nell'alfabeto inglese
addi t3 a0 0   #salvo a0 in t3 per non perderlo
li t4 91   #qui finiscono le maiuscole
li a2 123        #qui finiscono le minuscole
li t5 97       #qui iniziano le minuscole
blt a1 zero aggiustaneg         #se la variabile di sostituzione è negativa la devo sistemare
rem a1 a1 t2       #altrimenti se la variabile è postiva faccio il modulo con il numero di lettere nell'alfabeto inglese
j loopsost
aggiustaneg:    #se la variabile è negativa la rendo positiva, ne faccio il modulo e la sotraggo al numero di lettere dell'alfabeto per 'andare in dietro' con le lettere
li t0 -1
mul a1 a1 t0
rem a1 a1 t2
sub a1 t2 a1
loopsost:     #qui prima controllo se il carattere è una lettera maiuscola o minuscola e se lo e' ci sommo la variabile di sostituzione e controllo di non essere andato oltre il limite di lettere dell'alfabeto facendo il modulo della distanza dalla lettera a-A con 26
lb t0 0(t3)
beq t0 zero fine
blt t0 t1 resetloop
bge t0 a2 resetloop
blt t0 t4 Maiusc
blt t0 t5 resetloop
minusc:
add a4 t0 a1
addi a3 a4 -97
rem t6 a3 t2
addi t6 t6 97
sb t6 0(t3)
j resetloop
Maiusc:
add a4 t0 a1
addi a3 a4 -65
rem t6 a3 t2
addi t6 t6 65
sb t6 0(t3)
j resetloop
resetloop:
addi t3 t3 1
j loopsost
fine:         #qui resetto le variabili che ho usato per evitare che vadano a confliggere con altre procedure.
li t0 0
li t1 0
li t2 0
li t3 0
li t4 0
li t5 0
li t6 0
li a2 0
lw a1 sostK
jr ra





#DECIFRATORE SOSTITUZIONE
#per decifrare la stringa con sostituzione basta moltiplicare la variabile per -1 e riapplicare la procedura di sostituzione
DecodificaSost:     
li t1 -1
mul a1 a1 t1
addi sp sp -4
sw ra 0(sp)             #salvo il valore di ritorno della funzione nello stack per evitare che venga sovrascritto dalla funzione che andrò a chiamare
jal Sostituzione
lw ra 0(sp)    #recupero il valore di ra dallo stack
addi sp sp 4
jr ra








#CIFRATORE BLOCCHI
Cifrbloc:     #vado ad azzerare i registri temporanei per evitare che vadano in conflitto con la procedura
li t1 0
li t0 0
li t6 0
li t2 0
add t4 t4 a1
add t3 t3 a1
addi t5 a0 0
lunghstring:       #calcolo la lunghezza della chiave
lb t0 0(t4)
beq t0 zero block
addi t1 t1 1        #t1 conterra' la lunghezza della chiave
addi t4 t4 1
j lunghstring

block: 
lb t0 0(a0)
beq t0 zero finebloc     #controllo che la stringa non sia finita
lb t2 0(t3)
add t0 t2 t0
sb t0 0(a0)
addi t6 t6 1
rem t6 t6 t1
add t3 t6 a1
addi a0 a0 1
j block
finebloc:
addi a0 t5 0
li t0 0
li t1 0
li t2 0
li t3 0
li t4 0
li t5 0
li t6 0
li a2 0
jr ra




#DECIFRATORE BLOCCHI
DecCifr:
li t1 0
li t0 0
li t2 0
li t6 0
addi t4 a1 0
addi t3 a1 0
addi t5 a0 0
DElunghstring:
lb t0 0(t4)
beq t0 zero DEblock
addi t1 t1 1        #t1 conterr? la lunghezza della chiave
addi t4 t4 1
j DElunghstring

DEblock: 
lb t0 0(a0)
beq t0 zero DEfinebloc     #controllo che la stringa non sia finita
lb t2 0(t3)
sub t0 t0 t2
sb t0 0(a0)
addi t6 t6 1
rem t6 t6 t1
add t3 t6 a1
addi a0 a0 1
j DEblock
DEfinebloc:
addi a0 t5 0
li t0 0
li t1 0
li t2 0
li t3 0
li t4 0
li t5 0
li t6 0
li a2 0
jr ra

#CIFRATORE DIZIONARIO
dizionario:
addi a1 a0 0
li t1 48
li t2 58
li t3 65
li t4 91
li t5 97
li t6 123
li a7 26
dizloop:
lb t0 0(a1)
beq t0 zero fineloop
blt t0 t1 sym
blt t0 t2 decnumeri
blt t0 t3 sym
blt t0 t4 decMaiusc
blt t0 t5 sym
blt t0 t6 decMinusc
sym:
addi a1 a1 1
j dizloop

decnumeri:
addi t0 t0 -48
addi sp sp -16
sw a1 0(sp)
sw ra 4(sp)
sw a0 8(sp)
sw t1 12(sp)
addi a0 t0 0
jal calcolafact
mul t0 t0 t0
add a0 t0 a0
addi a0 a0 1
li t1 128
rem a0 a0 t1
add a0 a0 t1
lw a1 0(sp)
sb a0 0(a1)
lw ra 4(sp)
lw a0 8(sp)
lw t1 12(sp)
addi sp sp 16
addi a1 a1 1
j dizloop
decMaiusc:
addi t0 t0 -65
sub t0 a7 t0
addi t0 t0 96
sb t0 0(a1)
addi a1 a1 1
j dizloop

decMinusc:
addi t0 t0 -97
sub t0 a7 t0
addi t0 t0 64
sb t0 0(a1)
addi a1 a1 1
j dizloop
fineloop:
li t0 0
li t1 0
li t2 0
li t3 0
li t4 0
li t5 0
li t6 0
li a2 0
jr ra




calcolafact:
li t1 0
fact:
        addi sp, sp, -8 
        sw  ra, 4(sp) 
        sw  a0, 0(sp)  
        addi a0, a0, -1
        bgt a0, zero, recursion
base_case:
        addi a0, zero, 1
        addi sp, sp, 8 
					jr ra
recursion:
					jal fact
					addi t1, a0, 0 				# Contain partial factorial
        lw a0, 0(sp) 						# Current n
        lw ra, 4(sp) 						# Current ra
        addi sp, sp, 8 
        mul a0, a0, t1
        jr ra

#DECIFRATORE DIZIONARIO
DECdizionario:
addi a1 a0 0
li t1 48
li t2 58
li t3 65
li t4 91
li t5 97
li a7 26
DECdizloop:
lb t0 0(a1)
li t6 -126
beq t0 t6 0
li t6 -125
beq t0 t6 1
li t6 -121
beq t6 t0 2
li t6 -112
beq t6 t0 3
li t6 -87
beq t6 t0 4
li t6 -110
beq t6 t0 5
li t6 -11
beq t6 t0 6
li t6 -30
beq t6 t0 7
li t6 -63
beq t6 t0 8
li t6 -46
beq t6 t0 9
li t6 123
beq t0 zero DECfineloop
blt t0 t1 DECsym
blt t0 t2 DECdecnumeri   #non dovrei mai avere la codifica dei numeri nella stringa finale
blt t0 t3 DECsym
blt t0 t4 DECdecMaiusc
blt t0 t5 DECsym
blt t0 t6 DECdecMinusc
                   #devo per forza analizzare caso per caso le codifiche dei numeri

addi a1 a1 1
j DECdizloop
DECsym:
addi a1 a1 1
j DECdizloop

DECdecnumeri:

addi a1 a1 1
j DECdizloop
DECdecMaiusc:
addi t0 t0 -65
sub t0 a7 t0
addi t0 t0 96
sb t0 0(a1)
addi a1 a1 1
j DECdizloop

DECdecMinusc:
addi t0 t0 -97
sub t0 a7 t0
addi t0 t0 64
sb t0 0(a1)
addi a1 a1 1
j DECdizloop

0:
li t0 48
sb t0 0(a1)
addi a1 a1 1
j DECdizloop
1:
li t0 49
sb t0 0(a1)
addi a1 a1 1
j DECdizloop
2:
li t0 50
sb t0 0(a1)
addi a1 a1 1
j DECdizloop
3:
li t0 51
sb t0 0(a1)
addi a1 a1 1
j DECdizloop
4:
li t0 52
sb t0 0(a1)
addi a1 a1 1
j DECdizloop
5:
li t0 53
sb t0 0(a1)
addi a1 a1 1
j DECdizloop
6:
li t0 54
sb t0 0(a1)
addi a1 a1 1
j DECdizloop
7:
li t0 55
sb t0 0(a1)
addi a1 a1 1
j DECdizloop
8:
li t0 56
sb t0 0(a1)
addi a1 a1 1
j DECdizloop
9:
li t0 57
sb t0 0(a1)
addi a1 a1 1
j DECdizloop

DECfineloop:
li t0 0
li t1 0
li t2 0
li t3 0
li t4 0
li t5 0
li t6 0
li a2 0
jr ra


#CIFRATORE OCCORENZE
occorenze:
li t0 0
li t2 3
li t6 45
div a3 a0 t2
addi a7 a3 0
li t2 32
li a5 -1
poscarattere:
lb t5 0(a0)
beq t5 zero fineocc
addi t0 t0 1
bne t5 a5 evitarip
addi a0 a0 1
j poscarattere
evitarip:
sb t5 0(a3) #carico il carattere della stringa
addi a3 a3 1
sb t6 0(a3) #carico il carattere -
addi a3 a3 1
sb t0 0(a3) #carico la prima posizione del carattere
addi sp sp -12
sw a0 0(sp)
sw ra 4(sp)
sw t0 8(sp)
jal mettinposizione
lw ra 4(sp)
lw a0 0(sp)
lw t0 8(sp)
addi sp sp 12
addi a0 a0 1
addi a3 a3 1
sb t2 0(a3) #carico lo spazio
addi a3 a3 1
j poscarattere


fineocc:
addi a3 a3 -1
sb zero 0(a3)
addi a0 a7 0
li t0 0
li t1 0
li t2 0
li t3 0
li t4 0
li t5 0
li t6 0
li a3 0
jr ra



mettinposizione:
addi a0 a0 1
lb a6 0(a0)
beq a6 zero finepos
addi t0 t0 1
beq a6 t5 aggiungipos
j mettinposizione

finepos:
jr ra

aggiungipos:
addi a3 a3 1
sb t6 0(a3)
addi a3 a3 1
sb t0 0(a3)
sb a5 0(a0)
j mettinposizione





#DECIFRATORE OCCORENZE
Deocc:
li t6 45
li t5 32
li t0 5
li t1 0
li t2 0
mul a3 a0 t0
deocloop:
lb t0 0(a0)
beq t0 zero deoccend
posloop:
addi a0 a0 1
lb t1 0(a0)
beq t1 t6 contloop
addi a0 a0 1
j deocloop



contloop: 
addi a0 a0 1
lb t1 0(a0)
beq t1 zero deoccend
add t2 a3 t1
sb t0 0(t2)
j posloop

deoccend:
addi a0 a3 1
li t0 0
li t1 0
li t2 0
li t3 0
li t4 0
li t5 0
li t6 0
jr ra







end:
addi a1 a0 0
li a0 4
ecall
la a1 acapo
ecall