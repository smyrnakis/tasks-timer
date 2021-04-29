
_write_ds1307:

;tasks_timer.c,101 :: 		void write_ds1307(unsigned short address, unsigned short w_data){  //---- WRITE
;tasks_timer.c,102 :: 		I2C1_Start();           // issue I2C start signal
	CALL       _I2C1_Start+0
;tasks_timer.c,103 :: 		I2C1_Wr(0xD0);          // Device Address + W = 0xD0
	MOVLW      208
	MOVWF      FARG_I2C1_Wr_data_+0
	CALL       _I2C1_Wr+0
;tasks_timer.c,104 :: 		I2C1_Wr(address);       // send byte (address of DS1307 location)
	MOVF       FARG_write_ds1307_address+0, 0
	MOVWF      FARG_I2C1_Wr_data_+0
	CALL       _I2C1_Wr+0
;tasks_timer.c,105 :: 		I2C1_Wr(w_data);        // send data (data to be written)
	MOVF       FARG_write_ds1307_w_data+0, 0
	MOVWF      FARG_I2C1_Wr_data_+0
	CALL       _I2C1_Wr+0
;tasks_timer.c,106 :: 		I2C1_Stop();            // issue I2C stop signal
	CALL       _I2C1_Stop+0
;tasks_timer.c,107 :: 		}
L_end_write_ds1307:
	RETURN
; end of _write_ds1307

_read_ds1307:

;tasks_timer.c,109 :: 		unsigned short read_ds1307(unsigned short address){                //---- READ
;tasks_timer.c,110 :: 		I2C1_Start();
	CALL       _I2C1_Start+0
;tasks_timer.c,111 :: 		I2C1_Wr(0xD0);          // Device Address + W = 0xD0
	MOVLW      208
	MOVWF      FARG_I2C1_Wr_data_+0
	CALL       _I2C1_Wr+0
;tasks_timer.c,112 :: 		I2C1_Wr(address);
	MOVF       FARG_read_ds1307_address+0, 0
	MOVWF      FARG_I2C1_Wr_data_+0
	CALL       _I2C1_Wr+0
;tasks_timer.c,113 :: 		I2C1_Repeated_Start();
	CALL       _I2C1_Repeated_Start+0
;tasks_timer.c,114 :: 		I2C1_Wr(0xD1);          // Device Address + R = 0xD1
	MOVLW      209
	MOVWF      FARG_I2C1_Wr_data_+0
	CALL       _I2C1_Wr+0
;tasks_timer.c,115 :: 		readData=I2C1_Rd(0);    // Read Data from DS1307
	CLRF       FARG_I2C1_Rd_ack+0
	CALL       _I2C1_Rd+0
	MOVF       R0+0, 0
	MOVWF      _readData+0
;tasks_timer.c,116 :: 		I2C1_Stop();
	CALL       _I2C1_Stop+0
;tasks_timer.c,117 :: 		return(readData);
	MOVF       _readData+0, 0
	MOVWF      R0+0
;tasks_timer.c,118 :: 		}
L_end_read_ds1307:
	RETURN
; end of _read_ds1307

_BCD2UpperCh:

;tasks_timer.c,120 :: 		unsigned char BCD2UpperCh(unsigned char bcd){                      //---- BCD
;tasks_timer.c,121 :: 		return ((bcd >> 4) + '0');
	MOVF       FARG_BCD2UpperCh_bcd+0, 0
	MOVWF      R0+0
	RRF        R0+0, 1
	BCF        R0+0, 7
	RRF        R0+0, 1
	BCF        R0+0, 7
	RRF        R0+0, 1
	BCF        R0+0, 7
	RRF        R0+0, 1
	BCF        R0+0, 7
	MOVLW      48
	ADDWF      R0+0, 1
;tasks_timer.c,122 :: 		}
L_end_BCD2UpperCh:
	RETURN
; end of _BCD2UpperCh

_BCD2LowerCh:

;tasks_timer.c,124 :: 		unsigned char BCD2LowerCh(unsigned char bcd){                      //---- BCD
;tasks_timer.c,125 :: 		return ((bcd & 0x0F) + '0');
	MOVLW      15
	ANDWF      FARG_BCD2LowerCh_bcd+0, 0
	MOVWF      R0+0
	MOVLW      48
	ADDWF      R0+0, 1
;tasks_timer.c,126 :: 		}
L_end_BCD2LowerCh:
	RETURN
; end of _BCD2LowerCh

_read_time:

;tasks_timer.c,128 :: 		void read_time(){          // ------------- Reading Time & Date -------------
;tasks_timer.c,129 :: 		msg[0] = BCD2UpperCh(read_ds1307(4));     // Date
	MOVLW      4
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      FARG_BCD2UpperCh_bcd+0
	CALL       _BCD2UpperCh+0
	MOVF       R0+0, 0
	MOVWF      _msg+0
;tasks_timer.c,130 :: 		msg[1] = BCD2LowerCh(read_ds1307(4));     // Date
	MOVLW      4
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      FARG_BCD2LowerCh_bcd+0
	CALL       _BCD2LowerCh+0
	MOVF       R0+0, 0
	MOVWF      _msg+1
;tasks_timer.c,131 :: 		msg[2] = '/';
	MOVLW      47
	MOVWF      _msg+2
;tasks_timer.c,132 :: 		msg[3] = BCD2UpperCh(read_ds1307(5));     // Month
	MOVLW      5
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      FARG_BCD2UpperCh_bcd+0
	CALL       _BCD2UpperCh+0
	MOVF       R0+0, 0
	MOVWF      _msg+3
;tasks_timer.c,133 :: 		msg[4] = BCD2LowerCh(read_ds1307(5));     // Month
	MOVLW      5
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      FARG_BCD2LowerCh_bcd+0
	CALL       _BCD2LowerCh+0
	MOVF       R0+0, 0
	MOVWF      _msg+4
;tasks_timer.c,134 :: 		msg[5] = '/';
	MOVLW      47
	MOVWF      _msg+5
;tasks_timer.c,135 :: 		msg[6] = BCD2UpperCh(read_ds1307(6));     // Year
	MOVLW      6
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      FARG_BCD2UpperCh_bcd+0
	CALL       _BCD2UpperCh+0
	MOVF       R0+0, 0
	MOVWF      _msg+6
;tasks_timer.c,136 :: 		msg[7] = BCD2LowerCh(read_ds1307(6));     // Year
	MOVLW      6
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      FARG_BCD2LowerCh_bcd+0
	CALL       _BCD2LowerCh+0
	MOVF       R0+0, 0
	MOVWF      _msg+7
;tasks_timer.c,137 :: 		msg[11] = BCD2UpperCh(read_ds1307(2));    // Hour
	MOVLW      2
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      FARG_BCD2UpperCh_bcd+0
	CALL       _BCD2UpperCh+0
	MOVF       R0+0, 0
	MOVWF      _msg+11
;tasks_timer.c,138 :: 		msg[12] = BCD2LowerCh(read_ds1307(2));    // Hour
	MOVLW      2
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      FARG_BCD2LowerCh_bcd+0
	CALL       _BCD2LowerCh+0
	MOVF       R0+0, 0
	MOVWF      _msg+12
;tasks_timer.c,139 :: 		msg[13] = ':';
	MOVLW      58
	MOVWF      _msg+13
;tasks_timer.c,140 :: 		msg[14] = BCD2UpperCh(read_ds1307(1));    // Minute
	MOVLW      1
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      FARG_BCD2UpperCh_bcd+0
	CALL       _BCD2UpperCh+0
	MOVF       R0+0, 0
	MOVWF      _msg+14
;tasks_timer.c,141 :: 		msg[15] = BCD2LowerCh(read_ds1307(1));    // Minute
	MOVLW      1
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      FARG_BCD2LowerCh_bcd+0
	CALL       _BCD2LowerCh+0
	MOVF       R0+0, 0
	MOVWF      _msg+15
;tasks_timer.c,142 :: 		msg[8] = ' ';
	MOVLW      32
	MOVWF      _msg+8
;tasks_timer.c,143 :: 		msg[9] = ' ';
	MOVLW      32
	MOVWF      _msg+9
;tasks_timer.c,144 :: 		msg[10] = ' ';
	MOVLW      32
	MOVWF      _msg+10
;tasks_timer.c,145 :: 		msg[16] = '\0';
	CLRF       _msg+16
;tasks_timer.c,146 :: 		incData = read_ds1307(0);                 // Read seconds (temp use)
	CLRF       FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      _incData+0
;tasks_timer.c,147 :: 		Lcd_Out(1,1,msg);                         // Printing time on LCD
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _msg+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;tasks_timer.c,148 :: 		}                          // ------------------------------------------------
L_end_read_time:
	RETURN
; end of _read_time

_CopyConst2Ram:

;tasks_timer.c,150 :: 		char * CopyConst2Ram(char * dest, const char * src){  // - texts to RAM copy -
;tasks_timer.c,152 :: 		d = dest;
	MOVF       FARG_CopyConst2Ram_dest+0, 0
	MOVWF      R3+0
;tasks_timer.c,153 :: 		for(;*dest++ = *src++;)
L_CopyConst2Ram0:
	MOVF       FARG_CopyConst2Ram_dest+0, 0
	MOVWF      R2+0
	INCF       FARG_CopyConst2Ram_dest+0, 1
	MOVF       FARG_CopyConst2Ram_src+0, 0
	MOVWF      R0+0
	MOVF       FARG_CopyConst2Ram_src+1, 0
	MOVWF      R0+1
	INCF       FARG_CopyConst2Ram_src+0, 1
	BTFSC      STATUS+0, 2
	INCF       FARG_CopyConst2Ram_src+1, 1
	MOVF       R0+0, 0
	MOVWF      ___DoICPAddr+0
	MOVF       R0+1, 0
	MOVWF      ___DoICPAddr+1
	CALL       _____DoICP+0
	MOVWF      R0+0
	MOVF       R2+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
	MOVF       R2+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_CopyConst2Ram1
;tasks_timer.c,154 :: 		;
	GOTO       L_CopyConst2Ram0
L_CopyConst2Ram1:
;tasks_timer.c,155 :: 		return d;
	MOVF       R3+0, 0
	MOVWF      R0+0
;tasks_timer.c,156 :: 		}                          // ------------------------------------------------
L_end_CopyConst2Ram:
	RETURN
; end of _CopyConst2Ram

_segment:

;tasks_timer.c,158 :: 		void segment(){            // ----------- 7 segment configuration ------------
;tasks_timer.c,159 :: 		switch (item){
	GOTO       L_segment3
;tasks_timer.c,160 :: 		case 0:  portd = 192; break;
L_segment5:
	MOVLW      192
	MOVWF      PORTD+0
	GOTO       L_segment4
;tasks_timer.c,161 :: 		case 1:  portd = 249; break;
L_segment6:
	MOVLW      249
	MOVWF      PORTD+0
	GOTO       L_segment4
;tasks_timer.c,162 :: 		case 2:  portd = 164; break;
L_segment7:
	MOVLW      164
	MOVWF      PORTD+0
	GOTO       L_segment4
;tasks_timer.c,163 :: 		case 3:  portd = 176; break;
L_segment8:
	MOVLW      176
	MOVWF      PORTD+0
	GOTO       L_segment4
;tasks_timer.c,164 :: 		case 4:  portd = 153; break;
L_segment9:
	MOVLW      153
	MOVWF      PORTD+0
	GOTO       L_segment4
;tasks_timer.c,165 :: 		case 5:  portd = 146; break;
L_segment10:
	MOVLW      146
	MOVWF      PORTD+0
	GOTO       L_segment4
;tasks_timer.c,166 :: 		case 6:  portd = 130; break;
L_segment11:
	MOVLW      130
	MOVWF      PORTD+0
	GOTO       L_segment4
;tasks_timer.c,167 :: 		case 7:  portd = 248; break;
L_segment12:
	MOVLW      248
	MOVWF      PORTD+0
	GOTO       L_segment4
;tasks_timer.c,168 :: 		case 8:  portd = 128; break;
L_segment13:
	MOVLW      128
	MOVWF      PORTD+0
	GOTO       L_segment4
;tasks_timer.c,169 :: 		case 9:  portd = 144; break;
L_segment14:
	MOVLW      144
	MOVWF      PORTD+0
	GOTO       L_segment4
;tasks_timer.c,170 :: 		default: portd = 191; break;
L_segment15:
	MOVLW      191
	MOVWF      PORTD+0
	GOTO       L_segment4
;tasks_timer.c,171 :: 		}
L_segment3:
	MOVF       _item+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_segment5
	MOVF       _item+0, 0
	XORLW      1
	BTFSC      STATUS+0, 2
	GOTO       L_segment6
	MOVF       _item+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L_segment7
	MOVF       _item+0, 0
	XORLW      3
	BTFSC      STATUS+0, 2
	GOTO       L_segment8
	MOVF       _item+0, 0
	XORLW      4
	BTFSC      STATUS+0, 2
	GOTO       L_segment9
	MOVF       _item+0, 0
	XORLW      5
	BTFSC      STATUS+0, 2
	GOTO       L_segment10
	MOVF       _item+0, 0
	XORLW      6
	BTFSC      STATUS+0, 2
	GOTO       L_segment11
	MOVF       _item+0, 0
	XORLW      7
	BTFSC      STATUS+0, 2
	GOTO       L_segment12
	MOVF       _item+0, 0
	XORLW      8
	BTFSC      STATUS+0, 2
	GOTO       L_segment13
	MOVF       _item+0, 0
	XORLW      9
	BTFSC      STATUS+0, 2
	GOTO       L_segment14
	GOTO       L_segment15
L_segment4:
;tasks_timer.c,172 :: 		}                          // ------------------------------------------------
L_end_segment:
	RETURN
; end of _segment

_rgb:

;tasks_timer.c,174 :: 		void rgb(){                // --------------  RGB LED control ----------------
;tasks_timer.c,175 :: 		if (item == 10){
	MOVF       _item+0, 0
	XORLW      10
	BTFSS      STATUS+0, 2
	GOTO       L_rgb16
;tasks_timer.c,176 :: 		if ((state[0] || state[1] || state[2] || state[3] ||
	MOVF       _state+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_rgb18
	MOVF       _state+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L_rgb18
	MOVF       _state+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L_rgb18
	MOVF       _state+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L_rgb18
;tasks_timer.c,177 :: 		state[4] || state[5] || state[6] || state[7] ||
	MOVF       _state+4, 0
	BTFSS      STATUS+0, 2
	GOTO       L_rgb18
	MOVF       _state+5, 0
	BTFSS      STATUS+0, 2
	GOTO       L_rgb18
	MOVF       _state+6, 0
	BTFSS      STATUS+0, 2
	GOTO       L_rgb18
	MOVF       _state+7, 0
	BTFSS      STATUS+0, 2
	GOTO       L_rgb18
;tasks_timer.c,178 :: 		state[8] || state[9]) == 1){
	MOVF       _state+8, 0
	BTFSS      STATUS+0, 2
	GOTO       L_rgb18
	MOVF       _state+9, 0
	BTFSS      STATUS+0, 2
	GOTO       L_rgb18
	CLRF       R1+0
	GOTO       L_rgb17
L_rgb18:
	MOVLW      1
	MOVWF      R1+0
L_rgb17:
	MOVF       R1+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_rgb19
;tasks_timer.c,179 :: 		PORTA.f1 = 1;               // Blue LED
	BSF        PORTA+0, 1
;tasks_timer.c,180 :: 		PORTA.f2 = 0;               // Green LED
	BCF        PORTA+0, 2
;tasks_timer.c,181 :: 		PORTA.f3 = 0;               // Red LED
	BCF        PORTA+0, 3
;tasks_timer.c,182 :: 		} else {
	GOTO       L_rgb20
L_rgb19:
;tasks_timer.c,183 :: 		PORTA.f1 = 0;
	BCF        PORTA+0, 1
;tasks_timer.c,184 :: 		PORTA.f2 = 0;
	BCF        PORTA+0, 2
;tasks_timer.c,185 :: 		PORTA.f3 = 1;
	BSF        PORTA+0, 3
;tasks_timer.c,186 :: 		}
L_rgb20:
;tasks_timer.c,187 :: 		} else if (state[item]){
	GOTO       L_rgb21
L_rgb16:
	MOVF       _item+0, 0
	ADDLW      _state+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_rgb22
;tasks_timer.c,188 :: 		PORTA.f1 = 0;
	BCF        PORTA+0, 1
;tasks_timer.c,189 :: 		PORTA.f2 = 1;
	BSF        PORTA+0, 2
;tasks_timer.c,190 :: 		PORTA.f3 = 0;
	BCF        PORTA+0, 3
;tasks_timer.c,191 :: 		} else {
	GOTO       L_rgb23
L_rgb22:
;tasks_timer.c,192 :: 		if ((state[0] || state[1] || state[2] || state[3] ||
	MOVF       _state+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_rgb25
	MOVF       _state+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L_rgb25
	MOVF       _state+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L_rgb25
	MOVF       _state+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L_rgb25
;tasks_timer.c,193 :: 		state[4] || state[5] || state[6] || state[7] ||
	MOVF       _state+4, 0
	BTFSS      STATUS+0, 2
	GOTO       L_rgb25
	MOVF       _state+5, 0
	BTFSS      STATUS+0, 2
	GOTO       L_rgb25
	MOVF       _state+6, 0
	BTFSS      STATUS+0, 2
	GOTO       L_rgb25
	MOVF       _state+7, 0
	BTFSS      STATUS+0, 2
	GOTO       L_rgb25
;tasks_timer.c,194 :: 		state[8] || state[9]) == 1){
	MOVF       _state+8, 0
	BTFSS      STATUS+0, 2
	GOTO       L_rgb25
	MOVF       _state+9, 0
	BTFSS      STATUS+0, 2
	GOTO       L_rgb25
	CLRF       R1+0
	GOTO       L_rgb24
L_rgb25:
	MOVLW      1
	MOVWF      R1+0
L_rgb24:
	MOVF       R1+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_rgb26
;tasks_timer.c,195 :: 		PORTA.f1 = 1;
	BSF        PORTA+0, 1
;tasks_timer.c,196 :: 		PORTA.f2 = 0;
	BCF        PORTA+0, 2
;tasks_timer.c,197 :: 		PORTA.f3 = 0;
	BCF        PORTA+0, 3
;tasks_timer.c,198 :: 		} else {
	GOTO       L_rgb27
L_rgb26:
;tasks_timer.c,199 :: 		PORTA.f1 = 0;
	BCF        PORTA+0, 1
;tasks_timer.c,200 :: 		PORTA.f2 = 0;
	BCF        PORTA+0, 2
;tasks_timer.c,201 :: 		PORTA.f3 = 1;
	BSF        PORTA+0, 3
;tasks_timer.c,202 :: 		}
L_rgb27:
;tasks_timer.c,203 :: 		}
L_rgb23:
L_rgb21:
;tasks_timer.c,204 :: 		}                          // ------------------------------------------------
L_end_rgb:
	RETURN
; end of _rgb

_calc_minutes:

;tasks_timer.c,206 :: 		void calc_minutes(){       // --------- Calculating mins from secs -----------
;tasks_timer.c,207 :: 		if(item != 10){
	MOVF       _item+0, 0
	XORLW      10
	BTFSC      STATUS+0, 2
	GOTO       L_calc_minutes28
;tasks_timer.c,208 :: 		msg[0] = (((secCount[item]/60)/100)%10)+48;
	MOVF       _item+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	ADDLW      _secCount+0
	MOVWF      FLOC__calc_minutes+0
	MOVF       FLOC__calc_minutes+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R0+0
	INCF       FSR, 1
	MOVF       INDF+0, 0
	MOVWF      R0+1
	MOVLW      60
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Div_16x16_U+0
	MOVLW      100
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Div_16x16_U+0
	MOVLW      10
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Div_16x16_U+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      _msg+0
;tasks_timer.c,209 :: 		msg[1] = (((secCount[item]/60)/10)%10)+48;
	MOVF       FLOC__calc_minutes+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R0+0
	INCF       FSR, 1
	MOVF       INDF+0, 0
	MOVWF      R0+1
	MOVLW      60
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Div_16x16_U+0
	MOVLW      10
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Div_16x16_U+0
	MOVLW      10
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Div_16x16_U+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      _msg+1
;tasks_timer.c,210 :: 		msg[2] = ((secCount[item]/60)%10)+48;
	MOVF       FLOC__calc_minutes+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R0+0
	INCF       FSR, 1
	MOVF       INDF+0, 0
	MOVWF      R0+1
	MOVLW      60
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Div_16x16_U+0
	MOVLW      10
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Div_16x16_U+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      _msg+2
;tasks_timer.c,211 :: 		msg[3] = '\0';
	CLRF       _msg+3
;tasks_timer.c,212 :: 		} else {
	GOTO       L_calc_minutes29
L_calc_minutes28:
;tasks_timer.c,213 :: 		CopyConst2Ram(msg,blank3);
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _blank3+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_blank3+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
;tasks_timer.c,214 :: 		}
L_calc_minutes29:
;tasks_timer.c,215 :: 		Lcd_Out(2,14,msg);
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      14
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _msg+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;tasks_timer.c,216 :: 		}                          // ------------------------------------------------
L_end_calc_minutes:
	RETURN
; end of _calc_minutes

_print_state:

;tasks_timer.c,218 :: 		void print_state(){        // --------- Printing state of each task ----------
;tasks_timer.c,219 :: 		if (item == 10){
	MOVF       _item+0, 0
	XORLW      10
	BTFSS      STATUS+0, 2
	GOTO       L_print_state30
;tasks_timer.c,220 :: 		CopyConst2Ram(msg,blank7);
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _blank7+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_blank7+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
;tasks_timer.c,221 :: 		} else if (state[item] == 0){
	GOTO       L_print_state31
L_print_state30:
	MOVF       _item+0, 0
	ADDLW      _state+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_print_state32
;tasks_timer.c,222 :: 		CopyConst2Ram(msg,stopped);
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _stopped+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_stopped+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
;tasks_timer.c,223 :: 		} else {
	GOTO       L_print_state33
L_print_state32:
;tasks_timer.c,224 :: 		CopyConst2Ram(msg,running);
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _running+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_running+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
;tasks_timer.c,225 :: 		}
L_print_state33:
L_print_state31:
;tasks_timer.c,226 :: 		Lcd_Out(2,1,msg);
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _msg+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;tasks_timer.c,227 :: 		}                          // ------------------------------------------------
L_end_print_state:
	RETURN
; end of _print_state

_incHour:

;tasks_timer.c,229 :: 		void incHour(){            // -------- Time / Date setting functions ---------
;tasks_timer.c,230 :: 		read_time();
	CALL       _read_time+0
;tasks_timer.c,231 :: 		if ((msg[11] == 50) && (msg[12] == 51)){         // 23 --> 00
	MOVF       _msg+11, 0
	XORLW      50
	BTFSS      STATUS+0, 2
	GOTO       L_incHour36
	MOVF       _msg+12, 0
	XORLW      51
	BTFSS      STATUS+0, 2
	GOTO       L_incHour36
L__incHour373:
;tasks_timer.c,232 :: 		msg[11] = 48;
	MOVLW      48
	MOVWF      _msg+11
;tasks_timer.c,233 :: 		msg[12] = 48;
	MOVLW      48
	MOVWF      _msg+12
;tasks_timer.c,234 :: 		write_ds1307(0,0x80); // Stop Oscillator (0)
	CLRF       FARG_write_ds1307_address+0
	MOVLW      128
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,235 :: 		write_ds1307(2,0x00); // write hours
	MOVLW      2
	MOVWF      FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,236 :: 		write_ds1307(0,0x00); // Start Oscillator (1)
	CLRF       FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,237 :: 		} else if ((msg[11] == 48) && (msg[12] == 57)){  // 09 --> 10
	GOTO       L_incHour37
L_incHour36:
	MOVF       _msg+11, 0
	XORLW      48
	BTFSS      STATUS+0, 2
	GOTO       L_incHour40
	MOVF       _msg+12, 0
	XORLW      57
	BTFSS      STATUS+0, 2
	GOTO       L_incHour40
L__incHour372:
;tasks_timer.c,238 :: 		msg[11] = 49;
	MOVLW      49
	MOVWF      _msg+11
;tasks_timer.c,239 :: 		msg[12] = 48;
	MOVLW      48
	MOVWF      _msg+12
;tasks_timer.c,240 :: 		write_ds1307(0,0x80); // Stop Oscillator (0)
	CLRF       FARG_write_ds1307_address+0
	MOVLW      128
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,241 :: 		write_ds1307(2,0x10); // write hours
	MOVLW      2
	MOVWF      FARG_write_ds1307_address+0
	MOVLW      16
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,242 :: 		write_ds1307(0,0x00); // Start Oscillator (1)
	CLRF       FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,243 :: 		} else if ((msg[11] == 49) && (msg[12] == 57)){  // 19 --> 20
	GOTO       L_incHour41
L_incHour40:
	MOVF       _msg+11, 0
	XORLW      49
	BTFSS      STATUS+0, 2
	GOTO       L_incHour44
	MOVF       _msg+12, 0
	XORLW      57
	BTFSS      STATUS+0, 2
	GOTO       L_incHour44
L__incHour371:
;tasks_timer.c,244 :: 		msg[11] = 50;
	MOVLW      50
	MOVWF      _msg+11
;tasks_timer.c,245 :: 		msg[12] = 48;
	MOVLW      48
	MOVWF      _msg+12
;tasks_timer.c,246 :: 		write_ds1307(0,0x80); // Stop Oscillator (0)
	CLRF       FARG_write_ds1307_address+0
	MOVLW      128
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,247 :: 		write_ds1307(2,0x20); // write hours
	MOVLW      2
	MOVWF      FARG_write_ds1307_address+0
	MOVLW      32
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,248 :: 		write_ds1307(0,0x00); // Start Oscillator (1)
	CLRF       FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,249 :: 		} else {
	GOTO       L_incHour45
L_incHour44:
;tasks_timer.c,250 :: 		msg[12]++;
	INCF       _msg+12, 1
;tasks_timer.c,251 :: 		incData = read_ds1307(2);                     // read hour
	MOVLW      2
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      _incData+0
;tasks_timer.c,252 :: 		incData++;
	INCF       R0+0, 0
	MOVWF      _incData+0
;tasks_timer.c,253 :: 		write_ds1307(0,0x80); // Stop Oscillator (0)
	CLRF       FARG_write_ds1307_address+0
	MOVLW      128
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,254 :: 		write_ds1307(2,incData); // write hours
	MOVLW      2
	MOVWF      FARG_write_ds1307_address+0
	MOVF       _incData+0, 0
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,255 :: 		write_ds1307(0,0x00); // Start Oscillator (1)
	CLRF       FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,256 :: 		}
L_incHour45:
L_incHour41:
L_incHour37:
;tasks_timer.c,257 :: 		read_time();
	CALL       _read_time+0
;tasks_timer.c,258 :: 		delay_ms(25);
	MOVLW      33
	MOVWF      R12+0
	MOVLW      118
	MOVWF      R13+0
L_incHour46:
	DECFSZ     R13+0, 1
	GOTO       L_incHour46
	DECFSZ     R12+0, 1
	GOTO       L_incHour46
	NOP
;tasks_timer.c,259 :: 		}
L_end_incHour:
	RETURN
; end of _incHour

_incMin:

;tasks_timer.c,261 :: 		void incMin(){
;tasks_timer.c,262 :: 		read_time();
	CALL       _read_time+0
;tasks_timer.c,263 :: 		if ((msg[14] == 53) && (msg[15] == 57)){          // 59 --> 00
	MOVF       _msg+14, 0
	XORLW      53
	BTFSS      STATUS+0, 2
	GOTO       L_incMin49
	MOVF       _msg+15, 0
	XORLW      57
	BTFSS      STATUS+0, 2
	GOTO       L_incMin49
L__incMin379:
;tasks_timer.c,264 :: 		msg[14] = 48;
	MOVLW      48
	MOVWF      _msg+14
;tasks_timer.c,265 :: 		msg[15] = 48;
	MOVLW      48
	MOVWF      _msg+15
;tasks_timer.c,266 :: 		write_ds1307(0,0x80); // Stop Oscillator (0)
	CLRF       FARG_write_ds1307_address+0
	MOVLW      128
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,267 :: 		write_ds1307(1,0x00); // write minutes
	MOVLW      1
	MOVWF      FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,268 :: 		write_ds1307(0,0x00); // Start Oscillator (1)
	CLRF       FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,269 :: 		} else if ((msg[14] == 48) && (msg[15] == 57)){   // 09 --> 10
	GOTO       L_incMin50
L_incMin49:
	MOVF       _msg+14, 0
	XORLW      48
	BTFSS      STATUS+0, 2
	GOTO       L_incMin53
	MOVF       _msg+15, 0
	XORLW      57
	BTFSS      STATUS+0, 2
	GOTO       L_incMin53
L__incMin378:
;tasks_timer.c,270 :: 		msg[14] = 49;
	MOVLW      49
	MOVWF      _msg+14
;tasks_timer.c,271 :: 		msg[15] = 48;
	MOVLW      48
	MOVWF      _msg+15
;tasks_timer.c,272 :: 		write_ds1307(0,0x80); // Stop Oscillator (0)
	CLRF       FARG_write_ds1307_address+0
	MOVLW      128
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,273 :: 		write_ds1307(1,0x10); // write minutes
	MOVLW      1
	MOVWF      FARG_write_ds1307_address+0
	MOVLW      16
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,274 :: 		write_ds1307(0,0x00); // Start Oscillator (1)
	CLRF       FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,275 :: 		} else if ((msg[14] == 49) && (msg[15] == 57)){   // 19 --> 20
	GOTO       L_incMin54
L_incMin53:
	MOVF       _msg+14, 0
	XORLW      49
	BTFSS      STATUS+0, 2
	GOTO       L_incMin57
	MOVF       _msg+15, 0
	XORLW      57
	BTFSS      STATUS+0, 2
	GOTO       L_incMin57
L__incMin377:
;tasks_timer.c,276 :: 		msg[14] = 50;
	MOVLW      50
	MOVWF      _msg+14
;tasks_timer.c,277 :: 		msg[15] = 48;
	MOVLW      48
	MOVWF      _msg+15
;tasks_timer.c,278 :: 		write_ds1307(0,0x80); // Stop Oscillator (0)
	CLRF       FARG_write_ds1307_address+0
	MOVLW      128
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,279 :: 		write_ds1307(1,0x20); // write minutes
	MOVLW      1
	MOVWF      FARG_write_ds1307_address+0
	MOVLW      32
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,280 :: 		write_ds1307(0,0x00); // Start Oscillator (1)
	CLRF       FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,281 :: 		} else if ((msg[14] == 50) && (msg[15] == 57)){   // 29 --> 30
	GOTO       L_incMin58
L_incMin57:
	MOVF       _msg+14, 0
	XORLW      50
	BTFSS      STATUS+0, 2
	GOTO       L_incMin61
	MOVF       _msg+15, 0
	XORLW      57
	BTFSS      STATUS+0, 2
	GOTO       L_incMin61
L__incMin376:
;tasks_timer.c,282 :: 		msg[14] = 51;
	MOVLW      51
	MOVWF      _msg+14
;tasks_timer.c,283 :: 		msg[15] = 48;
	MOVLW      48
	MOVWF      _msg+15
;tasks_timer.c,284 :: 		write_ds1307(0,0x80); // Stop Oscillator (0)
	CLRF       FARG_write_ds1307_address+0
	MOVLW      128
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,285 :: 		write_ds1307(1,0x30); // write minutes
	MOVLW      1
	MOVWF      FARG_write_ds1307_address+0
	MOVLW      48
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,286 :: 		write_ds1307(0,0x00); // Start Oscillator (1)
	CLRF       FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,287 :: 		} else if ((msg[14] == 51) && (msg[15] == 57)){   // 39 --> 40
	GOTO       L_incMin62
L_incMin61:
	MOVF       _msg+14, 0
	XORLW      51
	BTFSS      STATUS+0, 2
	GOTO       L_incMin65
	MOVF       _msg+15, 0
	XORLW      57
	BTFSS      STATUS+0, 2
	GOTO       L_incMin65
L__incMin375:
;tasks_timer.c,288 :: 		msg[14] = 52;
	MOVLW      52
	MOVWF      _msg+14
;tasks_timer.c,289 :: 		msg[15] = 48;
	MOVLW      48
	MOVWF      _msg+15
;tasks_timer.c,290 :: 		write_ds1307(0,0x80); // Stop Oscillator (0)
	CLRF       FARG_write_ds1307_address+0
	MOVLW      128
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,291 :: 		write_ds1307(1,0x40); // write minutes
	MOVLW      1
	MOVWF      FARG_write_ds1307_address+0
	MOVLW      64
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,292 :: 		write_ds1307(0,0x00); // Start Oscillator (1)
	CLRF       FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,293 :: 		} else if ((msg[14] == 52) && (msg[15] == 57)){   // 49 --> 50
	GOTO       L_incMin66
L_incMin65:
	MOVF       _msg+14, 0
	XORLW      52
	BTFSS      STATUS+0, 2
	GOTO       L_incMin69
	MOVF       _msg+15, 0
	XORLW      57
	BTFSS      STATUS+0, 2
	GOTO       L_incMin69
L__incMin374:
;tasks_timer.c,294 :: 		msg[14] = 53;
	MOVLW      53
	MOVWF      _msg+14
;tasks_timer.c,295 :: 		msg[15] = 48;
	MOVLW      48
	MOVWF      _msg+15
;tasks_timer.c,296 :: 		write_ds1307(0,0x80); // Stop Oscillator (0)
	CLRF       FARG_write_ds1307_address+0
	MOVLW      128
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,297 :: 		write_ds1307(1,0x50); // write minutes
	MOVLW      1
	MOVWF      FARG_write_ds1307_address+0
	MOVLW      80
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,298 :: 		write_ds1307(0,0x00); // Start Oscillator (1)
	CLRF       FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,299 :: 		} else {
	GOTO       L_incMin70
L_incMin69:
;tasks_timer.c,300 :: 		msg[15]++;
	INCF       _msg+15, 1
;tasks_timer.c,301 :: 		incData = read_ds1307(1);                      // read hour
	MOVLW      1
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      _incData+0
;tasks_timer.c,302 :: 		incData++;
	INCF       R0+0, 0
	MOVWF      _incData+0
;tasks_timer.c,303 :: 		write_ds1307(0,0x80); // Stop Oscillator (0)
	CLRF       FARG_write_ds1307_address+0
	MOVLW      128
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,304 :: 		write_ds1307(1,incData); // write minute
	MOVLW      1
	MOVWF      FARG_write_ds1307_address+0
	MOVF       _incData+0, 0
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,305 :: 		write_ds1307(0,0x00); // Start Oscillator (1)
	CLRF       FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,306 :: 		}
L_incMin70:
L_incMin66:
L_incMin62:
L_incMin58:
L_incMin54:
L_incMin50:
;tasks_timer.c,307 :: 		read_time();
	CALL       _read_time+0
;tasks_timer.c,308 :: 		delay_ms(25);
	MOVLW      33
	MOVWF      R12+0
	MOVLW      118
	MOVWF      R13+0
L_incMin71:
	DECFSZ     R13+0, 1
	GOTO       L_incMin71
	DECFSZ     R12+0, 1
	GOTO       L_incMin71
	NOP
;tasks_timer.c,309 :: 		}
L_end_incMin:
	RETURN
; end of _incMin

_incDate:

;tasks_timer.c,311 :: 		void incDate(){
;tasks_timer.c,312 :: 		read_time();
	CALL       _read_time+0
;tasks_timer.c,313 :: 		if ((msg[0] == 51) && (msg[1] == 49)){            // 31 --> 01
	MOVF       _msg+0, 0
	XORLW      51
	BTFSS      STATUS+0, 2
	GOTO       L_incDate74
	MOVF       _msg+1, 0
	XORLW      49
	BTFSS      STATUS+0, 2
	GOTO       L_incDate74
L__incDate383:
;tasks_timer.c,314 :: 		msg[0] = 48;
	MOVLW      48
	MOVWF      _msg+0
;tasks_timer.c,315 :: 		msg[1] = 49;
	MOVLW      49
	MOVWF      _msg+1
;tasks_timer.c,316 :: 		write_ds1307(0,0x80); // Stop Oscillator (0)
	CLRF       FARG_write_ds1307_address+0
	MOVLW      128
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,317 :: 		write_ds1307(4,0x01); // write date
	MOVLW      4
	MOVWF      FARG_write_ds1307_address+0
	MOVLW      1
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,318 :: 		write_ds1307(0,0x00); // Start Oscillator (1)
	CLRF       FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,319 :: 		} else if ((msg[0] == 48) && (msg[1] == 57)){     // 09 --> 10
	GOTO       L_incDate75
L_incDate74:
	MOVF       _msg+0, 0
	XORLW      48
	BTFSS      STATUS+0, 2
	GOTO       L_incDate78
	MOVF       _msg+1, 0
	XORLW      57
	BTFSS      STATUS+0, 2
	GOTO       L_incDate78
L__incDate382:
;tasks_timer.c,320 :: 		msg[0] = 49;
	MOVLW      49
	MOVWF      _msg+0
;tasks_timer.c,321 :: 		msg[1] = 48;
	MOVLW      48
	MOVWF      _msg+1
;tasks_timer.c,322 :: 		write_ds1307(0,0x80); // Stop Oscillator (0)
	CLRF       FARG_write_ds1307_address+0
	MOVLW      128
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,323 :: 		write_ds1307(4,0x10); // write date
	MOVLW      4
	MOVWF      FARG_write_ds1307_address+0
	MOVLW      16
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,324 :: 		write_ds1307(0,0x00); // Start Oscillator (1)
	CLRF       FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,325 :: 		} else if ((msg[0] == 49) && (msg[1] == 57)){     // 19 --> 20
	GOTO       L_incDate79
L_incDate78:
	MOVF       _msg+0, 0
	XORLW      49
	BTFSS      STATUS+0, 2
	GOTO       L_incDate82
	MOVF       _msg+1, 0
	XORLW      57
	BTFSS      STATUS+0, 2
	GOTO       L_incDate82
L__incDate381:
;tasks_timer.c,326 :: 		msg[0] = 50;
	MOVLW      50
	MOVWF      _msg+0
;tasks_timer.c,327 :: 		msg[1] = 48;
	MOVLW      48
	MOVWF      _msg+1
;tasks_timer.c,328 :: 		write_ds1307(0,0x80); // Stop Oscillator (0)
	CLRF       FARG_write_ds1307_address+0
	MOVLW      128
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,329 :: 		write_ds1307(4,0x20); // write date
	MOVLW      4
	MOVWF      FARG_write_ds1307_address+0
	MOVLW      32
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,330 :: 		write_ds1307(0,0x00); // Start Oscillator (1)
	CLRF       FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,331 :: 		} else if ((msg[0] == 50) && (msg[1] == 57)){     // 29 --> 30
	GOTO       L_incDate83
L_incDate82:
	MOVF       _msg+0, 0
	XORLW      50
	BTFSS      STATUS+0, 2
	GOTO       L_incDate86
	MOVF       _msg+1, 0
	XORLW      57
	BTFSS      STATUS+0, 2
	GOTO       L_incDate86
L__incDate380:
;tasks_timer.c,332 :: 		msg[0] = 51;
	MOVLW      51
	MOVWF      _msg+0
;tasks_timer.c,333 :: 		msg[1] = 48;
	MOVLW      48
	MOVWF      _msg+1
;tasks_timer.c,334 :: 		write_ds1307(0,0x80); // Stop Oscillator (0)
	CLRF       FARG_write_ds1307_address+0
	MOVLW      128
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,335 :: 		write_ds1307(4,0x30); // write date
	MOVLW      4
	MOVWF      FARG_write_ds1307_address+0
	MOVLW      48
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,336 :: 		write_ds1307(0,0x00); // Start Oscillator (1)
	CLRF       FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,337 :: 		} else {
	GOTO       L_incDate87
L_incDate86:
;tasks_timer.c,338 :: 		msg[1]++;
	INCF       _msg+1, 1
;tasks_timer.c,339 :: 		incData = read_ds1307(4);                      // read hour
	MOVLW      4
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      _incData+0
;tasks_timer.c,340 :: 		incData++;
	INCF       R0+0, 0
	MOVWF      _incData+0
;tasks_timer.c,341 :: 		write_ds1307(0,0x80); // Stop Oscillator (0)
	CLRF       FARG_write_ds1307_address+0
	MOVLW      128
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,342 :: 		write_ds1307(4,incData); // write date
	MOVLW      4
	MOVWF      FARG_write_ds1307_address+0
	MOVF       _incData+0, 0
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,343 :: 		write_ds1307(0,0x00); // Start Oscillator (1)
	CLRF       FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,344 :: 		}
L_incDate87:
L_incDate83:
L_incDate79:
L_incDate75:
;tasks_timer.c,345 :: 		read_time();
	CALL       _read_time+0
;tasks_timer.c,346 :: 		delay_ms(25);
	MOVLW      33
	MOVWF      R12+0
	MOVLW      118
	MOVWF      R13+0
L_incDate88:
	DECFSZ     R13+0, 1
	GOTO       L_incDate88
	DECFSZ     R12+0, 1
	GOTO       L_incDate88
	NOP
;tasks_timer.c,347 :: 		}
L_end_incDate:
	RETURN
; end of _incDate

_incMonth:

;tasks_timer.c,349 :: 		void incMonth(){
;tasks_timer.c,350 :: 		read_time();
	CALL       _read_time+0
;tasks_timer.c,351 :: 		if ((msg[3] == 49) && (msg[4] == 50)){            // 12 --> 01
	MOVF       _msg+3, 0
	XORLW      49
	BTFSS      STATUS+0, 2
	GOTO       L_incMonth91
	MOVF       _msg+4, 0
	XORLW      50
	BTFSS      STATUS+0, 2
	GOTO       L_incMonth91
L__incMonth385:
;tasks_timer.c,352 :: 		msg[3] = 48;
	MOVLW      48
	MOVWF      _msg+3
;tasks_timer.c,353 :: 		msg[4] = 49;
	MOVLW      49
	MOVWF      _msg+4
;tasks_timer.c,354 :: 		write_ds1307(0,0x80); // Stop Oscillator (0)
	CLRF       FARG_write_ds1307_address+0
	MOVLW      128
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,355 :: 		write_ds1307(5,0x01); // write month
	MOVLW      5
	MOVWF      FARG_write_ds1307_address+0
	MOVLW      1
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,356 :: 		write_ds1307(0,0x00); // Start Oscillator (1)
	CLRF       FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,357 :: 		} else if ((msg[3] == 48) && (msg[4] == 57)){     // 09 --> 10
	GOTO       L_incMonth92
L_incMonth91:
	MOVF       _msg+3, 0
	XORLW      48
	BTFSS      STATUS+0, 2
	GOTO       L_incMonth95
	MOVF       _msg+4, 0
	XORLW      57
	BTFSS      STATUS+0, 2
	GOTO       L_incMonth95
L__incMonth384:
;tasks_timer.c,358 :: 		msg[3] = 49;
	MOVLW      49
	MOVWF      _msg+3
;tasks_timer.c,359 :: 		msg[4] = 48;
	MOVLW      48
	MOVWF      _msg+4
;tasks_timer.c,360 :: 		write_ds1307(0,0x80); // Stop Oscillator (0)
	CLRF       FARG_write_ds1307_address+0
	MOVLW      128
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,361 :: 		write_ds1307(5,0x10); // write month
	MOVLW      5
	MOVWF      FARG_write_ds1307_address+0
	MOVLW      16
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,362 :: 		write_ds1307(0,0x00); // Start Oscillator (1)
	CLRF       FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,363 :: 		} else {
	GOTO       L_incMonth96
L_incMonth95:
;tasks_timer.c,364 :: 		msg[4]++;
	INCF       _msg+4, 1
;tasks_timer.c,365 :: 		incData = read_ds1307(5);                      // read hour
	MOVLW      5
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      _incData+0
;tasks_timer.c,366 :: 		incData++;
	INCF       R0+0, 0
	MOVWF      _incData+0
;tasks_timer.c,367 :: 		write_ds1307(0,0x80); // Stop Oscillator (0)
	CLRF       FARG_write_ds1307_address+0
	MOVLW      128
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,368 :: 		write_ds1307(5,incData); // write month
	MOVLW      5
	MOVWF      FARG_write_ds1307_address+0
	MOVF       _incData+0, 0
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,369 :: 		write_ds1307(0,0x00); // Start Oscillator (1)
	CLRF       FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,370 :: 		}
L_incMonth96:
L_incMonth92:
;tasks_timer.c,371 :: 		read_time();
	CALL       _read_time+0
;tasks_timer.c,372 :: 		delay_ms(25);
	MOVLW      33
	MOVWF      R12+0
	MOVLW      118
	MOVWF      R13+0
L_incMonth97:
	DECFSZ     R13+0, 1
	GOTO       L_incMonth97
	DECFSZ     R12+0, 1
	GOTO       L_incMonth97
	NOP
;tasks_timer.c,373 :: 		}
L_end_incMonth:
	RETURN
; end of _incMonth

_incYear:

;tasks_timer.c,375 :: 		void incYear(){
;tasks_timer.c,376 :: 		read_time();
	CALL       _read_time+0
;tasks_timer.c,377 :: 		if ((msg[6] == 49) && (msg[7] == 55)){            // 17 --> 14
	MOVF       _msg+6, 0
	XORLW      49
	BTFSS      STATUS+0, 2
	GOTO       L_incYear100
	MOVF       _msg+7, 0
	XORLW      55
	BTFSS      STATUS+0, 2
	GOTO       L_incYear100
L__incYear386:
;tasks_timer.c,378 :: 		msg[6] = 49;
	MOVLW      49
	MOVWF      _msg+6
;tasks_timer.c,379 :: 		msg[7] = 52;
	MOVLW      52
	MOVWF      _msg+7
;tasks_timer.c,380 :: 		write_ds1307(0,0x80); // Stop Oscillator (0)
	CLRF       FARG_write_ds1307_address+0
	MOVLW      128
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,381 :: 		write_ds1307(6,0x14); // write year
	MOVLW      6
	MOVWF      FARG_write_ds1307_address+0
	MOVLW      20
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,382 :: 		write_ds1307(0,0x00); // Start Oscillator (1)
	CLRF       FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,383 :: 		} else {
	GOTO       L_incYear101
L_incYear100:
;tasks_timer.c,384 :: 		msg[7]++;
	INCF       _msg+7, 1
;tasks_timer.c,385 :: 		incData = read_ds1307(6);                      // read hour
	MOVLW      6
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      _incData+0
;tasks_timer.c,386 :: 		incData++;
	INCF       R0+0, 0
	MOVWF      _incData+0
;tasks_timer.c,387 :: 		write_ds1307(0,0x80); // Stop Oscillator (0)
	CLRF       FARG_write_ds1307_address+0
	MOVLW      128
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,388 :: 		write_ds1307(6,incData); // write year
	MOVLW      6
	MOVWF      FARG_write_ds1307_address+0
	MOVF       _incData+0, 0
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,389 :: 		write_ds1307(0,0x00); // Start Oscillator (1)
	CLRF       FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,390 :: 		}
L_incYear101:
;tasks_timer.c,391 :: 		read_time();
	CALL       _read_time+0
;tasks_timer.c,392 :: 		delay_ms(25);
	MOVLW      33
	MOVWF      R12+0
	MOVLW      118
	MOVWF      R13+0
L_incYear102:
	DECFSZ     R13+0, 1
	GOTO       L_incYear102
	DECFSZ     R12+0, 1
	GOTO       L_incYear102
	NOP
;tasks_timer.c,393 :: 		}                          // ------------------------------------------------
L_end_incYear:
	RETURN
; end of _incYear

_dispAlarmTime:

;tasks_timer.c,395 :: 		void dispAlarmTime(){      // ------------ Show Alarm time on LCD ------------
;tasks_timer.c,396 :: 		msg[0] = ((alarmHour/10)%10)+48;
	MOVLW      10
	MOVWF      R4+0
	MOVF       _alarmHour+0, 0
	MOVWF      R0+0
	CALL       _Div_8x8_U+0
	MOVLW      10
	MOVWF      R4+0
	CALL       _Div_8x8_U+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      _msg+0
;tasks_timer.c,397 :: 		msg[1] = (alarmHour%10)+48;
	MOVLW      10
	MOVWF      R4+0
	MOVF       _alarmHour+0, 0
	MOVWF      R0+0
	CALL       _Div_8x8_U+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      _msg+1
;tasks_timer.c,398 :: 		msg[2] = ':';
	MOVLW      58
	MOVWF      _msg+2
;tasks_timer.c,399 :: 		msg[3] = ((alarmMinute/10)%10)+48;
	MOVLW      10
	MOVWF      R4+0
	MOVF       _alarmMinute+0, 0
	MOVWF      R0+0
	CALL       _Div_8x8_U+0
	MOVLW      10
	MOVWF      R4+0
	CALL       _Div_8x8_U+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      _msg+3
;tasks_timer.c,400 :: 		msg[4] = (alarmMinute%10)+48;
	MOVLW      10
	MOVWF      R4+0
	MOVF       _alarmMinute+0, 0
	MOVWF      R0+0
	CALL       _Div_8x8_U+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      _msg+4
;tasks_timer.c,401 :: 		msg[5] = '\0';
	CLRF       _msg+5
;tasks_timer.c,402 :: 		Lcd_Out(1,12,msg);    // ------------------------------------------------
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      12
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _msg+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;tasks_timer.c,403 :: 		}
L_end_dispAlarmTime:
	RETURN
; end of _dispAlarmTime

_incAlarmHour:

;tasks_timer.c,405 :: 		void incAlarmHour(){       // --------- Alarm time setting functions ---------
;tasks_timer.c,406 :: 		if (alarmHour == 23){
	MOVF       _alarmHour+0, 0
	XORLW      23
	BTFSS      STATUS+0, 2
	GOTO       L_incAlarmHour103
;tasks_timer.c,407 :: 		alarmHour = 0;
	CLRF       _alarmHour+0
;tasks_timer.c,408 :: 		} else {
	GOTO       L_incAlarmHour104
L_incAlarmHour103:
;tasks_timer.c,409 :: 		alarmHour++;
	INCF       _alarmHour+0, 1
;tasks_timer.c,410 :: 		}
L_incAlarmHour104:
;tasks_timer.c,411 :: 		dispAlarmTime();
	CALL       _dispAlarmTime+0
;tasks_timer.c,412 :: 		delay_ms(25);
	MOVLW      33
	MOVWF      R12+0
	MOVLW      118
	MOVWF      R13+0
L_incAlarmHour105:
	DECFSZ     R13+0, 1
	GOTO       L_incAlarmHour105
	DECFSZ     R12+0, 1
	GOTO       L_incAlarmHour105
	NOP
;tasks_timer.c,413 :: 		}
L_end_incAlarmHour:
	RETURN
; end of _incAlarmHour

_incAlarmMin:

;tasks_timer.c,415 :: 		void incAlarmMin(){
;tasks_timer.c,416 :: 		if (alarmMinute == 59){
	MOVF       _alarmMinute+0, 0
	XORLW      59
	BTFSS      STATUS+0, 2
	GOTO       L_incAlarmMin106
;tasks_timer.c,417 :: 		alarmMinute = 0;
	CLRF       _alarmMinute+0
;tasks_timer.c,418 :: 		} else {
	GOTO       L_incAlarmMin107
L_incAlarmMin106:
;tasks_timer.c,419 :: 		alarmMinute++;
	INCF       _alarmMinute+0, 1
;tasks_timer.c,420 :: 		}
L_incAlarmMin107:
;tasks_timer.c,421 :: 		dispAlarmTime();
	CALL       _dispAlarmTime+0
;tasks_timer.c,422 :: 		delay_ms(25);
	MOVLW      33
	MOVWF      R12+0
	MOVLW      118
	MOVWF      R13+0
L_incAlarmMin108:
	DECFSZ     R13+0, 1
	GOTO       L_incAlarmMin108
	DECFSZ     R12+0, 1
	GOTO       L_incAlarmMin108
	NOP
;tasks_timer.c,423 :: 		}                          // ------------------------------------------------
L_end_incAlarmMin:
	RETURN
; end of _incAlarmMin

_checkAlarm:

;tasks_timer.c,425 :: 		void checkAlarm(){         // ---------- Checking if Alarm time --------------
;tasks_timer.c,426 :: 		if(genFlag.f4){
	BTFSS      _genFlag+0, 4
	GOTO       L_checkAlarm109
;tasks_timer.c,427 :: 		if (((((alarmMinute/10)%10)+48) == BCD2UpperCh(read_ds1307(1))) &&
	MOVLW      10
	MOVWF      R4+0
	MOVF       _alarmMinute+0, 0
	MOVWF      R0+0
	CALL       _Div_8x8_U+0
	MOVLW      10
	MOVWF      R4+0
	CALL       _Div_8x8_U+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      FLOC__checkAlarm+0
	CLRF       FLOC__checkAlarm+1
	BTFSC      STATUS+0, 0
	INCF       FLOC__checkAlarm+1, 1
	MOVLW      1
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      FARG_BCD2UpperCh_bcd+0
	CALL       _BCD2UpperCh+0
;tasks_timer.c,428 :: 		(((alarmMinute%10)+48) == BCD2LowerCh(read_ds1307(1)))){
	MOVLW      0
	XORWF      FLOC__checkAlarm+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__checkAlarm445
	MOVF       R0+0, 0
	XORWF      FLOC__checkAlarm+0, 0
L__checkAlarm445:
	BTFSS      STATUS+0, 2
	GOTO       L_checkAlarm112
	MOVLW      10
	MOVWF      R4+0
	MOVF       _alarmMinute+0, 0
	MOVWF      R0+0
	CALL       _Div_8x8_U+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      FLOC__checkAlarm+0
	CLRF       FLOC__checkAlarm+1
	BTFSC      STATUS+0, 0
	INCF       FLOC__checkAlarm+1, 1
	MOVLW      1
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      FARG_BCD2LowerCh_bcd+0
	CALL       _BCD2LowerCh+0
	MOVLW      0
	XORWF      FLOC__checkAlarm+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__checkAlarm446
	MOVF       R0+0, 0
	XORWF      FLOC__checkAlarm+0, 0
L__checkAlarm446:
	BTFSS      STATUS+0, 2
	GOTO       L_checkAlarm112
L__checkAlarm388:
;tasks_timer.c,429 :: 		if (((((alarmHour/10)%10)+48) == BCD2UpperCh(read_ds1307(2))) &&
	MOVLW      10
	MOVWF      R4+0
	MOVF       _alarmHour+0, 0
	MOVWF      R0+0
	CALL       _Div_8x8_U+0
	MOVLW      10
	MOVWF      R4+0
	CALL       _Div_8x8_U+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      FLOC__checkAlarm+0
	CLRF       FLOC__checkAlarm+1
	BTFSC      STATUS+0, 0
	INCF       FLOC__checkAlarm+1, 1
	MOVLW      2
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      FARG_BCD2UpperCh_bcd+0
	CALL       _BCD2UpperCh+0
;tasks_timer.c,430 :: 		(((alarmHour%10)+48) == BCD2LowerCh(read_ds1307(2)))){
	MOVLW      0
	XORWF      FLOC__checkAlarm+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__checkAlarm447
	MOVF       R0+0, 0
	XORWF      FLOC__checkAlarm+0, 0
L__checkAlarm447:
	BTFSS      STATUS+0, 2
	GOTO       L_checkAlarm115
	MOVLW      10
	MOVWF      R4+0
	MOVF       _alarmHour+0, 0
	MOVWF      R0+0
	CALL       _Div_8x8_U+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      FLOC__checkAlarm+0
	CLRF       FLOC__checkAlarm+1
	BTFSC      STATUS+0, 0
	INCF       FLOC__checkAlarm+1, 1
	MOVLW      2
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      FARG_BCD2LowerCh_bcd+0
	CALL       _BCD2LowerCh+0
	MOVLW      0
	XORWF      FLOC__checkAlarm+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__checkAlarm448
	MOVF       R0+0, 0
	XORWF      FLOC__checkAlarm+0, 0
L__checkAlarm448:
	BTFSS      STATUS+0, 2
	GOTO       L_checkAlarm115
L__checkAlarm387:
;tasks_timer.c,431 :: 		genFlag.f5 = 1;
	BSF        _genFlag+0, 5
;tasks_timer.c,432 :: 		if (incData%2){
	BTFSS      _incData+0, 0
	GOTO       L_checkAlarm116
;tasks_timer.c,433 :: 		Sound_Play(5000,70);  //!!!!!!!!!!!! NA TO KANW ME TIMER1 (INT -> sound)
	MOVLW      136
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      19
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      70
	MOVWF      FARG_Sound_Play_duration_ms+0
	MOVLW      0
	MOVWF      FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,434 :: 		Sound_Play(6000,30);
	MOVLW      112
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      23
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      30
	MOVWF      FARG_Sound_Play_duration_ms+0
	MOVLW      0
	MOVWF      FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,435 :: 		Sound_Play(0,100);
	CLRF       FARG_Sound_Play_freq_in_hz+0
	CLRF       FARG_Sound_Play_freq_in_hz+1
	MOVLW      100
	MOVWF      FARG_Sound_Play_duration_ms+0
	MOVLW      0
	MOVWF      FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,436 :: 		}
L_checkAlarm116:
;tasks_timer.c,437 :: 		}
L_checkAlarm115:
;tasks_timer.c,438 :: 		} else {
	GOTO       L_checkAlarm117
L_checkAlarm112:
;tasks_timer.c,439 :: 		genFlag.f5 = 0;
	BCF        _genFlag+0, 5
;tasks_timer.c,440 :: 		}
L_checkAlarm117:
;tasks_timer.c,441 :: 		}
L_checkAlarm109:
;tasks_timer.c,442 :: 		}                          // ------------------------------------------------
L_end_checkAlarm:
	RETURN
; end of _checkAlarm

_dispCountDTime:

;tasks_timer.c,444 :: 		void dispCountDTime(){      // ---------- Show Countdown time on LCD -----------
;tasks_timer.c,445 :: 		Lcd_Out(2,1,CopyConst2Ram(msg,blank11));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _blank11+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_blank11+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,446 :: 		msg[0] = (((countDownTime/60)/10)%10)+48;
	MOVLW      60
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       _countDownTime+0, 0
	MOVWF      R0+0
	MOVF       _countDownTime+1, 0
	MOVWF      R0+1
	CALL       _Div_16x16_U+0
	MOVF       R0+0, 0
	MOVWF      FLOC__dispCountDTime+0
	MOVF       R0+1, 0
	MOVWF      FLOC__dispCountDTime+1
	MOVLW      10
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       FLOC__dispCountDTime+0, 0
	MOVWF      R0+0
	MOVF       FLOC__dispCountDTime+1, 0
	MOVWF      R0+1
	CALL       _Div_16x16_U+0
	MOVLW      10
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Div_16x16_U+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      _msg+0
;tasks_timer.c,447 :: 		msg[1] = ((countDownTime/60)%10)+48;
	MOVLW      10
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       FLOC__dispCountDTime+0, 0
	MOVWF      R0+0
	MOVF       FLOC__dispCountDTime+1, 0
	MOVWF      R0+1
	CALL       _Div_16x16_U+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      _msg+1
;tasks_timer.c,448 :: 		msg[2] = ':';
	MOVLW      58
	MOVWF      _msg+2
;tasks_timer.c,449 :: 		msg[3] = ((countDownTime%60)/10)+48;
	MOVLW      60
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       _countDownTime+0, 0
	MOVWF      R0+0
	MOVF       _countDownTime+1, 0
	MOVWF      R0+1
	CALL       _Div_16x16_U+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	MOVF       R0+0, 0
	MOVWF      FLOC__dispCountDTime+0
	MOVF       R0+1, 0
	MOVWF      FLOC__dispCountDTime+1
	MOVLW      10
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       FLOC__dispCountDTime+0, 0
	MOVWF      R0+0
	MOVF       FLOC__dispCountDTime+1, 0
	MOVWF      R0+1
	CALL       _Div_16x16_U+0
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      _msg+3
;tasks_timer.c,450 :: 		msg[4] = ((countDownTime%60)%10)+48;
	MOVLW      10
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       FLOC__dispCountDTime+0, 0
	MOVWF      R0+0
	MOVF       FLOC__dispCountDTime+1, 0
	MOVWF      R0+1
	CALL       _Div_16x16_U+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      _msg+4
;tasks_timer.c,451 :: 		msg[5] = '\0';
	CLRF       _msg+5
;tasks_timer.c,452 :: 		Lcd_Out(2,12,msg);    // ------------------------------------------------
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      12
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _msg+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;tasks_timer.c,453 :: 		}
L_end_dispCountDTime:
	RETURN
; end of _dispCountDTime

_incCountDmin:

;tasks_timer.c,455 :: 		void incCountDmin(){       // ------- Countdown time setting functions --------
;tasks_timer.c,456 :: 		countDownTime+=60;
	MOVLW      60
	ADDWF      _countDownTime+0, 0
	MOVWF      R1+0
	MOVF       _countDownTime+1, 0
	BTFSC      STATUS+0, 0
	ADDLW      1
	MOVWF      R1+1
	MOVF       R1+0, 0
	MOVWF      _countDownTime+0
	MOVF       R1+1, 0
	MOVWF      _countDownTime+1
;tasks_timer.c,457 :: 		if(countDownTime > 3599){
	MOVF       R1+1, 0
	SUBLW      14
	BTFSS      STATUS+0, 2
	GOTO       L__incCountDmin451
	MOVF       R1+0, 0
	SUBLW      15
L__incCountDmin451:
	BTFSC      STATUS+0, 0
	GOTO       L_incCountDmin118
;tasks_timer.c,458 :: 		countDownTime = 1;
	MOVLW      1
	MOVWF      _countDownTime+0
	MOVLW      0
	MOVWF      _countDownTime+1
;tasks_timer.c,459 :: 		}
L_incCountDmin118:
;tasks_timer.c,460 :: 		dispCountDTime();
	CALL       _dispCountDTime+0
;tasks_timer.c,461 :: 		delay_ms(25);
	MOVLW      33
	MOVWF      R12+0
	MOVLW      118
	MOVWF      R13+0
L_incCountDmin119:
	DECFSZ     R13+0, 1
	GOTO       L_incCountDmin119
	DECFSZ     R12+0, 1
	GOTO       L_incCountDmin119
	NOP
;tasks_timer.c,462 :: 		}
L_end_incCountDmin:
	RETURN
; end of _incCountDmin

_incCountDsec:

;tasks_timer.c,464 :: 		void incCountDsec(){
;tasks_timer.c,465 :: 		countDownTime++;
	INCF       _countDownTime+0, 1
	BTFSC      STATUS+0, 2
	INCF       _countDownTime+1, 1
;tasks_timer.c,466 :: 		if(countDownTime > 3599){
	MOVF       _countDownTime+1, 0
	SUBLW      14
	BTFSS      STATUS+0, 2
	GOTO       L__incCountDsec453
	MOVF       _countDownTime+0, 0
	SUBLW      15
L__incCountDsec453:
	BTFSC      STATUS+0, 0
	GOTO       L_incCountDsec120
;tasks_timer.c,467 :: 		countDownTime = 1;
	MOVLW      1
	MOVWF      _countDownTime+0
	MOVLW      0
	MOVWF      _countDownTime+1
;tasks_timer.c,468 :: 		}
L_incCountDsec120:
;tasks_timer.c,469 :: 		dispCountDTime();
	CALL       _dispCountDTime+0
;tasks_timer.c,470 :: 		delay_ms(25);
	MOVLW      33
	MOVWF      R12+0
	MOVLW      118
	MOVWF      R13+0
L_incCountDsec121:
	DECFSZ     R13+0, 1
	GOTO       L_incCountDsec121
	DECFSZ     R12+0, 1
	GOTO       L_incCountDsec121
	NOP
;tasks_timer.c,471 :: 		}                          // ------------------------------------------------
L_end_incCountDsec:
	RETURN
; end of _incCountDsec

_checkCountDown:

;tasks_timer.c,473 :: 		void checkCountDown(){         // ------- Checking if Countdown time ---------
;tasks_timer.c,474 :: 		if(genFlag2.f3){
	BTFSS      _genFlag2+0, 3
	GOTO       L_checkCountDown122
;tasks_timer.c,475 :: 		if (countDownTime==0){
	MOVLW      0
	XORWF      _countDownTime+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__checkCountDown455
	MOVLW      0
	XORWF      _countDownTime+0, 0
L__checkCountDown455:
	BTFSS      STATUS+0, 2
	GOTO       L_checkCountDown123
;tasks_timer.c,476 :: 		genFlag2.f4 = 1;
	BSF        _genFlag2+0, 4
;tasks_timer.c,477 :: 		if (incData%2){
	BTFSS      _incData+0, 0
	GOTO       L_checkCountDown124
;tasks_timer.c,478 :: 		Sound_Play(6500,30);      //!!!!!!!!!!!! NA TO KANW ME TIMER1 (INT -> sound)
	MOVLW      100
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      25
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      30
	MOVWF      FARG_Sound_Play_duration_ms+0
	MOVLW      0
	MOVWF      FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,479 :: 		Sound_Play(7000,70);
	MOVLW      88
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      27
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      70
	MOVWF      FARG_Sound_Play_duration_ms+0
	MOVLW      0
	MOVWF      FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,480 :: 		Sound_Play(0,100);
	CLRF       FARG_Sound_Play_freq_in_hz+0
	CLRF       FARG_Sound_Play_freq_in_hz+1
	MOVLW      100
	MOVWF      FARG_Sound_Play_duration_ms+0
	MOVLW      0
	MOVWF      FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,481 :: 		}
L_checkCountDown124:
;tasks_timer.c,482 :: 		} else {
	GOTO       L_checkCountDown125
L_checkCountDown123:
;tasks_timer.c,483 :: 		genFlag2.f4 = 0;
	BCF        _genFlag2+0, 4
;tasks_timer.c,484 :: 		}
L_checkCountDown125:
;tasks_timer.c,485 :: 		}
L_checkCountDown122:
;tasks_timer.c,486 :: 		}                          // ------------------------------------------------
L_end_checkCountDown:
	RETURN
; end of _checkCountDown

_reset_one:

;tasks_timer.c,488 :: 		void reset_one(){          // -------------- Single task reset ---------------
;tasks_timer.c,489 :: 		Lcd_Out(1,1,CopyConst2Ram(msg,resetCurrent));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _resetCurrent+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_resetCurrent+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,490 :: 		Lcd_Out(2,1,CopyConst2Ram(msg,yesNo));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _yesNo+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_yesNo+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,491 :: 		tempCount=0;
	CLRF       _tempCount+0
;tasks_timer.c,492 :: 		while(1){
L_reset_one126:
;tasks_timer.c,493 :: 		if (Button(&PORTB,1,deb_time,0)){
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      1
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_reset_one128
;tasks_timer.c,494 :: 		secCount[item] = 0;
	MOVF       _item+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	ADDLW      _secCount+0
	MOVWF      FSR
	CLRF       INDF+0
	INCF       FSR, 1
	CLRF       INDF+0
;tasks_timer.c,495 :: 		state[item] = 0;
	MOVF       _item+0, 0
	ADDLW      _state+0
	MOVWF      FSR
	CLRF       INDF+0
;tasks_timer.c,496 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,497 :: 		Lcd_Out(1,1,CopyConst2Ram(msg,itemReseted));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _itemReseted+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_itemReseted+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,498 :: 		Sound_Play(3000,100);
	MOVLW      184
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      11
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      100
	MOVWF      FARG_Sound_Play_duration_ms+0
	MOVLW      0
	MOVWF      FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,499 :: 		Delay_ms(delayShort);
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L_reset_one129:
	DECFSZ     R13+0, 1
	GOTO       L_reset_one129
	DECFSZ     R12+0, 1
	GOTO       L_reset_one129
	DECFSZ     R11+0, 1
	GOTO       L_reset_one129
	NOP
	NOP
;tasks_timer.c,500 :: 		break;
	GOTO       L_reset_one127
;tasks_timer.c,501 :: 		}
L_reset_one128:
;tasks_timer.c,502 :: 		if (Button(&PORTB,2,deb_time,0)||tempCount==10){
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      2
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__reset_one389
	MOVF       _tempCount+0, 0
	XORLW      10
	BTFSC      STATUS+0, 2
	GOTO       L__reset_one389
	GOTO       L_reset_one132
L__reset_one389:
;tasks_timer.c,503 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,504 :: 		Lcd_Out(1,5,CopyConst2Ram(msg,noReset));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _noReset+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_noReset+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      5
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,505 :: 		Sound_Play(3000,100);
	MOVLW      184
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      11
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      100
	MOVWF      FARG_Sound_Play_duration_ms+0
	MOVLW      0
	MOVWF      FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,506 :: 		Delay_ms(delayShort);
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L_reset_one133:
	DECFSZ     R13+0, 1
	GOTO       L_reset_one133
	DECFSZ     R12+0, 1
	GOTO       L_reset_one133
	DECFSZ     R11+0, 1
	GOTO       L_reset_one133
	NOP
	NOP
;tasks_timer.c,507 :: 		break;
	GOTO       L_reset_one127
;tasks_timer.c,508 :: 		}
L_reset_one132:
;tasks_timer.c,509 :: 		}
	GOTO       L_reset_one126
L_reset_one127:
;tasks_timer.c,510 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,511 :: 		}                          // ------------------------------------------------
L_end_reset_one:
	RETURN
; end of _reset_one

_reset_all:

;tasks_timer.c,513 :: 		void reset_all(){          // --------------- All tasks reset ----------------
;tasks_timer.c,514 :: 		Lcd_Out(1,1,CopyConst2Ram(msg,resetAll));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _resetAll+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_resetAll+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,515 :: 		Lcd_Out(2,1,CopyConst2Ram(msg,yesNo));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _yesNo+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_yesNo+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,516 :: 		tempCount=0;
	CLRF       _tempCount+0
;tasks_timer.c,517 :: 		i=0;
	CLRF       _i+0
;tasks_timer.c,518 :: 		while(1){
L_reset_all134:
;tasks_timer.c,519 :: 		if (Button(&PORTB,1,deb_time,0)){
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      1
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_reset_all136
;tasks_timer.c,520 :: 		for (i=0; i<10; i++){
	CLRF       _i+0
L_reset_all137:
	MOVLW      10
	SUBWF      _i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_reset_all138
;tasks_timer.c,521 :: 		secCount[i] = 0;
	MOVF       _i+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	ADDLW      _secCount+0
	MOVWF      FSR
	CLRF       INDF+0
	INCF       FSR, 1
	CLRF       INDF+0
;tasks_timer.c,522 :: 		state[i] = 0;
	MOVF       _i+0, 0
	ADDLW      _state+0
	MOVWF      FSR
	CLRF       INDF+0
;tasks_timer.c,520 :: 		for (i=0; i<10; i++){
	INCF       _i+0, 1
;tasks_timer.c,523 :: 		}
	GOTO       L_reset_all137
L_reset_all138:
;tasks_timer.c,524 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,525 :: 		Lcd_Out(1,1,CopyConst2Ram(msg,allReseted));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _allReseted+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_allReseted+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,526 :: 		Sound_Play(3000,100);
	MOVLW      184
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      11
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      100
	MOVWF      FARG_Sound_Play_duration_ms+0
	MOVLW      0
	MOVWF      FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,527 :: 		Delay_ms(delayShort);
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L_reset_all140:
	DECFSZ     R13+0, 1
	GOTO       L_reset_all140
	DECFSZ     R12+0, 1
	GOTO       L_reset_all140
	DECFSZ     R11+0, 1
	GOTO       L_reset_all140
	NOP
	NOP
;tasks_timer.c,528 :: 		break;
	GOTO       L_reset_all135
;tasks_timer.c,529 :: 		}
L_reset_all136:
;tasks_timer.c,530 :: 		if (Button(&PORTB,2,deb_time,0)||tempCount==10){
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      2
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__reset_all390
	MOVF       _tempCount+0, 0
	XORLW      10
	BTFSC      STATUS+0, 2
	GOTO       L__reset_all390
	GOTO       L_reset_all143
L__reset_all390:
;tasks_timer.c,531 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,532 :: 		Lcd_Out(1,5,CopyConst2Ram(msg,noReset));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _noReset+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_noReset+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      5
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,533 :: 		Sound_Play(3000,100);
	MOVLW      184
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      11
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      100
	MOVWF      FARG_Sound_Play_duration_ms+0
	MOVLW      0
	MOVWF      FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,534 :: 		Delay_ms(delayShort);
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L_reset_all144:
	DECFSZ     R13+0, 1
	GOTO       L_reset_all144
	DECFSZ     R12+0, 1
	GOTO       L_reset_all144
	DECFSZ     R11+0, 1
	GOTO       L_reset_all144
	NOP
	NOP
;tasks_timer.c,535 :: 		break;
	GOTO       L_reset_all135
;tasks_timer.c,536 :: 		}
L_reset_all143:
;tasks_timer.c,537 :: 		}
	GOTO       L_reset_all134
L_reset_all135:
;tasks_timer.c,538 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,539 :: 		}                          // ------------------------------------------------
L_end_reset_all:
	RETURN
; end of _reset_all

_load_all:

;tasks_timer.c,569 :: 		void load_all(){           // -------------- Loading saved data --------------
;tasks_timer.c,570 :: 		Lcd_Out(1,1,CopyConst2Ram(msg,loadSavedData));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _loadSavedData+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_loadSavedData+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,571 :: 		Lcd_Out(2,1,CopyConst2Ram(msg,yesNo));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _yesNo+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_yesNo+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,572 :: 		tempCount=0;
	CLRF       _tempCount+0
;tasks_timer.c,573 :: 		while(1){
L_load_all145:
;tasks_timer.c,574 :: 		if (Button(&PORTB,1,deb_time,0)||tempCount==10){
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      1
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__load_all391
	MOVF       _tempCount+0, 0
	XORLW      10
	BTFSC      STATUS+0, 2
	GOTO       L__load_all391
	GOTO       L_load_all149
L__load_all391:
;tasks_timer.c,575 :: 		for (i=0; i<10; i++){
	CLRF       _i+0
L_load_all150:
	MOVLW      10
	SUBWF      _i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_load_all151
;tasks_timer.c,576 :: 		state[i] = read_ds1307(8+i);
	MOVF       _i+0, 0
	ADDLW      _state+0
	MOVWF      FLOC__load_all+0
	MOVF       _i+0, 0
	ADDLW      8
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       FLOC__load_all+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;tasks_timer.c,577 :: 		loadTemp = read_ds1307(18+i);
	MOVF       _i+0, 0
	ADDLW      18
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      _loadTemp+0
	CLRF       _loadTemp+1
;tasks_timer.c,578 :: 		loadTemp = (unsigned int)loadTemp<<8;
	MOVF       _loadTemp+0, 0
	MOVWF      R2+1
	CLRF       R2+0
	MOVF       R2+0, 0
	MOVWF      _loadTemp+0
	MOVF       R2+1, 0
	MOVWF      _loadTemp+1
;tasks_timer.c,579 :: 		secCount[i] = (unsigned int)loadTemp + read_ds1307(28+i);
	MOVF       _i+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	ADDLW      _secCount+0
	MOVWF      FLOC__load_all+2
	MOVF       R2+0, 0
	MOVWF      FLOC__load_all+0
	MOVF       R2+1, 0
	MOVWF      FLOC__load_all+1
	MOVF       _i+0, 0
	ADDLW      28
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVLW      0
	MOVWF      R0+1
	MOVF       FLOC__load_all+0, 0
	ADDWF      R0+0, 1
	MOVF       FLOC__load_all+1, 0
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDWF      R0+1, 1
	MOVF       FLOC__load_all+2, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
	MOVF       R0+1, 0
	INCF       FSR, 1
	MOVWF      INDF+0
;tasks_timer.c,575 :: 		for (i=0; i<10; i++){
	INCF       _i+0, 1
;tasks_timer.c,580 :: 		}
	GOTO       L_load_all150
L_load_all151:
;tasks_timer.c,581 :: 		alarmMinute = read_ds1307(40);
	MOVLW      40
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      _alarmMinute+0
;tasks_timer.c,582 :: 		alarmHour = read_ds1307(41);
	MOVLW      41
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      _alarmHour+0
;tasks_timer.c,583 :: 		loadTemp = read_ds1307(44);
	MOVLW      44
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      _loadTemp+0
	CLRF       _loadTemp+1
;tasks_timer.c,584 :: 		loadTemp = (unsigned int)loadTemp<<8;
	MOVF       _loadTemp+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       R0+0, 0
	MOVWF      _loadTemp+0
	MOVF       R0+1, 0
	MOVWF      _loadTemp+1
;tasks_timer.c,585 :: 		countDownTime = (unsigned int)loadTemp + read_ds1307(45);
	MOVF       R0+0, 0
	MOVWF      FLOC__load_all+0
	MOVF       R0+1, 0
	MOVWF      FLOC__load_all+1
	MOVLW      45
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	ADDWF      FLOC__load_all+0, 0
	MOVWF      _countDownTime+0
	MOVF       FLOC__load_all+1, 0
	BTFSC      STATUS+0, 0
	ADDLW      1
	MOVWF      _countDownTime+1
;tasks_timer.c,586 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,587 :: 		Lcd_Out(1,1,CopyConst2Ram(msg,allDataLoaded));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _allDataLoaded+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_allDataLoaded+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,588 :: 		Sound_Play(3000,100);
	MOVLW      184
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      11
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      100
	MOVWF      FARG_Sound_Play_duration_ms+0
	MOVLW      0
	MOVWF      FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,589 :: 		Delay_ms(delayShort);
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L_load_all153:
	DECFSZ     R13+0, 1
	GOTO       L_load_all153
	DECFSZ     R12+0, 1
	GOTO       L_load_all153
	DECFSZ     R11+0, 1
	GOTO       L_load_all153
	NOP
	NOP
;tasks_timer.c,590 :: 		break;
	GOTO       L_load_all146
;tasks_timer.c,591 :: 		}
L_load_all149:
;tasks_timer.c,592 :: 		if (Button(&PORTB,2,deb_time,0)){
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      2
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_load_all154
;tasks_timer.c,593 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,594 :: 		Lcd_Out(1,1,CopyConst2Ram(msg,noDataLoaded));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _noDataLoaded+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_noDataLoaded+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,595 :: 		Sound_Play(3000,100);
	MOVLW      184
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      11
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      100
	MOVWF      FARG_Sound_Play_duration_ms+0
	MOVLW      0
	MOVWF      FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,596 :: 		Delay_ms(delayShort);
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L_load_all155:
	DECFSZ     R13+0, 1
	GOTO       L_load_all155
	DECFSZ     R12+0, 1
	GOTO       L_load_all155
	DECFSZ     R11+0, 1
	GOTO       L_load_all155
	NOP
	NOP
;tasks_timer.c,597 :: 		break;
	GOTO       L_load_all146
;tasks_timer.c,598 :: 		}
L_load_all154:
;tasks_timer.c,599 :: 		}
	GOTO       L_load_all145
L_load_all146:
;tasks_timer.c,600 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,601 :: 		}                          // ------------------------------------------------
L_end_load_all:
	RETURN
; end of _load_all

_dataSave:

;tasks_timer.c,603 :: 		void dataSave(){           // ------------ Data saving procedure -------------
;tasks_timer.c,604 :: 		for(i=0;i<10;i++){
	CLRF       _i+0
L_dataSave156:
	MOVLW      10
	SUBWF      _i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_dataSave157
;tasks_timer.c,605 :: 		write_ds1307(8+i,state[i]);                     // Saving items' state
	MOVF       _i+0, 0
	ADDLW      8
	MOVWF      FARG_write_ds1307_address+0
	MOVF       _i+0, 0
	ADDLW      _state+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,606 :: 		write_ds1307(18+i,secCount[i]>>8);              // Saving high seconds
	MOVF       _i+0, 0
	ADDLW      18
	MOVWF      FARG_write_ds1307_address+0
	MOVF       _i+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	ADDLW      _secCount+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R3+0
	INCF       FSR, 1
	MOVF       INDF+0, 0
	MOVWF      R3+1
	MOVF       R3+1, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R0+0, 0
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,607 :: 		write_ds1307(28+i,secCount[i]&255);             // Saving low seconds
	MOVF       _i+0, 0
	ADDLW      28
	MOVWF      FARG_write_ds1307_address+0
	MOVF       _i+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	ADDLW      _secCount+0
	MOVWF      FSR
	MOVLW      255
	ANDWF      INDF+0, 0
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,604 :: 		for(i=0;i<10;i++){
	INCF       _i+0, 1
;tasks_timer.c,608 :: 		}
	GOTO       L_dataSave156
L_dataSave157:
;tasks_timer.c,609 :: 		write_ds1307(38,genFlag);                           // Saving Flags
	MOVLW      38
	MOVWF      FARG_write_ds1307_address+0
	MOVF       _genFlag+0, 0
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,610 :: 		write_ds1307(39,genFlag2);                           // Saving Flags (2)
	MOVLW      39
	MOVWF      FARG_write_ds1307_address+0
	MOVF       _genFlag2+0, 0
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,611 :: 		write_ds1307(40,alarmMinute);                       // Saving alarm minute
	MOVLW      40
	MOVWF      FARG_write_ds1307_address+0
	MOVF       _alarmMinute+0, 0
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,612 :: 		write_ds1307(41,alarmHour);                         // Saving alarm hour
	MOVLW      41
	MOVWF      FARG_write_ds1307_address+0
	MOVF       _alarmHour+0, 0
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,613 :: 		write_ds1307(44,countDownTime>>8);                  // Saving countdwn high
	MOVLW      44
	MOVWF      FARG_write_ds1307_address+0
	MOVF       _countDownTime+1, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R0+0, 0
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,614 :: 		write_ds1307(45,countDownTime&255);                 // Saving countdwn low
	MOVLW      45
	MOVWF      FARG_write_ds1307_address+0
	MOVLW      255
	ANDWF      _countDownTime+0, 0
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,615 :: 		}                          // ------------------------------------------------
L_end_dataSave:
	RETURN
; end of _dataSave

_powerCut:

;tasks_timer.c,617 :: 		void powerCut(){           // ------------- Black-out procedure --------------
;tasks_timer.c,618 :: 		Lcd_Out(1,1,CopyConst2Ram(msg,powerError));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _powerError+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_powerError+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,619 :: 		Lcd_Out(2,1,CopyConst2Ram(msg,blank16));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _blank16+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_blank16+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,620 :: 		PORTA.f4 = 0;                                       // LCD Backlight OFF
	BCF        PORTA+0, 4
;tasks_timer.c,621 :: 		PORTD = 255;                                        // 7Segment OFF
	MOVLW      255
	MOVWF      PORTD+0
;tasks_timer.c,622 :: 		PORTA.f1 = 0; PORTA.f2 = 0; PORTA.f3 = 0;           // RGB OFF
	BCF        PORTA+0, 1
	BCF        PORTA+0, 2
	BCF        PORTA+0, 3
;tasks_timer.c,623 :: 		INTCON.GIE = 0;                                     // Disabling Interrupts
	BCF        INTCON+0, 7
;tasks_timer.c,624 :: 		dataSave();                                        // Data save function
	CALL       _dataSave+0
;tasks_timer.c,625 :: 		write_ds1307(42,read_ds1307(1));                   // Saving Minutes
	MOVLW      1
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      FARG_write_ds1307_w_data+0
	MOVLW      42
	MOVWF      FARG_write_ds1307_address+0
	CALL       _write_ds1307+0
;tasks_timer.c,626 :: 		write_ds1307(43,read_ds1307(2));                   // Saving Hours
	MOVLW      2
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      FARG_write_ds1307_w_data+0
	MOVLW      43
	MOVWF      FARG_write_ds1307_address+0
	CALL       _write_ds1307+0
;tasks_timer.c,627 :: 		INTCON.GIE = 1;                                     // Enabling Interrupts
	BSF        INTCON+0, 7
;tasks_timer.c,628 :: 		Lcd_Out(2,1,CopyConst2Ram(msg,allDataSaved));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _allDataSaved+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_allDataSaved+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,629 :: 		Sound_Play(6000,60);                                // Sound alarm
	MOVLW      112
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      23
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      60
	MOVWF      FARG_Sound_Play_duration_ms+0
	MOVLW      0
	MOVWF      FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,630 :: 		Delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_powerCut159:
	DECFSZ     R13+0, 1
	GOTO       L_powerCut159
	DECFSZ     R12+0, 1
	GOTO       L_powerCut159
	NOP
	NOP
;tasks_timer.c,631 :: 		Sound_Play(5000,60);
	MOVLW      136
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      19
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      60
	MOVWF      FARG_Sound_Play_duration_ms+0
	MOVLW      0
	MOVWF      FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,632 :: 		Delay_ms(60);
	MOVLW      78
	MOVWF      R12+0
	MOVLW      235
	MOVWF      R13+0
L_powerCut160:
	DECFSZ     R13+0, 1
	GOTO       L_powerCut160
	DECFSZ     R12+0, 1
	GOTO       L_powerCut160
;tasks_timer.c,633 :: 		Sound_Play(6000,60);
	MOVLW      112
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      23
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      60
	MOVWF      FARG_Sound_Play_duration_ms+0
	MOVLW      0
	MOVWF      FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,634 :: 		Delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_powerCut161:
	DECFSZ     R13+0, 1
	GOTO       L_powerCut161
	DECFSZ     R12+0, 1
	GOTO       L_powerCut161
	NOP
	NOP
;tasks_timer.c,635 :: 		Sound_Play(5000,60);
	MOVLW      136
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      19
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      60
	MOVWF      FARG_Sound_Play_duration_ms+0
	MOVLW      0
	MOVWF      FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,636 :: 		Delay_ms(60);
	MOVLW      78
	MOVWF      R12+0
	MOVLW      235
	MOVWF      R13+0
L_powerCut162:
	DECFSZ     R13+0, 1
	GOTO       L_powerCut162
	DECFSZ     R12+0, 1
	GOTO       L_powerCut162
;tasks_timer.c,637 :: 		Sound_Play(6000,60);
	MOVLW      112
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      23
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      60
	MOVWF      FARG_Sound_Play_duration_ms+0
	MOVLW      0
	MOVWF      FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,638 :: 		Delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_powerCut163:
	DECFSZ     R13+0, 1
	GOTO       L_powerCut163
	DECFSZ     R12+0, 1
	GOTO       L_powerCut163
	NOP
	NOP
;tasks_timer.c,639 :: 		Sound_Play(5000,60);
	MOVLW      136
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      19
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      60
	MOVWF      FARG_Sound_Play_duration_ms+0
	MOVLW      0
	MOVWF      FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,640 :: 		while(PORTB.f5){                                    // While low power
L_powerCut164:
	BTFSS      PORTB+0, 5
	GOTO       L_powerCut165
;tasks_timer.c,641 :: 		asm NOP
	NOP
;tasks_timer.c,642 :: 		}
	GOTO       L_powerCut164
L_powerCut165:
;tasks_timer.c,643 :: 		Delay_ms(1000);
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L_powerCut166:
	DECFSZ     R13+0, 1
	GOTO       L_powerCut166
	DECFSZ     R12+0, 1
	GOTO       L_powerCut166
	DECFSZ     R11+0, 1
	GOTO       L_powerCut166
	NOP
	NOP
;tasks_timer.c,644 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,645 :: 		PORTA.f4 = 1;                                       // LCD Backlight ON
	BSF        PORTA+0, 4
;tasks_timer.c,646 :: 		}                          // ------------------------------------------------
L_end_powerCut:
	RETURN
; end of _powerCut

_last_off:

;tasks_timer.c,648 :: 		void last_off(){           // --------- Show time of last Power Off ----------
;tasks_timer.c,649 :: 		Lcd_Out(1,1,CopyConst2Ram(msg,lastPowerOff));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _lastPowerOff+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_lastPowerOff+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,650 :: 		Lcd_Out(2,1,CopyConst2Ram(msg,blank16));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _blank16+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_blank16+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,651 :: 		msg[0] =  BCD2UpperCh(read_ds1307(43));             // Hour
	MOVLW      43
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      FARG_BCD2UpperCh_bcd+0
	CALL       _BCD2UpperCh+0
	MOVF       R0+0, 0
	MOVWF      _msg+0
;tasks_timer.c,652 :: 		msg[1] =  BCD2LowerCh(read_ds1307(43));             // Hour
	MOVLW      43
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      FARG_BCD2LowerCh_bcd+0
	CALL       _BCD2LowerCh+0
	MOVF       R0+0, 0
	MOVWF      _msg+1
;tasks_timer.c,653 :: 		msg[2] = ':';
	MOVLW      58
	MOVWF      _msg+2
;tasks_timer.c,654 :: 		msg[3] =  BCD2UpperCh(read_ds1307(42));             // Minute
	MOVLW      42
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      FARG_BCD2UpperCh_bcd+0
	CALL       _BCD2UpperCh+0
	MOVF       R0+0, 0
	MOVWF      _msg+3
;tasks_timer.c,655 :: 		msg[4] =  BCD2LowerCh(read_ds1307(42));             // Minute
	MOVLW      42
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      FARG_BCD2LowerCh_bcd+0
	CALL       _BCD2LowerCh+0
	MOVF       R0+0, 0
	MOVWF      _msg+4
;tasks_timer.c,656 :: 		msg[5] = '\0';
	CLRF       _msg+5
;tasks_timer.c,657 :: 		Lcd_Out(2,6,msg);
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      6
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _msg+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;tasks_timer.c,658 :: 		Delay_ms(delayLong);
	MOVLW      11
	MOVWF      R11+0
	MOVLW      38
	MOVWF      R12+0
	MOVLW      93
	MOVWF      R13+0
L_last_off167:
	DECFSZ     R13+0, 1
	GOTO       L_last_off167
	DECFSZ     R12+0, 1
	GOTO       L_last_off167
	DECFSZ     R11+0, 1
	GOTO       L_last_off167
	NOP
	NOP
;tasks_timer.c,659 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,660 :: 		}                          // ------------------------------------------------
L_end_last_off:
	RETURN
; end of _last_off

_set_menu:

;tasks_timer.c,662 :: 		unsigned short set_menu(){ // -------------- Time/Date set menu --------------
;tasks_timer.c,663 :: 		PORTA.f1 = 0; PORTA.f2 = 0; PORTA.f3 = 0;         // RGB OFF
	BCF        PORTA+0, 1
	BCF        PORTA+0, 2
	BCF        PORTA+0, 3
;tasks_timer.c,664 :: 		Lcd_Out(1,1,CopyConst2Ram(msg,setMenu));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _setMenu+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_setMenu+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,665 :: 		dataSave();
	CALL       _dataSave+0
;tasks_timer.c,666 :: 		Lcd_Out(2,1,CopyConst2Ram(msg,blank16));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _blank16+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_blank16+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,667 :: 		delay_ms(delayShort);
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L_set_menu168:
	DECFSZ     R13+0, 1
	GOTO       L_set_menu168
	DECFSZ     R12+0, 1
	GOTO       L_set_menu168
	DECFSZ     R11+0, 1
	GOTO       L_set_menu168
	NOP
	NOP
;tasks_timer.c,668 :: 		read_time();                            // Printing date/time on LCD
	CALL       _read_time+0
;tasks_timer.c,669 :: 		i = 1;                                  // Counter initialization
	MOVLW      1
	MOVWF      _i+0
;tasks_timer.c,670 :: 		tempCount = 0;
	CLRF       _tempCount+0
;tasks_timer.c,671 :: 		while(1){
L_set_menu169:
;tasks_timer.c,672 :: 		if(i == 1){
	MOVF       _i+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_set_menu171
;tasks_timer.c,673 :: 		Lcd_Out(2,1,CopyConst2Ram(msg,settingDate));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _settingDate+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_settingDate+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,674 :: 		tempCount = 0;
	CLRF       _tempCount+0
;tasks_timer.c,675 :: 		while(1){
L_set_menu172:
;tasks_timer.c,676 :: 		if (Button(&PORTB,1,deb_time,0)){
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      1
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_set_menu174
;tasks_timer.c,677 :: 		tempCount = 0;
	CLRF       _tempCount+0
;tasks_timer.c,678 :: 		incDate();
	CALL       _incDate+0
;tasks_timer.c,679 :: 		} else if (Button(&PORTB,2,deb_time,0)){
	GOTO       L_set_menu175
L_set_menu174:
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      2
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_set_menu176
;tasks_timer.c,680 :: 		tempCount = 0;
	CLRF       _tempCount+0
;tasks_timer.c,681 :: 		incMonth();
	CALL       _incMonth+0
;tasks_timer.c,682 :: 		} else if (Button(&PORTB,3,deb_time,0)){
	GOTO       L_set_menu177
L_set_menu176:
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      3
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_set_menu178
;tasks_timer.c,683 :: 		tempCount = 0;
	CLRF       _tempCount+0
;tasks_timer.c,684 :: 		incYear();
	CALL       _incYear+0
;tasks_timer.c,685 :: 		} else if (Button(&PORTB,4,deb_time,0)||tempCount==10){
	GOTO       L_set_menu179
L_set_menu178:
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      4
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__set_menu396
	MOVF       _tempCount+0, 0
	XORLW      10
	BTFSC      STATUS+0, 2
	GOTO       L__set_menu396
	GOTO       L_set_menu182
L__set_menu396:
;tasks_timer.c,686 :: 		i = 2;
	MOVLW      2
	MOVWF      _i+0
;tasks_timer.c,687 :: 		Delay_ms(25);
	MOVLW      33
	MOVWF      R12+0
	MOVLW      118
	MOVWF      R13+0
L_set_menu183:
	DECFSZ     R13+0, 1
	GOTO       L_set_menu183
	DECFSZ     R12+0, 1
	GOTO       L_set_menu183
	NOP
;tasks_timer.c,688 :: 		break;
	GOTO       L_set_menu173
;tasks_timer.c,689 :: 		}
L_set_menu182:
L_set_menu179:
L_set_menu177:
L_set_menu175:
;tasks_timer.c,690 :: 		}
	GOTO       L_set_menu172
L_set_menu173:
;tasks_timer.c,691 :: 		} else if(i == 2){
	GOTO       L_set_menu184
L_set_menu171:
	MOVF       _i+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_set_menu185
;tasks_timer.c,692 :: 		Lcd_Out(2,1,CopyConst2Ram(msg,settingTime));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _settingTime+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_settingTime+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,693 :: 		tempCount = 0;
	CLRF       _tempCount+0
;tasks_timer.c,694 :: 		while(1){
L_set_menu186:
;tasks_timer.c,695 :: 		if (Button(&PORTB,1,deb_time,0)){
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      1
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_set_menu188
;tasks_timer.c,696 :: 		tempCount = 0;
	CLRF       _tempCount+0
;tasks_timer.c,697 :: 		incHour();
	CALL       _incHour+0
;tasks_timer.c,698 :: 		} else if (Button(&PORTB,2,deb_time,0)){
	GOTO       L_set_menu189
L_set_menu188:
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      2
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_set_menu190
;tasks_timer.c,699 :: 		tempCount = 0;
	CLRF       _tempCount+0
;tasks_timer.c,700 :: 		incMin();
	CALL       _incMin+0
;tasks_timer.c,701 :: 		} else if (Button(&PORTB,4,deb_time,0)||tempCount==10){
	GOTO       L_set_menu191
L_set_menu190:
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      4
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__set_menu395
	MOVF       _tempCount+0, 0
	XORLW      10
	BTFSC      STATUS+0, 2
	GOTO       L__set_menu395
	GOTO       L_set_menu194
L__set_menu395:
;tasks_timer.c,702 :: 		i = 3;
	MOVLW      3
	MOVWF      _i+0
;tasks_timer.c,703 :: 		Delay_ms(25);
	MOVLW      33
	MOVWF      R12+0
	MOVLW      118
	MOVWF      R13+0
L_set_menu195:
	DECFSZ     R13+0, 1
	GOTO       L_set_menu195
	DECFSZ     R12+0, 1
	GOTO       L_set_menu195
	NOP
;tasks_timer.c,704 :: 		break;
	GOTO       L_set_menu187
;tasks_timer.c,705 :: 		}
L_set_menu194:
L_set_menu191:
L_set_menu189:
;tasks_timer.c,706 :: 		}
	GOTO       L_set_menu186
L_set_menu187:
;tasks_timer.c,707 :: 		} else if (i == 3){
	GOTO       L_set_menu196
L_set_menu185:
	MOVF       _i+0, 0
	XORLW      3
	BTFSS      STATUS+0, 2
	GOTO       L_set_menu197
;tasks_timer.c,708 :: 		Lcd_Out(2,1,CopyConst2Ram(msg,settingAlarm));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _settingAlarm+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_settingAlarm+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,709 :: 		dispAlarmTime();
	CALL       _dispAlarmTime+0
;tasks_timer.c,710 :: 		portd = 136;                        // "A" @ 7Segment
	MOVLW      136
	MOVWF      PORTD+0
;tasks_timer.c,711 :: 		tempCount = 0;
	CLRF       _tempCount+0
;tasks_timer.c,712 :: 		while(1){
L_set_menu198:
;tasks_timer.c,713 :: 		if (Button(&PORTB,1,deb_time,0)){
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      1
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_set_menu200
;tasks_timer.c,714 :: 		tempCount = 0;
	CLRF       _tempCount+0
;tasks_timer.c,715 :: 		incAlarmHour();
	CALL       _incAlarmHour+0
;tasks_timer.c,716 :: 		genFlag.f4 = 1;
	BSF        _genFlag+0, 4
;tasks_timer.c,717 :: 		} else if (Button(&PORTB,2,deb_time,0)){
	GOTO       L_set_menu201
L_set_menu200:
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      2
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_set_menu202
;tasks_timer.c,718 :: 		tempCount = 0;
	CLRF       _tempCount+0
;tasks_timer.c,719 :: 		incAlarmMin();
	CALL       _incAlarmMin+0
;tasks_timer.c,720 :: 		genFlag.f4 = 1;
	BSF        _genFlag+0, 4
;tasks_timer.c,721 :: 		} else if (Button(&PORTB,3,deb_time,0)){
	GOTO       L_set_menu203
L_set_menu202:
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      3
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_set_menu204
;tasks_timer.c,722 :: 		tempCount = 0;
	CLRF       _tempCount+0
;tasks_timer.c,723 :: 		genFlag.f4 = ~genFlag.f4;
	MOVLW      16
	XORWF      _genFlag+0, 1
;tasks_timer.c,724 :: 		} else if (Button(&PORTB,4,deb_time,0)||tempCount==10){
	GOTO       L_set_menu205
L_set_menu204:
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      4
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__set_menu394
	MOVF       _tempCount+0, 0
	XORLW      10
	BTFSC      STATUS+0, 2
	GOTO       L__set_menu394
	GOTO       L_set_menu208
L__set_menu394:
;tasks_timer.c,725 :: 		i = 4;
	MOVLW      4
	MOVWF      _i+0
;tasks_timer.c,726 :: 		Delay_ms(25);
	MOVLW      33
	MOVWF      R12+0
	MOVLW      118
	MOVWF      R13+0
L_set_menu209:
	DECFSZ     R13+0, 1
	GOTO       L_set_menu209
	DECFSZ     R12+0, 1
	GOTO       L_set_menu209
	NOP
;tasks_timer.c,727 :: 		break;
	GOTO       L_set_menu199
;tasks_timer.c,728 :: 		}
L_set_menu208:
L_set_menu205:
L_set_menu203:
L_set_menu201:
;tasks_timer.c,729 :: 		if (genFlag.f4){                // Green Led control
	BTFSS      _genFlag+0, 4
	GOTO       L_set_menu210
;tasks_timer.c,730 :: 		PORTA.f2 = 1;
	BSF        PORTA+0, 2
;tasks_timer.c,731 :: 		} else {
	GOTO       L_set_menu211
L_set_menu210:
;tasks_timer.c,732 :: 		PORTA.f2 = 0;
	BCF        PORTA+0, 2
;tasks_timer.c,733 :: 		}
L_set_menu211:
;tasks_timer.c,734 :: 		}
	GOTO       L_set_menu198
L_set_menu199:
;tasks_timer.c,735 :: 		} else if (i == 4){
	GOTO       L_set_menu212
L_set_menu197:
	MOVF       _i+0, 0
	XORLW      4
	BTFSS      STATUS+0, 2
	GOTO       L_set_menu213
;tasks_timer.c,736 :: 		Lcd_Out(1,1,CopyConst2Ram(msg,settingCountDW));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _settingCountDW+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_settingCountDW+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,737 :: 		dispCountDtime();
	CALL       _dispCountDTime+0
;tasks_timer.c,738 :: 		portd = 161;                        // "d" @ 7Segment
	MOVLW      161
	MOVWF      PORTD+0
;tasks_timer.c,739 :: 		tempCount = 0;
	CLRF       _tempCount+0
;tasks_timer.c,740 :: 		while(1){
L_set_menu214:
;tasks_timer.c,741 :: 		if (Button(&PORTB,1,deb_time,0)){
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      1
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_set_menu216
;tasks_timer.c,742 :: 		tempCount = 0;
	CLRF       _tempCount+0
;tasks_timer.c,743 :: 		genFlag2.f3 = 0;
	BCF        _genFlag2+0, 3
;tasks_timer.c,744 :: 		incCountDMin();
	CALL       _incCountDmin+0
;tasks_timer.c,745 :: 		genFlag.f7 = 1;
	BSF        _genFlag+0, 7
;tasks_timer.c,746 :: 		} else if (Button(&PORTB,2,deb_time,0)){
	GOTO       L_set_menu217
L_set_menu216:
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      2
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_set_menu218
;tasks_timer.c,747 :: 		tempCount = 0;
	CLRF       _tempCount+0
;tasks_timer.c,748 :: 		genFlag2.f3 = 0;
	BCF        _genFlag2+0, 3
;tasks_timer.c,749 :: 		incCountDSec();
	CALL       _incCountDsec+0
;tasks_timer.c,750 :: 		genFlag.f7 = 1;
	BSF        _genFlag+0, 7
;tasks_timer.c,751 :: 		} else if (Button(&PORTB,3,deb_time,0)){
	GOTO       L_set_menu219
L_set_menu218:
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      3
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_set_menu220
;tasks_timer.c,752 :: 		tempCount = 0;
	CLRF       _tempCount+0
;tasks_timer.c,753 :: 		genFlag2.f3 = ~genFlag2.f3;
	MOVLW      8
	XORWF      _genFlag2+0, 1
;tasks_timer.c,754 :: 		} else if (Button(&PORTB,4,deb_time,0)||tempCount==10){
	GOTO       L_set_menu221
L_set_menu220:
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      4
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__set_menu393
	MOVF       _tempCount+0, 0
	XORLW      10
	BTFSC      STATUS+0, 2
	GOTO       L__set_menu393
	GOTO       L_set_menu224
L__set_menu393:
;tasks_timer.c,755 :: 		i = 5;
	MOVLW      5
	MOVWF      _i+0
;tasks_timer.c,756 :: 		if(genFlag.f7){              // If CDW to be enabled
	BTFSS      _genFlag+0, 7
	GOTO       L_set_menu225
;tasks_timer.c,757 :: 		genFlag2.f3 = 1;        // Enable
	BSF        _genFlag2+0, 3
;tasks_timer.c,758 :: 		genFlag.f7 = 0;         // Reset ToBeEN flag
	BCF        _genFlag+0, 7
;tasks_timer.c,759 :: 		}
L_set_menu225:
;tasks_timer.c,760 :: 		Delay_ms(25);
	MOVLW      33
	MOVWF      R12+0
	MOVLW      118
	MOVWF      R13+0
L_set_menu226:
	DECFSZ     R13+0, 1
	GOTO       L_set_menu226
	DECFSZ     R12+0, 1
	GOTO       L_set_menu226
	NOP
;tasks_timer.c,761 :: 		break;
	GOTO       L_set_menu215
;tasks_timer.c,762 :: 		}
L_set_menu224:
L_set_menu221:
L_set_menu219:
L_set_menu217:
;tasks_timer.c,763 :: 		if (genFlag2.f3){                // Green Led control
	BTFSS      _genFlag2+0, 3
	GOTO       L_set_menu227
;tasks_timer.c,764 :: 		PORTA.f2 = 1;
	BSF        PORTA+0, 2
;tasks_timer.c,765 :: 		} else {
	GOTO       L_set_menu228
L_set_menu227:
;tasks_timer.c,766 :: 		PORTA.f2 = 0;
	BCF        PORTA+0, 2
;tasks_timer.c,767 :: 		}
L_set_menu228:
;tasks_timer.c,768 :: 		dispCountDtime();
	CALL       _dispCountDTime+0
;tasks_timer.c,769 :: 		}
	GOTO       L_set_menu214
L_set_menu215:
;tasks_timer.c,770 :: 		} else if (i == 5){
	GOTO       L_set_menu229
L_set_menu213:
	MOVF       _i+0, 0
	XORLW      5
	BTFSS      STATUS+0, 2
	GOTO       L_set_menu230
;tasks_timer.c,771 :: 		Lcd_Out(1,1,CopyConst2Ram(msg,settingChimes));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _settingChimes+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_settingChimes+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,772 :: 		portd = 167;                        // "c" @ 7Segment
	MOVLW      167
	MOVWF      PORTD+0
;tasks_timer.c,773 :: 		tempCount = 0;
	CLRF       _tempCount+0
;tasks_timer.c,774 :: 		while(1){
L_set_menu231:
;tasks_timer.c,775 :: 		if (Button(&PORTB,1,deb_time,0)){
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      1
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_set_menu233
;tasks_timer.c,776 :: 		tempCount = 0;
	CLRF       _tempCount+0
;tasks_timer.c,777 :: 		genFlag.f6 = ~genFlag.f6;
	MOVLW      64
	XORWF      _genFlag+0, 1
;tasks_timer.c,778 :: 		} else if (Button(&PORTB,4,deb_time,0)||tempCount==10){
	GOTO       L_set_menu234
L_set_menu233:
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      4
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__set_menu392
	MOVF       _tempCount+0, 0
	XORLW      10
	BTFSC      STATUS+0, 2
	GOTO       L__set_menu392
	GOTO       L_set_menu237
L__set_menu392:
;tasks_timer.c,779 :: 		i = 6;
	MOVLW      6
	MOVWF      _i+0
;tasks_timer.c,780 :: 		Delay_ms(25);
	MOVLW      33
	MOVWF      R12+0
	MOVLW      118
	MOVWF      R13+0
L_set_menu238:
	DECFSZ     R13+0, 1
	GOTO       L_set_menu238
	DECFSZ     R12+0, 1
	GOTO       L_set_menu238
	NOP
;tasks_timer.c,781 :: 		break;
	GOTO       L_set_menu232
;tasks_timer.c,782 :: 		}
L_set_menu237:
L_set_menu234:
;tasks_timer.c,783 :: 		if (genFlag.f6){                // Green Led control
	BTFSS      _genFlag+0, 6
	GOTO       L_set_menu239
;tasks_timer.c,784 :: 		PORTA.f2 = 1;
	BSF        PORTA+0, 2
;tasks_timer.c,785 :: 		} else {
	GOTO       L_set_menu240
L_set_menu239:
;tasks_timer.c,786 :: 		PORTA.f2 = 0;
	BCF        PORTA+0, 2
;tasks_timer.c,787 :: 		}
L_set_menu240:
;tasks_timer.c,788 :: 		if (genFlag.f6){
	BTFSS      _genFlag+0, 6
	GOTO       L_set_menu241
;tasks_timer.c,789 :: 		Lcd_Out(2,1,CopyConst2Ram(msg,on));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _on+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_on+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,790 :: 		} else {
	GOTO       L_set_menu242
L_set_menu241:
;tasks_timer.c,791 :: 		Lcd_Out(2,1,CopyConst2Ram(msg,off));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _off+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_off+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,792 :: 		}
L_set_menu242:
;tasks_timer.c,793 :: 		}
	GOTO       L_set_menu231
L_set_menu232:
;tasks_timer.c,794 :: 		} else {
	GOTO       L_set_menu243
L_set_menu230:
;tasks_timer.c,795 :: 		break;
	GOTO       L_set_menu170
;tasks_timer.c,796 :: 		}
L_set_menu243:
L_set_menu229:
L_set_menu212:
L_set_menu196:
L_set_menu184:
;tasks_timer.c,797 :: 		}
	GOTO       L_set_menu169
L_set_menu170:
;tasks_timer.c,798 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,799 :: 		return 0;
	CLRF       R0+0
;tasks_timer.c,800 :: 		}                          // ------------------------------------------------
L_end_set_menu:
	RETURN
; end of _set_menu

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;tasks_timer.c,802 :: 		void interrupt(){          // -- Current task's second ++ / Countdown calc ---
;tasks_timer.c,803 :: 		if(INTCON.INTF){
	BTFSS      INTCON+0, 1
	GOTO       L_interrupt244
;tasks_timer.c,804 :: 		INTCON.INTF = 0;
	BCF        INTCON+0, 1
;tasks_timer.c,805 :: 		porta.f0 = ~porta.f0;                           // 7Segment dot
	MOVLW      1
	XORWF      PORTA+0, 1
;tasks_timer.c,806 :: 		tempCount++;                                    // For auto menus
	INCF       _tempCount+0, 1
;tasks_timer.c,807 :: 		movedCount++;                                   // For battery mode
	INCF       _movedCount+0, 1
;tasks_timer.c,808 :: 		for(i=0; i<10; i++){                            // All active: +1 sec
	CLRF       _i+0
L_interrupt245:
	MOVLW      10
	SUBWF      _i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt246
;tasks_timer.c,809 :: 		if(state[i] == 1){
	MOVF       _i+0, 0
	ADDLW      _state+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt248
;tasks_timer.c,810 :: 		secCount[i] ++;
	MOVF       _i+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	ADDLW      _secCount+0
	MOVWF      R2+0
	MOVF       R2+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	ADDLW      1
	MOVWF      R0+0
	MOVLW      0
	BTFSC      STATUS+0, 0
	ADDLW      1
	INCF       FSR, 1
	ADDWF      INDF+0, 0
	MOVWF      R0+1
	MOVF       R2+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
	MOVF       R0+1, 0
	INCF       FSR, 1
	MOVWF      INDF+0
;tasks_timer.c,811 :: 		}
L_interrupt248:
;tasks_timer.c,808 :: 		for(i=0; i<10; i++){                            // All active: +1 sec
	INCF       _i+0, 1
;tasks_timer.c,812 :: 		}
	GOTO       L_interrupt245
L_interrupt246:
;tasks_timer.c,813 :: 		if(genFlag2.f3){                                // If countdown active
	BTFSS      _genFlag2+0, 3
	GOTO       L_interrupt249
;tasks_timer.c,814 :: 		if(countDownTime>0){
	MOVF       _countDownTime+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt465
	MOVF       _countDownTime+0, 0
	SUBLW      0
L__interrupt465:
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt250
;tasks_timer.c,815 :: 		countDownTime--;                           // Countdown --
	MOVLW      1
	SUBWF      _countDownTime+0, 1
	BTFSS      STATUS+0, 0
	DECF       _countDownTime+1, 1
;tasks_timer.c,816 :: 		}
L_interrupt250:
;tasks_timer.c,817 :: 		}
L_interrupt249:
;tasks_timer.c,818 :: 		}
L_interrupt244:
;tasks_timer.c,819 :: 		}                          // ------------------------------------------------
L_end_interrupt:
L__interrupt464:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;tasks_timer.c,821 :: 		void main() {              // ---------------- Main function -----------------
;tasks_timer.c,822 :: 		PORTA = 0x00;                         // Reseting ports
	CLRF       PORTA+0
;tasks_timer.c,823 :: 		PORTB = 0x00;
	CLRF       PORTB+0
;tasks_timer.c,824 :: 		PORTC = 0x00;
	CLRF       PORTC+0
;tasks_timer.c,825 :: 		PORTD = 0x00;
	CLRF       PORTD+0
;tasks_timer.c,826 :: 		PORTE = 0x00;
	CLRF       PORTE+0
;tasks_timer.c,828 :: 		TRISA      = 0b00100000;              // Setting direction of ports
	MOVLW      32
	MOVWF      TRISA+0
;tasks_timer.c,829 :: 		TRISB      = 255;
	MOVLW      255
	MOVWF      TRISB+0
;tasks_timer.c,830 :: 		TRISC      = 0;
	CLRF       TRISC+0
;tasks_timer.c,831 :: 		TRISD      = 0;
	CLRF       TRISD+0
;tasks_timer.c,832 :: 		TRISE      = 255;
	MOVLW      255
	MOVWF      TRISE+0
;tasks_timer.c,834 :: 		ANSEL      = 0b00010000;              // Configure pin RA5 as analog AN4
	MOVLW      16
	MOVWF      ANSEL+0
;tasks_timer.c,835 :: 		ANSELH     = 0;                       // All other pins as digital
	CLRF       ANSELH+0
;tasks_timer.c,836 :: 		C1ON_bit   = 0;                       // Disable comparators
	BCF        C1ON_bit+0, BitPos(C1ON_bit+0)
;tasks_timer.c,837 :: 		C2ON_bit   = 0;
	BCF        C2ON_bit+0, BitPos(C2ON_bit+0)
;tasks_timer.c,838 :: 		ADCON1     = 0b10000000;              // Analog "right justified", Vref set
	MOVLW      128
	MOVWF      ADCON1+0
;tasks_timer.c,839 :: 		ADCON0.f7  = 1;                       // Analog module settings
	BSF        ADCON0+0, 7
;tasks_timer.c,840 :: 		ADCON0.f6  = 0;
	BCF        ADCON0+0, 6
;tasks_timer.c,842 :: 		OPTION_REG = 0b01111111;              // Enable pull-up resistors in portb
	MOVLW      127
	MOVWF      OPTION_REG+0
;tasks_timer.c,843 :: 		WPUB       = 0b00011111;              // Connects pull-ups
	MOVLW      31
	MOVWF      WPUB+0
;tasks_timer.c,845 :: 		I2C1_Init(100000);                    // Initializing I2C at 100KHz
	MOVLW      10
	MOVWF      SSPADD+0
	CALL       _I2C1_Init+0
;tasks_timer.c,846 :: 		Lcd_Init();                           // Initializing LCD
	CALL       _Lcd_Init+0
;tasks_timer.c,847 :: 		Sound_Init(&PORTD,7);                 // Initializing sound module
	MOVLW      PORTD+0
	MOVWF      FARG_Sound_Init_snd_port+0
	MOVLW      7
	MOVWF      FARG_Sound_Init_snd_pin+0
	CALL       _Sound_Init+0
;tasks_timer.c,848 :: 		ADC_Init();                           // Initializing analog module
	CALL       _ADC_Init+0
;tasks_timer.c,850 :: 		Lcd_Cmd(_LCD_CLEAR);                  // Clear display
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,851 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);             // Cursor off
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,852 :: 		PORTA.F0 = 1;                         // 7Segment DOT
	BSF        PORTA+0, 0
;tasks_timer.c,853 :: 		PORTA.F4 = 1;                         // LCD Backligh ON
	BSF        PORTA+0, 4
;tasks_timer.c,854 :: 		PORTD = 191;                          // 7Segment print "-"
	MOVLW      191
	MOVWF      PORTD+0
;tasks_timer.c,855 :: 		movedCount = 0;                       // Seconds NOT moved reset
	CLRF       _movedCount+0
;tasks_timer.c,856 :: 		item = 10;
	MOVLW      10
	MOVWF      _item+0
;tasks_timer.c,857 :: 		Sound_Play(1500,200);                 // Beep @ start
	MOVLW      220
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      5
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      200
	MOVWF      FARG_Sound_Play_duration_ms+0
	CLRF       FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,860 :: 		if(PORTB.f4 == 0) {
	BTFSC      PORTB+0, 4
	GOTO       L_main251
;tasks_timer.c,861 :: 		write_ds1307(0,0x80);  // Reset second to 0 and stop Oscillator (0)
	CLRF       FARG_write_ds1307_address+0
	MOVLW      128
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,862 :: 		write_ds1307(1,0x00);  // write minutes
	MOVLW      1
	MOVWF      FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,863 :: 		write_ds1307(2,0x12);  // write hours
	MOVLW      2
	MOVWF      FARG_write_ds1307_address+0
	MOVLW      18
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,864 :: 		write_ds1307(3,0x01);  // write day of week 1:Sunday
	MOVLW      3
	MOVWF      FARG_write_ds1307_address+0
	MOVLW      1
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,865 :: 		write_ds1307(4,0x01);  // write date
	MOVLW      4
	MOVWF      FARG_write_ds1307_address+0
	MOVLW      1
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,866 :: 		write_ds1307(5,0x01);  // write month
	MOVLW      5
	MOVWF      FARG_write_ds1307_address+0
	MOVLW      1
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,867 :: 		write_ds1307(6,0x14);  // write year : 20XX
	MOVLW      6
	MOVWF      FARG_write_ds1307_address+0
	MOVLW      20
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,868 :: 		write_ds1307(7,0b00010000); // SQWE output at 1 Hz
	MOVLW      7
	MOVWF      FARG_write_ds1307_address+0
	MOVLW      16
	MOVWF      FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,869 :: 		write_ds1307(38,0x00);
	MOVLW      38
	MOVWF      FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,870 :: 		write_ds1307(39,0x00);
	MOVLW      39
	MOVWF      FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,871 :: 		write_ds1307(40,0x00);
	MOVLW      40
	MOVWF      FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,872 :: 		write_ds1307(41,0x00);
	MOVLW      41
	MOVWF      FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,873 :: 		write_ds1307(42,0x00); // Last power Off minute reset
	MOVLW      42
	MOVWF      FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,874 :: 		write_ds1307(43,0x00); // Last power Off hour reset
	MOVLW      43
	MOVWF      FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,875 :: 		write_ds1307(44,0x00); // Countdown high time
	MOVLW      44
	MOVWF      FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,876 :: 		write_ds1307(45,0x00); // Countdown low time
	MOVLW      45
	MOVWF      FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,877 :: 		write_ds1307(0,0x00);  // Reset second to 0 and start Oscillator (1)
	CLRF       FARG_write_ds1307_address+0
	CLRF       FARG_write_ds1307_w_data+0
	CALL       _write_ds1307+0
;tasks_timer.c,878 :: 		Lcd_Out(1,1,CopyConst2Ram(msg,defaultsReseted));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _defaultsReseted+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_defaultsReseted+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,879 :: 		while (PORTB.f4 == 0){
L_main252:
	BTFSC      PORTB+0, 4
	GOTO       L_main253
;tasks_timer.c,880 :: 		asm NOP
	NOP
;tasks_timer.c,881 :: 		}
	GOTO       L_main252
L_main253:
;tasks_timer.c,882 :: 		}   // ------------------------------------------------
L_main251:
;tasks_timer.c,884 :: 		Lcd_Out(1,1,CopyConst2Ram(msg,tasksTimer));
	MOVLW      _msg+0
	MOVWF      FARG_CopyConst2Ram_dest+0
	MOVLW      _tasksTimer+0
	MOVWF      FARG_CopyConst2Ram_src+0
	MOVLW      hi_addr(_tasksTimer+0)
	MOVWF      FARG_CopyConst2Ram_src+1
	CALL       _CopyConst2Ram+0
	MOVF       R0+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	CALL       _Lcd_Out+0
;tasks_timer.c,885 :: 		Delay_ms(delayShort);
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L_main254:
	DECFSZ     R13+0, 1
	GOTO       L_main254
	DECFSZ     R12+0, 1
	GOTO       L_main254
	DECFSZ     R11+0, 1
	GOTO       L_main254
	NOP
	NOP
;tasks_timer.c,886 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,888 :: 		for (i=0; i<10; i++){                 // Reseting variables
	CLRF       _i+0
L_main255:
	MOVLW      10
	SUBWF      _i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main256
;tasks_timer.c,889 :: 		secCount[i] = 0;
	MOVF       _i+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	ADDLW      _secCount+0
	MOVWF      FSR
	CLRF       INDF+0
	INCF       FSR, 1
	CLRF       INDF+0
;tasks_timer.c,890 :: 		state[i] = 0;
	MOVF       _i+0, 0
	ADDLW      _state+0
	MOVWF      FSR
	CLRF       INDF+0
;tasks_timer.c,888 :: 		for (i=0; i<10; i++){                 // Reseting variables
	INCF       _i+0, 1
;tasks_timer.c,891 :: 		}
	GOTO       L_main255
L_main256:
;tasks_timer.c,892 :: 		genFlag.f7 = 0;                       // CDW ToBeEN flag reset
	BCF        _genFlag+0, 7
;tasks_timer.c,894 :: 		INTCON = 0b10010000;                  // Enable RB0/INT - GIE interrupt
	MOVLW      144
	MOVWF      INTCON+0
;tasks_timer.c,896 :: 		last_off();                           // Show time of last Power Off
	CALL       _last_off+0
;tasks_timer.c,897 :: 		load_all();                           // Saved data load function
	CALL       _load_all+0
;tasks_timer.c,900 :: 		genFlag = read_ds1307(38);
	MOVLW      38
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      _genFlag+0
;tasks_timer.c,901 :: 		genFlag2 = read_ds1307(39);
	MOVLW      39
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      _genFlag2+0
;tasks_timer.c,902 :: 		alarmMinute = read_ds1307(40);
	MOVLW      40
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      _alarmMinute+0
;tasks_timer.c,903 :: 		alarmHour = read_ds1307(41);
	MOVLW      41
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      _alarmHour+0
;tasks_timer.c,904 :: 		loadTemp = read_ds1307(44);
	MOVLW      44
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	MOVWF      _loadTemp+0
	CLRF       _loadTemp+1
;tasks_timer.c,905 :: 		loadTemp = (unsigned int)loadTemp<<8;
	MOVF       _loadTemp+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       R0+0, 0
	MOVWF      _loadTemp+0
	MOVF       R0+1, 0
	MOVWF      _loadTemp+1
;tasks_timer.c,906 :: 		countDownTime = (unsigned int)loadTemp + read_ds1307(45);
	MOVF       R0+0, 0
	MOVWF      FLOC__main+0
	MOVF       R0+1, 0
	MOVWF      FLOC__main+1
	MOVLW      45
	MOVWF      FARG_read_ds1307_address+0
	CALL       _read_ds1307+0
	MOVF       R0+0, 0
	ADDWF      FLOC__main+0, 0
	MOVWF      _countDownTime+0
	MOVF       FLOC__main+1, 0
	BTFSC      STATUS+0, 0
	ADDLW      1
	MOVWF      _countDownTime+1
;tasks_timer.c,908 :: 		while(1){
L_main258:
;tasks_timer.c,909 :: 		read_time();                                       // Read time
	CALL       _read_time+0
;tasks_timer.c,911 :: 		if((msg[15]%2==0)&&(incData==0)){                  // Saving data
	MOVLW      1
	ANDWF      _msg+15, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main262
	MOVF       _incData+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main262
L__main425:
;tasks_timer.c,912 :: 		dataSave();                                  // @ even mins
	CALL       _dataSave+0
;tasks_timer.c,913 :: 		}
L_main262:
;tasks_timer.c,915 :: 		checkAlarm();
	CALL       _checkAlarm+0
;tasks_timer.c,916 :: 		checkCountDown();
	CALL       _checkCountDown+0
;tasks_timer.c,918 :: 		if((msg[11]==49)&&(genFlag.f6)){                   // Chimes
	MOVF       _msg+11, 0
	XORLW      49
	BTFSS      STATUS+0, 2
	GOTO       L_main265
	BTFSS      _genFlag+0, 6
	GOTO       L_main265
L__main424:
;tasks_timer.c,919 :: 		if (msg[12]==50&&msg[14]==48&&msg[15]==48&&genFlag.f0==0){
	MOVF       _msg+12, 0
	XORLW      50
	BTFSS      STATUS+0, 2
	GOTO       L_main268
	MOVF       _msg+14, 0
	XORLW      48
	BTFSS      STATUS+0, 2
	GOTO       L_main268
	MOVF       _msg+15, 0
	XORLW      48
	BTFSS      STATUS+0, 2
	GOTO       L_main268
	BTFSC      _genFlag+0, 0
	GOTO       L_main268
L__main423:
;tasks_timer.c,920 :: 		Sound_Play(5000,200);
	MOVLW      136
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      19
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      200
	MOVWF      FARG_Sound_Play_duration_ms+0
	CLRF       FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,921 :: 		Sound_Play(0,150);
	CLRF       FARG_Sound_Play_freq_in_hz+0
	CLRF       FARG_Sound_Play_freq_in_hz+1
	MOVLW      150
	MOVWF      FARG_Sound_Play_duration_ms+0
	CLRF       FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,922 :: 		Sound_Play(5000,200);
	MOVLW      136
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      19
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      200
	MOVWF      FARG_Sound_Play_duration_ms+0
	CLRF       FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,923 :: 		genFlag.f0 = 1;                           // Flag @12:00
	BSF        _genFlag+0, 0
;tasks_timer.c,924 :: 		}
L_main268:
;tasks_timer.c,925 :: 		if (msg[12]==50&&msg[14]==51&&msg[15]==48&&genFlag.f1==0){
	MOVF       _msg+12, 0
	XORLW      50
	BTFSS      STATUS+0, 2
	GOTO       L_main271
	MOVF       _msg+14, 0
	XORLW      51
	BTFSS      STATUS+0, 2
	GOTO       L_main271
	MOVF       _msg+15, 0
	XORLW      48
	BTFSS      STATUS+0, 2
	GOTO       L_main271
	BTFSC      _genFlag+0, 1
	GOTO       L_main271
L__main422:
;tasks_timer.c,926 :: 		Sound_Play(5000,200);
	MOVLW      136
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      19
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      200
	MOVWF      FARG_Sound_Play_duration_ms+0
	CLRF       FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,927 :: 		Sound_Play(0,150);
	CLRF       FARG_Sound_Play_freq_in_hz+0
	CLRF       FARG_Sound_Play_freq_in_hz+1
	MOVLW      150
	MOVWF      FARG_Sound_Play_duration_ms+0
	CLRF       FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,928 :: 		Sound_Play(5000,200);
	MOVLW      136
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      19
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      200
	MOVWF      FARG_Sound_Play_duration_ms+0
	CLRF       FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,929 :: 		genFlag.f1 = 1;                           // Flag @12:30
	BSF        _genFlag+0, 1
;tasks_timer.c,930 :: 		}
L_main271:
;tasks_timer.c,931 :: 		if (msg[12]==53&&msg[14]==50&&msg[15]==48&&genFlag.f2==0){
	MOVF       _msg+12, 0
	XORLW      53
	BTFSS      STATUS+0, 2
	GOTO       L_main274
	MOVF       _msg+14, 0
	XORLW      50
	BTFSS      STATUS+0, 2
	GOTO       L_main274
	MOVF       _msg+15, 0
	XORLW      48
	BTFSS      STATUS+0, 2
	GOTO       L_main274
	BTFSC      _genFlag+0, 2
	GOTO       L_main274
L__main421:
;tasks_timer.c,932 :: 		Sound_Play(5000,200);
	MOVLW      136
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      19
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      200
	MOVWF      FARG_Sound_Play_duration_ms+0
	CLRF       FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,933 :: 		genFlag.f2 = 1;                           // Flag @15:20
	BSF        _genFlag+0, 2
;tasks_timer.c,934 :: 		}
L_main274:
;tasks_timer.c,935 :: 		if (msg[12]==53&&msg[14]==51&&msg[15]==48&&genFlag.f3==0){
	MOVF       _msg+12, 0
	XORLW      53
	BTFSS      STATUS+0, 2
	GOTO       L_main277
	MOVF       _msg+14, 0
	XORLW      51
	BTFSS      STATUS+0, 2
	GOTO       L_main277
	MOVF       _msg+15, 0
	XORLW      48
	BTFSS      STATUS+0, 2
	GOTO       L_main277
	BTFSC      _genFlag+0, 3
	GOTO       L_main277
L__main420:
;tasks_timer.c,936 :: 		Sound_Play(5000,200);
	MOVLW      136
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      19
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      200
	MOVWF      FARG_Sound_Play_duration_ms+0
	CLRF       FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,937 :: 		Sound_Play(0,150);
	CLRF       FARG_Sound_Play_freq_in_hz+0
	CLRF       FARG_Sound_Play_freq_in_hz+1
	MOVLW      150
	MOVWF      FARG_Sound_Play_duration_ms+0
	CLRF       FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,938 :: 		Sound_Play(5000,200);
	MOVLW      136
	MOVWF      FARG_Sound_Play_freq_in_hz+0
	MOVLW      19
	MOVWF      FARG_Sound_Play_freq_in_hz+1
	MOVLW      200
	MOVWF      FARG_Sound_Play_duration_ms+0
	CLRF       FARG_Sound_Play_duration_ms+1
	CALL       _Sound_Play+0
;tasks_timer.c,939 :: 		genFlag.f3 = 1;                           // Flag @15:30
	BSF        _genFlag+0, 3
;tasks_timer.c,940 :: 		}
L_main277:
;tasks_timer.c,941 :: 		} else
	GOTO       L_main278
L_main265:
;tasks_timer.c,942 :: 		genFlag.f0 = genFlag.f1 = genFlag.f2 = genFlag.f3 = 0;
	BCF        _genFlag+0, 3
	BTFSC      _genFlag+0, 3
	GOTO       L__main467
	BCF        _genFlag+0, 2
	GOTO       L__main468
L__main467:
	BSF        _genFlag+0, 2
L__main468:
	BTFSC      _genFlag+0, 2
	GOTO       L__main469
	BCF        _genFlag+0, 1
	GOTO       L__main470
L__main469:
	BSF        _genFlag+0, 1
L__main470:
	BTFSC      _genFlag+0, 1
	GOTO       L__main471
	BCF        _genFlag+0, 0
	GOTO       L__main472
L__main471:
	BSF        _genFlag+0, 0
L__main472:
L_main278:
;tasks_timer.c,944 :: 		if (Button(&PORTB,1,deb_time,0)){                  // Item ++
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      1
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main279
;tasks_timer.c,945 :: 		Lcd_Cmd(_LCD_TURN_ON);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,946 :: 		segment();          // 7Segment display function
	CALL       _segment+0
;tasks_timer.c,947 :: 		PORTA.f4 = 1;       // LCD on
	BSF        PORTA+0, 4
;tasks_timer.c,948 :: 		rgb();              // RGB Led function
	CALL       _rgb+0
;tasks_timer.c,949 :: 		if(genFlag.f5 && genFlag.f4){                // Stopping
	BTFSS      _genFlag+0, 5
	GOTO       L_main282
	BTFSS      _genFlag+0, 4
	GOTO       L_main282
L__main419:
;tasks_timer.c,950 :: 		genFlag.f4 = 0;                          // alarm
	BCF        _genFlag+0, 4
;tasks_timer.c,951 :: 		} else if(genFlag2.f3 && genFlag2.f4){       // Stopping
	GOTO       L_main283
L_main282:
	BTFSS      _genFlag2+0, 3
	GOTO       L_main286
	BTFSS      _genFlag2+0, 4
	GOTO       L_main286
L__main418:
;tasks_timer.c,952 :: 		genFlag2.f3 = 0;                         // CountDown
	BCF        _genFlag2+0, 3
;tasks_timer.c,953 :: 		} else {
	GOTO       L_main287
L_main286:
;tasks_timer.c,954 :: 		item++;
	INCF       _item+0, 1
;tasks_timer.c,955 :: 		if (item == 11){
	MOVF       _item+0, 0
	XORLW      11
	BTFSS      STATUS+0, 2
	GOTO       L_main288
;tasks_timer.c,956 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,957 :: 		item = 0;
	CLRF       _item+0
;tasks_timer.c,958 :: 		}
L_main288:
;tasks_timer.c,959 :: 		}
L_main287:
L_main283:
;tasks_timer.c,960 :: 		movedCount = 0;                              // Reset secs
	CLRF       _movedCount+0
;tasks_timer.c,961 :: 		}
L_main279:
;tasks_timer.c,962 :: 		if (Button(&PORTB,2,deb_time,0) && (item != 10)){  // Start / Stop
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      2
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main291
	MOVF       _item+0, 0
	XORLW      10
	BTFSC      STATUS+0, 2
	GOTO       L_main291
L__main417:
;tasks_timer.c,963 :: 		Lcd_Cmd(_LCD_TURN_ON);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,964 :: 		segment();          // 7Segment display function
	CALL       _segment+0
;tasks_timer.c,965 :: 		PORTA.f4 = 1;       // LCD on
	BSF        PORTA+0, 4
;tasks_timer.c,966 :: 		rgb();              // RGB Led function
	CALL       _rgb+0
;tasks_timer.c,967 :: 		if(genFlag.f5 && genFlag.f4){                // Stopping
	BTFSS      _genFlag+0, 5
	GOTO       L_main294
	BTFSS      _genFlag+0, 4
	GOTO       L_main294
L__main416:
;tasks_timer.c,968 :: 		genFlag.f4 = 0;                          // alarm
	BCF        _genFlag+0, 4
;tasks_timer.c,969 :: 		} else if(genFlag2.f3 && genFlag2.f4){       // Stopping
	GOTO       L_main295
L_main294:
	BTFSS      _genFlag2+0, 3
	GOTO       L_main298
	BTFSS      _genFlag2+0, 4
	GOTO       L_main298
L__main415:
;tasks_timer.c,970 :: 		genFlag2.f3 = 0;                         // CountDown
	BCF        _genFlag2+0, 3
;tasks_timer.c,971 :: 		} else {
	GOTO       L_main299
L_main298:
;tasks_timer.c,972 :: 		if(state[item] == 0){
	MOVF       _item+0, 0
	ADDLW      _state+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main300
;tasks_timer.c,973 :: 		state[item] = 1;
	MOVF       _item+0, 0
	ADDLW      _state+0
	MOVWF      FSR
	MOVLW      1
	MOVWF      INDF+0
;tasks_timer.c,974 :: 		} else if (state[item] == 1){
	GOTO       L_main301
L_main300:
	MOVF       _item+0, 0
	ADDLW      _state+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main302
;tasks_timer.c,975 :: 		state[item] = 0;
	MOVF       _item+0, 0
	ADDLW      _state+0
	MOVWF      FSR
	CLRF       INDF+0
;tasks_timer.c,976 :: 		}
L_main302:
L_main301:
;tasks_timer.c,977 :: 		}
L_main299:
L_main295:
;tasks_timer.c,978 :: 		movedCount = 0;
	CLRF       _movedCount+0
;tasks_timer.c,979 :: 		}
L_main291:
;tasks_timer.c,980 :: 		if (Button(&PORTB,2,deb_time,0) && (item == 10)){  // All Reset
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      2
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main305
	MOVF       _item+0, 0
	XORLW      10
	BTFSS      STATUS+0, 2
	GOTO       L_main305
L__main414:
;tasks_timer.c,981 :: 		Lcd_Cmd(_LCD_TURN_ON);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,982 :: 		segment();          // 7Segment display function
	CALL       _segment+0
;tasks_timer.c,983 :: 		PORTA.f4 = 1;       // LCD on
	BSF        PORTA+0, 4
;tasks_timer.c,984 :: 		rgb();              // RGB Led function
	CALL       _rgb+0
;tasks_timer.c,985 :: 		if(genFlag.f5 && genFlag.f4){                // Stopping
	BTFSS      _genFlag+0, 5
	GOTO       L_main308
	BTFSS      _genFlag+0, 4
	GOTO       L_main308
L__main413:
;tasks_timer.c,986 :: 		genFlag.f4 = 0;                          // alarm
	BCF        _genFlag+0, 4
;tasks_timer.c,987 :: 		} else if(genFlag2.f3 && genFlag2.f4){       // Stopping
	GOTO       L_main309
L_main308:
	BTFSS      _genFlag2+0, 3
	GOTO       L_main312
	BTFSS      _genFlag2+0, 4
	GOTO       L_main312
L__main412:
;tasks_timer.c,988 :: 		genFlag2.f3 = 0;                         // CountDown
	BCF        _genFlag2+0, 3
;tasks_timer.c,989 :: 		} else {
	GOTO       L_main313
L_main312:
;tasks_timer.c,990 :: 		reset_all();
	CALL       _reset_all+0
;tasks_timer.c,991 :: 		}
L_main313:
L_main309:
;tasks_timer.c,992 :: 		movedCount = 0;
	CLRF       _movedCount+0
;tasks_timer.c,993 :: 		}
L_main305:
;tasks_timer.c,994 :: 		if (Button(&PORTB,3,deb_time,0) && (item == 10)){  // Last Off
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      3
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main316
	MOVF       _item+0, 0
	XORLW      10
	BTFSS      STATUS+0, 2
	GOTO       L_main316
L__main411:
;tasks_timer.c,995 :: 		Lcd_Cmd(_LCD_TURN_ON);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,996 :: 		segment();          // 7Segment display function
	CALL       _segment+0
;tasks_timer.c,997 :: 		PORTA.f4 = 1;       // LCD on
	BSF        PORTA+0, 4
;tasks_timer.c,998 :: 		rgb();              // RGB Led function
	CALL       _rgb+0
;tasks_timer.c,999 :: 		if(genFlag.f5 && genFlag.f4){                // Stopping
	BTFSS      _genFlag+0, 5
	GOTO       L_main319
	BTFSS      _genFlag+0, 4
	GOTO       L_main319
L__main410:
;tasks_timer.c,1000 :: 		genFlag.f4 = 0;                          // alarm
	BCF        _genFlag+0, 4
;tasks_timer.c,1001 :: 		} else if(genFlag2.f3 && genFlag2.f4){       // Stopping
	GOTO       L_main320
L_main319:
	BTFSS      _genFlag2+0, 3
	GOTO       L_main323
	BTFSS      _genFlag2+0, 4
	GOTO       L_main323
L__main409:
;tasks_timer.c,1002 :: 		genFlag2.f3 = 0;                         // CountDown
	BCF        _genFlag2+0, 3
;tasks_timer.c,1003 :: 		} else {
	GOTO       L_main324
L_main323:
;tasks_timer.c,1004 :: 		last_off();
	CALL       _last_off+0
;tasks_timer.c,1005 :: 		}
L_main324:
L_main320:
;tasks_timer.c,1006 :: 		movedCount = 0;
	CLRF       _movedCount+0
;tasks_timer.c,1007 :: 		}
L_main316:
;tasks_timer.c,1008 :: 		if (Button(&PORTB,3,deb_time,0) && (item != 10)){  // Item Reset
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      3
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main327
	MOVF       _item+0, 0
	XORLW      10
	BTFSC      STATUS+0, 2
	GOTO       L_main327
L__main408:
;tasks_timer.c,1009 :: 		Lcd_Cmd(_LCD_TURN_ON);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,1010 :: 		segment();          // 7Segment display function
	CALL       _segment+0
;tasks_timer.c,1011 :: 		PORTA.f4 = 1;       // LCD on
	BSF        PORTA+0, 4
;tasks_timer.c,1012 :: 		rgb();              // RGB Led function
	CALL       _rgb+0
;tasks_timer.c,1013 :: 		if(genFlag.f5 && genFlag.f4){                // Stopping
	BTFSS      _genFlag+0, 5
	GOTO       L_main330
	BTFSS      _genFlag+0, 4
	GOTO       L_main330
L__main407:
;tasks_timer.c,1014 :: 		genFlag.f4 = 0;                          // alarm
	BCF        _genFlag+0, 4
;tasks_timer.c,1015 :: 		} else if(genFlag2.f3 && genFlag2.f4){       // Stopping
	GOTO       L_main331
L_main330:
	BTFSS      _genFlag2+0, 3
	GOTO       L_main334
	BTFSS      _genFlag2+0, 4
	GOTO       L_main334
L__main406:
;tasks_timer.c,1016 :: 		genFlag2.f3 = 0;                         // CountDown
	BCF        _genFlag2+0, 3
;tasks_timer.c,1017 :: 		} else {
	GOTO       L_main335
L_main334:
;tasks_timer.c,1018 :: 		reset_one();
	CALL       _reset_one+0
;tasks_timer.c,1019 :: 		}
L_main335:
L_main331:
;tasks_timer.c,1020 :: 		movedCount = 0;
	CLRF       _movedCount+0
;tasks_timer.c,1021 :: 		}
L_main327:
;tasks_timer.c,1022 :: 		if (Button(&PORTB,4,deb_time,0) && (item == 10)){  // Setting Menu
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      4
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main338
	MOVF       _item+0, 0
	XORLW      10
	BTFSS      STATUS+0, 2
	GOTO       L_main338
L__main405:
;tasks_timer.c,1023 :: 		Lcd_Cmd(_LCD_TURN_ON);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,1024 :: 		segment();          // 7Segment display function
	CALL       _segment+0
;tasks_timer.c,1025 :: 		PORTA.f4 = 1;       // LCD on
	BSF        PORTA+0, 4
;tasks_timer.c,1026 :: 		rgb();              // RGB Led function
	CALL       _rgb+0
;tasks_timer.c,1027 :: 		if(genFlag.f5 && genFlag.f4){                // Stopping
	BTFSS      _genFlag+0, 5
	GOTO       L_main341
	BTFSS      _genFlag+0, 4
	GOTO       L_main341
L__main404:
;tasks_timer.c,1028 :: 		genFlag.f4 = 0;                          // alarm
	BCF        _genFlag+0, 4
;tasks_timer.c,1029 :: 		} else if(genFlag2.f3 && genFlag2.f4){       // Stopping
	GOTO       L_main342
L_main341:
	BTFSS      _genFlag2+0, 3
	GOTO       L_main345
	BTFSS      _genFlag2+0, 4
	GOTO       L_main345
L__main403:
;tasks_timer.c,1030 :: 		genFlag2.f3 = 0;                         // CountDown
	BCF        _genFlag2+0, 3
;tasks_timer.c,1031 :: 		} else {
	GOTO       L_main346
L_main345:
;tasks_timer.c,1032 :: 		set_menu();
	CALL       _set_menu+0
;tasks_timer.c,1033 :: 		}
L_main346:
L_main342:
;tasks_timer.c,1034 :: 		movedCount = 0;
	CLRF       _movedCount+0
;tasks_timer.c,1035 :: 		}
L_main338:
;tasks_timer.c,1036 :: 		if (Button(&PORTB,4,deb_time,0) && (item != 10)){  // Toggle act.
	MOVLW      PORTB+0
	MOVWF      FARG_Button_port+0
	MOVLW      4
	MOVWF      FARG_Button_pin+0
	MOVLW      90
	MOVWF      FARG_Button_time_ms+0
	CLRF       FARG_Button_active_state+0
	CALL       _Button+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main349
	MOVF       _item+0, 0
	XORLW      10
	BTFSC      STATUS+0, 2
	GOTO       L_main349
L__main402:
;tasks_timer.c,1037 :: 		Lcd_Cmd(_LCD_TURN_ON);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,1038 :: 		segment();          // 7Segment display function
	CALL       _segment+0
;tasks_timer.c,1039 :: 		PORTA.f4 = 1;       // LCD on
	BSF        PORTA+0, 4
;tasks_timer.c,1040 :: 		rgb();              // RGB Led function
	CALL       _rgb+0
;tasks_timer.c,1041 :: 		if(genFlag.f5 && genFlag.f4){                // Stopping
	BTFSS      _genFlag+0, 5
	GOTO       L_main352
	BTFSS      _genFlag+0, 4
	GOTO       L_main352
L__main401:
;tasks_timer.c,1042 :: 		genFlag.f4 = 0;                          // alarm
	BCF        _genFlag+0, 4
;tasks_timer.c,1043 :: 		} else if(genFlag2.f3 && genFlag2.f4){       // Stopping
	GOTO       L_main353
L_main352:
	BTFSS      _genFlag2+0, 3
	GOTO       L_main356
	BTFSS      _genFlag2+0, 4
	GOTO       L_main356
L__main400:
;tasks_timer.c,1044 :: 		genFlag2.f3 = 0;                         // CountDown
	BCF        _genFlag2+0, 3
;tasks_timer.c,1045 :: 		} else {
	GOTO       L_main357
L_main356:
;tasks_timer.c,1046 :: 		item++;
	INCF       _item+0, 1
;tasks_timer.c,1047 :: 		while((item > 9)||(secCount[item] == 0)){
L_main358:
	MOVF       _item+0, 0
	SUBLW      9
	BTFSS      STATUS+0, 0
	GOTO       L__main399
	MOVF       _item+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	ADDLW      _secCount+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      R1+0
	INCF       FSR, 1
	MOVF       INDF+0, 0
	MOVWF      R1+1
	MOVLW      0
	XORWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main473
	MOVLW      0
	XORWF      R1+0, 0
L__main473:
	BTFSC      STATUS+0, 2
	GOTO       L__main399
	GOTO       L_main359
L__main399:
;tasks_timer.c,1048 :: 		item++;
	INCF       _item+0, 1
;tasks_timer.c,1049 :: 		}
	GOTO       L_main358
L_main359:
;tasks_timer.c,1050 :: 		}
L_main357:
L_main353:
;tasks_timer.c,1051 :: 		movedCount = 0;
	CLRF       _movedCount+0
;tasks_timer.c,1052 :: 		}
L_main349:
;tasks_timer.c,1054 :: 		print_state();            // "Stopped" or "Running"
	CALL       _print_state+0
;tasks_timer.c,1055 :: 		calc_minutes();           // Calculate current item's minutes
	CALL       _calc_minutes+0
;tasks_timer.c,1057 :: 		if (PORTB.f5 == 1){                    // Power supply check
	BTFSS      PORTB+0, 5
	GOTO       L_main362
;tasks_timer.c,1058 :: 		powerCut();
	CALL       _powerCut+0
;tasks_timer.c,1059 :: 		}
L_main362:
;tasks_timer.c,1061 :: 		if (genFlag.f5 && genFlag.f4){         // LCD On when alarm
	BTFSS      _genFlag+0, 5
	GOTO       L_main365
	BTFSS      _genFlag+0, 4
	GOTO       L_main365
L__main398:
;tasks_timer.c,1062 :: 		movedCount = 0;
	CLRF       _movedCount+0
;tasks_timer.c,1063 :: 		}
L_main365:
;tasks_timer.c,1064 :: 		if (genFlag2.f3 && genFlag2.f4){       // LCD On when CountDown
	BTFSS      _genFlag2+0, 3
	GOTO       L_main368
	BTFSS      _genFlag2+0, 4
	GOTO       L_main368
L__main397:
;tasks_timer.c,1065 :: 		movedCount = 0;
	CLRF       _movedCount+0
;tasks_timer.c,1066 :: 		}
L_main368:
;tasks_timer.c,1067 :: 		if (PORTE.f0 == 0){       // Reseting seconds @ movement
	BTFSC      PORTE+0, 0
	GOTO       L_main369
;tasks_timer.c,1068 :: 		movedCount = 0;
	CLRF       _movedCount+0
;tasks_timer.c,1069 :: 		}
L_main369:
;tasks_timer.c,1070 :: 		if (movedCount > 253){    // NOT moved secs overload protection
	MOVF       _movedCount+0, 0
	SUBLW      253
	BTFSC      STATUS+0, 0
	GOTO       L_main370
;tasks_timer.c,1071 :: 		movedCount = 20;
	MOVLW      20
	MOVWF      _movedCount+0
;tasks_timer.c,1072 :: 		}
L_main370:
;tasks_timer.c,1074 :: 		Lcd_Cmd(_LCD_TURN_ON);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;tasks_timer.c,1075 :: 		segment();                // 7Segment display function
	CALL       _segment+0
;tasks_timer.c,1076 :: 		PORTA.f4 = 1;             // LCD on
	BSF        PORTA+0, 4
;tasks_timer.c,1077 :: 		rgb();                    // RGB Led function
	CALL       _rgb+0
;tasks_timer.c,1078 :: 		}
	GOTO       L_main258
;tasks_timer.c,1079 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
