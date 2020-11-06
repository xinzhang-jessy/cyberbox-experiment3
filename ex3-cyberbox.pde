import ddf.minim.*;
import ddf.minim.signals.*;
import processing.serial.*; // import the Processing serial library
import processing.sound.*;
SoundFile file;
Serial myPort;              // The serial port
Minim minim;
AudioPlayer noise;

PImage comment1;
PImage comment2;
PImage comment3;
PImage balloon;
PImage pop;

int totalPins =12;
int pinValues[] = new int[totalPins];
int pinValuesPre[] = new int[totalPins];
int a0Value = 0;
int a0ValuePre = 0;
static final int FADE = 600;
PImage[] images = new PImage[3];
Boolean newComment = false;
Boolean balloonLarge = false;
Boolean popPlaying = false;
int balloonCount = 0;
Boolean poped = false;

class Comment {
  int x;
  int y;
  PImage img;
  
  // Contructor
Comment(int x, int y, int index) {
    this.x = x;
    this.y = y;
    print(index);
    this.img = images[index];
  }
}

ArrayList<Comment> comments = new ArrayList<Comment>();
 int balWidth = 100;
 int balHeight =180;

void setup(){
  size(1200,720);
  comment1 = loadImage("comment1.png");
  comment2 = loadImage("comment2.png");
  comment3 = loadImage("comment3.png");
  balloon =loadImage("balloon.png");
  pop =loadImage("pop.png");
  file = new SoundFile(this, "boom1.mp3");
  
  images[0] = comment1;
  images[1] = comment2;
  images[2] = comment3;
  comments.add(new Comment(100,200, 0));
  minim = new Minim(this);
  noise = minim.loadFile("talkingaudio.mp3");
  noise.loop();
  
  String portName = Serial.list()[6];
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');
}

void draw(){
  background(0);
  if (poped){
    drawPop();
  }else {
    drawDefault();
  }
}


void drawPop(){
  noise.pause();
  image(pop, 400,200, pop.width/2, pop.height/2);
  textSize(28);
  textAlign(CENTER);
  text("Press the spacebar to restart !", 600, 600);
  fill(255,255,255);

  if (!popPlaying){
    file.play();
    popPlaying = !popPlaying;
  }
}

void keyReleased(){
  if (key == ' ' && poped){
     poped = false;
     popPlaying = false;
     balWidth = 100;
     balHeight = 180;
  }
}


void drawDefault(){
int width =1200;
  int height = 720;
  int unit = 6; // width/height of cube
  
  // draw background cubes
  for (int i =0;i<=width;i+=unit*2){
    for (int j=0; j<=height; j+=unit*2){
      fill(64,106,17);
      noStroke();
      rect(i,j,unit, unit);
    }
  }
  
  // draw vertical divide line
  stroke(126,211,33);
  int count = width/(2*3*unit);
  line(count*unit*2-unit/2, 0, count*unit*2-unit/2,height);
  line(count*unit*4-unit/2, 0, count*unit*4-unit/2, height);
  
  // draw comment
  if (newComment){
    comments. add(new Comment(floor(random(240)),floor(random(750)), floor(random(3))));
    newComment = false;  
  }
  for (int i = 0; i< comments.size(); i++){
    Comment c = comments.get(i);
    image(c.img, c.x, c.y, c.img.width/2, c.img.height/2);
  }
  
  // draw noise columns
  int base = count*unit*2-unit/2;
  int noiseWidth = count*unit*2;
  int colWidth = 3;
  int cols = noiseWidth/colWidth;
  int sampleCount = noise.bufferSize()/cols;
  int magnifyRate = a0Value*120/1025; // rate for magnify
  if (magnifyRate < 1){
    magnifyRate = 1;
  };
  if (a0Value > a0ValuePre+10){
    noise.shiftGain(noise.getGain(),50,FADE);
  }else if (a0Value < a0ValuePre-10){
    noise.shiftGain(noise.getGain(),-50,FADE);
  } else{
    //ignore
  }
  
  for (int i = 0; i<cols; i++){
    float sum = 0;
    for (int j =i*sampleCount; j<(i+1)*sampleCount; j++){
      sum += noise.left.get(j)*100* magnifyRate;
    }
    int val = floor(sum/sampleCount);
    
    stroke(126,211,33);
    int barHeight = val;
    rect(base+i*colWidth, height/2-barHeight/2 , colWidth, barHeight);
  }
  
  //draw balloon
  if(balloonLarge){
    balloonCount +=1 ;
    balWidth = floor(balWidth*1.2); balHeight= floor(balHeight*1.2);
    balloonLarge = false;
    if (balloonCount >=4){
      poped = true;
      balloonCount = 0;
    }
  }
  
  image(balloon, 1000-balWidth/2, 360-balHeight/2, balWidth, balHeight);
}

void serialEvent(Serial myPort) {
  // read the serial buffer:
  String myString = myPort.readStringUntil('\n');
  if (myString != null) {
    // println(myString);
    myString = trim(myString);
    
    //store the message as a string array
    String tempData[] = split(myString,',');
    if (tempData.length<=1){
      return;
    }
    String source = tempData[0];
    //uncomment to see what the data looks like in the string array
    //printArray(tempData);
    // printArray(tempData);
    if (source.equals("A0")){
      a0ValuePre = a0Value;
      a0Value = int(tempData[1]);
      // print("recv A0:", a0Value);
      // println("");
    } else if (source.equals("Ada")) {
      for (int i=0;i<totalPins;i++){
        pinValuesPre[i] = pinValues[i];
      }
      for(int i=0;i<totalPins;i++)
      {
       pinValues[i]=int(tempData[i+1]); 
      }
      
      if (pinValues[7] == 1 && pinValuesPre[7] == 0){
        newComment = true;
        println("new comment:", pinValues[7]);
      }
      
      if (pinValues[1] ==1 && pinValuesPre[1] ==0){
        balloonLarge = true;
        println("balloon large:", pinValues[1]);
      }
      //print("recv PIN:");
      //printArray(pinValues);
      //println("");
    }  
  }


  
}
