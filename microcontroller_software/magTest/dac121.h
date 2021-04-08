/*
  dac121.h
*/

#include<SPI.h>
#include<arduino.h>

// ensure this library description is only included once
#ifndef dac121_h
#define dac121_h

// library interface description
class DAC
{
  // user-accessible "public" interface
  public:
    DAC(int);
    void write(short);

  // library-accessible "private" interface
  private:
    int CSBp;
};

#endif
