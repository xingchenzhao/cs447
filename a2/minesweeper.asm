.data
	board:  .space 256
	space:	.asciiz "\n"
	leftClickAtRow: .asciiz "Left-Click at row " 
	rightClickAtRow:	.asciiz "Right-Click at row "
	column: .asciiz " column "
	mine:	.asciiz "Mine"
	nothing: .asciiz "Nothing"
	colon:	.asciiz " : "
	newLine: .asciiz  "\n"
	
.text 
	add $s0,$zero,$zero	
	#initial 8*8
	jal _clearBuffer
	addi $a1,$zero,10		#passing upperBounds of Mines
	addi $a2,$zero,64		#number of Cells
	addi $a3,$zero,8
	addi $s0,$zero,8	
	jal _placeMines
	
	add  $t9, $zero, $zero		# Ready to receive an input, set $t9 to 0
		#save of x * x 	
wait:
	beq $t9, $zero, wait	
	addi $t1, $zero,0x08080000	#8*8
	addi $t2, $zero,0x0c0c0000	#12*12
	addi $t3, $zero,0x10100000	#16*16		
	sll  $t0,$t9,16			# get the last four number
        
	beq $t1,$t0,eightTimeEight
	beq $t2,$t0,twelveTimeTwelve
	beq $t3,$t0,sixteenTimeSixteen
	
clickMouse:
	srl $t4,$t9,8			#first move right two to remove the col
	sll $t4,$t4,24			#then move left six to get the row
	srl $t4,$t4,24			#finally, move right to get the final result t4
	
	sll $t5,$t9,24			#move left six to get the col
	srl $t5,$t5,24			#finally, move right six to get the final result t5
	
	srl $t6,$t9,16			#$t6 is right click or left click
	
	add $a0,$zero,$t4		#rowIndex
	add $a1,$zero,$t5		#colIndex
	add $a2,$zero,$t6		#whichClick
	add $a3,$zero,$s0		# x*x
	jal _mouseClick
	
	add $t9,$zero,$zero
	j wait
	
eightTimeEight:
	jal _clearBuffer
	addi $a1,$zero,10		#passing upperBounds of Mines
	addi $a2,$zero,64		#number of Cells
	addi $a3,$zero,8
	addi $s0,$zero,8	
	jal _placeMines	
	
	add $t9,$zero,$zero
	j wait
twelveTimeTwelve:
	jal _clearBuffer
	addi $a1,$zero,15	#passing upperBounds of Mines
	addi $a2,$zero,144		#number of Cells
	addi $a3,$zero,12
	addi $s0,$zero,12		
	jal _placeMines	
	
	add $t9,$zero,$zero
	j wait
sixteenTimeSixteen:
	jal _clearBuffer
	addi $a1,$zero,20		#passing upperBounds of Mines
	addi $a2,$zero,256		#number of Cells
	addi $a3,$zero,16	
	addi $s0,$zero,16	
	jal _placeMines	

	add $t9,$zero,$zero
	j wait
		
_randomNumber:
	addi $sp,$sp,-4
	sw   $ra,0($sp)
	add  $t0,$zero,$a2		#passing the number of cells
	addi $v0,$zero,30 		#system time
	syscall
	addi $v0,$zero,40
	add  $a1,$zero,$a0		#RNG seed
	syscall
	addi $v0,$zero,42		# Syscall 42: Random int range
	add  $a0, $zero,$zero
	add  $a1, $zero,$t0		#set upper bound to $t0
	syscall
	add  $v0,$zero,$a0
	lw   $ra,0($sp)
	addi $sp,$sp,4
	jr   $ra

_placeMines:  #a1: upperBounds of Mines  #a2: number of Cells
	addi $sp,$sp,-36
	sw   $s0,32($sp)
	sw   $s1,28($sp)
	sw   $s2,24($sp)
	sw   $s3,20($sp)
	sw   $s4,16($sp)
	sw   $s5,12($sp)
	sw   $s6,8($sp)
	sw   $s7,4($sp)
	sw   $ra,0($sp)
	
	add  $s1,$zero,$zero		#counter
	add  $s2,$zero,$a2		#number of cells
	add  $s3,$zero,$a1		#Upper Bound
	addi $s4,$zero,10		#mine
	add  $s7,$zero,$a3		#x * x
	
loopMine:
	beq  $s1,$s3,doneMines
	la   $s0,board

	add  $a2,$zero,$s2
	jal _randomNumber
	add  $t1,$zero,$v0		#t1 is random number
	add  $s0,$s0,$t1		#change the address with a random value
	
#check if the random number is repeated, then generate a new random number
	lb   $t5,0($s0)
	beq  $t5,$s4,loopMine
		
	sb   $s4,0($s0)			#store mines into board
	add  $s1,$s1,1			#increase the counter by 1
	j    loopMine

doneMines:
	add $a1,$zero,$s7		#x * x 
	add $a0,$zero,$s2 		#64
	jal _placeNumbers
	
	add $a0,$zero,$s2 
	jal  _display	
	
	lw   $s0,32($sp)
	lw   $s1,28($sp)
	lw   $s2,24($sp)
	lw   $s3,20($sp)
	lw   $s4,16($sp)
	lw   $s5,12($sp)
	lw   $s6,8($sp)
	lw   $s7,4($sp)
	lw   $ra,0($sp)
	addi $sp,$sp,36
	jr $ra
	
_display:
	addi $sp,$sp,-20
	sw   $s0,16($sp)
	sw   $s1,12($sp)
	sw   $s2,8($sp)
	sw   $s3,4($sp)
	sw   $ra,0($sp)
	
	add $s0,$zero,$a0	#bound
	add $s1,$zero,$zero 	#counter
	la  $s2,board		#load board	
	la  $s3,0xffff8000	#load display
	
loopDisplay:	
	beq  $s1,$s0,doneDisplayOfMines
	lb   $t0,0($s2)           #t0 is the number in the cell
	sb   $t0,0($s3)
	addi $s2,$s2,1
	addi $s3,$s3,1
	addi $s1,$s1,1
	j    loopDisplay
	#jr    $ra
	
doneDisplayOfMines:
	lw   $s0,16($sp)
	lw   $s1,12($sp)
	lw   $s2,8($sp)
	lw   $s3,4($sp)
	lw   $ra,0($sp)
	addi $sp,$sp,20
	jr    $ra

_placeNumbers:
	addi $sp,$sp,-36
	sw   $s0,32($sp)
	sw   $s1,28($sp)
	sw   $s2,24($sp)
	sw   $s3,20($sp)
	sw   $s4,16($sp)
	sw   $s5,12($sp)
	sw   $s6,8($sp)
	sw   $s7,4($sp)
	sw   $ra,0($sp)

	add  $s1,$zero,$a0		#number of cells
	add  $s0,$zero,$zero		#counter of total
	la   $s2,board			#load the address of board
	add  $s3,$zero,$zero  	   	#counter of row
	add  $s4,$zero,$zero		#counter of col
	add  $s6,$zero,$zero		#counter of going to nextLine
	add  $t9,$zero,$s2	
	add  $s7,$zero,$a1		#s7 is x * x
	
loopNumbers:
	beq $s0,$s1,doneLoopNumber 
	beq $s4,$s7,toNextRow		#if it is greater than x, then go to nextRow
	lb  $t0,0($t9)			#load the byte of board
	beq $t0,10,isMineInitial	#if it is 10 at initial, then it is mine
	
#beginToCheckThreeLine:
	add $t7,$zero,$zero		#count of mines
	add $s5,$zero,$zero		#counter of each Line checking
#checkUpperLine
checkUpperLine:
	subi $t1,$s3,1			#goToUpperRow 
	subi $t2,$s4,1			#goToLeftCol
	
loopTotalLine:
	beq $s6,3,doneLoopTotal		
loopUpper:
	beq $s5,3,checkNext		#s5 is counter, upperbound is 3  #note the 3
	add $t6,$zero,$s2		# pass the address of board to a temporary register
	add $a0,$zero,$t1		# a0 is rowIndex
	add $a1,$zero,$t2		# a1 is colIndex
	add $a2,$zero,$s7		
	jal _isOut
	
	add $t3,$zero,$v0		#t3 is the true or false
	beq $t3,0,itIsOut		# if t3 is 0 ,then it is out 
	
	add $a0,$zero,$t1		# a0 is rowIndex
	add $a1,$zero,$t2		# a1 is colIndex
	add $a2,$zero,$s1		# a2 is hwo many cells
	#jal _getNumbersOfCell
	
	mul $t0,$t1,$s7
	add $t0,$t0,$t2
	
	#add $t4,$zero,$v0		# get the location of cell
	add $t6,$t6,$t0			# change the address of board
	lb  $t5,0($t6)			#get the value in that cell
	beq $t5,10,itIsMineCheck	#if it is a mine when checking
	addi $t2,$t2,1			# go to the right col
	addi $s5,$s5,1			# increase the counter by 1
	j loopUpper
	
itIsMineCheck:
	addi $t7,$t7,1			#increase the count of mine by 1
	addi $t2,$t2,1			# go to the right col
	addi $s5,$s5,1			# increase the counter by 1
	j loopUpper			
	
itIsOut:
	addi $t2,$t2,1			# go to the right col
	addi $s5,$s5,1			# increase the counter by 1
	j loopUpper	
			
#checkUpperLineEnd
checkNext:	
	add  $s5,$zero,$zero
	addi $t1,$t1,1			#go to next row
	subi $t2,$s4,1			#reset ToLeftCol
       	addi $s6,$s6,1			#increase the counter by 1
      
	j loopTotalLine

isMineInitial:
	addi $s0,$s0,1			#increase the counter by 1
	addi $t9,$t9,1			#increase the address by 1
	addi $s4,$s4,1			#increase the col by 1
	j loopNumbers

toNextRow:
	addi $s3,$s3,1			#increase the row by 1
	add  $s4,$zero,$zero		#reset the col to 0
	j loopNumbers

doneLoopTotal:
	add $s6,$zero,$zero
	#add $s7,$zero,$t7		#s7 is the number of mines in the nearby area
	beq $t7,$zero, noMines
	sb  $t7,0($t9)
	addi $s0,$s0,1			#increase the counter by 1
	addi $t9,$t9,1			#increase the address by 1
	addi $s4,$s4,1			#increase the col by 1
	j loopNumbers
	
noMines:
	addi $t7,$zero,9
	sb $t7, 0($t9)
	addi $s0,$s0,1			#increase the counter by 1
	addi $t9,$t9,1			#increase the address by 1
	addi $s4,$s4,1			#increase the col by 1
	j loopNumbers
	
doneLoopNumber: 
	
	lw   $s0,32($sp)
	lw   $s1,28($sp)
	lw   $s2,24($sp)
	lw   $s3,20($sp)
	lw   $s4,16($sp)
	lw   $s5,12($sp)
	lw   $s6,8($sp)
	lw   $s7,4($sp)
	lw   $ra,0($sp)
	addi $sp,$sp,36
	jr   $ra
	

_isOut:
	addi $sp,$sp,-36
	sw   $s0,32($sp)
	sw   $s1,28($sp)
	sw   $s2,24($sp)
	sw   $s3,20($sp)
	sw   $s4,16($sp)
	sw   $s5,12($sp) 
	sw   $s6,8($sp)
	sw   $s7,4($sp)
	sw   $ra,0($sp) 
	
	add $s0,$zero,$a0	#s0 is the rowIndex
	add $s1,$zero,$a1	#s1 is the colIndex
	add $s6,$zero,$a2	#x*x
	
	subi $s6,$s6,1
	
#checkRow
	sge $s2,$s0,0		# if rowIndex is greater and equal than 0, then s2 is 1, otherwise it is 0	
	sle $s3,$s0,$s6		# if rowIndex is less and equal then 7, then s3 is 1, otherwise 0
	and $s2,$s2,$s3		# if rowIndex is between 0 and 7 ,then s2 is 1
	
	sge $s4,$s1,0		# if colIndex is greater and equal than 0, then s4 is 1, otherwise it is 0
	sle $s5,$s1,$s6		# if colIndex is less and equal then 7, then s5 is 1, otherwise 0
	and $s4,$s4,$s5		# if colIndex is between 0 and 7 , then s4 is 1
	
	and $v0,$s4,$s2		# return

	lw   $s0,32($sp)
	lw   $s1,28($sp)
	lw   $s2,24($sp)
	lw   $s3,20($sp)
	lw   $s4,16($sp)
	lw   $s5,12($sp)
	lw   $s6,8($sp)
	lw   $s7,4($sp)
	lw   $ra,0($sp)
	addi $sp,$sp,36
	jr   $ra

_mouseClick:
	addi $sp,$sp,-20
	sw   $s0,16($sp)
	sw   $s1,12($sp)
	sw   $s2,8($sp)
	sw   $s3,4($sp)
	sw   $ra,0($sp)

	add $s0,$zero,$a0	#row
	add $s1,$zero,$a1	#col
	add $s2,$zero,$a2	#click
	add $s3,$zero,$a3	#colSize
	la  $s4,board

checkMouseClick:
	beq $s2,0x00008000,leftClick
	beq $s2,0x00008800,rightClick
	
leftClick:
	addi $v0,$zero,4
	la $a0,	leftClickAtRow
	syscall
	
	addi $v0,$zero,1	#print rowIndex
	add $a0,$zero,$s0
	syscall
	
	addi $v0,$zero,4
	la $a0,	column
	syscall
		
	addi $v0,$zero,1	#print colIndex
	add $a0,$zero,$s1
	syscall
	
	addi $v0,$zero,4
	la $a0,	colon
	syscall
			
	j checkValue
	
rightClick:
	addi $v0,$zero,4
	la $a0,	rightClickAtRow
	syscall
	
	addi $v0,$zero,1	#print rowIndex
	add $a0,$zero,$s0
	syscall
	
	addi $v0,$zero,4
	la $a0,	column
	syscall
		
	addi $v0,$zero,1	#print colIndex
	add $a0,$zero,$s1
	syscall
	
	addi $v0,$zero,4
	la $a0,	colon
	syscall
	
	j checkValue
		
checkValue:						
	mul $t0,$s0,$s3		#rowIndex  * colSize
	add $t1,$t0,$s1		#(rowIndex * colSize) + colIndex 
	
	add $s4,$s4,$t1		#change the address
	lb  $t2,0($s4)		#get the value
	beq $t2,10,clickIsMine
	beq $t2,9,clickIsBlank
	addi $v0,$zero,1	
	add $a0,$zero,$t2
	syscall
	j doneClick
	
clickIsMine:
	addi $v0,$zero,4
	la $a0,	mine
	syscall
	j doneClick

clickIsBlank:
	addi $v0,$zero,4
	la $a0,	nothing
	syscall
	j doneClick
	
doneClick:	
	addi $v0,$zero,4
	la $a0,	newLine
	syscall		
	lw   $s0,16($sp)
	lw   $s1,12($sp)
	lw   $s2,8($sp)
	lw   $s3,4($sp)
	lw   $ra,0($sp)
	addi $sp,$sp,20
	
	jr $ra
	

_clearBuffer:
	addi $sp,$sp,-20
	sw   $s0,16($sp)
	sw   $s1,12($sp)
	sw   $s2,8($sp)
	sw   $s3,4($sp)
	sw   $ra,0($sp)
	
	la    $s0,board
	add   $s1,$zero,$zero   #counter
	addi  $s2,$zero,256    #bound
	addi  $s3,$s3,0
	
loopClear:
	beq  $s1,$s2, doneClear
	sb   $s3,0($s0)
	addi $s0,$s0,1
	addi $s1,$s1,1
	j loopClear
	
doneClear:
	lw   $s0,16($sp)
	lw   $s1,12($sp)
	lw   $s2,8($sp)
	lw   $s3,4($sp)
	lw   $ra,0($sp)
	addi $sp,$sp,20
	
	jr $ra
