import processing.serial.*;

Serial  myPort;
int     lf = 10;       //ASCII linefeed
String  inString;      //String for testing serial communication


StringList commands;


void setup() {
  size(700, 500);
  printArray(Serial.list());
  try {
    myPort = new Serial(this, Serial.list()[5], 115200);
    myPort.clear();
    myPort.bufferUntil(lf);
  }
  catch(Exception e) {
    println("Cannot open serial port.");
  }

  //noLoop();
  commands = new StringList();
}

void draw() {

  bezier(width/2, height, width/2-100, height/2+50, width/2, height/2, width-100, height/2+150);
  drawsegmentBezier(20);
}


void drawsegmentBezier(int _s) {
  int steps = _s;
  for (int i = 0; i <= steps; i++) {
    float t = i / float(steps);
    float x = bezierPoint(width/2-5, width/2-100, width/2, width-100, t);
    float y = bezierPoint( height-5, height/2+50, height/2, height/2+150, t);

    /*String cmd = "G1 X"+x+" Y"+y;
     cmd+='\n';
     myPort.write(cmd);
     */
    fill(255, 0, 0);
    ellipse(x, y, 35, 35);
  }
}

void segmentBezier(int _s) {
  int steps = _s;
  for (int i = 0; i <= steps; i++) {
    float t = i / float(steps);
    float x = bezierPoint(width/2-5, width/2-100, width/2, width-100, t);
    float y = bezierPoint( height-5, height/2+50, height/2, height/2+150, t);


    float xPos =width/2-x;
    float yPos =height-y;

    // println(x+" "+y);

     String cmd = "G1 X"+xPos+" Y"+yPos;
    // cmd+='\n';
     //myPort.write(cmd);
     //delay(10);
     
    commands.append(cmd);

    //fill(255,0,0);
    //ellipse(x, y, 35, 35);
  }
  
  startDraw();
  // redraw();
}





void mousePressed() {
  int xPos =width/2-mouseX;
  int yPos =height-mouseY;

  /* String cmd = "M1 50d";
   cmd+='\n';
   myPort.write(cmd);*/

  String cmd = "G1 X"+xPos+" Y"+yPos;
  cmd+='\n';
  myPort.write(cmd);
  /*
  cmd = "M1 100d";
   cmd+='\n';
   myPort.write(cmd);*/
}


void keyPressed() {
  if (key == 'h') {

    String cmd = "M1 100d";
    cmd+='\n';
    myPort.write(cmd);

    cmd = "G28";
    cmd+='\n';
    myPort.write(cmd);
  }


  if (key=='s') {

    segmentBezier(20);
  }
}

void startDraw() {
  println("start draw");
  sendFeed();
}

void sendFeed() {
    println(commands.size()+" left");

  if (commands.size()>0) {
    String cmd = commands.get(0);
    println(cmd);
     cmd+='\n';
    myPort.write(cmd);
    commands.remove(0);
  }
   println(commands.size()+" left");

  //if(commands.length==0){}
}


// This is where we read
void serialEvent(Serial p) {
  inString = (myPort.readStringUntil('\n'));
  inString=inString.trim();
  if (inString.equals("DONE") == true) {
    println("next");
    /*String cmd = "G28";
     cmd+='\n';
     myPort.write(cmd);*/
     sendFeed();
  } else {
  }
}