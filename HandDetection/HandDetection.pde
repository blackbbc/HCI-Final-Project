import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.lang.*;

Capture video;
OpenCV opencv;

PImage cursorImg, folderImg;

Rectangle hand = new Rectangle();
Rectangle preHand = new Rectangle(0, 0, 0, 0);
Rectangle camera = new Rectangle(0, 0, 640, 480);

int cursorX = 960, cursorY = 240;
int folderBaseX = 660, folderBaseY = 20;
int nameBaseX = 705, nameBaseY = 120;

int imgWidth = 96, imgHeight = 96, collisionWidth = 60, collisionHeight = 80;

int folderIndex = 5;

ArrayList<Folder> folders = new ArrayList();

boolean mouseLocked = false;

public class Folder {
  
  public boolean locked = false;
  public boolean overFolder = false;
  public String folderName;
  public Rectangle legalRect;
  public Rectangle folderRect;
  
  public int xOffset;
  public int yOffset;
  
  public Folder(Rectangle folderRect) {
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
    if (folderRect.contains(cursorX, cursorY)) {
      overFolder = true;
      tint(0, 153, 204, 126);
    } else {
      overFolder = false;
    }
  }
  
  public void updatePressed() {
    if (overFolder) {
      if (!mouseLocked) {
        locked = true;
        mouseLocked = true;
      }
    } else {
      if (locked)
        mouseLocked = false;
      locked = false;
    }
    xOffset = cursorX - folderRect.x;
    yOffset = cursorY - folderRect.y;
  }
  
  public void updateDragged() {
    if (locked) {
      folderRect.x = cursorX - xOffset;
      folderRect.y = cursorY - yOffset;
      //Update legalRect
      
//      if (this.getCollisionRect().intersects(camera))
//        return;
        
      if (this.getCollisionRect().x < 640 || this.getCollisionRect().x+this.getCollisionRect().width > 1280 || this.getCollisionRect().y < 0 || this.getCollisionRect().y+this.getCollisionRect().height>480)
        return;
      
      for (Folder folder:folders)
        if (this != folder)
          if (this.getCollisionRect().intersects(folder.getCollisionRect()))
            return;
      //println("Get legal rectangle");
      this.legalRect = new Rectangle(this.folderRect);
    }
  }
  
  public void updateReleased() {
    locked = false;
    mouseLocked = false;
    
    if (this.legalRect != null)
      this.folderRect = new Rectangle(this.legalRect);
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
  
  textSize(9);  
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
    
    double dis = Math.sqrt(dx*dx + dy*dy);
    
    if (dis >= 5.0 && dis <= 50.0) {
      cursorX += 2 * dx;
      cursorY += 2 * dy;
      
      if (cursorX < 640) cursorX = 640;
      if (cursorX > 1268) cursorX = 1268;
      if (cursorY < 0) cursorY = 0;
      if (cursorY > 460) cursorY = 460;
    }
    
//    println(dis);
//    println(dx);
//    println(dy);
//    println();
    
    preHand = hand;
  }
  
  for (Folder folder:folders) {
    folder.updateDragged();
    folder.update();
    folder.draw();
  }
  
  image(cursorImg, cursorX, cursorY);
  
}

void createFolder(String folderName) {
  for (int j = 0; j < 4; j++)
    for (int i = 0; i < 7; i++) {
      Rectangle tempRect = new Rectangle(650+90*i, 20+110*j, 96, 96);
      
      Folder newFolder;
      if (folderName.equals(""))
        newFolder = new Folder(tempRect);
      else
        newFolder = new Folder(folderName, tempRect);

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
        if (folderName.equals(""))
          folderIndex++;
        folders.add(newFolder);
        return;
      }
    }
    
  println("Create folder failed!");
}

String solveName(String originName) {
  //To do
  String folderName;
  String regex;
  Pattern pattern;
  Matcher matcher;
  int index = 0, tempIndex;
  
  if (originName.indexOf("Copy") < 0) {
    folderName = originName;
  } else {
    regex = "Copy of ([a-zA-Z]+_\\d+)";
    pattern = Pattern.compile(regex);
    matcher = pattern.matcher(originName);
    matcher.find();
    folderName = matcher.group(1);
  }
  
  //println(folderName);
  
  regex = "Copy of " + folderName + "\\((\\d+)\\)";
  pattern = Pattern.compile(regex);
  
  //println(regex);
  
  for (Folder folder:folders) {
   matcher = pattern.matcher(folder. folderName);
   if (folder.folderName.indexOf("Copy of "+folderName) >= 0)
     index = 1 > index? 1: index;
   if (matcher.find()) {
     tempIndex = Integer.parseInt(matcher.group(1));
   } else {
     tempIndex = 0;
   }
   index = tempIndex > index? tempIndex: index;
  }
  
  index ++;
  if (index == 1)
    return "Copy of " + folderName;
  else
    return "Copy of " + folderName + "(" + index + ")";
  
}

void keyPressed() {
  
  //Move
  if (key == 'm')
    for (Folder folder:folders) folder.updatePressed();
    
  //Create
  if (key == 'n') {
    createFolder("");
  }
  
  //Copy
  if (key == 'c') {
    for (int i = folders.size() - 1; i>=0; i--)
      if (folders.get(i).overFolder) {
        String newFolderName = solveName(folders.get(i).folderName);
        createFolder(newFolderName);
      }
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

//DEBUG MODE
//For Move Only
//void mouseMoved() {
//  for (Folder folder:folders) folder.updateDragged();
//}


void captureEvent(Capture c) {
  c.read();
}

