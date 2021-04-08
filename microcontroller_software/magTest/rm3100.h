/*
  rm3100.h - Library for communication with RM3100 magnetometer
*/

#include<SPI.h>
#include<arduino.h>

//Sensor's memory register addresses:
#define POLL	0x00      //Register of poll
#define CCX		0x04
#define CCY		0x06
#define CCZ		0x08
#define MX		0x24
#define MY		0x27
#define MZ		0x2A
#define READ	0x80    // RM3100's read command
#define WRITE	0x00    // RM3100's write command
#define CMM   0x01
#define TMRC  0x0B

// ensure this library description is only included once
#ifndef rm3100_h
#define rm3100_h

// library interface description
class RM3100
{
  // user-accessible "public" interface
  public:
    RM3100(int);
	  void singleMeasurement(int*);
    void initContinuous(int);
    void readResult(float*);

  // library-accessible "private" interface
  private:
	  int CSBp;
	  int dataRate;
	  void writeRegister(byte, byte);
	  int readRegister(byte, int);
};

#endif
