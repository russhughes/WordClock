/*
 WORD CLOCK - 8x8 NeoPixel Desktop Edition
 by Andy Doro
 
 Hardware:
 
 - Trinket Pro 5V (should work with other Arduino-compatibles with minor modifications)
 - DS1307 RTC breakout
 - NeoPixel NeoMatrix 8x8


Software:

This code requires the following libraries:

 - RTClib https://github.com/adafruit/RTClib
 - Adafruit_GFX https://github.com/adafruit/Adafruit-GFX-Library
 - Adafruit_NeoPixel https://github.com/adafruit/Adafruit_NeoPixel
 - Adafruit_NeoMatrix https://github.com/adafruit/Adafruit_NeoMatrix


 Wiring:
 - Solder DS1307 breakout to Trinket Pro, A2 to GND, A3 to PWR, A4 to SDA, A5 to SCL
   If you leave off / clip the unused SQW pin on the RTC breakout, the breakout can sit right on top of the Trinket Pro for a compact design! It'll be difficult to reach the Trinket Pro reset button, but you can activate the bootloader by plugging in the USB.
 - Solder NeoMatrix 5V to Trinket 5V, GND to GND, DIN to Trinket Pro pin 8.
 

 Aword clock using NeoPixel RGB LEDs for a color shift effect.
 
 grid pattern

 A T W E N T Y D
 Q U A R T E R Y
 F I V E H A L F
 D P A S T O R O
 F I V E I G H T
 S I X T H R E E
 T W E L E V E N
 F O U R N I N E
 
 
 Acknowledgements:
  - Thanks Dano for faceplate / 3D models & project inspiration!
 
 */


// include the library code:
#include <SPI.h>
#include <Wire.h>
#include <RTClib.h>
#include <RTC_DS3231.h>
#include <Adafruit_GFX.h>
#include <Adafruit_NeoMatrix.h>
#include <Adafruit_NeoPixel.h>
#include <Bounce2.h>

// define how to write each of the words

// 64-bits is too big! let's use two 32-bit numbers to create masks.
unsigned long topMask;
unsigned long bottomMask;

// define masks for each word. we add them with "bitwise or" to generate a mask for the entire "phrase".
// have to use two different 32-bits numbers, luckily none of the words are spread across top and bottom halves of the NeoMatrix.
#define MFIVE topMask |= 0xF000        // these are in hexadecimal
#define MTEN topMask |= 0x58000000
#define AQUARTER topMask |= 0x80FE0000
#define TWENTY topMask |= 0x7E000000
#define HALF topMask |= 0xF00
#define PAST topMask |= 0x78
#define TO topMask |= 0xC
#define ONE bottomMask |= 0x43
#define TWO bottomMask |= 0xC040
#define THREE bottomMask |= 0x1F0000
#define FOUR bottomMask |= 0xF0
#define FIVE bottomMask |= 0xF0000000
#define SIX bottomMask |= 0xE00000
#define SEVEN bottomMask |= 0x800F00
#define EIGHT bottomMask |= 0x1F000000
#define NINE bottomMask |= 0xF
#define TEN bottomMask |= 0x1010100
#define ELEVEN bottomMask |= 0x3F00
#define TWELVE bottomMask |= 0xF600
#define ANDYDORO topMask |= 0x89010087

// brightness based on time of day- could try warmer colors at night?
#define DAYBRIGHTNESS 40
#define NIGHTBRIGHTNESS 20

// cutoff times for day / night brightness. feel free to modify.
#define MORNINGCUTOFF 7  // when does daybrightness begin?   7am
#define NIGHTCUTOFF   22 // when does nightbrightness begin? 10pm

// define delays
#define FLASHDELAY 250  // delay for startup "flashWords" sequence
#define SHIFTDELAY 100   // controls color shifting speed

RTC_DS3231 RTC; // Establish clock object
DateTime thetime; // Holds current clock time
int j;   // an integer for the color shifting effect

// define pins
#define NEOPIN 3  // connect to DIN on NeoMatrix 8x8
#define HOURPIN 11
#define MINPIN 8

Bounce Button_hour = Bounce(); 
Bounce Button_minute = Bounce();

// Parameter 1 = number of pixels in strip
// Parameter 2 = Arduino pin number (most are valid)
// Parameter 3 = pixel type flags, add together as needed:
//   NEO_KHZ800  800 KHz bitstream (most NeoPixel products w/WS2812 LEDs)
//   NEO_KHZ400  400 KHz (classic 'v1' (not v2) FLORA pixels, WS2811 drivers)
//   NEO_GRB     Pixels are wired for GRB bitstream (most NeoPixel products)
//   NEO_RGB     Pixels are wired for RGB bitstream (v1 FLORA pixels, not v2)
//Adafruit_NeoPixel matrix = Adafruit_NeoPixel(64, NEOPIN, NEO_GRB + NEO_KHZ800);

// configure for 8x8 neopixel matrix
Adafruit_NeoMatrix matrix = Adafruit_NeoMatrix(8, 8, NEOPIN,
                            NEO_MATRIX_TOP  + NEO_MATRIX_LEFT +
                            NEO_MATRIX_ROWS + NEO_MATRIX_PROGRESSIVE,
                            NEO_GRB         + NEO_KHZ800);
                            

void setup() {
  // put your setup code here, to run once:
  
  //Serial for debugging
  Serial.begin(9600);
  Serial.println("Running...");
    
  // set pinmodes
  pinMode(NEOPIN, OUTPUT);
  pinMode(HOURPIN, INPUT_PULLUP);
  pinMode(MINPIN, INPUT_PULLUP);
  
  Button_hour.attach(HOURPIN);
  Button_hour.interval(25);
  
  Button_minute.attach(MINPIN);
  Button_minute.interval(25);
    
  // start clock
  Wire.begin();
  SPI.begin();  // Begin I2C
  RTC.begin();   // begin clock

 if (!RTC.isrunning())  
 {
    Serial.println("RTC is NOT running!");
    // following line sets the RTC to the date & time this sketch was compiled
    RTC.adjust(DateTime(__DATE__, __TIME__));
  } 
  else
  	Serial.println("RTC is running...");
   
  matrix.begin();
  matrix.setBrightness(DAYBRIGHTNESS);
  matrix.fillScreen(0); // Initialize all pixels to 'off'
  matrix.show(); 
  
  // startup sequence... do colorwipe?
  //delay(500);
  //rainbowCycle(10);
  //delay(500);
  
  //flashWords(); // briefly flash each word in sequence 
  //delay(500);
}

void loop() {
  // put your main code here, to run repeatedly:
  
  Button_hour.update();
  Button_minute.update();
    
  thetime = RTC.now();
  
  if (Button_hour.read() == LOW)
  {
    while(Button_hour.read() == LOW) 
      Button_hour.update();
      
    thetime+= 3600;
    RTC.adjust(thetime);
  }

  if (Button_minute.read() == LOW)
  {
    while(Button_minute.read() == LOW) 
     Button_minute.update();
      
    thetime+= 60;
    RTC.adjust(thetime);
  }
 
  adjustBrightness();
  displayTime();
  
  //mode_moon(); // uncomment to show moon mode instead!
}


