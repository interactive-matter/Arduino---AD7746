void displayStatus() {
  unsigned char data[18];
  
  readRegisters(0,18,data);
  
  Serial.println("\nAD7746 Registers:");
  Serial.print("Status (0x0): ");
  Serial.println(data[0],BIN);
  Serial.print("Cap Data (0x1-0x3): ");
  Serial.print(data[1],BIN);
  Serial.print(".");
  Serial.print(data[2],BIN);
  Serial.print(".");
  Serial.println(data[3],BIN);
  Serial.print("VT Data (0x4-0x6): ");
  Serial.print(data[4],BIN);
  Serial.print(".");
  Serial.print(data[5],BIN);
  Serial.print(".");
  Serial.println(data[6],BIN);
  Serial.print("Cap Setup (0x7): ");
  Serial.println(data[7],BIN);
    Serial.print("VT Setup (0x8): ");
  Serial.println(data[8],BIN);
  Serial.print("EXC Setup (0x9): ");
  Serial.println(data[9],BIN);
  Serial.print("Configuration (0xa): ");
  Serial.println(data[10],BIN);
  Serial.print("Cap Dac A (0xb): ");
  Serial.println(data[11],BIN);
  Serial.print("Cap Dac B (0xc): ");
  Serial.println(data[12],BIN);
  Serial.print("Cap Offset (0xd-0xe): ");
  Serial.print(data[13],BIN);
  Serial.print(".");
  Serial.println(data[14],BIN);
  Serial.print("Cap Gain (0xf-0x10): ");
  Serial.print(data[15],BIN);
  Serial.print(".");
  Serial.println(data[16],BIN);
  Serial.print("Volt Gain (0x11-0x12): ");
  Serial.print(data[17],BIN);
  Serial.print(".");
  Serial.println(data[18],BIN);
  
}
