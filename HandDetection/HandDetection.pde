import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;

PImage cursor, folder;

boolean isFirst = true;
Rectangle hand = new Rectangle();
Rectangle preHand = new Rectangle(0, 0, 0, 0);

int cursorX = 960, cursorY = 240;
int folderBaseX = 660, folderBaseY = 20;
int nameBaseX = 680, nameBaseY = 75;

boolean[][] folderStates = new boolean[9][6];
String[][] names = new String[9][6];

void setup() {
  size(1280, 480);
  video = new Capture(this, 640, 480);
  opencv = new OpenCV(this, 640, 480);
  opencv.loadCascade("aGest.xml");
  
  cursor = loadImage("cursor.png");
  folder = loadImage("folder.png");
  
  //Initialize
  folderStates[0][0] = true;
  names[0][0] = "folder_0";
  folderStates[1][0] = true;
  names[1][0] = "Copy of folder_0";
  folderStates[2][0] = true;
  names[2][0] = "folder_2";
  folderStates[3][0] = true;
  names[3][0] = "folder_3";

  video.start();
}

void draw() {
  background(176, 190, 197);
  
  opencv.loadImage(video);
  
  tint(255, 255, 255);
  
  image(video, 0, 0 );

  noFill();
  stroke(0, 255, 0);
  strokeWeight(3);
  Rectangle[] hands = opencv.detect();
  //println(faces.length);
  

  float area = 0f;
  hand = null;

  for (int i = 0; i < hands.length; i++) {
    //println(hands[i].x + "," + hands[i].y);
    if (hands[i].width * hands[i].height > area) {
      area = hands[i].width * hands[i].height;
      hand = hands[i];
    } 
  }
  
  int dx = 0, dy = 0;
  //if dx and dy too large, throw it!
  if (hand != null) {
    rect(hand.x, hand.y, hand.width, hand.height);
    dx = hand.x - preHand.x;
    dy = hand.y - preHand.y;
    
    if (abs(dx) <= 20 && abs(dy) <= 20) {
      cursorX += 2 * dx;
      cursorY += 2 * dy;
      
      if (cursorX < 640) cursorX = 640;
      if (cursorX > 1268) cursorX = 1268;
      if (cursorY < 0) cursorY = 0;
      if (cursorY > 460) cursorY = 460;
    }
    
    
    println(dx);
    println(dy);
    println();
    
    preHand = hand;
  }
  
  
  
  
  //tint(0, 153, 204, 126);
  
  textSize(10);  
  textAlign(CENTER);
  for (int i = 0; i < 9; i++)
    for (int j = 0; j < 6; j++) {
      if (folderStates[i][j]) {
        Rectangle currentFolder = new Rectangle(folderBaseX + 70 * i, folderBaseY + 70 * j, 48, 48);
        if (currentFolder.contains(cursorX, cursorY))
          tint(0, 153, 204, 126);
        image(folder, folderBaseX + 70 * i, folderBaseY + 70 * j);
        text(names[i][j], nameBaseX + 70 * i, nameBaseY + 70 * j);
        noTint();
      }
    }
    
  image(cursor, cursorX, cursorY);
  
}

void captureEvent(Capture c) {
  c.read();
}

