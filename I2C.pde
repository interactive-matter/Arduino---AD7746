
void writeRegister(unsigned char r, unsigned char v)
{
  Wire.beginTransmission(I2C_ADDRESS);
  Wire.send(r);
  Wire.send(v);
  Wire.endTransmission();
}

void writeInteger(unsigned char r, unsigned int v) {
  writeRegister(r,(unsigned byte)v);
  writeRegister(r+1,(unsigned byte)(v>>8));
}

unsigned char readRegister(unsigned char r)
{
  unsigned char v;
  Wire.beginTransmission(I2C_ADDRESS);
  Wire.send(r);  // register to read
  Wire.endTransmission();

  Wire.requestFrom(I2C_ADDRESS, 1); // read a byte
  while(Wire.available()==0) {
    // waiting
  }
  v = Wire.receive();
  return v;
}

void readRegisters(unsigned char r, unsigned int numberOfBytes, unsigned char buffer[])
{
  unsigned char v;
  Wire.beginTransmission(I2C_ADDRESS);
  Wire.send(r);  // register to read
  Wire.endTransmission();

  Wire.requestFrom(I2C_ADDRESS, numberOfBytes); // read a byte
  char i = 0;
  while (i<numberOfBytes) {
    while(!Wire.available()) {
      // waiting
    }
    buffer[i] = Wire.receive();
    i++;
  }
}

unsigned int readInteger(unsigned char r) {
  union {
    char data[2];
    unsigned int value;
  } 
  byteMappedInt;

  byteMappedInt.value = 0;

  Wire.beginTransmission(I2C_ADDRESS); // begin read cycle
  Wire.send(0); //pointer to first cap data register
  Wire.endTransmission(); // end cycle
  //after this, the address pointer is set to 0 - since a stop condition has been sent

  Wire.requestFrom(I2C_ADDRESS,r+2); // reads 2 bytes plus all bytes before the register

    while (!Wire.available()==r+2) {
      ; //wait
    }

  for (int i=r+1; i>=0; i--) {
    uint8_t c = Wire.receive();
    if (i<2) {
      byteMappedInt.data[i]= c;
    }
  }

  return byteMappedInt.value;

}

unsigned long readLong(unsigned char r) {
  union {
    char data[4];
    unsigned long value;
  } 
  byteMappedLong;

  byteMappedLong.value = 0L;

  Wire.beginTransmission(I2C_ADDRESS); // begin read cycle
  Wire.send(0); //pointer to first data register
  Wire.endTransmission(); // end cycle
  //the data pointer is reset anyway - so read from 0 on

  Wire.requestFrom(I2C_ADDRESS,r+4); // reads 2 bytes plus all bytes before the register

    while (!Wire.available()==r+4) {
      ; //wait
    }
  for (int i=r+3; i>=0; i--) {
    uint8_t c = Wire.receive();
    if (i<4) {
      byteMappedLong.data[i]= c;
    }
  }

  return byteMappedLong.value;

}
