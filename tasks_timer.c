// ------------------------ Pin connections -----------------------------
// PORTA.0         -->  7Segment Dot       - OUT
// PORTA.1         -->  Blue Led           - OUT
// PORTA.2         -->  Green Led          - OUT
// PORTA.3         -->  Red Led            - OUT
// PORTA.4         -->  LCD Back Light     - OUT
// PORTA.5         -->  Battery voltage    - IN
// PORTA.6-7       -->  4Mhz Oscillator
// PORTB.0         -->  DS1307 Interrupt   - IN
// PORTB.1         -->  Button 1           - IN
// PORTB.2         -->  Button 2           - IN
// PORTB.3         -->  Button 3           - IN
// PORTB.4         -->  Button 4           - IN
// PORTB.5         -->  Power State        - IN
// PORTB.6-7       -->  ICSP
// PORTC.0-2,5-7   -->  LCD 2X16           - OUT
// PORTC.3,4       -->  I2C SCL / SDA
// PORTD.0-6       -->  7Segment a-g       - OUT
// PORTD.7         -->  Piezo Buzzer       - OUT
// PORTE.0         -->  Motion Sensor      - IN
// PORTE.1-2       -->  FREE
// PORTE.3         -->  ~MCLR
// ----------------------------- END ------------------------------------
// ------------------------- Declarations -------------------------------
unsigned short incData;                           // Incremented data @ set
unsigned short readData;                          // Read data from DS1307
unsigned short tempCount;                         // Interrupt counter
unsigned short movedCount;                        // Seconds NOT moved counter
unsigned short genFlag;     // 0-3Beeps, 4AlarmEn, 5Alarm!, 6BeepsEn, 7CDW ToBeEn
unsigned short genFlag2;    // 0-1PowSaveMode(ON/OFF-Auto), 2LowBatChecked, 3CDW EN, 4CDW!
unsigned short alarmMinute;                       // Alarm minute
unsigned short alarmHour;                         // Alarm hour

unsigned int countDownTime;                       // Countdown time remain (sec)
unsigned int secCount[10];                        // Running seconds count
unsigned short state[10];                         // Task's state (0 or 1)
unsigned int loadTemp=0;                          // Temp data @ loading

sbit LCD_RS at RC0_bit;                           // -- LCD Configuration --
sbit LCD_EN at RC1_bit;
sbit LCD_D4 at RC2_bit;
sbit LCD_D5 at RC5_bit;
sbit LCD_D6 at RC6_bit;
sbit LCD_D7 at RC7_bit;
sbit LCD_RS_Direction at TRISC0_bit;
sbit LCD_EN_Direction at TRISC1_bit;
sbit LCD_D4_Direction at TRISC2_bit;
sbit LCD_D5_Direction at TRISC5_bit;
sbit LCD_D6_Direction at TRISC6_bit;
sbit LCD_D7_Direction at TRISC7_bit;              // -----------------------

const delayShort = 1000;                          // 1 sec delay
const delayLong = 2000;                           // 2 sec delay
const deb_time = 90;                              // Debouncing time
unsigned short item = 0;                          // Task index counter
unsigned short i;                                 // General purpose counter

unsigned short powerLoss = 0;                     // Power state flag

void rgb();

char msg[17];                                     // String to be loaded to LCD
const char stopped[] = "Stopped";
const char running[] = "Running";
const char resetCurrent[] = " Reset current? ";
const char itemReseted[] = "  Item reseted  ";
const char resetAll[] = "Reset all data? ";
const char yesNo[] = " 1-YES  /  2-NO ";
const char allReseted[] = "All data reseted";
const char noReset[] = "No reset";
const char defaultsReseted[] = "Defaults Reseted";
const char tasksTimer[] = "  TASKS  TIMER  ";
const char setMenu[] = "    SET MENU    ";
const char settingDate[] = "  Setting Date  ";
const char settingTime[] = "  Setting Time  ";
const char settingAlarm[] = " Setting Alarm  ";
const char settingCountDW[] = "Setting Count DW";
const char settingChimes[] = "Enable chimes:  ";
const char settingPowerSave[] = "Power Save mode:";
const char batteryVoltage[] = "Battery voltage:";
const char dcMode[] = "    DC Mode     ";
const char lowBattery[] = "! Low  Battery !";
const char on[] = "       ON       ";
const char off[] = "       OFF      ";
const char automatic[] = "      AUTO      ";
const char powerError[] = "!!Power  Error!!";
const char allDataSaved[] = "!All data saved!";
const char loadSavedData[] = "Load saved data?";
const char allDataLoaded[] = "All data loaded!";
const char noDataLoaded[] = " No data loaded ";
const char lastPowerOff[] = "Last Power Off @";
const char calcOffTime[] = " Calc Off time? ";
const char timeUpdated[] = " Time updated!  ";
const char noChange[] = "   No change!   ";
const char blank3[] = "   ";
const char blank7[] = "       ";
const char blank11[] = "           ";
const char blank16[] = "                ";
// ----------------------------- END -----------------------------------

void write_ds1307(unsigned short address, unsigned short w_data){  //---- WRITE
 I2C1_Start();           // issue I2C start signal
 I2C1_Wr(0xD0);          // Device Address + W = 0xD0
 I2C1_Wr(address);       // send byte (address of DS1307 location)
 I2C1_Wr(w_data);        // send data (data to be written)
 I2C1_Stop();            // issue I2C stop signal
}

unsigned short read_ds1307(unsigned short address){                //---- READ
 I2C1_Start();
 I2C1_Wr(0xD0);          // Device Address + W = 0xD0
 I2C1_Wr(address);
 I2C1_Repeated_Start();
 I2C1_Wr(0xD1);          // Device Address + R = 0xD1
 readData=I2C1_Rd(0);    // Read Data from DS1307
 I2C1_Stop();
 return(readData);
}

unsigned char BCD2UpperCh(unsigned char bcd){                      //---- BCD
 return ((bcd >> 4) + '0');
}

unsigned char BCD2LowerCh(unsigned char bcd){                      //---- BCD
 return ((bcd & 0x0F) + '0');
}

void read_time(){          // ------------- Reading Time & Date -------------
          msg[0] = BCD2UpperCh(read_ds1307(4));     // Date
          msg[1] = BCD2LowerCh(read_ds1307(4));     // Date
          msg[2] = '/';
          msg[3] = BCD2UpperCh(read_ds1307(5));     // Month
          msg[4] = BCD2LowerCh(read_ds1307(5));     // Month
          msg[5] = '/';
          msg[6] = BCD2UpperCh(read_ds1307(6));     // Year
          msg[7] = BCD2LowerCh(read_ds1307(6));     // Year
          msg[11] = BCD2UpperCh(read_ds1307(2));    // Hour
          msg[12] = BCD2LowerCh(read_ds1307(2));    // Hour
          msg[13] = ':';
          msg[14] = BCD2UpperCh(read_ds1307(1));    // Minute
          msg[15] = BCD2LowerCh(read_ds1307(1));    // Minute
          msg[8] = ' ';
          msg[9] = ' ';
          msg[10] = ' ';
          msg[16] = '\0';
          incData = read_ds1307(0);                 // Read seconds (temp use)
          Lcd_Out(1,1,msg);                         // Printing time on LCD
}                          // ------------------------------------------------

char * CopyConst2Ram(char * dest, const char * src){  // - texts to RAM copy -
      char * d ;
      d = dest;
      for(;*dest++ = *src++;)
        ;
      return d;
}                          // ------------------------------------------------

void segment(){            // ----------- 7 segment configuration ------------
     switch (item){
       case 0:  portd = 192; break;
       case 1:  portd = 249; break;
       case 2:  portd = 164; break;
       case 3:  portd = 176; break;
       case 4:  portd = 153; break;
       case 5:  portd = 146; break;
       case 6:  portd = 130; break;
       case 7:  portd = 248; break;
       case 8:  portd = 128; break;
       case 9:  portd = 144; break;
       default: portd = 191; break;
     }
}                          // ------------------------------------------------

void rgb(){                // --------------  RGB LED control ----------------
      if (item == 10){
             if ((state[0] || state[1] || state[2] || state[3] ||
               state[4] || state[5] || state[6] || state[7] ||
               state[8] || state[9]) == 1){
                           PORTA.f1 = 1;               // Blue LED
                           PORTA.f2 = 0;               // Green LED
                           PORTA.f3 = 0;               // Red LED
             } else {
                           PORTA.f1 = 0;
                           PORTA.f2 = 0;
                           PORTA.f3 = 1;
             }
      } else if (state[item]){
             PORTA.f1 = 0;
             PORTA.f2 = 1;
             PORTA.f3 = 0;
      } else {
             if ((state[0] || state[1] || state[2] || state[3] ||
                   state[4] || state[5] || state[6] || state[7] ||
                   state[8] || state[9]) == 1){
                           PORTA.f1 = 1;
                           PORTA.f2 = 0;
                           PORTA.f3 = 0;
             } else {
                           PORTA.f1 = 0;
                           PORTA.f2 = 0;
                           PORTA.f3 = 1;
             }
      }
}                          // ------------------------------------------------

void calc_minutes(){       // --------- Calculating mins from secs -----------
     if(item != 10){
             msg[0] = (((secCount[item]/60)/100)%10)+48;
             msg[1] = (((secCount[item]/60)/10)%10)+48;
             msg[2] = ((secCount[item]/60)%10)+48;
             msg[3] = '\0';
     } else {
             CopyConst2Ram(msg,blank3);
     }
     Lcd_Out(2,14,msg);
}                          // ------------------------------------------------

void print_state(){        // --------- Printing state of each task ----------
     if (item == 10){
        CopyConst2Ram(msg,blank7);
     } else if (state[item] == 0){
        CopyConst2Ram(msg,stopped);
     } else {
        CopyConst2Ram(msg,running);
     }
     Lcd_Out(2,1,msg);
}                          // ------------------------------------------------

void incHour(){            // -------- Time / Date setting functions ---------
     read_time();
     if ((msg[11] == 50) && (msg[12] == 51)){         // 23 --> 00
        msg[11] = 48;
        msg[12] = 48;
        write_ds1307(0,0x80); // Stop Oscillator (0)
        write_ds1307(2,0x00); // write hours
        write_ds1307(0,0x00); // Start Oscillator (1)
     } else if ((msg[11] == 48) && (msg[12] == 57)){  // 09 --> 10
        msg[11] = 49;
        msg[12] = 48;
        write_ds1307(0,0x80); // Stop Oscillator (0)
        write_ds1307(2,0x10); // write hours
        write_ds1307(0,0x00); // Start Oscillator (1)
     } else if ((msg[11] == 49) && (msg[12] == 57)){  // 19 --> 20
        msg[11] = 50;
        msg[12] = 48;
        write_ds1307(0,0x80); // Stop Oscillator (0)
        write_ds1307(2,0x20); // write hours
        write_ds1307(0,0x00); // Start Oscillator (1)
     } else {
        msg[12]++;
        incData = read_ds1307(2);                     // read hour
        incData++;
        write_ds1307(0,0x80); // Stop Oscillator (0)
        write_ds1307(2,incData); // write hours
        write_ds1307(0,0x00); // Start Oscillator (1)
     }
     read_time();
     delay_ms(25);
}

void incMin(){
     read_time();
     if ((msg[14] == 53) && (msg[15] == 57)){          // 59 --> 00
        msg[14] = 48;
        msg[15] = 48;
        write_ds1307(0,0x80); // Stop Oscillator (0)
        write_ds1307(1,0x00); // write minutes
        write_ds1307(0,0x00); // Start Oscillator (1)
     } else if ((msg[14] == 48) && (msg[15] == 57)){   // 09 --> 10
        msg[14] = 49;
        msg[15] = 48;
        write_ds1307(0,0x80); // Stop Oscillator (0)
        write_ds1307(1,0x10); // write minutes
        write_ds1307(0,0x00); // Start Oscillator (1)
     } else if ((msg[14] == 49) && (msg[15] == 57)){   // 19 --> 20
        msg[14] = 50;
        msg[15] = 48;
        write_ds1307(0,0x80); // Stop Oscillator (0)
        write_ds1307(1,0x20); // write minutes
        write_ds1307(0,0x00); // Start Oscillator (1)
     } else if ((msg[14] == 50) && (msg[15] == 57)){   // 29 --> 30
        msg[14] = 51;
        msg[15] = 48;
        write_ds1307(0,0x80); // Stop Oscillator (0)
        write_ds1307(1,0x30); // write minutes
        write_ds1307(0,0x00); // Start Oscillator (1)
     } else if ((msg[14] == 51) && (msg[15] == 57)){   // 39 --> 40
        msg[14] = 52;
        msg[15] = 48;
        write_ds1307(0,0x80); // Stop Oscillator (0)
        write_ds1307(1,0x40); // write minutes
        write_ds1307(0,0x00); // Start Oscillator (1)
     } else if ((msg[14] == 52) && (msg[15] == 57)){   // 49 --> 50
        msg[14] = 53;
        msg[15] = 48;
        write_ds1307(0,0x80); // Stop Oscillator (0)
        write_ds1307(1,0x50); // write minutes
        write_ds1307(0,0x00); // Start Oscillator (1)
     } else {
        msg[15]++;
        incData = read_ds1307(1);                      // read hour
        incData++;
        write_ds1307(0,0x80); // Stop Oscillator (0)
        write_ds1307(1,incData); // write minute
        write_ds1307(0,0x00); // Start Oscillator (1)
     }
     read_time();
     delay_ms(25);
}

void incDate(){
     read_time();
     if ((msg[0] == 51) && (msg[1] == 49)){            // 31 --> 01
        msg[0] = 48;
        msg[1] = 49;
        write_ds1307(0,0x80); // Stop Oscillator (0)
        write_ds1307(4,0x01); // write date
        write_ds1307(0,0x00); // Start Oscillator (1)
     } else if ((msg[0] == 48) && (msg[1] == 57)){     // 09 --> 10
        msg[0] = 49;
        msg[1] = 48;
        write_ds1307(0,0x80); // Stop Oscillator (0)
        write_ds1307(4,0x10); // write date
        write_ds1307(0,0x00); // Start Oscillator (1)
     } else if ((msg[0] == 49) && (msg[1] == 57)){     // 19 --> 20
        msg[0] = 50;
        msg[1] = 48;
        write_ds1307(0,0x80); // Stop Oscillator (0)
        write_ds1307(4,0x20); // write date
        write_ds1307(0,0x00); // Start Oscillator (1)
     } else if ((msg[0] == 50) && (msg[1] == 57)){     // 29 --> 30
        msg[0] = 51;
        msg[1] = 48;
        write_ds1307(0,0x80); // Stop Oscillator (0)
        write_ds1307(4,0x30); // write date
        write_ds1307(0,0x00); // Start Oscillator (1)
     } else {
        msg[1]++;
        incData = read_ds1307(4);                      // read hour
        incData++;
        write_ds1307(0,0x80); // Stop Oscillator (0)
        write_ds1307(4,incData); // write date
        write_ds1307(0,0x00); // Start Oscillator (1)
     }
     read_time();
     delay_ms(25);
}

void incMonth(){
     read_time();
     if ((msg[3] == 49) && (msg[4] == 50)){            // 12 --> 01
        msg[3] = 48;
        msg[4] = 49;
        write_ds1307(0,0x80); // Stop Oscillator (0)
        write_ds1307(5,0x01); // write month
        write_ds1307(0,0x00); // Start Oscillator (1)
     } else if ((msg[3] == 48) && (msg[4] == 57)){     // 09 --> 10
        msg[3] = 49;
        msg[4] = 48;
        write_ds1307(0,0x80); // Stop Oscillator (0)
        write_ds1307(5,0x10); // write month
        write_ds1307(0,0x00); // Start Oscillator (1)
     } else {
        msg[4]++;
        incData = read_ds1307(5);                      // read hour
        incData++;
        write_ds1307(0,0x80); // Stop Oscillator (0)
        write_ds1307(5,incData); // write month
        write_ds1307(0,0x00); // Start Oscillator (1)
     }
     read_time();
     delay_ms(25);
}

void incYear(){
     read_time();
     if ((msg[6] == 49) && (msg[7] == 55)){            // 17 --> 14
        msg[6] = 49;
        msg[7] = 52;
        write_ds1307(0,0x80); // Stop Oscillator (0)
        write_ds1307(6,0x14); // write year
        write_ds1307(0,0x00); // Start Oscillator (1)
     } else {
        msg[7]++;
        incData = read_ds1307(6);                      // read hour
        incData++;
        write_ds1307(0,0x80); // Stop Oscillator (0)
        write_ds1307(6,incData); // write year
        write_ds1307(0,0x00); // Start Oscillator (1)
     }
     read_time();
     delay_ms(25);
}                          // ------------------------------------------------

void dispAlarmTime(){      // ------------ Show Alarm time on LCD ------------
     msg[0] = ((alarmHour/10)%10)+48;
     msg[1] = (alarmHour%10)+48;
     msg[2] = ':';
     msg[3] = ((alarmMinute/10)%10)+48;
     msg[4] = (alarmMinute%10)+48;
     msg[5] = '\0';
     Lcd_Out(1,12,msg);    // ------------------------------------------------
}

void incAlarmHour(){       // --------- Alarm time setting functions ---------
     if (alarmHour == 23){
        alarmHour = 0;
     } else {
        alarmHour++;
     }
     dispAlarmTime();
     delay_ms(25);
}

void incAlarmMin(){
     if (alarmMinute == 59){
        alarmMinute = 0;
     } else {
        alarmMinute++;
     }
     dispAlarmTime();
     delay_ms(25);
}                          // ------------------------------------------------

void checkAlarm(){         // ---------- Checking if Alarm time --------------
     if(genFlag.f4){
         if (((((alarmMinute/10)%10)+48) == BCD2UpperCh(read_ds1307(1))) &&
            (((alarmMinute%10)+48) == BCD2LowerCh(read_ds1307(1)))){
              if (((((alarmHour/10)%10)+48) == BCD2UpperCh(read_ds1307(2))) &&
                 (((alarmHour%10)+48) == BCD2LowerCh(read_ds1307(2)))){
                 genFlag.f5 = 1;
                 if (incData%2){
                    Sound_Play(5000,70);  //!!!!!!!!!!!! To do using TIMER1 (INT -> sound)
                    Sound_Play(6000,30);
                    Sound_Play(0,100);
                 }
              }
         } else {
              genFlag.f5 = 0;
         }
     }
}                          // ------------------------------------------------

void dispCountDTime(){      // ---------- Show Countdown time on LCD -----------
     Lcd_Out(2,1,CopyConst2Ram(msg,blank11));
     msg[0] = (((countDownTime/60)/10)%10)+48;
     msg[1] = ((countDownTime/60)%10)+48;
     msg[2] = ':';
     msg[3] = ((countDownTime%60)/10)+48;
     msg[4] = ((countDownTime%60)%10)+48;
     msg[5] = '\0';
     Lcd_Out(2,12,msg);    // ------------------------------------------------
}

void incCountDmin(){       // ------- Countdown time setting functions --------
     countDownTime+=60;
     if(countDownTime > 3599){
       countDownTime = 1;
     }
     dispCountDTime();
     delay_ms(25);
}

void incCountDsec(){
     countDownTime++;
     if(countDownTime > 3599){
       countDownTime = 1;
     }
     dispCountDTime();
     delay_ms(25);
}                          // ------------------------------------------------

void checkCountDown(){         // ------- Checking if Countdown time ---------
     if(genFlag2.f3){
         if (countDownTime==0){
              genFlag2.f4 = 1;
              if (incData%2){
                 Sound_Play(6500,30);      //!!!!!!!!!!!! To do using TIMER1 (INT -> sound)
                 Sound_Play(7000,70);
                 Sound_Play(0,100);
              }
         } else {
              genFlag2.f4 = 0;
         }
     }
}                          // ------------------------------------------------

void reset_one(){          // -------------- Single task reset ---------------
     Lcd_Out(1,1,CopyConst2Ram(msg,resetCurrent));
     Lcd_Out(2,1,CopyConst2Ram(msg,yesNo));
     tempCount=0;
     while(1){
          if (Button(&PORTB,1,deb_time,0)){
                 secCount[item] = 0;
                 state[item] = 0;
                 Lcd_Cmd(_LCD_CLEAR);
                 Lcd_Out(1,1,CopyConst2Ram(msg,itemReseted));
                 Sound_Play(3000,100);
                 Delay_ms(delayShort);
                 break;
          }
          if (Button(&PORTB,2,deb_time,0)||tempCount==10){
                 Lcd_Cmd(_LCD_CLEAR);
                 Lcd_Out(1,5,CopyConst2Ram(msg,noReset));
                 Sound_Play(3000,100);
                 Delay_ms(delayShort);
                 break;
          }
     }
     Lcd_Cmd(_LCD_CLEAR);
}                          // ------------------------------------------------

void reset_all(){          // --------------- All tasks reset ----------------
     Lcd_Out(1,1,CopyConst2Ram(msg,resetAll));
     Lcd_Out(2,1,CopyConst2Ram(msg,yesNo));
     tempCount=0;
     i=0;
     while(1){
          if (Button(&PORTB,1,deb_time,0)){
                 for (i=0; i<10; i++){
                     secCount[i] = 0;
                     state[i] = 0;
                 }
                 Lcd_Cmd(_LCD_CLEAR);
                 Lcd_Out(1,1,CopyConst2Ram(msg,allReseted));
                 Sound_Play(3000,100);
                 Delay_ms(delayShort);
                 break;
          }
          if (Button(&PORTB,2,deb_time,0)||tempCount==10){
                 Lcd_Cmd(_LCD_CLEAR);
                 Lcd_Out(1,5,CopyConst2Ram(msg,noReset));
                 Sound_Play(3000,100);
                 Delay_ms(delayShort);
                 break;
          }
     }
     Lcd_Cmd(_LCD_CLEAR);
}                          // ------------------------------------------------
/*                         // NA DW ME UNIX TIME  -  SYNARTHSEIS Time
void calcTime(){           // --- Calculate running time during Power Off ----
     Lcd_Out(1,1,CopyConst2Ram(msg,calcOffTime));
     Lcd_Out(2,1,CopyConst2Ram(msg,yesNo));
     tempCount=0;
     while(1){
          if (Button(&PORTB,1,deb_time,0)){
                 // .................
                 Lcd_Cmd(_LCD_CLEAR);
                 Lcd_Out(1,1,CopyConst2Ram(msg,timeUpdated));
                 Sound_Play(3000,100);
                 Delay_ms(delayShort);
                 break;
          }
          if (Button(&PORTB,2,deb_time,0)||tempCount==120){
                 Lcd_Cmd(_LCD_CLEAR);
                 Lcd_Out(1,1,CopyConst2Ram(msg,noChange));
                 Sound_Play(3000,100);
                 Delay_ms(delayShort);
                 break;
          }
          if (tempCount>30&&tempCount%2){
                 Sound_Play(500,250);
                 Sound_Play(0,100);
          }
     }
     Lcd_Cmd(_LCD_CLEAR);
}                          // ------------------------------------------------
*/
void load_all(){           // -------------- Loading saved data --------------
     Lcd_Out(1,1,CopyConst2Ram(msg,loadSavedData));
     Lcd_Out(2,1,CopyConst2Ram(msg,yesNo));
     tempCount=0;
     while(1){
          if (Button(&PORTB,1,deb_time,0)||tempCount==10){
                 for (i=0; i<10; i++){
                     state[i] = read_ds1307(8+i);
                     loadTemp = read_ds1307(18+i);
                     loadTemp = (unsigned int)loadTemp<<8;
                     secCount[i] = (unsigned int)loadTemp + read_ds1307(28+i);
                 }
                 alarmMinute = read_ds1307(40);
                 alarmHour = read_ds1307(41);
                 loadTemp = read_ds1307(44);
                 loadTemp = (unsigned int)loadTemp<<8;
                 countDownTime = (unsigned int)loadTemp + read_ds1307(45);
                 Lcd_Cmd(_LCD_CLEAR);
                 Lcd_Out(1,1,CopyConst2Ram(msg,allDataLoaded));
                 Sound_Play(3000,100);
                 Delay_ms(delayShort);
                 break;
          }
          if (Button(&PORTB,2,deb_time,0)){
                 Lcd_Cmd(_LCD_CLEAR);
                 Lcd_Out(1,1,CopyConst2Ram(msg,noDataLoaded));
                 Sound_Play(3000,100);
                 Delay_ms(delayShort);
                 break;
          }
     }
     Lcd_Cmd(_LCD_CLEAR);
}                          // ------------------------------------------------

void dataSave(){           // ------------ Data saving procedure -------------
     for(i=0;i<10;i++){
         write_ds1307(8+i,state[i]);                     // Saving items' state
         write_ds1307(18+i,secCount[i]>>8);              // Saving high seconds
         write_ds1307(28+i,secCount[i]&255);             // Saving low seconds
     }
     write_ds1307(38,genFlag);                           // Saving Flags
     write_ds1307(39,genFlag2);                           // Saving Flags (2)
     write_ds1307(40,alarmMinute);                       // Saving alarm minute
     write_ds1307(41,alarmHour);                         // Saving alarm hour
     write_ds1307(44,countDownTime>>8);                  // Saving countdwn high
     write_ds1307(45,countDownTime&255);                 // Saving countdwn low
}                          // ------------------------------------------------

void powerCut(){           // ------------- Black-out procedure --------------
     Lcd_Out(1,1,CopyConst2Ram(msg,powerError));
     Lcd_Out(2,1,CopyConst2Ram(msg,blank16));
     PORTA.f4 = 0;                                       // LCD Backlight OFF
     PORTD = 255;                                        // 7Segment OFF
     PORTA.f1 = 0; PORTA.f2 = 0; PORTA.f3 = 0;           // RGB OFF
     INTCON.GIE = 0;                                     // Disabling Interrupts
      dataSave();                                        // Data save function
      write_ds1307(42,read_ds1307(1));                   // Saving Minutes
      write_ds1307(43,read_ds1307(2));                   // Saving Hours
     INTCON.GIE = 1;                                     // Enabling Interrupts
     Lcd_Out(2,1,CopyConst2Ram(msg,allDataSaved));
     Sound_Play(6000,60);                                // Sound alarm
     Delay_ms(10);
     Sound_Play(5000,60);
     Delay_ms(60);
     Sound_Play(6000,60);
     Delay_ms(10);
     Sound_Play(5000,60);
     Delay_ms(60);
     Sound_Play(6000,60);
     Delay_ms(10);
     Sound_Play(5000,60);
     while(PORTB.f5){                                    // While low power
        asm NOP
     }
     Delay_ms(1000);
     Lcd_Cmd(_LCD_CLEAR);
     PORTA.f4 = 1;                                       // LCD Backlight ON
}                          // ------------------------------------------------

void last_off(){           // --------- Show time of last Power Off ----------
     Lcd_Out(1,1,CopyConst2Ram(msg,lastPowerOff));
     Lcd_Out(2,1,CopyConst2Ram(msg,blank16));
     msg[0] =  BCD2UpperCh(read_ds1307(43));             // Hour
     msg[1] =  BCD2LowerCh(read_ds1307(43));             // Hour
     msg[2] = ':';
     msg[3] =  BCD2UpperCh(read_ds1307(42));             // Minute
     msg[4] =  BCD2LowerCh(read_ds1307(42));             // Minute
     msg[5] = '\0';
     Lcd_Out(2,6,msg);
     Delay_ms(delayLong);
     Lcd_Cmd(_LCD_CLEAR);
}                          // ------------------------------------------------

unsigned short set_menu(){ // -------------- Time/Date set menu --------------
     PORTA.f1 = 0; PORTA.f2 = 0; PORTA.f3 = 0;         // RGB OFF
     Lcd_Out(1,1,CopyConst2Ram(msg,setMenu));
     dataSave();
     Lcd_Out(2,1,CopyConst2Ram(msg,blank16));
     delay_ms(delayShort);
     read_time();                            // Printing date/time on LCD
     i = 1;                                  // Counter initialization
     tempCount = 0;
     while(1){
              if(i == 1){
                   Lcd_Out(2,1,CopyConst2Ram(msg,settingDate));
                   tempCount = 0;
                   while(1){
                       if (Button(&PORTB,1,deb_time,0)){
                          tempCount = 0;
                          incDate();
                       } else if (Button(&PORTB,2,deb_time,0)){
                          tempCount = 0;
                          incMonth();
                       } else if (Button(&PORTB,3,deb_time,0)){
                          tempCount = 0;
                          incYear();
                       } else if (Button(&PORTB,4,deb_time,0)||tempCount==10){
                          i = 2;
                          Delay_ms(25);
                          break;
                       }
                   }
              } else if(i == 2){
                   Lcd_Out(2,1,CopyConst2Ram(msg,settingTime));
                   tempCount = 0;
                   while(1){
                       if (Button(&PORTB,1,deb_time,0)){
                          tempCount = 0;
                          incHour();
                       } else if (Button(&PORTB,2,deb_time,0)){
                          tempCount = 0;
                          incMin();
                       } else if (Button(&PORTB,4,deb_time,0)||tempCount==10){
                          i = 3;
                          Delay_ms(25);
                          break;
                       }
                   }
              } else if (i == 3){
                   Lcd_Out(2,1,CopyConst2Ram(msg,settingAlarm));
                   dispAlarmTime();
                   portd = 136;                        // "A" @ 7Segment
                   tempCount = 0;
                   while(1){
                       if (Button(&PORTB,1,deb_time,0)){
                          tempCount = 0;
                          incAlarmHour();
                          genFlag.f4 = 1;
                       } else if (Button(&PORTB,2,deb_time,0)){
                          tempCount = 0;
                          incAlarmMin();
                          genFlag.f4 = 1;
                       } else if (Button(&PORTB,3,deb_time,0)){
                          tempCount = 0;
                          genFlag.f4 = ~genFlag.f4;
                       } else if (Button(&PORTB,4,deb_time,0)||tempCount==10){
                          i = 4;
                          Delay_ms(25);
                          break;
                       }
                       if (genFlag.f4){                // Green Led control
                          PORTA.f2 = 1;
                       } else {
                          PORTA.f2 = 0;
                       }
                   }
              } else if (i == 4){
                   Lcd_Out(1,1,CopyConst2Ram(msg,settingCountDW));
                   dispCountDtime();
                   portd = 161;                        // "d" @ 7Segment
                   tempCount = 0;
                   while(1){
                       if (Button(&PORTB,1,deb_time,0)){
                          tempCount = 0;
                          genFlag2.f3 = 0;
                          incCountDMin();
                          genFlag.f7 = 1;
                       } else if (Button(&PORTB,2,deb_time,0)){
                          tempCount = 0;
                          genFlag2.f3 = 0;
                          incCountDSec();
                          genFlag.f7 = 1;
                       } else if (Button(&PORTB,3,deb_time,0)){
                          tempCount = 0;
                          genFlag2.f3 = ~genFlag2.f3;
                       } else if (Button(&PORTB,4,deb_time,0)||tempCount==10){
                          i = 5;
                          if(genFlag.f7){              // If CDW to be enabled
                               genFlag2.f3 = 1;        // Enable 
                               genFlag.f7 = 0;         // Reset ToBeEN flag
                          }
                          Delay_ms(25);
                          break;
                       }
                       if (genFlag2.f3){                // Green Led control
                          PORTA.f2 = 1;
                       } else {
                          PORTA.f2 = 0;
                       }
                       dispCountDtime();
                   }
              } else if (i == 5){
                   Lcd_Out(1,1,CopyConst2Ram(msg,settingChimes));
                   portd = 167;                        // "c" @ 7Segment
                   tempCount = 0;
                   while(1){
                       if (Button(&PORTB,1,deb_time,0)){
                          tempCount = 0;
                          genFlag.f6 = ~genFlag.f6;
                       } else if (Button(&PORTB,4,deb_time,0)||tempCount==10){
                          i = 6;
                          Delay_ms(25);
                          break;
                       }
                       if (genFlag.f6){                // Green Led control
                          PORTA.f2 = 1;
                       } else {
                          PORTA.f2 = 0;
                       }
                       if (genFlag.f6){
                          Lcd_Out(2,1,CopyConst2Ram(msg,on));
                       } else {
                          Lcd_Out(2,1,CopyConst2Ram(msg,off));
                       }
                   }
              } else {
                   break;
              }
     }
     Lcd_Cmd(_LCD_CLEAR);
     return 0;
}                          // ------------------------------------------------

void interrupt(){          // -- Current task's second ++ / Countdown calc ---
     if(INTCON.INTF){
         INTCON.INTF = 0;
         porta.f0 = ~porta.f0;                           // 7Segment dot
         tempCount++;                                    // For auto menus
         movedCount++;                                   // For battery mode
         for(i=0; i<10; i++){                            // All active: +1 sec
           if(state[i] == 1){
             secCount[i] ++;
           }
         }
         if(genFlag2.f3){                                // If countdown active
           if(countDownTime>0){
              countDownTime--;                           // Countdown --
           }
         }
     }
}                          // ------------------------------------------------

void main() {              // ---------------- Main function -----------------
     PORTA = 0x00;                         // Reseting ports
     PORTB = 0x00;
     PORTC = 0x00;
     PORTD = 0x00;
     PORTE = 0x00;

     TRISA      = 0b00100000;              // Setting direction of ports
     TRISB      = 255;
     TRISC      = 0;
     TRISD      = 0;
     TRISE      = 255;

     ANSEL      = 0b00010000;              // Configure pin RA5 as analog AN4
     ANSELH     = 0;                       // All other pins as digital
     C1ON_bit   = 0;                       // Disable comparators
     C2ON_bit   = 0;
     ADCON1     = 0b10000000;              // Analog "right justified", Vref set
     ADCON0.f7  = 1;                       // Analog module settings
     ADCON0.f6  = 0;

     OPTION_REG = 0b01111111;              // Enable pull-up resistors in portb
     WPUB       = 0b00011111;              // Connects pull-ups

     I2C1_Init(100000);                    // Initializing I2C at 100KHz
     Lcd_Init();                           // Initializing LCD
     Sound_Init(&PORTD,7);                 // Initializing sound module
     ADC_Init();                           // Initializing analog module
  
     Lcd_Cmd(_LCD_CLEAR);                  // Clear display
     Lcd_Cmd(_LCD_CURSOR_OFF);             // Cursor off
     PORTA.F0 = 1;                         // 7Segment DOT
     PORTA.F4 = 1;                         // LCD Backligh ON
     PORTD = 191;                          // 7Segment print "-"
     movedCount = 0;                       // Seconds NOT moved reset
     item = 10;
     Sound_Play(1500,200);                 // Beep @ start
     
         // -- Initialising DS1307 (Possible ONLY when the programme starts) --
     if(PORTB.f4 == 0) {
           write_ds1307(0,0x80);  // Reset second to 0 and stop Oscillator (0)
           write_ds1307(1,0x00);  // write minutes
           write_ds1307(2,0x12);  // write hours
           write_ds1307(3,0x01);  // write day of week 1:Sunday
           write_ds1307(4,0x01);  // write date
           write_ds1307(5,0x01);  // write month
           write_ds1307(6,0x14);  // write year : 20XX
           write_ds1307(7,0b00010000); // SQWE output at 1 Hz
           write_ds1307(38,0x00);
           write_ds1307(39,0x00);
           write_ds1307(40,0x00);
           write_ds1307(41,0x00);
           write_ds1307(42,0x00); // Last power Off minute reset
           write_ds1307(43,0x00); // Last power Off hour reset
           write_ds1307(44,0x00); // Countdown high time
           write_ds1307(45,0x00); // Countdown low time
           write_ds1307(0,0x00);  // Reset second to 0 and start Oscillator (1)
           Lcd_Out(1,1,CopyConst2Ram(msg,defaultsReseted));
           while (PORTB.f4 == 0){
                 asm NOP
           }
     }   // ------------------------------------------------

     Lcd_Out(1,1,CopyConst2Ram(msg,tasksTimer));
     Delay_ms(delayShort);
     Lcd_Cmd(_LCD_CLEAR);

     for (i=0; i<10; i++){                 // Reseting variables
         secCount[i] = 0;
         state[i] = 0;
     }
     genFlag.f7 = 0;                       // CDW ToBeEN flag reset

     INTCON = 0b10010000;                  // Enable RB0/INT - GIE interrupt
     
     last_off();                           // Show time of last Power Off
     load_all();                           // Saved data load function
//     calcTime();                           // Calculate elapsed time while Off

     genFlag = read_ds1307(38);
     genFlag2 = read_ds1307(39);
     alarmMinute = read_ds1307(40);
     alarmHour = read_ds1307(41);
     loadTemp = read_ds1307(44);
     loadTemp = (unsigned int)loadTemp<<8;
     countDownTime = (unsigned int)loadTemp + read_ds1307(45);

     while(1){
              read_time();                                       // Read time
              
              if((msg[15]%2==0)&&(incData==0)){                  // Saving data
                    dataSave();                                  // @ even mins
              }

              checkAlarm();
              checkCountDown();

              if((msg[11]==49)&&(genFlag.f6)){                   // Chimes
                    if (msg[12]==50&&msg[14]==48&&msg[15]==48&&genFlag.f0==0){
                       Sound_Play(5000,200);
                       Sound_Play(0,150);
                       Sound_Play(5000,200);                     
                       genFlag.f0 = 1;                           // Flag @12:00
                    }
                    if (msg[12]==50&&msg[14]==51&&msg[15]==48&&genFlag.f1==0){
                       Sound_Play(5000,200);
                       Sound_Play(0,150);
                       Sound_Play(5000,200);
                       genFlag.f1 = 1;                           // Flag @12:30
                    }
                    if (msg[12]==53&&msg[14]==50&&msg[15]==48&&genFlag.f2==0){
                       Sound_Play(5000,200);
                       genFlag.f2 = 1;                           // Flag @15:20
                    }
                    if (msg[12]==53&&msg[14]==51&&msg[15]==48&&genFlag.f3==0){
                       Sound_Play(5000,200);
                       Sound_Play(0,150);
                       Sound_Play(5000,200);
                       genFlag.f3 = 1;                           // Flag @15:30
                    }
              } else
                    genFlag.f0 = genFlag.f1 = genFlag.f2 = genFlag.f3 = 0;

              if (Button(&PORTB,1,deb_time,0)){                  // Item ++
                    Lcd_Cmd(_LCD_TURN_ON);
                    segment();          // 7Segment display function
                    PORTA.f4 = 1;       // LCD on
                    rgb();              // RGB Led function
                    if(genFlag.f5 && genFlag.f4){                // Stopping
                        genFlag.f4 = 0;                          // alarm
                    } else if(genFlag2.f3 && genFlag2.f4){       // Stopping
                        genFlag2.f3 = 0;                         // CountDown
                    } else {
                        item++;
                        if (item == 11){
                            Lcd_Cmd(_LCD_CLEAR);
                            item = 0;
                        }
                    }
                    movedCount = 0;                              // Reset secs
              }
              if (Button(&PORTB,2,deb_time,0) && (item != 10)){  // Start / Stop
                    Lcd_Cmd(_LCD_TURN_ON);
                    segment();          // 7Segment display function
                    PORTA.f4 = 1;       // LCD on
                    rgb();              // RGB Led function
                    if(genFlag.f5 && genFlag.f4){                // Stopping
                        genFlag.f4 = 0;                          // alarm
                    } else if(genFlag2.f3 && genFlag2.f4){       // Stopping
                        genFlag2.f3 = 0;                         // CountDown
                    } else {
                        if(state[item] == 0){
                            state[item] = 1;
                        } else if (state[item] == 1){
                            state[item] = 0;
                        }
                    }
                    movedCount = 0;
              }
              if (Button(&PORTB,2,deb_time,0) && (item == 10)){  // All Reset
                    Lcd_Cmd(_LCD_TURN_ON);
                    segment();          // 7Segment display function
                    PORTA.f4 = 1;       // LCD on
                    rgb();              // RGB Led function
                    if(genFlag.f5 && genFlag.f4){                // Stopping
                        genFlag.f4 = 0;                          // alarm
                    } else if(genFlag2.f3 && genFlag2.f4){       // Stopping
                        genFlag2.f3 = 0;                         // CountDown
                    } else {
                        reset_all();
                    }
                    movedCount = 0;
              }
              if (Button(&PORTB,3,deb_time,0) && (item == 10)){  // Last Off
                    Lcd_Cmd(_LCD_TURN_ON);
                    segment();          // 7Segment display function
                    PORTA.f4 = 1;       // LCD on
                    rgb();              // RGB Led function
                    if(genFlag.f5 && genFlag.f4){                // Stopping
                        genFlag.f4 = 0;                          // alarm
                    } else if(genFlag2.f3 && genFlag2.f4){       // Stopping
                        genFlag2.f3 = 0;                         // CountDown
                    } else {
                        last_off();
                    }
                    movedCount = 0;
              }
              if (Button(&PORTB,3,deb_time,0) && (item != 10)){  // Item Reset
                    Lcd_Cmd(_LCD_TURN_ON);
                    segment();          // 7Segment display function
                    PORTA.f4 = 1;       // LCD on
                    rgb();              // RGB Led function
                    if(genFlag.f5 && genFlag.f4){                // Stopping
                        genFlag.f4 = 0;                          // alarm
                    } else if(genFlag2.f3 && genFlag2.f4){       // Stopping
                        genFlag2.f3 = 0;                         // CountDown
                    } else {
                        reset_one();
                    }
                    movedCount = 0;
              }
              if (Button(&PORTB,4,deb_time,0) && (item == 10)){  // Setting Menu
                    Lcd_Cmd(_LCD_TURN_ON);
                    segment();          // 7Segment display function
                    PORTA.f4 = 1;       // LCD on
                    rgb();              // RGB Led function
                    if(genFlag.f5 && genFlag.f4){                // Stopping
                        genFlag.f4 = 0;                          // alarm
                    } else if(genFlag2.f3 && genFlag2.f4){       // Stopping
                        genFlag2.f3 = 0;                         // CountDown
                    } else {
                        set_menu();
                    }
                    movedCount = 0;
              }
              if (Button(&PORTB,4,deb_time,0) && (item != 10)){  // Toggle act.
                    Lcd_Cmd(_LCD_TURN_ON);
                    segment();          // 7Segment display function
                    PORTA.f4 = 1;       // LCD on
                    rgb();              // RGB Led function
                    if(genFlag.f5 && genFlag.f4){                // Stopping
                        genFlag.f4 = 0;                          // alarm
                    } else if(genFlag2.f3 && genFlag2.f4){       // Stopping
                        genFlag2.f3 = 0;                         // CountDown
                    } else {
                        item++;
                        while((item > 9)||(secCount[item] == 0)){
                            item++;
                        }
                    }
                    movedCount = 0;
              }

              print_state();            // "Stopped" or "Running"
              calc_minutes();           // Calculate current item's minutes

              if (PORTB.f5 == 1){                    // Power supply check
                 powerCut();
              }

              if (genFlag.f5 && genFlag.f4){         // LCD On when alarm
                    movedCount = 0;
              }
              if (genFlag2.f3 && genFlag2.f4){       // LCD On when CountDown
                    movedCount = 0;
              }
              if (PORTE.f0 == 0){       // Reseting seconds @ movement
                    movedCount = 0;
              }
              if (movedCount > 253){    // NOT moved secs overload protection
                    movedCount = 20;
              }
              
              Lcd_Cmd(_LCD_TURN_ON);
              segment();                // 7Segment display function
              PORTA.f4 = 1;             // LCD on
              rgb();                    // RGB Led function
     }
}