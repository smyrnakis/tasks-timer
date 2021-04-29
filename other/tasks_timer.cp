#line 1 "C:/Users/Tolis/Dropbox/mikroC/tasks_timer/v17/tasks_timer.c"
#line 25 "C:/Users/Tolis/Dropbox/mikroC/tasks_timer/v17/tasks_timer.c"
unsigned short incData;
unsigned short readData;
unsigned short tempCount;
unsigned short movedCount;
unsigned short genFlag;
unsigned short genFlag2;
unsigned short alarmMinute;
unsigned short alarmHour;

unsigned int countDownTime;
unsigned int secCount[10];
unsigned short state[10];
unsigned int loadTemp=0;

sbit LCD_RS at RC0_bit;
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
sbit LCD_D7_Direction at TRISC7_bit;

const delayShort = 1000;
const delayLong = 2000;
const deb_time = 90;
unsigned short item = 0;
unsigned short i;

unsigned short powerLoss = 0;

void rgb();

char msg[17];
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


void write_ds1307(unsigned short address, unsigned short w_data){
 I2C1_Start();
 I2C1_Wr(0xD0);
 I2C1_Wr(address);
 I2C1_Wr(w_data);
 I2C1_Stop();
}

unsigned short read_ds1307(unsigned short address){
 I2C1_Start();
 I2C1_Wr(0xD0);
 I2C1_Wr(address);
 I2C1_Repeated_Start();
 I2C1_Wr(0xD1);
 readData=I2C1_Rd(0);
 I2C1_Stop();
 return(readData);
}

unsigned char BCD2UpperCh(unsigned char bcd){
 return ((bcd >> 4) + '0');
}

unsigned char BCD2LowerCh(unsigned char bcd){
 return ((bcd & 0x0F) + '0');
}

void read_time(){
 msg[0] = BCD2UpperCh(read_ds1307(4));
 msg[1] = BCD2LowerCh(read_ds1307(4));
 msg[2] = '/';
 msg[3] = BCD2UpperCh(read_ds1307(5));
 msg[4] = BCD2LowerCh(read_ds1307(5));
 msg[5] = '/';
 msg[6] = BCD2UpperCh(read_ds1307(6));
 msg[7] = BCD2LowerCh(read_ds1307(6));
 msg[11] = BCD2UpperCh(read_ds1307(2));
 msg[12] = BCD2LowerCh(read_ds1307(2));
 msg[13] = ':';
 msg[14] = BCD2UpperCh(read_ds1307(1));
 msg[15] = BCD2LowerCh(read_ds1307(1));
 msg[8] = ' ';
 msg[9] = ' ';
 msg[10] = ' ';
 msg[16] = '\0';
 incData = read_ds1307(0);
 Lcd_Out(1,1,msg);
}

char * CopyConst2Ram(char * dest, const char * src){
 char * d ;
 d = dest;
 for(;*dest++ = *src++;)
 ;
 return d;
}

void segment(){
 switch (item){
 case 0: portd = 192; break;
 case 1: portd = 249; break;
 case 2: portd = 164; break;
 case 3: portd = 176; break;
 case 4: portd = 153; break;
 case 5: portd = 146; break;
 case 6: portd = 130; break;
 case 7: portd = 248; break;
 case 8: portd = 128; break;
 case 9: portd = 144; break;
 default: portd = 191; break;
 }
}

void rgb(){
 if (item == 10){
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
}

void calc_minutes(){
 if(item != 10){
 msg[0] = (((secCount[item]/60)/100)%10)+48;
 msg[1] = (((secCount[item]/60)/10)%10)+48;
 msg[2] = ((secCount[item]/60)%10)+48;
 msg[3] = '\0';
 } else {
 CopyConst2Ram(msg,blank3);
 }
 Lcd_Out(2,14,msg);
}

void print_state(){
 if (item == 10){
 CopyConst2Ram(msg,blank7);
 } else if (state[item] == 0){
 CopyConst2Ram(msg,stopped);
 } else {
 CopyConst2Ram(msg,running);
 }
 Lcd_Out(2,1,msg);
}

void incHour(){
 read_time();
 if ((msg[11] == 50) && (msg[12] == 51)){
 msg[11] = 48;
 msg[12] = 48;
 write_ds1307(0,0x80);
 write_ds1307(2,0x00);
 write_ds1307(0,0x00);
 } else if ((msg[11] == 48) && (msg[12] == 57)){
 msg[11] = 49;
 msg[12] = 48;
 write_ds1307(0,0x80);
 write_ds1307(2,0x10);
 write_ds1307(0,0x00);
 } else if ((msg[11] == 49) && (msg[12] == 57)){
 msg[11] = 50;
 msg[12] = 48;
 write_ds1307(0,0x80);
 write_ds1307(2,0x20);
 write_ds1307(0,0x00);
 } else {
 msg[12]++;
 incData = read_ds1307(2);
 incData++;
 write_ds1307(0,0x80);
 write_ds1307(2,incData);
 write_ds1307(0,0x00);
 }
 read_time();
 delay_ms(25);
}

void incMin(){
 read_time();
 if ((msg[14] == 53) && (msg[15] == 57)){
 msg[14] = 48;
 msg[15] = 48;
 write_ds1307(0,0x80);
 write_ds1307(1,0x00);
 write_ds1307(0,0x00);
 } else if ((msg[14] == 48) && (msg[15] == 57)){
 msg[14] = 49;
 msg[15] = 48;
 write_ds1307(0,0x80);
 write_ds1307(1,0x10);
 write_ds1307(0,0x00);
 } else if ((msg[14] == 49) && (msg[15] == 57)){
 msg[14] = 50;
 msg[15] = 48;
 write_ds1307(0,0x80);
 write_ds1307(1,0x20);
 write_ds1307(0,0x00);
 } else if ((msg[14] == 50) && (msg[15] == 57)){
 msg[14] = 51;
 msg[15] = 48;
 write_ds1307(0,0x80);
 write_ds1307(1,0x30);
 write_ds1307(0,0x00);
 } else if ((msg[14] == 51) && (msg[15] == 57)){
 msg[14] = 52;
 msg[15] = 48;
 write_ds1307(0,0x80);
 write_ds1307(1,0x40);
 write_ds1307(0,0x00);
 } else if ((msg[14] == 52) && (msg[15] == 57)){
 msg[14] = 53;
 msg[15] = 48;
 write_ds1307(0,0x80);
 write_ds1307(1,0x50);
 write_ds1307(0,0x00);
 } else {
 msg[15]++;
 incData = read_ds1307(1);
 incData++;
 write_ds1307(0,0x80);
 write_ds1307(1,incData);
 write_ds1307(0,0x00);
 }
 read_time();
 delay_ms(25);
}

void incDate(){
 read_time();
 if ((msg[0] == 51) && (msg[1] == 49)){
 msg[0] = 48;
 msg[1] = 49;
 write_ds1307(0,0x80);
 write_ds1307(4,0x01);
 write_ds1307(0,0x00);
 } else if ((msg[0] == 48) && (msg[1] == 57)){
 msg[0] = 49;
 msg[1] = 48;
 write_ds1307(0,0x80);
 write_ds1307(4,0x10);
 write_ds1307(0,0x00);
 } else if ((msg[0] == 49) && (msg[1] == 57)){
 msg[0] = 50;
 msg[1] = 48;
 write_ds1307(0,0x80);
 write_ds1307(4,0x20);
 write_ds1307(0,0x00);
 } else if ((msg[0] == 50) && (msg[1] == 57)){
 msg[0] = 51;
 msg[1] = 48;
 write_ds1307(0,0x80);
 write_ds1307(4,0x30);
 write_ds1307(0,0x00);
 } else {
 msg[1]++;
 incData = read_ds1307(4);
 incData++;
 write_ds1307(0,0x80);
 write_ds1307(4,incData);
 write_ds1307(0,0x00);
 }
 read_time();
 delay_ms(25);
}

void incMonth(){
 read_time();
 if ((msg[3] == 49) && (msg[4] == 50)){
 msg[3] = 48;
 msg[4] = 49;
 write_ds1307(0,0x80);
 write_ds1307(5,0x01);
 write_ds1307(0,0x00);
 } else if ((msg[3] == 48) && (msg[4] == 57)){
 msg[3] = 49;
 msg[4] = 48;
 write_ds1307(0,0x80);
 write_ds1307(5,0x10);
 write_ds1307(0,0x00);
 } else {
 msg[4]++;
 incData = read_ds1307(5);
 incData++;
 write_ds1307(0,0x80);
 write_ds1307(5,incData);
 write_ds1307(0,0x00);
 }
 read_time();
 delay_ms(25);
}

void incYear(){
 read_time();
 if ((msg[6] == 49) && (msg[7] == 55)){
 msg[6] = 49;
 msg[7] = 52;
 write_ds1307(0,0x80);
 write_ds1307(6,0x14);
 write_ds1307(0,0x00);
 } else {
 msg[7]++;
 incData = read_ds1307(6);
 incData++;
 write_ds1307(0,0x80);
 write_ds1307(6,incData);
 write_ds1307(0,0x00);
 }
 read_time();
 delay_ms(25);
}

void dispAlarmTime(){
 msg[0] = ((alarmHour/10)%10)+48;
 msg[1] = (alarmHour%10)+48;
 msg[2] = ':';
 msg[3] = ((alarmMinute/10)%10)+48;
 msg[4] = (alarmMinute%10)+48;
 msg[5] = '\0';
 Lcd_Out(1,12,msg);
}

void incAlarmHour(){
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
}

void checkAlarm(){
 if(genFlag.f4){
 if (((((alarmMinute/10)%10)+48) == BCD2UpperCh(read_ds1307(1))) &&
 (((alarmMinute%10)+48) == BCD2LowerCh(read_ds1307(1)))){
 if (((((alarmHour/10)%10)+48) == BCD2UpperCh(read_ds1307(2))) &&
 (((alarmHour%10)+48) == BCD2LowerCh(read_ds1307(2)))){
 genFlag.f5 = 1;
 if (incData%2){
 Sound_Play(5000,70);
 Sound_Play(6000,30);
 Sound_Play(0,100);
 }
 }
 } else {
 genFlag.f5 = 0;
 }
 }
}

void dispCountDTime(){
 Lcd_Out(2,1,CopyConst2Ram(msg,blank11));
 msg[0] = (((countDownTime/60)/10)%10)+48;
 msg[1] = ((countDownTime/60)%10)+48;
 msg[2] = ':';
 msg[3] = ((countDownTime%60)/10)+48;
 msg[4] = ((countDownTime%60)%10)+48;
 msg[5] = '\0';
 Lcd_Out(2,12,msg);
}

void incCountDmin(){
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
}

void checkCountDown(){
 if(genFlag2.f3){
 if (countDownTime==0){
 genFlag2.f4 = 1;
 if (incData%2){
 Sound_Play(6500,30);
 Sound_Play(7000,70);
 Sound_Play(0,100);
 }
 } else {
 genFlag2.f4 = 0;
 }
 }
}

void reset_one(){
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
}

void reset_all(){
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
}
#line 569 "C:/Users/Tolis/Dropbox/mikroC/tasks_timer/v17/tasks_timer.c"
void load_all(){
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
}

void dataSave(){
 for(i=0;i<10;i++){
 write_ds1307(8+i,state[i]);
 write_ds1307(18+i,secCount[i]>>8);
 write_ds1307(28+i,secCount[i]&255);
 }
 write_ds1307(38,genFlag);
 write_ds1307(39,genFlag2);
 write_ds1307(40,alarmMinute);
 write_ds1307(41,alarmHour);
 write_ds1307(44,countDownTime>>8);
 write_ds1307(45,countDownTime&255);
}

void powerCut(){
 Lcd_Out(1,1,CopyConst2Ram(msg,powerError));
 Lcd_Out(2,1,CopyConst2Ram(msg,blank16));
 PORTA.f4 = 0;
 PORTD = 255;
 PORTA.f1 = 0; PORTA.f2 = 0; PORTA.f3 = 0;
 INTCON.GIE = 0;
 dataSave();
 write_ds1307(42,read_ds1307(1));
 write_ds1307(43,read_ds1307(2));
 INTCON.GIE = 1;
 Lcd_Out(2,1,CopyConst2Ram(msg,allDataSaved));
 Sound_Play(6000,60);
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
 while(PORTB.f5){
 asm NOP
 }
 Delay_ms(1000);
 Lcd_Cmd(_LCD_CLEAR);
 PORTA.f4 = 1;
}

void last_off(){
 Lcd_Out(1,1,CopyConst2Ram(msg,lastPowerOff));
 Lcd_Out(2,1,CopyConst2Ram(msg,blank16));
 msg[0] = BCD2UpperCh(read_ds1307(43));
 msg[1] = BCD2LowerCh(read_ds1307(43));
 msg[2] = ':';
 msg[3] = BCD2UpperCh(read_ds1307(42));
 msg[4] = BCD2LowerCh(read_ds1307(42));
 msg[5] = '\0';
 Lcd_Out(2,6,msg);
 Delay_ms(delayLong);
 Lcd_Cmd(_LCD_CLEAR);
}

unsigned short set_menu(){
 PORTA.f1 = 0; PORTA.f2 = 0; PORTA.f3 = 0;
 Lcd_Out(1,1,CopyConst2Ram(msg,setMenu));
 dataSave();
 Lcd_Out(2,1,CopyConst2Ram(msg,blank16));
 delay_ms(delayShort);
 read_time();
 i = 1;
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
 portd = 136;
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
 if (genFlag.f4){
 PORTA.f2 = 1;
 } else {
 PORTA.f2 = 0;
 }
 }
 } else if (i == 4){
 Lcd_Out(1,1,CopyConst2Ram(msg,settingCountDW));
 dispCountDtime();
 portd = 161;
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
 if(genFlag.f7){
 genFlag2.f3 = 1;
 genFlag.f7 = 0;
 }
 Delay_ms(25);
 break;
 }
 if (genFlag2.f3){
 PORTA.f2 = 1;
 } else {
 PORTA.f2 = 0;
 }
 dispCountDtime();
 }
 } else if (i == 5){
 Lcd_Out(1,1,CopyConst2Ram(msg,settingChimes));
 portd = 167;
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
 if (genFlag.f6){
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
}

void interrupt(){
 if(INTCON.INTF){
 INTCON.INTF = 0;
 porta.f0 = ~porta.f0;
 tempCount++;
 movedCount++;
 for(i=0; i<10; i++){
 if(state[i] == 1){
 secCount[i] ++;
 }
 }
 if(genFlag2.f3){
 if(countDownTime>0){
 countDownTime--;
 }
 }
 }
}

void main() {
 PORTA = 0x00;
 PORTB = 0x00;
 PORTC = 0x00;
 PORTD = 0x00;
 PORTE = 0x00;

 TRISA = 0b00100000;
 TRISB = 255;
 TRISC = 0;
 TRISD = 0;
 TRISE = 255;

 ANSEL = 0b00010000;
 ANSELH = 0;
 C1ON_bit = 0;
 C2ON_bit = 0;
 ADCON1 = 0b10000000;
 ADCON0.f7 = 1;
 ADCON0.f6 = 0;

 OPTION_REG = 0b01111111;
 WPUB = 0b00011111;

 I2C1_Init(100000);
 Lcd_Init();
 Sound_Init(&PORTD,7);
 ADC_Init();

 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Cmd(_LCD_CURSOR_OFF);
 PORTA.F0 = 1;
 PORTA.F4 = 1;
 PORTD = 191;
 movedCount = 0;
 item = 10;
 Sound_Play(1500,200);


 if(PORTB.f4 == 0) {
 write_ds1307(0,0x80);
 write_ds1307(1,0x00);
 write_ds1307(2,0x12);
 write_ds1307(3,0x01);
 write_ds1307(4,0x01);
 write_ds1307(5,0x01);
 write_ds1307(6,0x14);
 write_ds1307(7,0b00010000);
 write_ds1307(38,0x00);
 write_ds1307(39,0x00);
 write_ds1307(40,0x00);
 write_ds1307(41,0x00);
 write_ds1307(42,0x00);
 write_ds1307(43,0x00);
 write_ds1307(44,0x00);
 write_ds1307(45,0x00);
 write_ds1307(0,0x00);
 Lcd_Out(1,1,CopyConst2Ram(msg,defaultsReseted));
 while (PORTB.f4 == 0){
 asm NOP
 }
 }

 Lcd_Out(1,1,CopyConst2Ram(msg,tasksTimer));
 Delay_ms(delayShort);
 Lcd_Cmd(_LCD_CLEAR);

 for (i=0; i<10; i++){
 secCount[i] = 0;
 state[i] = 0;
 }
 genFlag.f7 = 0;

 INTCON = 0b10010000;

 last_off();
 load_all();


 genFlag = read_ds1307(38);
 genFlag2 = read_ds1307(39);
 alarmMinute = read_ds1307(40);
 alarmHour = read_ds1307(41);
 loadTemp = read_ds1307(44);
 loadTemp = (unsigned int)loadTemp<<8;
 countDownTime = (unsigned int)loadTemp + read_ds1307(45);

 while(1){
 read_time();

 if((msg[15]%2==0)&&(incData==0)){
 dataSave();
 }

 checkAlarm();
 checkCountDown();

 if((msg[11]==49)&&(genFlag.f6)){
 if (msg[12]==50&&msg[14]==48&&msg[15]==48&&genFlag.f0==0){
 Sound_Play(5000,200);
 Sound_Play(0,150);
 Sound_Play(5000,200);
 genFlag.f0 = 1;
 }
 if (msg[12]==50&&msg[14]==51&&msg[15]==48&&genFlag.f1==0){
 Sound_Play(5000,200);
 Sound_Play(0,150);
 Sound_Play(5000,200);
 genFlag.f1 = 1;
 }
 if (msg[12]==53&&msg[14]==50&&msg[15]==48&&genFlag.f2==0){
 Sound_Play(5000,200);
 genFlag.f2 = 1;
 }
 if (msg[12]==53&&msg[14]==51&&msg[15]==48&&genFlag.f3==0){
 Sound_Play(5000,200);
 Sound_Play(0,150);
 Sound_Play(5000,200);
 genFlag.f3 = 1;
 }
 } else
 genFlag.f0 = genFlag.f1 = genFlag.f2 = genFlag.f3 = 0;

 if (Button(&PORTB,1,deb_time,0)){
 Lcd_Cmd(_LCD_TURN_ON);
 segment();
 PORTA.f4 = 1;
 rgb();
 if(genFlag.f5 && genFlag.f4){
 genFlag.f4 = 0;
 } else if(genFlag2.f3 && genFlag2.f4){
 genFlag2.f3 = 0;
 } else {
 item++;
 if (item == 11){
 Lcd_Cmd(_LCD_CLEAR);
 item = 0;
 }
 }
 movedCount = 0;
 }
 if (Button(&PORTB,2,deb_time,0) && (item != 10)){
 Lcd_Cmd(_LCD_TURN_ON);
 segment();
 PORTA.f4 = 1;
 rgb();
 if(genFlag.f5 && genFlag.f4){
 genFlag.f4 = 0;
 } else if(genFlag2.f3 && genFlag2.f4){
 genFlag2.f3 = 0;
 } else {
 if(state[item] == 0){
 state[item] = 1;
 } else if (state[item] == 1){
 state[item] = 0;
 }
 }
 movedCount = 0;
 }
 if (Button(&PORTB,2,deb_time,0) && (item == 10)){
 Lcd_Cmd(_LCD_TURN_ON);
 segment();
 PORTA.f4 = 1;
 rgb();
 if(genFlag.f5 && genFlag.f4){
 genFlag.f4 = 0;
 } else if(genFlag2.f3 && genFlag2.f4){
 genFlag2.f3 = 0;
 } else {
 reset_all();
 }
 movedCount = 0;
 }
 if (Button(&PORTB,3,deb_time,0) && (item == 10)){
 Lcd_Cmd(_LCD_TURN_ON);
 segment();
 PORTA.f4 = 1;
 rgb();
 if(genFlag.f5 && genFlag.f4){
 genFlag.f4 = 0;
 } else if(genFlag2.f3 && genFlag2.f4){
 genFlag2.f3 = 0;
 } else {
 last_off();
 }
 movedCount = 0;
 }
 if (Button(&PORTB,3,deb_time,0) && (item != 10)){
 Lcd_Cmd(_LCD_TURN_ON);
 segment();
 PORTA.f4 = 1;
 rgb();
 if(genFlag.f5 && genFlag.f4){
 genFlag.f4 = 0;
 } else if(genFlag2.f3 && genFlag2.f4){
 genFlag2.f3 = 0;
 } else {
 reset_one();
 }
 movedCount = 0;
 }
 if (Button(&PORTB,4,deb_time,0) && (item == 10)){
 Lcd_Cmd(_LCD_TURN_ON);
 segment();
 PORTA.f4 = 1;
 rgb();
 if(genFlag.f5 && genFlag.f4){
 genFlag.f4 = 0;
 } else if(genFlag2.f3 && genFlag2.f4){
 genFlag2.f3 = 0;
 } else {
 set_menu();
 }
 movedCount = 0;
 }
 if (Button(&PORTB,4,deb_time,0) && (item != 10)){
 Lcd_Cmd(_LCD_TURN_ON);
 segment();
 PORTA.f4 = 1;
 rgb();
 if(genFlag.f5 && genFlag.f4){
 genFlag.f4 = 0;
 } else if(genFlag2.f3 && genFlag2.f4){
 genFlag2.f3 = 0;
 } else {
 item++;
 while((item > 9)||(secCount[item] == 0)){
 item++;
 }
 }
 movedCount = 0;
 }

 print_state();
 calc_minutes();

 if (PORTB.f5 == 1){
 powerCut();
 }

 if (genFlag.f5 && genFlag.f4){
 movedCount = 0;
 }
 if (genFlag2.f3 && genFlag2.f4){
 movedCount = 0;
 }
 if (PORTE.f0 == 0){
 movedCount = 0;
 }
 if (movedCount > 253){
 movedCount = 20;
 }

 Lcd_Cmd(_LCD_TURN_ON);
 segment();
 PORTA.f4 = 1;
 rgb();
 }
}
