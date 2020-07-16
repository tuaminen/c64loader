;-------------------------------------------------------------------------------
; Covert Bitops Fastloader-based loader, https://github.com/cadaver/c64loader
; Modded by Petri Tuominen.
;
; Fastload & unpack main PRG file, and starts the main PRG by jumping to $80d.
;
; This loader is initially loaded to $800.. area, where the loader is then relocated to 
; $8000 (LOADER_START_ADDR) area. This is necessary because the actual .PRG will 
; be loaded to $800 area and must not overwrite this fastloader (except initloader).
;
;-------------------------------------------------------------------------------

LOADER_START_ADDR = $8000
PTPRG_JUMP_ADDR	  = $80d


                processor 6502
				org $0801

                dc.b $0b,$08           ;Address of next BASIC instruction
                dc.w 1984              ;Line number
                dc.b $9e               ;SYS-token
				dc.b $32,$30,$36,$31   ;2061 in ASCII 
                dc.b $00,$00,$00       ;BASIC program end

start:          
				; Black colors
				lda #0
				sta $d020
				sta $d021

; Relocate code
; SRC: https://www.lemon64.com/forum/viewtopic.php?t=69663&sid=5c688fe04415b5e5267f34f6237bd858
;
				ldx #$00

RELsrc: 		lda relocated_start,x
RELdst:  		sta LOADER_START_ADDR,x
				inx
				bne RELsrc

				inc RELsrc+2
				inc RELdst+2

				lda RELsrc+2
				cmp #>relocated_end
				bne RELsrc

				jmp LOADER_START_ADDR
	

; Relocated code begins ------
relocated_start:		
				rorg LOADER_START_ADDR
								
				jsr initloader
						
                ldx #<mainfilename
				ldy #>mainfilename
				
				jsr loadfile_exomizer   ;Load file
                bcc ok
			
                sta $d020               ;If error, show errorcode in border
exit:           jsr getin
                tax
                beq exit
                jmp 64738

ok:             jmp PTPRG_JUMP_ADDR

				include cfg_exom3.s
                include loader.s

mainfilename:       dc.b "GAME",0 ; Must use CAPITAL LETTERS!


relocated_end:
; Relocated code ended  ------