.data
	mainMenu:   	.asciiz "Main Menu\n"
	dashes: 	.asciiz "=========\n"
	firstOption:	.asciiz "1. String to Morse code\n"
	secondOption:	.asciiz "2. Morse code to string\n"
	thirdOption:	.asciiz "3. Exit program\n"
	chooseOption:	.asciiz "What do you want to do? :\n"
	invalidOption:  .asciiz "Invalid option\n"
	newLine:	.asciiz	"\n"
	buffer:		.space 1000
	#alphabetArray
	alphabetArray: 	.byte 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
				'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z' 
	doubleSpace:	.asciiz "  "
	space:		.asciiz " "
	counter: 	.word 0
	iterator: 	.word 0
	size:		.word 52
	
	dot:		.asciiz "."
	dash:		.asciiz "-"
	
	#MorseArray
	a:  		.asciiz ".-"
	bb:		.asciiz "-..."
	c:		.asciiz "-.-."
	d:		.asciiz "-.."
	e:		.asciiz "."
	f:		.asciiz "..-."
	g:		.asciiz "--."
	h:		.asciiz "...."
	i:		.asciiz ".."
	jj:		.asciiz ".---"
	k:		.asciiz "-.-"
	l:		.asciiz ".-.."
	m:		.asciiz "--"
	n:		.asciiz "-."
	o:		.asciiz "---"
	p:		.asciiz ".--."
	q:		.asciiz "--.-"
	r:		.asciiz ".-."
	s:		.asciiz "..."
	t:		.asciiz "-"
	u:		.asciiz "..-"
	v:		.asciiz "...-"
	w:		.asciiz ".--"
	x:		.asciiz "-..-"
	y:		.asciiz "-.--"
	z:		.asciiz "--.."
	A:  		.asciiz ".-"
	BB:		.asciiz "-..."
	C:		.asciiz "-.-."
	D:		.asciiz "-.."
	E:		.asciiz "."
	F:		.asciiz "..-."
	G:		.asciiz "--."
	H:		.asciiz "...."
	I:		.asciiz ".."
	JJ:		.asciiz ".---"
	K:		.asciiz "-.-"
	L:		.asciiz ".-.."
	M:		.asciiz "--"
	N:		.asciiz "-."
	O:		.asciiz "---"
	P:		.asciiz ".--."
	Q:		.asciiz "--.-"
	R:		.asciiz ".-."
	S:		.asciiz "..."
	T:		.asciiz "-"
	U:		.asciiz "..-"
	V:		.asciiz "...-"
	W:		.asciiz ".--"
	X:		.asciiz "-..-"
	Y:		.asciiz "-.--"
	Z:		.asciiz "--.."

	morseArray:	.word   a, bb, c, d, e, f, g, h, i, jj, k, l, m, n, o, p, q, r, s, t, u , v, w, x , y, z
				,A,BB,C,D,E,F,G,H,I,JJ,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z
	
	morseToStringArray:  .byte 'a','a', 'E','T','I','A','N','M','S','U','R','W','D','K','G','O','H','V','F','b', 'L','b'
					,'P','J','B','X','C','Y','Z','Q','b','b' 
				#lowercase a for space, lowercase b for null
.text 
	
printMenu:

	addi $v0,$zero, 4	#print mainMenu
	la $a0, newLine
	syscall 
	
	la $a0, mainMenu
	syscall
	

	la $a0, dashes
	syscall
	

	la $a0, firstOption
	syscall
	

	la $a0, secondOption
	syscall
	

	la $a0, thirdOption
	syscall

	la $a0, chooseOption
	syscall
	
	addi $v0,$zero,5		#read option
	syscall
	
	add $t0,$zero,$v0

	
	beq $t0,1,readString_To_Morse		#check option
	beq $t0,2,readMorse
	beq $t0,3,done
	bgt $t0,3, invalidOptionPrint
	blt $t0,1, invalidOptionPrint
	
invalidOptionPrint:
	addi $v0,$zero,4
	la $a0, invalidOption
	syscall
	
	j printMenu

readString_To_Morse:
	
	addi $v0,$zero,8
	la $a0,buffer
	li $a1,1000	#readStringInput
	syscall

	la $s0,buffer	#load input from buffer
		
#string to morse	
loadABC:
	li $t7, ' '
	la $t1,	alphabetArray
	li $t3, 0		#counter
checkStringLoop:
	lb $t2, ($t1)	
	lb $t0, 0($s0)		#load first byte from #$s0
	
	beq $t0,10, printMenu
	beq $t0,$t7, printSpaceBetweenWord	#if there is a space between two word, then print two space
	beq  $t0,$t2, printMorse		
	addi $t1,$t1, 1		#go to next byte of Alphabet
	addi $t3,$t3, 1		#counter of MorseCode +1
	
	j checkStringLoop
	
printSpaceBetweenWord:
	addi $v0,$zero,4
	la $a0, space
	syscall
	
	addi $s0,$s0,1
	
	j checkStringLoop
	
printMorse:
	la $t4, morseArray
	sll $t5, $t3, 2		#count*4
	
	addu $t5,$t5,$t4	
	
	addi $v0,$zero,4
	lw $a0,0($t5)		#print Morse
	syscall
	
	la $a0, space		#print space
	syscall
	
	addi $s0,$s0,1		#go to next byte of input string
	la $t6,alphabetArray	#initialize alphabetArray
	add $t1,$zero,$t6	#give it to $t1
	add $t3,$zero,$zero	#initialize counter
	j checkStringLoop

#string to morse end
#Morse to String Start
readMorse:
	addi $v0,$zero,8
	la $a0,buffer
	li $a1,1000
	syscall
	
	la $s2,buffer
	lb $t1, dot
	lb $t2, dash
	lb $t5, space
	addi $t4,$zero,1 #currentIndex
	
	li $t5, ' '
	addi $s3,$zero,0
checkMorseLoop:
	lb $t3,0($s2)		#load byte of Morse Code
	
	beq $t3,$t1,countDot
	beq $t3,$t2,countDash 
	beq $t3,$t5,checkSpace
	
	beqz $t3,printMenu

checkSpace:

	addi $s2,$s2,1
	lb $t3,0($s2)
	bne $t3,$t5, oneSpace
	beq $t3,$t5, TwoSpace

oneSpace:
	addi $s3,$zero,1
	j backOne

TwoSpace:
	addi $s3,$zero,2
	j backOne

backOne:
	sub $s2,$s2,1
	j printLetter		
	
printLetter:
	la $t6, morseToStringArray
	add $t6,$t6,$t4
	addi $v0,$zero,11
	lb $a0,0($t6)
	syscall
	
	addi $s2,$s2,1
	addi $t4,$zero,1		#currentIndex
	
	beq $s3,2,printDoubleSpace
	j checkMorseLoop

printDoubleSpace:
	addi $v0,$zero,4
	la $a0,doubleSpace
	syscall
	addi $s2,$s2,1
	j checkMorseLoop
	
countDot:
	sll $t4,$t4,1		#times 2
	addi $s2,$s2,1		#move to next byte of Morse Code
	j checkMorseLoop

countDash:
	sll $t4,$t4,1		#times 2
	addi $t4,$t4,1		#plus1
	addi $s2,$s2,1
	j checkMorseLoop

done:

	addi $v0,$zero, 10 
	syscall
	
