import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;

PImage cursorImg, folderImg;

Rectangle hand = new Rectangle();
Rectangle preHand = new Rectangle(0, 0, 0, 0);

int cursorX = 960, cursorY = 240;
int folderBaseX = 660, folderBaseY = 20;
int nameBaseX = 705, nameBaseY = 120;

int imgWidth = 96, imgHeight = 96, collisionWidth = 60, collisionHeight = 80;

int folderIndex = 3;

ArrayList<Folder> folders = new ArrayList();

public class Folder {
  
  public boolean locked = false;
  public boolean overFolder = false;
  public String folderName;
  public Rectangle folderRect;
  public Rectangle collisionRect;
  
  public int xOffset;
  public int yOffset;
  
  public Folder(Rectangle folderRect) {
    folderIndex++;
    this.folderName = "Folder_" + folderIndex;
    this.folderRect = folderRect;
  }
  
  public Folder(String folderName, Rectangle folderRect) {
    this.folderName = folderName;
    this.folderRect = folderRect;
  }
  
  public Rectangle getCollisionRect() {
    return new Rectangle(folderRect.x, folderRect.y, collisionWidth, collisionHeight);
  }
  
  public void update() {
    
    if (folderRect.contains(mouseX, mouseY)) {
      overFolder = true;
      tint(0, 153, 204, 126);
    } else {
      overFolder = false;
    }
  }
  
  public void updatePressed() {
    if (overFolder) {
      locked = true;
    } else {
      locked = false;
    }
    xOffset = mouseX - folderRect.x;
    yOffset = mouseY - folderRect.y;
  }
  
  public void updateDragged() {
    if (locked) {
      folderRect.x = mouseX - xOffset;
      folderRect.y = mouseY - yOffset;
    }
  }
  
  public void updateReleased() {
    locked = false;
  }
  
  public void draw() {
    image(folderImg, folderRect.x, folderRect.y, folderRect.width, folderRect.height);
    text(folderName, folderRect.x+45, folderRect.y+100);
    noTint();
  }
}

void setup() {
  size(1280, 480);
  video = new Capture(this, 640, 480);
  opencv = new OpenCV(this, 640, 480);
  opencv.loadCascade("aGest.xml");
  
  textSize(10);  
  textAlign(CENTER);
  
  cursorImg = loadImage("cursor.png");
  folderImg = loadImage("folder.png");
  
  //Initialize
  Folder folder = new Folder("Folder_1", new Rectangle(650, 20, 96, 96));
  folders.add(folder);
  folder = new Folder("Folder_2", new Rectangle(740, 20, 96, 96));
  folders.add(folder);
  folder = new Folder("Folder_3", new Rectangle(830, 20, 96, 96));
  folders.add(folder);
  folder = new Folder("Folder_4", new Rectangle(920, 20, 96, 96));
  folders.add(folder);
  
  
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
  

  //detect hand
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
    
    //println(dx);
    //println(dy);
    //println();
    
    preHand = hand;
  }
  
  for (Folder folder:folders) {
    folder.update();
    folder.draw();
  }
  
  //image(cursorImg, cursorX, cursorY);
  
}

void keyPressed() {
  
  //Move
  if (key == 'm')
    for (Folder folder:folders) folder.updatePressed();
    
  //Create
  if (key == 'n') {
    for (int j = 0; j < 4; j++)
      for (int i = 0; i < 7; i++) {
        Rectangle tempRect = new Rectangle(650+90*i, 20+110*j, 96, 96);
        Folder newFolder = new Folder(tempRect);
        boolean isIntersects = false;
        for (Folder folder:folders)
          if (newFolder.getCollisionRect().intersects(folder.getCollisionRect())) {
            //println();
            //println(tempRect.x);
            //println(tempRect.y);
            //println(folder.getCollisionRect().x);
            //println(folder.getCollisionRect().y);
            isIntersects = true;
            break;
          }
          
        if (!isIntersects) {
          folders.add(newFolder);
          return;
        }
      }
      
    println("Create folder failed!");
  }
  
  //Copy
  if (key == 'c') {
    
    
  }
  
  //Delete
  if (key == 'd') {
    for (int i = folders.size() - 1; i >= 0; i--) {
      if (folders.get(i).overFolder)
        folders.remove(i);
    }
  }
}

void keyReleased() {
  if (key == 'm')
    for (Folder folder:folders) folder.updateReleased();
}

//For Move Only
void mouseMoved() {
  for (Folder folder:folders) folder.updateDragged();
} 

void captureEvent(Capture c) {
  c.read();
}

