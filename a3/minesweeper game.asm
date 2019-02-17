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
	askCloseCells: .asciiz "Press Enter key to continue..."
	youLose:  .asciiz  "Haha! You lose! Please reset!\n"
	userInput: .space  10
	same:	   .asciiz "flags are equal to number"
	notSame:	.asciiz "flags are not equal to number"
	numOfOpenCells:  .asciiz "Number of Open Cells: "
	numOfFlags:	.asciiz " Number of Flags: "
	youWin:          .asciiz "You Win !!!\n"
.text   
	add $s0,$zero,$zero	
	#initial 8*8
	jal _clearBuffer 
	addi $a1,$zero,10		#passing upperBounds of Mines
	addi $a2,$zero,64		#number of Cells
	addi $a3,$zero,8
	addi $s0,$zero,8	
	jal _placeMines
	jal _askCloseAllCells
	add  $t9, $zero, $zero		# Ready to receive an input, set $t9 to 0
		
wait:
	beq $t9, $zero, wait	
	addi $t1, $zero,0x0000200A	#8*8
	addi $t2, $zero,0x0000200F	#12*12
	addi $t3, $zero,0x00002014	#16*16	
	addi $t4, $zero,0x0000400A	#8*8
	addi $t5, $zero,0x0000400F	#12*12
	addi $t6, $zero,0x00004014	#16*16
	srl  $t0,$t9,16			# get the last four number
        
	beq $t1,$t0,eightTimeEight
	beq $t4,$t0,eightTimeEight
	beq $t2,$t0,twelveTimeTwelve
	beq $t5,$t0,twelveTimeTwelve
	beq $t3,$t0,sixteenTimeSixteen
	beq $t6,$t0,sixteenTimeSixteen
	
clickMouse:
	srl $t4,$t9,8			#first move right two to remove the col
	sll $t4,$t4,24			#then move left six to get the row
	srl $t4,$t4,24			#finally, move right to get the final result t4
	add $s5,$zero,$t4		#s3 is rowIndex
	
	sll $t5,$t9,24			#move left six to get the col
	srl $t5,$t5,24			#finally, move right six to get the final result t5
	add $s6,$zero,$t5		#s5 is colIndex
	
	srl $t6,$t9,16			#$t6 is right click or left click
	add $s7,$zero,$t6		#s5 is whichClick
	
	add $a0,$zero,$s5		#rowIndex
	add $a1,$zero,$s6		#colIndex
	add $a2,$zero,$s7		#whichClick
	add $a3,$zero,$s0		# x*x
	jal _mouseClick
	
	
	add $a0,$zero,$s5		#rowIndex
	add $a1,$zero,$s6		#colIndex
	add $a2,$zero,$s7		#whichClick
	add $a3,$zero,$s0		#x*x
	jal _leftClickNum
	add $t8,$zero,$v0		#t8 is return value
	beq $t8,1,goToWait
	
	add $a0,$zero,$s5		#rowIndex
	add $a1,$zero,$s6		#colIndex
	add $a2,$zero,$s0		# x*x
	add $a3,$zero,$s7		#whichClick
	jal _openCell	
					
	add $a0,$zero,$s0		#x*x
	jal _showStatus	
	
goToWait:		
	add $t9,$zero,$zero
	j   wait
	
eightTimeEight:
	addi $s0,$zero,8	
	jal _clearBuffer
	addi $a1,$zero,10		#passing upperBounds of Mines
	addi $a2,$zero,64		#number of Cells
	addi $a3,$zero,8
	jal _placeMines	
	jal _askCloseAllCells
	add $t9,$zero,$zero

	j wait
twelveTimeTwelve:
	addi $s0,$zero,12
	jal _clearBuffer
	addi $a1,$zero,15	#passing upperBounds of Mines
	addi $a2,$zero,144		#number of Cells
	addi $a3,$zero,12		
	jal _placeMines	
	jal _askCloseAllCells
	add $t9,$zero,$zero
	j wait
sixteenTimeSixteen:
	addi $s0,$zero,16
	jal _clearBuffer
	addi $a1,$zero,20		#passing upperBounds of Mines
	addi $a2,$zero,256		#number of Cells
	addi $a3,$zero,16	
	jal _placeMines	
	jal _askCloseAllCells
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
	
_openCell:
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
	
	addi $s0,$zero,0x00008800
	add $s1,$zero,$a3		#whichClick
	add $s2,$zero,$a0		#s2 is rowIndex
	add $s3,$zero,$a1		#s3 is colIndex
	add $s4,$zero,$a2		#s4 is x*x
	la  $s5,board			#load board
	la  $s6,0xffff8000		#load display
	add $t3,$zero,$zero		#t3 is zero
	addi $t4,$zero, 10		#t4 is 10
	
beginOpenCell:
	mul $t0,$s2,$s4			#rowIndex * colSize
	add $t1,$t0,$s3			#(rowIndex*colSize) + colIndex		
	add $s5,$s5,$t1			#go to the location of the board
	lb  $t2,0($s5)			#get the number from the location of the board
	beq $s1,$s0,setRightClick	#if the mouse click is right
	
leftClickOpenCell:
	add $s6,$s6,$t1			#go to the location of the tempDisplay
	lb  $t9,0($s6)			#load the cell
	la  $s6,0xffff8000
	beq $t9,12,cellHasFlagDoNothing	# if it has flag
	beq $t2,10,openAllMines
	beq $t2,9,openSurroundEmpty
	sgt $t5,$t2,$t3			# if t2 is greater than 0, then set t5 as 1
	slt $t6,$t2,$t4			# if t2 is less than 10, then set t6 as 1
	and $t7,$t5,$t6
	beq $t7,1,openNum		# if t2 is greater than 0 and less than 10, then openNum
	j doneOpenCell			# if t2 is outside of 0 to 10, then do nothing

setRightClick:
	addi $t6,$zero,12
	add $s6,$s6,$t1
	lb  $t5,0($s6)
	beq $t5,$zero,closedNoFlag		
	beq $t5,12,closedHasFlag
	j doneOpenCell
closedNoFlag:
	sb  $t6,0($s6)
	j doneOpenCell
closedHasFlag:
	sb $zero,0($s6)
	j doneOpenCell	
		
cellHasFlagDoNothing:
	j doneOpenCell	
				
openAllMines:
	add $a0,$zero,$t1		#a0 is the location of the board
	add $a1,$zero,$s4		#a1 is the colSize
	jal _openAllMines
	
	
	
	j doneOpenCell	
	
openSurroundEmpty: # not finished yet
	add $a0,$zero,$s2		#a0 is the rowIndex
	add $a1,$zero,$s3		#a1 is the colIndex
	add $a2,$zero,$s4		#a2 is the colSize
	jal _recursiveOpenEmpty
	j doneOpenCell			
openNum:
	add $s6,$s6,$t1
	sb $t2,0($s6)
	j doneOpenCell
			
doneOpenCell:
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
	
####################
_recursiveOpenEmpty:
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
	add $s2,$zero,$a2	#s2 is the colSize
	la  $s3,board		#load board
	la  $s4,0xffff8000	#load displayBoard
	
	mul $t0,$s0,$s2		#t0 is (rowIndex * colSize)
	add $t0,$t0,$s1		#now t0 is(rowIndex*colSize) + colIndex						
	add $s3,$s3,$t0		#go to the location in the board
	lb  $t1,0($s3)		#load byte from the location of the board
	add $s4,$s4,$t0		#go to the location in the diplay
	lb  $t8,0($s4)		#load byte from the display
	beq $t8,9,hasRevealed
	la  $s4,0xffff8000
	beq $t1,9,displayNothing
	beq $t1,10,returnMine
	j   returnNum 
	
displayNothing:
	addi $t2,$zero,9
	add $s4,$s4,$t0
	sb $t2,0($s4)	

#check row-1 and col-1 
firstCheck:		
	subi $t3,$s0,1		#row-1
	subi $t4,$s1,1		#col-1
	add $a0,$zero,$t3	#a0 is (row-1)
	add $a1,$zero,$t4	#a1 is (col-1)
	add $a2,$zero,$s2	#a2 is the colSize
	jal _isOut		#calling is out to check if it is inbound
	add $t5,$zero,$v0	#t5 is the answer  1 means inBound, 0 means outBound
	beq $t5,1,rcInboundOne	
	beq $t5,0,secondCheck
rcInboundOne:
	add $a0,$zero,$t3
	add $a1,$zero,$t4
	add $a2,$zero,$s2
	jal _recursiveOpenEmpty	
	beq $v0,1,returnMine

secondCheck:
	subi $t3,$s0,1		#row -1
	add  $t4,$zero,$s1	#col
	add  $a0,$zero,$t3      #a0 is row -1
	add  $a1,$zero,$t4     	#a1 is col
	add  $a2,$zero,$s2	#a2 is the colSize
	jal  _isOut		#check inbound
	add  $t5,$zero,$v0	
	beq  $t5,1,rcInboundTwo
	beq  $t5,0,thirdCheck	
	
rcInboundTwo:
	add $a0,$zero,$t3
	add $a1,$zero,$t4
	add $a2,$zero,$s2
	jal _recursiveOpenEmpty	
	beq $v0,1,returnMine	

thirdCheck:	
	subi $t3,$s0,1		#row -1
	addi $t4,$s1,1		#col +1
	add  $a0,$zero,$t3      #a0 is row -1
	add  $a1,$zero,$t4     	#a1 is col +1
	add  $a2,$zero,$s2	#a2 is the colSize
	jal  _isOut		#check inbound
	add  $t5,$zero,$v0	
	beq  $t5,1,rcInboundThree
	beq  $t5,0,fourthCheck			

rcInboundThree:
	add $a0,$zero,$t3
	add $a1,$zero,$t4
	add $a2,$zero,$s2
	jal _recursiveOpenEmpty	
	beq $v0,1,returnMine	

										
fourthCheck:							
	add  $t3,$s0,$zero	#row 
	subi $t4,$s1,1		#col -1
	add  $a0,$zero,$t3      #a0 is row 
	add  $a1,$zero,$t4     	#a1 is col -1
	add  $a2,$zero,$s2	#a2 is the colSize
	jal  _isOut		#check inbound
	add  $t5,$zero,$v0	
	beq  $t5,1,rcInboundFour
	beq  $t5,0,fifthCheck										
											
rcInboundFour:
	add $a0,$zero,$t3
	add $a1,$zero,$t4
	add $a2,$zero,$s2
	jal _recursiveOpenEmpty	
	beq $v0,1,returnMine													
															
fifthCheck:																	
	add  $t3,$s0,$zero	#row 
	addi $t4,$s1,1		#col +1
	add  $a0,$zero,$t3      #a0 is row 
	add  $a1,$zero,$t4     	#a1 is col +1
	add  $a2,$zero,$s2	#a2 is the colSize
	jal  _isOut		#check inbound
	add  $t5,$zero,$v0	
	beq  $t5,1,rcInboundFive
	beq  $t5,0,sixthCheck																			
																					
rcInboundFive:
	add $a0,$zero,$t3
	add $a1,$zero,$t4
	add $a2,$zero,$s2
	jal _recursiveOpenEmpty	
	beq $v0,1,returnMine	
	
sixthCheck:
	addi $t3,$s0,1		#row +1
	subi $t4,$s1,1		#col -1
	add  $a0,$zero,$t3      #a0 is row +1
	add  $a1,$zero,$t4     	#a1 is col -1
	add  $a2,$zero,$s2	#a2 is the colSize
	jal  _isOut		#check inbound
	add  $t5,$zero,$v0	
	beq  $t5,1,rcInboundSix
	beq  $t5,0,seventhCheck																																																

rcInboundSix:
	add $a0,$zero,$t3
	add $a1,$zero,$t4
	add $a2,$zero,$s2
	jal _recursiveOpenEmpty	
	beq $v0,1,returnMine
	
seventhCheck:
	addi $t3,$s0,1		#row +1
	add $t4,$s1,$zero	#col 
	add  $a0,$zero,$t3      #a0 is row +1
	add  $a1,$zero,$t4     	#a1 is col 
	add  $a2,$zero,$s2	#a2 is the colSize
	jal  _isOut		#check inbound
	add  $t5,$zero,$v0	
	beq  $t5,1,rcInboundSeven
	beq  $t5,0,eighthCheck																																																							
rcInboundSeven:
	add $a0,$zero,$t3
	add $a1,$zero,$t4
	add $a2,$zero,$s2
	jal _recursiveOpenEmpty	
	beq $v0,1,returnMine

eighthCheck:
	addi $t3,$s0,1		#row +1
	addi $t4,$s1,1		#col +1
	add  $a0,$zero,$t3      #a0 is row +1
	add  $a1,$zero,$t4     	#a1 is col +1
	add  $a2,$zero,$s2	#a2 is the colSize
	jal  _isOut		#check inbound
	add  $t5,$zero,$v0	
	beq  $t5,1,rcInboundEight
	beq  $t5,0,doneCheck	
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																	
rcInboundEight:
	add $a0,$zero,$t3
	add $a1,$zero,$t4
	add $a2,$zero,$s2
	jal _recursiveOpenEmpty	
	beq $v0,1,returnMine																																																																																																																																																																																																																																																																																																																																																																																																													 																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																			
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																												
doneCheck:																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																								
	add $v0,$zero,$zero																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																			
	j   recOpenEmptyDone																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																														
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																												
hasRevealed:
	add $v0,$zero,$zero
	j    recOpenEmptyDone																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																					
returnMine:	
	addi $v0,$zero,1
	j recOpenEmptyDone
returnNum:
	add  $v0,$zero,$zero
	add  $s4,$s4,$t0
	sb   $t1,0($s4)	
	j    recOpenEmptyDone																																																																									
recOpenEmptyDone:
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
####################
_openAllMines:
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
	
	add $s0,$zero,$a0	#s0 is the index of the cell		
	add $s1,$zero,$a1	#s1 is the colSize
	mul $s1,$s1,$s1		#now s1 is the num(bound) of the cell
	add $s2,$zero,$zero	#s2 is the counter
	la  $s3,board		#s3 is the address of the board
	la  $s4, 0xffff8000	#s4 is the address of the displayBoard
	addi $s5,$zero,10	#s5 is the mine(10)
	
displayExplodedMine:
	#add  $s3,$s3,$s0		# go to the location of the mines in the board
	add  $s4,$s4,$s0	# go to the location of the mines in the displayBoard
	addi $t1,$zero,13	# t1 is the exploded mines(13)
	sb   $t1,0($s4)		# store the exploded mines in the displayBoard
	#sb   $t1,0($s3)
	la   $s4, 0xffff8000
	la   $s3,board
beginDisplayAllMines:
	beq $s2,$s1,doneDisplayAllMines
	lb  $t0,0($s3)		#t0 is the stuff in the location of the board
	beq $s2,$s0,finishStoreMine
	beq $t0,10,storeMine		
	j finishStoreMine
	
storeMine:
	sb $s5,0($s4)		#store mines in the displayBoard
	
finishStoreMine:
	addi $s3,$s3,1
	addi $s4,$s4,1
	addi $s2,$s2,1	
	j beginDisplayAllMines
																				
doneDisplayAllMines:
	addi $v0,$zero,4
	la $a0,youLose 
	syscall 
	
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
################															
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
	beq $t2,11,clickIsMine
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
####################	
_askCloseAllCells: 
	addi $sp,$sp,-28
	sw   $s0,24($sp)
	sw   $s1,20($sp)
	sw   $s2,16($sp)
	sw   $s3,12($sp)
	sw   $s4,8($sp)
	sw   $s5,4($sp)
	sw   $ra,0($sp)
	
	la $s1,newLine

#Display Message
closeAllCells: 
	addi $v0,$zero,4
	la $a0,askCloseCells 
	syscall 

	#ask input 
	addi $v0,$zero,8 
	la $a0,userInput
	li $a1,1000
	syscall

	la $s2,userInput
cmpStrLoop:
	lb $s4,0($s1)
	lb $s5,0($s2)
	bne $s4,$s5,closeAllCells
	beq $s4,$zero,closeCell
	addi $s1,$s1,1
	addi $s2,$s2,1
	j cmpStrLoop

closeCell:
	jal _clearDisplay	
	
DoneCloseCell:
	addi $v0,$zero,4
	la $a0,newLine
	syscall
	
	lw   $s0,24($sp)
	lw   $s1,20($sp)
	lw   $s2,16($sp)
	lw   $s3,12($sp)
	lw   $s4,8($sp)
	lw   $s5,4($sp)
	lw   $ra,0($sp)
	addi $sp,$sp,28
	jr    $ra
	
########################	
_leftClickNum:	
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
	
	add $s0,$zero,$a0	#rowIndex
	add $s1,$zero,$a1	#colIndex
	add $s2,$zero,$a2	#which click
	add $s3,$zero,$a3	#colSize
	addi $t0,$zero,0x00008000	#leftClick
	la  $s4,board
	la  $s5,0xffff8000
	subi $s6,$s0,1		#s4 is row - 1
	subi $s7,$s1,1		#s5 is col -1
checkClick:
	bne $t0,$s2,doneClickNum
checkIfOpen:
	mul  $t2,$s0,$s3	#rowIndex * colSize
	add  $t2,$t2,$s1	#(row * colSize)+colIndex
	add  $t4,$zero,$s5	#add temp Display
	add  $t4,$t4,$t2	#go to the location of the display
	lb   $t5,0($t4)		#load the byte from the location
	beq  $t5,$zero,doneClickNum
checkEqualNumOfFlag:
	add  $a0,$zero,$s0	#rowIndex
	add  $a1,$zero,$s1	#colIndex
	add  $a2,$zero,$s3	#colSize
	jal _checkEqualFlag
	add  $t1,$zero,$v0	#t1 is the num of flag
	mul  $t2,$s0,$s3	#rowIndex * colSize
	add  $t2,$t2,$s1	#(row * colSize)+colIndex
	add  $s5,$s5,$t2	#go to the location of the display
	lb   $t5,0($s5)		#load byte from the location
	bne  $t1,$t5,doneClickNum
	add  $a0,$zero,$s0	#rowIndex
	add  $a1,$zero,$s1	#colIndex
	add  $a2,$zero,$s3	#colSize
	jal _isNumOrMine
	add  $t0,$zero,$v0	#if t0 is 1, it is num, then done
	beq  $t0,1,gameOverLeftClickNum
	
beginClickNum:	
equalNumFirst:
	subi $t0,$s0,1		#row-1
	subi $t1,$s1,1		#col-1
	add  $a0,$zero,$t0	#a0 is row-1
	add  $a1,$zero,$t1	#a1 is col-1
	add  $a2,$zero,$s3	#a2 is colSize
	jal  _isOut		#checkInBound, In is 1, out is 0
	beq  $v0,$zero,equalNumSecond
checkEqualNumCloseOne:
	#mul  $t2,$s6,$s3	#(row-1)*colSize
	#add  $t2,$t2,$s7	#(row - 1)*colSize + (col-1)
	mul  $t2,$t0,$s3
	add  $t2,$t2,$t1
	la   $t3,0xffff8000
	add  $t3,$t3,$t2	#go to the location of the board
	lb   $t4,0($t3)		#load byte from the location
	bne  $t4,0,notCloseOne
	j    okOne
notCloseOne:	
	bne  $t4,12,equalNumSecond
	
okOne:	
	add  $a0,$zero,$t0
	add  $a1,$zero,$t1
	add  $a2,$zero,$s3
	jal  _recursiveOpenEmpty
	#add  $t5,$zero,$v0	#return value
	#beq  $t5,1,doneClickNum
equalNumSecond:
	subi $t0,$s0,1		#row-1
	add  $t1,$s1,$zero	#col
	add  $a0,$zero,$t0	#a0 is row-1
	add  $a1,$zero,$t1	#a1 is col
	add  $a2,$zero,$s3	#a2 is colSize
	jal  _isOut		#checkInBound, In is 1, out is 0
	beq  $v0,$zero,equalNumThird
checkEqualNumCloseTwo:
	#mul  $t2,$s6,$s3	#(row-1)*colSize
	#add  $t2,$t2,$s7	#(row - 1)*colSize + (col-1)
	mul  $t2,$t0,$s3
	add  $t2,$t2,$t1
	la   $t3,0xffff8000
	add  $t3,$t3,$t2	#go to the location of the board
	lb   $t4,0($t3)		#load byte from the location
	bne  $t4,0,notCloseTwo
	j    okTwo
notCloseTwo:	
	bne  $t4,12,equalNumThird
okTwo:	
	add  $a0,$zero,$t0
	add  $a1,$zero,$t1
	add  $a2,$zero,$s3
	jal  _recursiveOpenEmpty
	#add  $t5,$zero,$v0	#return value
	#beq  $t5,1,doneClickNum	
	
equalNumThird:
	subi  $t0,$s0,1		#row-1
	addi  $t1,$s1,1		#col+1
	add  $a0,$zero,$t0	#a0 is row-1
	add  $a1,$zero,$t1	#a1 is col+1
	add  $a2,$zero,$s3	#a2 is colSize
	jal  _isOut		#checkInBound, In is 1, out is 0
	beq  $v0,$zero,equalNumFourth											
checkEqualNumCloseThree:
	#mul  $t2,$s6,$s3	#(row-1)*colSize
	#add  $t2,$t2,$s7	#(row - 1)*colSize + (col-1)
	mul  $t2,$t0,$s3
	add  $t2,$t2,$t1
	la   $t3,0xffff8000
	add  $t3,$t3,$t2	#go to the location of the board
	lb   $t4,0($t3)		#load byte from the location
	bne  $t4,0,notCloseThree
	j    okThree
notCloseThree:
	bne  $t4,12,equalNumFourth	
okThree:	
	add  $a0,$zero,$t0
	add  $a1,$zero,$t1
	add  $a2,$zero,$s3
	jal  _recursiveOpenEmpty
	#add  $t5,$zero,$v0	#return value
	#beq  $t5,1,doneClickNum	
	
equalNumFourth:
	add   $t0,$s0,$zero	#row
	subi  $t1,$s1,1		#col-1
	add  $a0,$zero,$t0	#a0 is row
	add  $a1,$zero,$t1	#a1 is col-1
	add  $a2,$zero,$s3	#a2 is colSize
	jal  _isOut		#checkInBound, In is 1, out is 0
	beq  $v0,$zero,equalNumFifth																							

checkEqualNumCloseFour:
	#mul  $t2,$s6,$s3	#(row-1)*colSize
	#add  $t2,$t2,$s7	#(row - 1)*colSize + (col-1)
	mul  $t2,$t0,$s3
	add  $t2,$t2,$t1
	la   $t3,0xffff8000
	add  $t3,$t3,$t2	#go to the location of the board
	lb   $t4,0($t3)		#load byte from the location
	bne  $t4,0,notCloseFour
	j    okFour
	
notCloseFour:		
	bne  $t4,12,equalNumFifth
	
okFour:	
	add  $a0,$zero,$t0
	add  $a1,$zero,$t1
	add  $a2,$zero,$s3
	jal  _recursiveOpenEmpty
	#add  $t5,$zero,$v0	#return value
	#beq  $t5,1,doneClickNum																																										
																																																																																		
equalNumFifth:
	add   $t0,$s0,$zero	#row
	addi  $t1,$s1,1		#col+1
	add  $a0,$zero,$t0	#a0 is row
	add  $a1,$zero,$t1	#a1 is col+1
	add  $a2,$zero,$s3	#a2 is colSize
	jal  _isOut		#checkInBound, In is 1, out is 0
	beq  $v0,$zero,equalNumSixth																																																																																																																												
checkEqualNumCloseFive:																																																																																																																																																																																																													
	#mul  $t2,$s6,$s3	#(row-1)*colSize
	#add  $t2,$t2,$s7	#(row - 1)*colSize + (col-1)
	mul  $t2,$t0,$s3
	add  $t2,$t2,$t1
	la   $t3,0xffff8000
	add  $t3,$t3,$t2	#go to the location of the board
	lb   $t4,0($t3)		#load byte from the location
	bne  $t4,0,notCloseFive
	j     okFive
notCloseFive:	
	bne  $t4,12,equalNumSixth
okFive:	
	add  $a0,$zero,$t0
	add  $a1,$zero,$t1
	add  $a2,$zero,$s3
	jal  _recursiveOpenEmpty
	#add  $t5,$zero,$v0	#return value
	#beq  $t5,1,doneClickNum		
																																																																																					
equalNumSixth:
	addi  $t0,$s0,1		#row+1
	subi  $t1,$s1,1		#col-1
	add  $a0,$zero,$t0	#a0 is row+1
	add  $a1,$zero,$t1	#a1 is col-1
	add  $a2,$zero,$s3	#a2 is colSize
	jal  _isOut		#checkInBound, In is 1, out is 0
	beq  $v0,$zero,equalNumSeventh	
checkEqualNumCloseSix:	
	#mul  $t2,$s6,$s3	#(row-1)*colSize
	#add  $t2,$t2,$s7	#(row - 1)*colSize + (col-1)
	mul  $t2,$t0,$s3
	add  $t2,$t2,$t1
	la   $t3,0xffff8000
	add  $t3,$t3,$t2	#go to the location of the board
	lb   $t4,0($t3)		#load byte from the location
	bne  $t4,0,notCloseSix	
	j    okSix
	
notCloseSix:	
	bne  $t4,12,equalNumSeventh
okSix:	
	add  $a0,$zero,$t0
	add  $a1,$zero,$t1
	add  $a2,$zero,$s3
	jal  _recursiveOpenEmpty
	#add  $t5,$zero,$v0	#return value
	#beq  $t5,1,doneClickNum	
equalNumSeventh:
	addi  $t0,$s0,1		#row+1
	add   $t1,$s1,$zero	#col
	add  $a0,$zero,$t0	#a0 is row+1
	add  $a1,$zero,$t1	#a1 is col
	add  $a2,$zero,$s3	#a2 is colSize
	jal  _isOut		#checkInBound, In is 1, out is 0
	beq  $v0,$zero,equalNumEighth		
checkEqualNumCloseSeven:
	#mul  $t2,$s6,$s3	#(row-1)*colSize
	#add  $t2,$t2,$s7	#(row - 1)*colSize + (col-1)
	mul  $t2,$t0,$s3
	add  $t2,$t2,$t1
	la   $t3,0xffff8000
	add  $t3,$t3,$t2	#go to the location of the board
	lb   $t4,0($t3)		#load byte from the location
	bne  $t4,0,notCloseSeven
	j    okSeven
	
notCloseSeven:	
	bne  $t4,12,equalNumEighth
okSeven:	
	add  $a0,$zero,$t0
	add  $a1,$zero,$t1
	add  $a2,$zero,$s3
	jal  _recursiveOpenEmpty 
	#add  $t5,$zero,$v0	#return value
	#beq  $t5,1,doneClickNum		
	
equalNumEighth:
	addi  $t0,$s0,1		#row+1
	addi  $t1,$s1,1		#col+1
	add  $a0,$zero,$t0	#a0 is row+1
	add  $a1,$zero,$t1	#a1 is col+1
	add  $a2,$zero,$s3	#a2 is colSize
	jal  _isOut		#checkInBound, In is 1, out is 0
	beq  $v0,$zero,doneClickNum		
checkEqualNumCloseEight:
	#mul  $t2,$s6,$s3	#(row-1)*colSize
	#add  $t2,$t2,$s7	#(row - 1)*colSize + (col-1)
	mul  $t2,$t0,$s3
	add  $t2,$t2,$t1
	la   $t3,0xffff8000
	add  $t3,$t3,$t2	#go to the location of the board
	lb   $t4,0($t3)		#load byte from the location
	bne  $t4,0,notCloseEight
	j   okEight
	
notCloseEight:
	bne  $t4,12,doneClickNum
okEight:	
	add  $a0,$zero,$t0
	add  $a1,$zero,$t1
	add  $a2,$zero,$s3
	jal  _recursiveOpenEmpty
	j doneClickNum
	#add  $t5,$zero,$v0	#return value
	#beq  $t5,1,doneClickNum		
	
#equalNumFinal:
#	add $v0,$zero,$zero																																																																																																																																																																																																																																									
#	j doneClickNum
gameOverLeftClickNum:
	add  $v0,$zero,1	#if game over ,then return 1
	j  doneClickNum
doneClickNum:	
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
#####################	
_checkEqualFlag:	
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
	
	add $s0,$zero,$a0	#rowIndex
	add $s1,$zero,$a1	#colIndex
	add $s2,$zero,$a2	#colSize
	add $s3,$zero,$zero	#counter of flag
	la  $s4,0xffff8000	#load display
	
checkFirst:
	subi $t0,$s0,1		#row - 1
	subi $t1,$s1,1		#col - 1
	mul  $t2,$t0,$s2	#(row - 1)*colSize
	add  $t2,$t2,$t1	#(row-1)*colSize + (col-1) (location)
	add  $t3,$zero,$s4	#add temp display
	add  $t3,$t3,$t2	#go to the location
	lb   $t4,0($t3)		#load byte from the location of the display
	bne  $t4,12,checkSecond #if the byte is not flag, then go to check second
	addi $s3,$s3,1		 #if yes, then counter plus 1
	
checkSecond:
	subi $t0,$s0,1		#row - 1
	add  $t1,$s1,$zero	#col
	mul  $t2,$t0,$s2	#(row - 1)*colSize
	add  $t2,$t2,$t1	#(row - 1)*colSize + col
	add  $t3,$zero,$s4	#add temp display
	add  $t3,$t3,$t2	#go to the location
	lb   $t4,0($t3)		#load byte from the location of the display
	bne  $t4,12,checkThird  
	addi  $s3,$s3,1
	
checkThird:
	subi $t0,$s0,1		#row - 1
	addi  $t1,$s1,1  	#col +1
	mul  $t2,$t0,$s2	#(row - 1)*colSize
	add  $t2,$t2,$t1	#(row - 1)*colSize + (col+1)
	add  $t3,$zero,$s4	#add temp display
	add  $t3,$t3,$t2	#go to the location
	lb   $t4,0($t3)		#load byte from the location of the display
	bne  $t4,12,checkFourth 
	addi  $s3,$s3,1
checkFourth:
	add  $t0,$s0,$zero	#row 
	subi $t1,$s1,1  	#col -1
	mul  $t2,$t0,$s2	#(row )*c-lSize
	add  $t2,$t2,$t1	#(row )*colSize + (col-1)
	add  $t3,$zero,$s4	#add temp display
	add  $t3,$t3,$t2	#go to the location
	lb   $t4,0($t3)		#load byte from the location of the display
	bne  $t4,12,checkFifth
	addi  $s3,$s3,1	
checkFifth:
	add  $t0,$s0,$zero	#row 
	addi $t1,$s1,1  	#col +1
	mul  $t2,$t0,$s2	#(row )*c-lSize
	add  $t2,$t2,$t1	#(row )*colSize + (col+1)
	add  $t3,$zero,$s4	#add temp display
	add  $t3,$t3,$t2	#go to the location
	lb   $t4,0($t3)		#load byte from the location of the display
	bne  $t4,12,checkSixth
	addi  $s3,$s3,1
checkSixth:	
	addi $t0,$s0,1		#row + 1
	subi $t1,$s1,1  	#col -1
	mul  $t2,$t0,$s2	#(row + 1)*c-lSize
	add  $t2,$t2,$t1	#(row + 1)*colSize + (col-1)
	add  $t3,$zero,$s4	#add temp display
	add  $t3,$t3,$t2	#go to the location
	lb   $t4,0($t3)		#load byte from the location of the display
	bne  $t4,12,checkSeventh
	addi  $s3,$s3,1	
		
checkSeventh:
	addi $t0,$s0,1		#row + 1
	add  $t1,$s1,$zero	#col 
	mul  $t2,$t0,$s2	#(row + 1)*colSize
	add  $t2,$t2,$t1	#(row + 1)*colSize + (col)
	add  $t3,$zero,$s4	#add temp display
	add  $t3,$t3,$t2	#go to the location
	lb   $t4,0($t3)		#load byte from the location of the display
	bne  $t4,12,checkEighth
	addi  $s3,$s3,1	
					
checkEighth:
	addi $t0,$s0,1		#row+1
	addi $t1,$s1,1		#col+1
	mul  $t2,$t0,$s2	#(row+1)*colSize
	add  $t2,$t2,$t1	#(row+1)*colSize +(col+1)	
	add  $t3,$zero,$s4	#add temp display
	add  $t3,$t3,$t2	#go to the location
	lb   $t4,0($t3)		#load byte from the location of the display
	bne  $t4,12,doneCheckEqualFlag
	addi $s3,$s3,1
							
doneCheckEqualFlag:
	add  $v0,$zero,$s3
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
##################
_isNumOrMine:
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
	
	add $s0,$zero,$a0	#s0 is rowIndex
	add $s1,$zero,$a1	#s1 is colIndex	
	add $s2,$zero,$a2	#s2 is colSize
	la  $s3,board		#s3 is the address of board
	la  $s4,0xffff8000	#s4 is the address of the display
	
isNumOrMineOne:
	subi $t0,$s0,1		#t0 is row -1 
	subi $t1,$s1,1		#t1 is col -1 
	mul  $s5,$t0,$s2	#(row - 1)*colSize
	add  $s5,$s5,$t1	#(row-1)*colSize + (col-1) (location) s5 
	add  $t3,$zero,$s3	#temp board
	add  $t4,$zero,$s4	#temp display
	add  $t4,$t4,$s5	#go to the location of the temp display
	lb   $t5,0($t4)		#load byte from the temp display
	bne  $t5,12,isNumOrMineTwo
	add  $t3,$t3,$s5	#go to the location of the temp board
	lb   $t5,0($t3)		#load byte from the temp board
	bne  $t5,10,boomMine	#if the byte is not 10, then boom all mine
		
isNumOrMineTwo:	
	subi $t0,$s0,1		#t0 is row -1 
	add  $t1,$s1,$zero	#t1 is col  
	mul  $s5,$t0,$s2	#(row - 1)*colSize
	add  $s5,$s5,$t1	#(row-1)*colSize + (col) (location) s5 
	add  $t3,$zero,$s3	#temp board
	add  $t4,$zero,$s4	#temp display
	add  $t4,$t4,$s5	#go to the location of the temp display
	lb   $t5,0($t4)		#load byte from the temp display
	bne  $t5,12,isNumOrMineThree
	add  $t3,$t3,$s5	#go to the location of the temp board
	lb   $t5,0($t3)		#load byte from the temp board
	bne  $t5,10,boomMine	#if the byte is not 10, then boom all mine
isNumOrMineThree:
	subi $t0,$s0,1		#t0 is row -1 
	addi  $t1,$s1,1		#t1 is col +1 
	mul  $s5,$t0,$s2	#(row - 1)*colSize
	add  $s5,$s5,$t1	#(row-1)*colSize + (col+1) (location) s5 
	add  $t3,$zero,$s3	#temp board
	add  $t4,$zero,$s4	#temp display
	add  $t4,$t4,$s5	#go to the location of the temp display
	lb   $t5,0($t4)		#load byte from the temp display
	bne  $t5,12,isNumOrMineFour
	add  $t3,$t3,$s5	#go to the location of the temp board
	lb   $t5,0($t3)		#load byte from the temp board
	bne  $t5,10,boomMine	#if the byte is not 10, then boom all mine
isNumOrMineFour:
	add  $t0,$s0,$zero	#t0 is row 
	subi $t1,$s1,1		#t1 is col -1 
	mul  $s5,$t0,$s2	#(row)*colSize
	add  $s5,$s5,$t1	#(row)*colSize + (col-1) (location) s5 
	add  $t3,$zero,$s3	#temp board
	add  $t4,$zero,$s4	#temp display
	add  $t4,$t4,$s5	#go to the location of the temp display
	lb   $t5,0($t4)		#load byte from the temp display
	bne  $t5,12,isNumOrMineFive
	add  $t3,$t3,$s5	#go to the location of the temp board
	lb   $t5,0($t3)		#load byte from the temp board
	bne  $t5,10,boomMine	#if the byte is not 10, then boom all mine
isNumOrMineFive:
	add  $t0,$s0,$zero	#t0 is row 
	addi $t1,$s1,1		#t1 is col +1 
	mul  $s5,$t0,$s2	#(row)*colSize
	add  $s5,$s5,$t1	#(row)*colSize + (col+1) (location) s5 
	add  $t3,$zero,$s3	#temp board
	add  $t4,$zero,$s4	#temp display
	add  $t4,$t4,$s5	#go to the location of the temp display
	lb   $t5,0($t4)		#load byte from the temp display
	bne  $t5,12,isNumOrMineSix
	add  $t3,$t3,$s5	#go to the location of the temp board
	lb   $t5,0($t3)		#load byte from the temp board
	bne  $t5,10,boomMine	#if the byte is not 10, then boom all mine
isNumOrMineSix:	
	addi $t0,$s0,1		#t0 is row +1
	subi $t1,$s1,1		#t1 is col -1 
	mul  $s5,$t0,$s2	#(row)*colSize
	add  $s5,$s5,$t1	#(row+1)*colSize + (col-1) (location) s5 
	add  $t3,$zero,$s3	#temp board
	add  $t4,$zero,$s4	#temp display
	add  $t4,$t4,$s5	#go to the location of the temp display
	lb   $t5,0($t4)		#load byte from the temp display
	bne  $t5,12,isNumOrMineSeven
	add  $t3,$t3,$s5	#go to the location of the temp board
	lb   $t5,0($t3)		#load byte from the temp board
	bne  $t5,10,boomMine	#if the byte is not 10, then boom all mine
isNumOrMineSeven:	
	addi $t0,$s0,1		#t0 is row +1
	add  $t1,$s1,$zero	#t1 is col 
	mul  $s5,$t0,$s2	#(row)*colSize
	add  $s5,$s5,$t1	#(row+1)*colSize + (col) (location) s5 
	add  $t3,$zero,$s3	#temp board
	add  $t4,$zero,$s4	#temp display
	add  $t4,$t4,$s5	#go to the location of the temp display
	lb   $t5,0($t4)		#load byte from the temp display
	bne  $t5,12,isNumOrMineEight
	add  $t3,$t3,$s5	#go to the location of the temp board
	lb   $t5,0($t3)		#load byte from the temp board
	bne  $t5,10,boomMine	#if the byte is not 10, then boom all mine
	
isNumOrMineEight:
	addi $t0,$s0,1		#t0 is row +1
	addi $t1,$s1,1		#t1 is col +1 
	mul  $s5,$t0,$s2	#(row)*colSize
	add  $s5,$s5,$t1	#(row+1)*colSize + (col+1) (location) s5 
	add  $t3,$zero,$s3	#temp board
	add  $t4,$zero,$s4	#temp display
	add  $t4,$t4,$s5	#go to the location of the temp display
	lb   $t5,0($t4)		#load byte from the temp display
	bne  $t5,12,doneIsNumOrMine
	add  $t3,$t3,$s5	#go to the location of the temp board
	lb   $t5,0($t3)		#load byte from the temp board
	bne  $t5,10,boomMine	#if the byte is not 10, then boom all mine
	j   doneIsNumOrMine		
boomMine:	
	add $a0,$zero,$s5	#the index of wrong click flag
	add $a1,$zero,$s2	#the colSize
	jal _openAllMines
	add $s4,$s4,$s5		#go to the location of the display
	addi $s6,$zero,11	#red cross mine
	sb  $s6,0($s4)		#display the red cross
	add $v0,$zero,1		#if it booms, then v0 is 1
	j finishIsNumOrMine
	
doneIsNumOrMine:
	add  $v0,$zero,$zero
	j  finishIsNumOrMine
finishIsNumOrMine:

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
	
##################
_showStatus:
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
	
	add $t0,$zero,$a0	#x*x
	mul $s0,$t0,$t0		#bound
	add $s2,$zero,$zero	#counter of board
	add $s3,$zero,$zero	#counter of open cells
	add $s4,$zero,$zero	#counter of flags
	la  $s5,0xffff8000
	
	beq $t0,8,tenMines
	beq $t0,12,fifteenMines
	beq $t0,16,sixteenMines
tenMines:
	addi $t8,$zero,54
	j beginCheckStatus
fifteenMines:
	addi $t8,$zero,129		
	j beginCheckStatus
sixteenMines:
	addi $t8,$zero,236
	j beginCheckStatus
	
beginCheckStatus:
	beq $s2,$s0,printStatus #if counter equal to bound, then done				
	lb  $t1,0($s5)		#load the byte from the display
	beq $t1,$zero,notOpen	  #if the byte is zero, then it is closed
	beq $t1,12,flagStatus	#if it is a flag
	addi $s3,$s3,1		#add 1 to the counter of open cells
	addi $s5,$s5,1		#add 1 to the display
	addi $s2,$s2,1		#add 1 to the counter of the board
	j beginCheckStatus

flagStatus:
	addi $s4,$s4,1		#add the counter of flag 1 		
	addi $s5,$s5,1		#add 1 to the display
	addi $s2,$s2,1		#add 1 to the counter of the board
	j beginCheckStatus
notOpen:
	addi $s2,$s2,1		#add 1 to the counter of the board 
	addi $s5,$s5,1		#add counter 
	j beginCheckStatus		
printStatus:
	#add num of open cells and flags
	#Print 
	addi $v0,$zero,4	#print message
	la $a0,	numOfOpenCells
	syscall
	
	addi $v0,$zero,1	#print counter of the openCells
	add $a0,$zero,$s3
	syscall
	
	addi $v0,$zero,4	#print message
	la $a0, numOfFlags
	syscall
	
	addi $v0,$zero,1
	add $a0,$zero,$s4	#print the counter of flags
	syscall
	
	addi $v0,$zero,4
	la $a0,newLine
	syscall
	
	
	beq $s3,$t8,winGame
	j doneShowStatus

winGame:
	addi $v0,$zero,4
	la $a0,youWin
	syscall
	j doneShowStatus		
doneShowStatus:
	
	add  $v0,$zero,$s3
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
		
####################	
_clearDisplay:
	addi $sp,$sp,-20
	sw   $s0,16($sp)
	sw   $s1,12($sp)
	sw   $s2,8($sp)
	sw   $s3,4($sp)
	sw   $ra,0($sp)
	
	addi $s0,$zero,256	#bound
	add $s1,$zero,$zero 	#counter
	la  $s2,0xffff8000	#load display
	
loopClearDisplay:	
	beq  $s1,$s0,doneClearDisplay
	sb   $zero,0($s2)
	addi $s2,$s2,1
	addi $s1,$s1,1
	j    loopClearDisplay
	#jr    $ra
	
doneClearDisplay:
	lw   $s0,16($sp)
	lw   $s1,12($sp)
	lw   $s2,8($sp)
	lw   $s3,4($sp)
	lw   $ra,0($sp)
	addi $sp,$sp,20
	jr    $ra	
####################	
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
####################	

