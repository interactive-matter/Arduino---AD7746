import processing.opengl.*;
import processing.serial.*;
import java.io.*;

// The serial port:
Serial arduinoPort;  
Thread serialThread;
int testMode = 0;
//line delimiter
int lf = 10;

int viewHeight = 600;
int viewWidth = 1200;
float viewAreaX = 90;
float viewAreaY = 90;
color backLight=30;
color titleColor=255;
int titleSize=18;
int titleY=20;

color axisColor = 150;
float axisStroke = 1;

color gridTextColor = 200;
float leftBorder = 0.035;
float gridTextOffset = 7;
int gridTextSize=10;

color gridColor=100;
float gridStart=-0.005;

color lineColor = 255;
float lineStroke = 0.01;

String unit="pF";

PFont font;

float changeThreshold = 0.001;
float lightThreshold = 0.5;



float viewRatio = (viewWidth*viewAreaX/100.0)/(viewHeight*viewAreaY/100.0);

//here we store the data
DataSet dataSet = new DataSet(500);

//data to store files
String filePath = "/Users/marcus/Desktop/AD7746";
int fileNumber = 0;
String fileBaseName ="AD7746";
String fileExtension="png";
int fileWait = 0;
int fileMaxWait=10;

void setup() {
  size(viewWidth, viewHeight, OPENGL);
  smooth();
  //noStroke();

  font = loadFont("LucidaGrande-48.vlw");

  // List all the available serial ports:
  if (testMode==0) {
    println(Serial.list());
    arduinoPort = new Serial(this, Serial.list()[0], 9600);

    serialThread = new Thread(new Runnable() {
      public void run() {
        while(true) {
          String text = arduinoPort.readStringUntil(lf);
          if ((text!=null) && (text.length()>2)) {
            //println(text);
            text=text.substring(0,text.length()-2);
            StringTokenizer tokenizer = new StringTokenizer(text,"/\n");
            if (tokenizer.countTokens()==3){
              String c = tokenizer.nextToken();
              String d = tokenizer.nextToken();
              String v = tokenizer.nextToken();
              //println(c+","+d+" -> "+v);
              try {
                int calibration =Integer.parseInt(c);
                int value = Integer.parseInt(v);
                int capdac = Integer.parseInt(d);
                //println(calibration+" -> "+value);
                float capacitance = (value-calibration)*2.441406395519e-07-capdac*0.1640625;
                //println(capacitance);
                dataSet.addSample(capacitance);
              } 
              catch (NumberFormatException e) {
                //did not work
                println("Could not understand '"+text+"'.");
              }
            }
          }
        }
      }
    }
    );
  } 
  else {

    serialThread = new Thread(new Runnable() {
      int number = 0;
      public void run() {
        while(true) {
          dataSet.addSample(sin(number++/(4*PI)));
          delay(50);
        }
      }
    }
    );
  }

  serialThread.start();
}

void draw() {
  background(backLight);


  synchronized(dataSet) { 


    //can this be done simpler?
    float border = min((viewWidth*(100-viewAreaX)/100.0)/2.0,(viewHeight*(100-viewAreaY)/100.0)/2.0); 
    float left = (int)(border)+viewWidth*leftBorder;
    float right = viewWidth - border;
    float bottom = (int)(border);
    float top = viewHeight - border;

    float arrowLong = (float)bottom*0.5;
    float arrowShort = (float)bottom*0.2;

    stroke(axisColor);
    strokeWeight (axisStroke);

    textMode(MODEL);
    textFont(font,titleSize);
    textAlign(CENTER);
    fill(titleColor);
    text("AD7746 Readout",viewWidth/2,titleY);

    //draw the axis
    //viewport is mirrored – 0 is at top
    line (left,bottom,left,top);
    line ((float)left,(float)bottom,left+arrowShort,bottom+arrowLong);
    line ((float)left,(float)bottom,left-arrowShort,bottom+arrowLong);
    line (left,top,right,top);
    line ((float)right,(float)top,right-arrowLong,top+arrowShort);
    line ((float)right,(float)top,right-arrowLong,top-arrowShort);

    float mi = dataSet.getMin();
    float ma = dataSet.getMax();
    float span = ma-mi;
    double magnitude = round((float)Math.log10(span));
    float factor = (float)Math.pow(10,1-magnitude);
    float lower = round((float)(mi*factor)-1.0)/factor;
    float upper = round((float)(ma*factor)+1.0)/factor;
    int steps = round((float)(span*factor));
    int textSteps = 1;
    if (steps>10) {
      textSteps=round(((float)steps+1.5)/10.0);
    }

    println(mi+" ("+lower+") - "+ma+" ("+upper+") = "+span+" ("+steps+" / "+textSteps+") @ "+magnitude+","+factor);

    float stepLength = (upper - lower) / steps;

    //Y-axis texts
    stroke(gridTextColor);
    textFont(font,gridTextSize);
    textAlign(RIGHT);

    //viewport is not normalized yet - we have to doit ourself
    //draw the grid
    for (int i=1; i<steps; i++) {
      //we use ints to produce 'nice numbers'
      int valueText = (int)((lower+(stepLength*i))*factor);
      float value =(float)valueText/factor;
      //normalize between top & bottom
      float pos = map(value,lower,upper,top,bottom);

      if ((i % textSteps) == 0) {
        fill(gridTextColor);
        text(value+unit,left-gridTextOffset,pos);
      }
      stroke(gridColor);
      line (left+gridStart,pos,right,pos);
    }


    //prepare the viewport so that it is 0-1 with 0,0 at bottom
    rotateX(PI);
    translate(0,-viewHeight);
    translate (left,bottom);
    scale (right-left,top-bottom);

    //draw the actual data
    float sampleSteps = 1.0 / dataSet.getNumberOfSamples();
    for (int i=1; i < dataSet.getNumberOfSamples(); i++) {
      float sample = norm(dataSet.getSample(i), lower, upper);
      float previous = norm(dataSet.getSample(i-1), lower, upper);

      float lineLeft = (i-1)*sampleSteps;
      float lineRight = i*sampleSteps;

      stroke(lineColor);
      strokeWeight(lineStroke);
      line(lineLeft,previous,lineRight,sample);


    }
  }

  if(keyPressed) {
    if (key == 's' || key == 'S') {
      if (fileWait==0) {
        saveImage();
        fileWait++;
      } 
      else {
        fileWait++;
        if (fileWait>fileMaxWait) {
          fileWait=0;
        }
      }
    } 
    else {
      fileWait=0;
    }
  }

  translate(viewWidth*viewAreaX/100.0, viewHeight*viewAreaY/100.0);
}

void saveImage() {

  File path = new File(filePath);
  if (path.mkdir()) {
    println("Directory "+filePath+" created");
  }
  println("Saving file \'"+filePath+"/"+fileBaseName+fileNumber+"."+fileExtension);
  File imageFile;
  String filename;
  do {
    fileNumber++;
    filename = filePath+"/"+fileBaseName+fileNumber+"."+fileExtension;
    imageFile=new File(filename);
  } 
  while (imageFile.exists());
  save(filename);
}












