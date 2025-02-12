; UNIVERSIDAD DEL VALLE DE GUATEMALA
; IE2023: Programación de microcontroladores
; Laboratorio 1.asm
; Autor : Eduardo Samuel Urbina Pérez
; Proyecto : Prelaboratorio 1
; Hardware : ATmega 328
; Creado: 5/02/2025
; Descripción: el prelaboratorio 1 consiste en hacer un contador de 4 bits
;El laboratorio consiste en poner el contador 1 en un subrutina y hacer un segundo contador
;El postlbaoratorio consiste en sumar los dos contadores y encender un led si se activa carry
; aumentando con un boton en el pinD0 y decrementando con otro boton en el pinD1

.include "M328PDEF.inc"
.cseg
.org 0x0000

;Configuracion de la pila
LDI		R16, LOW(RAMEND)
OUT		SPL, R16 //cargar 0xff a SPL
LDI		R16, HIGH(RAMEND)
OUT		SPH, R16 //Cargar 0x08 a SPH

//Configuracion MCU
SETUP:
	//Configurar puertos
	//Configurar puerto C como entrada con pull-ups habilitados
	LDI		R16, 0x00
	OUT		DDRC, R16 //Configurar puerto C como entrada
	LDI		R16, 0xFF
	OUT		PORTC, R16 //Habilitara pull-ups
	//PB y PD - Salida
	//Configurar puerto B y D como salida
	LDI		R16, 0xFF
	OUT		DDRB, R16 //Configurar puerto B como salida
	OUT		DDRD, R16 //Configurar puerto D como salida

	LDI		R17, 0xFF //r17 se usa para guardar el estado de los botones
   	LDI		R18, 0x00 //r18 registro del contador a 0
	LDI		R21, 0x00 //r20 registro del contador 2 a 0
//Loop principal o infinito
LOOP:
	IN		R16, PINC //Leer puerto C
	CP		R17, R16 //Se apagó algun bit del puerto C?
	BREQ	LOOP

	CALL DELAY

	//Volver a leer
	IN		R16, PINC //Leer puerto C
	CP		R17, R16
	BREQ	LOOP

	MOV		R17, R16 //Se guarda estado nuevo de botones

	//Detectar que contador se está aumentando
	//Contador 1
	SBRC	R16, 1
	CALL	CON1
	SBRC	R16, 2
	CALL	CON1
	//Contador 2
	SBRC	R16, 4
	CALL	CON2
	SBRC	R16, 5
	CALL	CON2
	//Detectar suma
	SBRC	R16, 0
	RJMP	LOOP
	CALL	SUM
	RJMP	LOOP

//Contador 1
CON1:
	ANDI	R23, 0X0F //Borra los bits altos y deja los bajos
	SBRC	R16, 2 //se puso 0 bit 2 salta
	CALL	DEC1 
	SBRC	R16, 1 //se puso 0 bit 1 salta
	CALL	INC1
	ANDI	R18, 0xF0 //Permite que solo tenga valores en los bits altos
	ADD		R23, R18 //Suma el nuevo valor
	OUT		PORTD, R23
	RET
//Contador 2
CON2:
	ANDI	R23, 0XF0 //Borra los bits bajos
	SBRC	R16, 5 //se puso 0 bit 5 salta
	DEC		R21
	SBRC	R16, 4 //se puso 0 bit 4 salta
	INC		R21
	ANDI	R21, 0x0F
	ADD		R23, R21 //Suma el nuevo valor
	OUT		PORTD, R23
	RET
SUM:
	LDI		R22, 0xF0 //Se agrega un valor inicial para verificar overflow
	SWAP	R18
	ADD		R22, R18
	SWAP	R18
	ADC		R22, R21
	BRCS    ENCENDER // Si C=1, saltar a ENCENDER
    CBI     PORTB, 4 //Si no hay Carry, apagar PB4
	ANDI	R22, 0x0F
	OUT		PORTB, R22
	RET
DEC1:
	SWAP	R18
	DEC		R18
	SWAP	R18
	RET
INC1:
	SWAP	R18
	INC		R18
	SWAP	R18
	RET
ENCENDER:
	SBI     PORTB, 4 //Si C=1, encender PB4
	RET
//Agregar un delay
//Subrutinas(que no son interrupcion)
DELAY:
	LDI		R19, 0
	LDI		R24, 0
BUCLE:
	INC		R19
	CPI		R19, 0
	BRNE	BUCLE
	INC		R24
	CPI		R24, 0
	BRNE	BUCLE
	RET
