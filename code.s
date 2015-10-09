	   THUMB
       AREA    DATA, ALIGN=2
       ALIGN          
       AREA    |.text|, CODE, READONLY, ALIGN=2
       EXPORT  Start
	   ;unlock 0x4C4F434B
	   
	   ;PF4 is SW1
	   ;PF0 is SW2
	   ;PF1 is RGB Red
	   ;Enable Clock RCGCGPIO p338
	   ;Set direction 1 is out 0 is in. GPIODIR
	   ;DEN 
	   ; 0x3FC
	   
PA EQU 0x40004000
PB EQU 0x40005000
PE EQU 0x40024000
PF EQU 0x40025000
PD EQU 0x40007000
T2 EQU 0x40032000
DELAY5 EQU 0xFFFF
CP EQU 0xE000E000
	
RCGC2 EQU 0x400FE108


Start  
	; set up clock
	LDR R1,=RCGC2
	LDR R0,=0x3B
	STR R0,[R1]
	
	ldr R1,=0x400FE000
	mov R0,#0x4
	strb R0,[R1,#0x106]
	
	NOP
	NOP
	
	
	; Port B Configuration
	LDR R1, =PB
	; Disable alternative functionality
	MOV R0, #0x0
	STR R0, [R1, #0x420]
	; Set Direction
	LDR R0, [R1,#0x400]
	MOV R0, #0x33 ;0x33= 0b00110011 0145
	STR R0, [R1,#0x400]
	; Enable
	MOV R0, #0x33
	STR R0, [R1, #0x51C]
	
	
	; Port A Configuration
	LDR R1, =PA
	; Disable alternative functionality
	MOV R0, #0x0
	STR R0, [R1, #0x420]
	; Set Direction
	LDR R0, [R1,#0x400]
	MOV R0, #0xE0 ;0xE0= 0b11100000 567
	STR R0, [R1,#0x400]
	; Enable
	MOV R0, #0xE4
	STR R0, [R1, #0x51C]


	; Port E Configuration
	LDR R1, =PE
	; Disable alternative functionality
	MOV R0, #0x0
	STR R0, [R1, #0x420]
	; Set Direction
	MOV R0, #0x32 ;0x32= 0b00110010
	STR R0, [R1,#0x400]
	; Enable
	MOV R0, #0x32
	STR R0, [R1, #0x51C]
	
	
	;Port D
	LDR R1, =PD
	MOV R0, #0x0
	STR R0, [R1, #0x420] ; Disable alternative functionality
	STR R0, [R1, #0x400] ; Direction
	STR R0, [R1, #0x50C] ; Open Drain
	MOV R0, #0xCF
	STR R0, [R1, #0x51C]
	
	
	; Port F Configuration
	LDR R1, =PF
	; Unlock port
	mov32 R0, #0x4C4F434B
	STR R0, [R1,#0x520]
	MOV R0, #0x1F ;giiocr
	STR R0, [R1, #0x524]
	MOV R0, #0x11 ;giiocr
	STR R0, [R1, #0x510]
	; Disable alternative functionality
	MOV R0, #0x0
	STR R0, [R1, #0x420]
	; Set Direction
	LDR R0, [R1,#0x400]
	MOV R0, #0x00 ;0x11= 0b00010001
	STR R0, [R1,#0x400]
	; Enable
	MOV R0, #0x1F
	STR R0, [R1, #0x51C]
	
	; Timer2
	LDR R1, =T2
	; Stop timer
	MOV R0, #0x0
	STR R0, [R1, #0xC]
	; Select 16 bit mode
	MOV R0, #0x4
	STR R0, [R1, #0x0]
	; Select periodic for timer a
	MOV R0, #0x2
	STR R0, [R1, #0x4]
	; Select one shot for timer b
	MOV R0, #0x1
	STR R0, [R1, #0x8]
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
	;load R2 and R3 with on and off values for the LEDs
	MOV R5, #0x0; LED 5 off state
	MOV R6, #0x0; LED 6 off state
		
Flash;reset was just pressed
	MOV R2, #0x10; turn on led 5
	MOV R3, #0x20; turn on led 6
	BL SetLEDs
		
	BL Timer2
		
	MOV R2, R5; turn them off
	MOV R3, R6
	BL SetLEDs
	
	BL Timer2
	
	ORR R7, R5, R6
	CMP R7, #0x30
	BNE Flash
	B StartGame
    

Timer5
	LDR R1, =T2
	LDR R0, =DELAY5		;the number of iterations 8000
	STR R0, [R1, #0x2C]
	MOV R0, #0x100				;start timer
	STR R0, [R1, #0xC]
	
Tloop5
	LDR R1, =T2
	LDRB R10, [R1, #0x1D]		;load time in to see if it is ready yet
	MOV R0, #0x1
	CMP R0, R10		;check to see if 1
	BNE Tloop5
	
	BX LR
	
Timer2
	PUSH{LR}
	LDR R1, =0xE000E000
	LDR R0, =1D6136	;the number of iterations 8000
	STR R0, [R1, #0x14]
	MOV R0, #1				;start timer
	STR R0, [R1, #0x10]
	B Tloop2
	
Tloop2
	BL Timer5
	
	;code to check pin D for sw1#0x1 and sw2#0x2
	LDR R1, =PD ;sw 1
	LDR R0, [R1, #0x3FC] ; Load data for external switches
	AND R1, R0, #0x3
	
	;Now we check our 
	CMP R1, #0x1 ; Check for sw1
	ITT EQ ;jump if not equal
	MOVEQ R5, #0x10
	BLEQ StartRandomTimer
	
	CMP R1, #0x2 ;check for sw2
	ITT EQ ;jump if not equal
	MOVEQ R6, #0x20
	BLEQ StartRandomTimer
	
	LDR R1, =0xE000E000
	ldr R10, [R1, #0x10]		;load time in to see if it is ready yet
	MOV R0, #0x1
	CMP R0, R10, LSR #16		;check to see if 1
	BNE Tloop2
	
	MOV R0, #0				;stop timer
	STR R0, [R1, #0x10]
	POP{LR}
	BX LR
	
StartRandomTimer
	ORR R0, R5, R6
	CMP R0, #0x30
	BXEQ LR

	LDR R1, =T2
	LDR R0, =DELAY5		;the number of iterations 8000
	STR R0, [R1, #0x2C]
	MOV R0, #0x1				;start timer
	STR R0, [R1, #0xC]

	BX LR
	

StartGame
	; Load the random time value from T2A
	LDR R1, =T2
	LDR R11, [R1,#0x50]
	LSL R11, #8
	
	MOV R12, #0 ; Number of draws

	MOV R2, #0x20 ; Left Player
	MOV R3, #0x10 ; Right Player

	BL SetLEDs

	B MoveDelay


MoveDelay
	LDR R5, =CP
	MOV R0, #0
	STR R0, [R5, #0x10]
	LDR R0, =0x3AC26C ; 1 Second
	ADD R0, R11
	STR R0, [R5, #0x14]
	MOV R0, #0
	STR R0, [R5, #0x18]
	MOV R0, #0x5
	STR R0, [R5, #0x10]

MoveDelayLoop
	LDRB R0, [R5, #0x12]
	MOV R1, #0x1
	CMP R0, R1
	BEQ MoveApart

	B MoveDelayLoop


MoveApart
	LSL R2, R2, #1
	LSR R3, R3, #1

	BL SetLEDs

	B FirstRace


FirstRace
	LDR R4, =PD
	LDR R0, [R4, #0x3FC] ; Load data for switches

	AND R1, R0, #0x3

	CMP R1, #0x1
	BEQ MovePlayer2

	CMP R1, #0x2
	BEQ MovePlayer1
	
	BL Timer5
	B FirstRace


MovePlayer1
	LSR R2, R2, #1
	BL SetLEDs

	; Start timer for player 1
	LDR R5, =CP
	MOV R0, #0
	STR R0, [R5, #0x10]
	
	LDR R0, [R4, #0x3FC] ; Load data for switches
	AND R1, R0, #0xC0
	LSR R1, #6
	
	BL SetRoundDelay
	
	MOV R0, #0
	STR R0, [R5, #0x18]
	MOV R0, #0x5
	STR R0, [R5, #0x10]

WaitForPlayer2
	LDRB R0, [R5, #0x12]
	MOV R1, #0x1
	CMP R0, R1
	BEQ Player1WonRound

	LDR R0, [R4, #0x3FC] ; Load data for switches
	AND R1, R0, #0x3

	CMP R1, #0x1
	BEQ Draw1
	BL Timer5
	B WaitForPlayer2

Player1WonRound
	LSR R2, R2, #1
	BL SetLEDs

	CMP R3, #0x1
	BEQ GameOver

	B MoveDelay
	
Draw1
	LSL R3, R3, #1
	BL SetLEDs
	
	ADD R12, #1
	
	B MoveDelay


MovePlayer2
	LSL R3, R3, #1
	BL SetLEDs

	; Start timer for player 2
	LDR R5, =CP
	MOV R0, #0
	STR R0, [R5, #0x10]
	
	LDR R0, [R4, #0x3FC] ; Load data for switches
	AND R1, R0, #0xC
	LSR R1, #2
	
	BL SetRoundDelay
	
	LSR R1, R0
	
	MOV R0, #0
	STR R0, [R5, #0x18]
	MOV R0, #0x5
	STR R0, [R5, #0x10]

WaitForPlayer1
	LDRB R0, [R5, #0x12]
	MOV R1, #0x1
	CMP R0, R1
	BEQ Player2WonRound

	LDR R0, [R4, #0x3FC] ; Load data for switches
	AND R1, R0, #0x3

	CMP R1, #0x2
	BEQ Draw2
	BL Timer5
	B WaitForPlayer1

Player2WonRound
	LSL R3, R3, #1
	BL SetLEDs

	MOV R0, #0x200
	CMP R2, R0
	BEQ GameOver

	B MoveDelay
	
Draw2
	LSR R2, R2, #1
	BL SetLEDs
	
	ADD R12, #1

	B MoveDelay
	
SetRoundDelay
; Note: Delay for the player needs to be in R1
; and R5 should contain the address to the timer
	MOV R0, #80
	MUL R1, R0
	MOV R0, #320
	SUB R1, R0, R1
	
	MOV R0, #4
	CMP R0, R12
	IT LS
	MOVLS R0, R12
	
	LSR R1, R0
	
	LDR R0, =0x03FC68
	MUL R1, R0
	
	STR R1, [R5, #0x14]
	
	BX LR
	

GameOver
	MOV R5, R2
	MOV R6, R3
EndFlash;reset was just pressed
	MOV R2, R5
	MOV R3, R6; turn on led 6
	BL SetLEDs
		
	BL EndTimer
		
	MOV R2, #0x0; turn them off
	MOV R3, #0x0
	BL SetLEDs
	
	BL EndTimer
	
	B EndFlash
	
	
EndTimer
	PUSH{LR}
	LDR R1, =0xE000E000
	LDR R0, =0x1D6136	;the number of iterations 8000
	STR R0, [R1, #0x14]
	MOV R0, #1				;start timer
	STR R0, [R1, #0x10]
	B EndTloop
	
EndTloop
	LDR R1, =0xE000E000
	ldr R10, [R1, #0x10]		;load time in to see if it is ready yet
	MOV R0, #0x1
	CMP R0, R10, LSR #16		;check to see if 1
	BNE EndTloop
	
	MOV R0, #0				;stop timer
	STR R0, [R1, #0x10]
	POP{LR}
	BX LR



SetLEDs
	;2^0 -> B5
	;2^1 -> B0
	;2^2 -> B1
	;2^3 -> E4
	;2^4 -> E5
	;2^5 -> B4
	;2^6 -> A5
	;2^7 -> A6
	;2^8 -> A7
	;2^9 -> E1

	;A pins
	MOV R0, #0   		; Clear out the value in R0
	ORR R1, R2, R3 ; Get the value to set to the LEDs

	;A5
	LSRS R1, R1, #7
	IT CS
	ORRCS R0, R0, #0x20 

	;A6
	LSRS R1, R1, #1
	IT CS
	ORRCS R0, R0, #0x40 

	;A7
	LSRS R1, R1, #1
	IT CS
	ORRCS R0, R0, #0x80

	;Invert A data (active low) and write to GIPO
	MVN R0, R0
	LDR R1, =PA
	STR R0, [R1, #0x3FC]


	;B pins
	MOV R0, #0   		; Clear out the value in R0
	ORR R1, R2, R3 ; Get the value to set to the LEDs

	;B5
	LSRS R1, R1, #1
	IT CS
	ORRCS R0, R0, #0x20

	;B0
	LSRS R1, R1, #1
	IT CS
	ORRCS R0, R0, #0x1

	;B1
	LSRS R1, R1, #1
	IT CS
	ORRCS R0, R0, #0x2

	;B4
	LSRS R1, R1, #3
	IT CS
	ORRCS R0, R0, #0x10

	;Invert B data (active low) and write to GIPO
	MVN R0, R0
	LDR R1, =PB
	STR R0, [R1, #0x3FC]


	;E pins
	MOV R0, #0   		; Clear out the value in R0
	ORR R1, R2, R3 ; Get the value to set to the LEDs

	;E4
	LSRS R1, R1, #4
	IT CS
	ORRCS R0, R0, #0x10

	;E5
	LSRS R1, R1, #1
	IT CS
	ORRCS R0, R0, #0x20

	;E1
	LSRS R1, R1, #5
	IT CS
	ORRCS R0, R0, #0x2

	;Invert E data (active low) and write to GIPO
	MVN R0, R0
	LDR R1, =PE
	STR R0, [R1, #0x3FC]

	BX LR
	

 ALIGN      
 END  
