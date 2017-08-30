// the image to asciify
PImage img;

// sampling resolution: colors will be sampled every n pixels 
// to determine which character to display
int resolutionX = 20;
int resolutionY = 20;

int step=2;
int threshold=250;




void setup() {
  img = loadImage("image.jpg");
  size(1000, 1000);
  background(255);
  fill(0);
  noStroke();
  rasterify();
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

    for (int x = 0; x < img.width-resolutionX; x += resolutionX) {
      //Get the colorvalue
      color pix = img.get(x+resolutionX/2, y+resolutionY/2);
      float brightness=brightness(pix);
      if (x==0)println(brightness);
      brightness=constrain(brightness, 0, threshold);

      // 
      float dil=map(brightness, 0, threshold, resolutionY/2, 0);
      float steps=map(brightness, 0, threshold, resolutionX/2, 1);
      float stepsize=resolutionX/steps;

      println("steps "+steps+" "+stepsize);

      float lastX=x;
      for (float i=stepsize; i<=resolutionX; i+=stepsize) {
        println("i "+i);
        stroke(0, 0, 255);
        line(lastX, lastY, x+i, y+dil);
        lastX=x+i;
        lastY=y+dil;
        dil*=-1;
      }

      // close Gaps 
      if (lastX<x+resolutionX) {
       // ellipse(lastX, y, 5, 5);
        line(lastX, lastY, x+resolutionX, y+dil);
        lastY=y+dil;

      }

      //stroke(0,255,255);

      // line(lastX, lastY, x+resolutionX, y+dil);


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
      /*for (int s1 = step; s1 <= resolutionX; s1 +=step) {
       line(xoff, lastY, bx+s1, y+dil);
       xoff=bx+s1;
       lastY=y+dil;
       dil*=-1;
       }*/
      bx=x;
    }
  }
}