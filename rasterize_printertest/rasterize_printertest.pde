import processing.serial.*;

Serial  myPort;
boolean isConnected=false;
int     lf = 10;       //ASCII linefeed
String  inString;      //String for testing serial communication
StringList commands;
boolean done=true;


PImage img;

// sampling resolution: colors will be sampled every n pixels 
// to determine which character to display
int resolutionX = 20;
int resolutionY = 10;

int threshold=250;

int xOffset=200;
int yOffset=150;
float scale=1;

boolean penIsUp=false;



import controlP5.*;
ControlP5 cp5;


void setup() {
  img = loadImage("image.jpg");
  size(1000, 700);
  printArray(Serial.list());
  pixelDensity(2);
  try {
    myPort = new Serial(this, Serial.list()[5], 115200);
    myPort.clear();
    myPort.bufferUntil(lf);
    isConnected=true;
  }
  catch(Exception e) {
    println("Cannot open serial port.");
  }
  commands = new StringList();

  background(255);
  fill(0);
  noStroke();

  cp5 = new ControlP5(this);

  Group g1 = cp5.addGroup("g1")
    .setPosition(10, 140)
    .setBackgroundHeight(100)
    .setBackgroundColor(color(50, 50))
    ;

  cp5.addBang("Pen Up")
    .setPosition(10, 20)
    .setSize(80, 20)
    .setGroup(g1)
    ;

  cp5.addBang("Pen Down")
    .setPosition(10, 60)
    .setSize(80, 20)
    .setGroup(g1)
    ;


  Group g2 = cp5.addGroup("g2")
    .setPosition(10, 10)
    .setWidth(300)
    .activateEvent(true)
    .setBackgroundColor(color(50, 80))
    .setBackgroundHeight(100)
    .setLabel("Hello World.")
    ;

  cp5.addSlider("XPos")
    .setPosition(10, 10)
    .setSize(180, 20)
    .setRange(0, width)
    .setValue(width/2-200)
    .setGroup(g2)
    ;

  cp5.addSlider("YPos")
    .setPosition(10, 40)
    .setSize(180, 20)
    .setRange(0, height)
    .setValue(100)
    .setGroup(g2)
    ;

  cp5.addSlider("Scale")
    .setPosition(10, 70)
    .setSize(180, 20)
    .setRange(0, 5)
    .setValue(1)
    .setGroup(g2)
    ;
}

void draw() {
  if (done)sendFeed();
  background(255);
  drawRaster();
}



void drawRaster() {

  // since the text is just black and white, converting the image
  // to grayscale seems a little more accurate when calculating brightness
  //img.resize(int(img.width*scale), int(img.height*scale));
  img.filter(GRAY);
  img.loadPixels();

  /*
  for (int x = 0; x < img.width-resolutionX; x += resolutionX) {
   stroke(0, 255, 0);
   line(x, 0, x, img.height);
   }
   
   for (int y = 0; y < img.height-resolutionY; y += resolutionY) {
   stroke(255, 0, 0);
   line(0, y, img.width, y);
   }
   */

  // grab the color of every nth pixel in the image

  for (int y = resolutionY/2; y < img.height-resolutionY; y += resolutionY) {
    float lastY=y;

    for (int x = 0; x < img.width-resolutionX; x += resolutionX) {
      //Get the colorvalue
      color pix = img.get(x+resolutionX/2, y+resolutionY/2);
      float brightness=brightness(pix);
      brightness=constrain(brightness, 0, threshold);

      float dil=map(brightness, 0, threshold, resolutionY/2, 0);
      float steps=map(brightness, 0, threshold, resolutionX/2, 1);
      float stepsize=resolutionX/steps;



      float rX=x+xOffset;
      float rY=y+yOffset;
      float drawFromX=rX*scale;
      float drawToX=rX;
      float drawFromY=rY*scale;
      float drawToY=rY;

      // moveTo(int(lastX+xOffset), int(lastY+yOffset));


      for (float i=stepsize; i<=resolutionX; i+=stepsize) {
        drawToX=(rX+i)*scale;
        drawToY=(rY+dil)*scale;
        stroke(0, 0, 255);
        line(drawFromX, drawFromY, drawToX, drawToY);
        drawFromX=drawToX;
        drawFromY=drawToY;
        dil*=-1;
      }

      // close Gaps 
      if (drawFromX<(rX+resolutionX)*scale) {
        // stroke(255,0,0);
         line(drawFromX, drawFromY, (rX+resolutionX)*scale, rY*scale);
      }
    }
  }
}


void rasterify() {
  // since the text is just black and white, converting the image
  // to grayscale seems a little more accurate when calculating brightness
  img.filter(GRAY);
  img.loadPixels();

  /*
  for (int x = 0; x < img.width-resolutionX; x += resolutionX) {
   stroke(0, 255, 0);
   line(x, 0, x, img.height);
   }
   
   for (int y = 0; y < img.height-resolutionY; y += resolutionY) {
   stroke(255, 0, 0);
   line(0, y, img.width, y);
   }
   */

  // grab the color of every nth pixel in the image

  for (int y = resolutionY/2; y < img.height-resolutionY; y += resolutionY) {
    float bx=0;
    float lastY=y;

    moveTo(0+xOffset, y+yOffset);

    for (int x = 0; x < img.width-resolutionX; x += resolutionX) {
      //Get the colorvalue
      color pix = img.get(x+resolutionX/2, y+resolutionY/2);
      float brightness=brightness(pix);
      brightness=constrain(brightness, 0, threshold);

      float dil=map(brightness, 0, threshold, resolutionY/2, 0);
      float steps=map(brightness, 0, threshold, resolutionX/2, 1);
      float stepsize=resolutionX/steps;


      float lastX=x;

      // moveTo(int(lastX+xOffset), int(lastY+yOffset));


      for (float i=stepsize; i<=resolutionX; i+=stepsize) {
        stroke(0, 0, 255);
        line(lastX+xOffset, lastY+yOffset, x+i+xOffset, y+dil+yOffset);
        drawTo(int(x+i+xOffset), int(y+dil+yOffset));

        lastX=x+i;
        lastY=y+dil;
        dil*=-1;
      }

      // close Gaps 
      if (lastX<x+resolutionX) {
        line(lastX+xOffset, lastY+yOffset, x+resolutionX+xOffset, y+dil+yOffset);
        drawTo(int(x+resolutionX+xOffset), int(y+dil+yOffset));
        lastY=y+dil;
      }

      /*

       float xoff=bx;
       
       fill(0);
       stroke(0);
       if (brightness(pix)>threshold) {
       stroke(255, 0, 0);
       //  bx+=resolutionX;
       //continue;//
       }
       
       // if (random(1)>0.5) dil*=-1;
       // generate peaks / lines
       for (int s1 = step; s1 <= resolutionX; s1 +=step) {
       line(xoff, lastY, bx+s1, y+dil);
       xoff=bx+s1;
       lastY=y+dil;
       dil*=-1;
       }
       bx=x;*/
    }
  }
}



void drawBezier(int ax1, int ay1, int sx1, int sy1, int sx2, int sy2, int ax2, int ay2) {
  pushStyle();
  bezier(ax1, ay1, sx1, sy1, sx2, sy2, ax2, ay2);
  fill(0, 255, 0);
  noStroke();
  ellipse(sx1, sy1, 5, 5);
  ellipse(sx2, sy2, 5, 5);

  stroke(0, 255, 0);
  line(ax1, ay1, sx1, sy1);
  line(ax2, ay2, sx2, sy2);
  drawSegmentBezier(ax1, ay1, sx1, sy1, sx2, sy2, ax2, ay2, 50, 5);
  // segmentBezier(ax1, ay1, sx1, sy1, sx2, sy2, ax2, ay2,10);
  popStyle();
}

void drawSegmentBezier(int ax1, int ay1, int sx1, int sy1, int sx2, int sy2, int ax2, int ay2, int steps, int size) {
  for (int i = 0; i <= steps; i++) {
    float t = i / float(steps);
    float x = bezierPoint(ax1, sx1, sx2, ax2, t);
    float y = bezierPoint( ay1, sy1, sy2, ay2, t);
    float xPos =width/2-x;
    float yPos =height-y;
    pushStyle();
    fill(255, 0, 0);
    noStroke();
    ellipse(x, y, 5, 5);
    popStyle();
  }
}

void segmentBezier(int ax1, int ay1, int sx1, int sy1, int sx2, int sy2, int ax2, int ay2, int steps) {
  for (int i = 0; i <= steps; i++) {
    float t = i / float(steps);
    float x = bezierPoint(ax1, sx1, sx2, ax2, t);
    float y = bezierPoint( ay1, sy1, sy2, ay2, t);
    float xPos =width/2-x;
    float yPos =height-y;
    String cmd = "G1 X"+xPos+" Y"+yPos;
    commands.append(cmd);
  }
}



void keyPressed() {
  if (key == 'h') {
    goHome();
  }

  if (key=='p') {
    int xPos =width/2-mouseX;
    int yPos =height-mouseY;
    drawTo(xPos, yPos);
  }

  if (key=='s') {
    //segmentBezier(50);
    segmentBezier(width/2, height, width/2, height-200, width-200, height-200, width, height-200, 50);
  }

  if (key=='u') {
    penUp();
  }

  if (key=='d') {
    penDown();
  }

  if (key=='r') {
    rasterify();
  }
}

void moveTo(float posX, float posY) {
  if (!penIsUp)penUp();
  // remap coordinates
  posX=width/2-posX;
  posY=height-posY;

  String cmd = "G1 X"+posX+" Y"+posY;
  commands.append(cmd);
}

void drawTo(int posX, int posY) {
  if (penIsUp)penDown();

  // remap coordinates
  posX=width/2-posX;
  posY=height-posY;

  String cmd = "G1 X"+posX+" Y"+posY;
  commands.append(cmd);
  //penUp();
}

void penUp() {
  String cmd = "M1 100d";
  commands.append(cmd);
  penIsUp=true;
}

void penDown() {
  String cmd = "M1 60d";
  commands.append(cmd);
  penIsUp=false;
}

void goHome() {
  penUp();
  String cmd="G28";
  commands.append(cmd);
}





void sendFeed() {
  if (commands.size()>0) {
    println(commands.size()+" commands in buffer");
    String cmd = commands.get(0);
    println("command " +cmd);
    cmd+='\n';
    myPort.write(cmd);
    commands.remove(0);
    done=false;
  }
}


// This is where we read
void serialEvent(Serial p) {
  inString = (myPort.readStringUntil('\n'));
  inString=inString.trim();
  println("Incoming: "+inString);
  if (inString.equals("OK") == true) {
    done=true;
  } else {
  }
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup()) {
    println("got an event from group "
      +theEvent.getGroup().getName()
      +", isOpen? "+theEvent.getGroup().isOpen()
      );
  } else if (theEvent.isController()) {
    println("got something from a controller "
      +theEvent.getController().getName()
      );


    if (theEvent.getController().getName().equals("Pen Up")) {
      if (isConnected)penUp();
    }

    if (theEvent.getController().getName().equals("Pen Down")) {
      if (isConnected)penDown();
    }

    if (theEvent.getController().getName().equals("XPos")) {
      xOffset=int(theEvent.getController().getValue());
    }

    if (theEvent.getController().getName().equals("YPos")) {
      yOffset=int(theEvent.getController().getValue());
    }

    if (theEvent.getController().getName().equals("Scale")) {
      scale=theEvent.getController().getValue();
    }
  }
}