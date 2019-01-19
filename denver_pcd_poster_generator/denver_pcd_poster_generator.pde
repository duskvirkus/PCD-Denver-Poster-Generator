// press s to save 1 poster
// press d to save 10 posters (won't render between them and may take a second)

// Mode
int PIXELS = 0;
int INCHES = 1;
int runningMode = INCHES;

// Variables for Size in Pixels
int widthPixels = 1920;
int heightPixels = 1080;

// Variables for Size in Inches
float widthInches = 11;
float heightInches = 17;
int dotsPerInch = 300;

int typeScale = 15;

PGraphics poster;

color bgColor;
color textColor;
ArrayList<Color> colors = new ArrayList<Color>();

int saveCounter = 0;
boolean posterGenerated = false;

ArrayList<PFont> swagger = new ArrayList<PFont>();

void setup() {
  size(500, 600);
  setColors();
  generatePoster();
}

void draw() {
  if (posterGenerated) {
    showPoster();
    posterGenerated = false;
  }
}

void keyPressed() {
  if (key == 's') {
    savePoster();
  }
  if (key == 'd') {
    for (int i = 0; i < 10; i++) {
      savePoster();
    }
  }
}

void savePoster() {
  poster.save("export/PCD-Denver-Poster-" + getPosterDimensions() + "-" + saveCounter + ".png");
  saveCounter++;
  generatePoster();
}

String getPosterDimensions() {
  if (runningMode == INCHES) {
    return widthInches + "by" + heightInches + "inches";
  } else if (runningMode == PIXELS) {
    return widthPixels + "by" + heightPixels + "px";
  }
  return "DimensionsUnknown";
}

void swaggerFont(int size) {
  for (PFont f : swagger) {
    if (f.getSize() == size) {
      poster.textFont(f);
      return;
    }
  }
  PFont temp = createFont("Swagger.ttf", size);
  poster.textFont(temp);
  swagger.add(temp);
}

void setColors() {
  bgColor = color(180, 200, 230);
  textColor = color(0);
  colors.add(new Color(color(255, 85, 85))); // redish pink
  colors.add(new Color(color(245, 225, 65))); // yellow
  colors.add(new Color(color(90, 130, 240))); // blue
  colors.add(new Color(color(195, 75, 160))); // purple
}

void generatePoster() {
  if (runningMode == PIXELS) {
    poster = createGraphics(widthPixels, heightPixels);
  } else if (runningMode == INCHES) {
    poster = createGraphics(int(widthInches * dotsPerInch), int(heightInches * dotsPerInch));
  } else {
    println("Error runningMode " + runningMode + " not supported!");
  }
  noiseSeed((long)random(Integer.MAX_VALUE));
  poster.beginDraw();
  poster.background(bgColor);
  poster.noStroke();
  randomCircles(250);
  posterText();
  poster.endDraw();
  posterGenerated = true;
}

void randomCircles(int numberOfCircles) {
  float previousX = 0;
  float previousY = 0;
  for (int i = 0; i <= numberOfCircles; i++) {
    poster.fill(colors.get(int(random(colors.size()))).c);
    float x = map(noise(i * 0.045, 0), .25, .75, 0, poster.width);
    float y = map(noise(i * 0.045, 100), .25, .75, 0, poster.height);
    if (i == 0) {
      previousX = x;
      previousY = y;
      continue;
    }
    float speed = abs(x - previousX) + abs(y - previousY);
    poster.ellipse(x, y, speed, speed);
    previousX = x;
    previousY = y;
  }
}

void posterText() {
  int boarder = poster.width/12;
  int x, y;
  
  poster.fill(textColor);
  int typeSize;
  if (poster.height > poster.width) {
    typeSize = poster.width/typeScale;
  } else {
    typeSize = poster.width/(typeScale * 2);
  }
  
  // Title Section
  swaggerFont(typeSize);
  x = boarder;
  y = boarder;
  poster.textAlign(LEFT, TOP);
  poster.text("Processing Community Day", x, y);
  y += typeSize * 1.2;
  poster.text("in Denver", x, y);
  y += typeSize * 1.2;
  typeSize = typeSize / 16 * 13;
  swaggerFont(typeSize);
  poster.text("at The Commons on Champa", x, y);
  y += typeSize * 1.2;
  poster.text("Febuary 9, 2019", x, y);
  
  // Bottom - reverse order
  typeSize = typeSize / 16 * 13;
  swaggerFont(typeSize);
  y = poster.height - boarder;
  poster.textAlign(LEFT, BOTTOM);
  poster.text("More Information at ProcessingDayDenver.org", x, y);
  y -= typeSize * 1.8;
  typeSize = typeSize / 16 * 13;
  swaggerFont(typeSize);
  poster.text("for learning how to code within the context of the visual arts.", x, y);
  y -= typeSize * 1.2;
  poster.text("Processing is a flexible software sketchbook and a language", x, y);
  y -= typeSize * 1.8;
  poster.text("to celebrate and explore art, code and community!", x, y);
  y -= typeSize * 1.2;
  poster.text("An inclusive event that will bring together people of all ages", x, y);
  y -= typeSize * 1.2;
  
}

float calculateHeight(PImage img, float currentWidth) {
  float ratio = img.height/float(img.width);
  return currentWidth * ratio;
}

void showPoster() {
  int scale = 1;
  while (poster.width/scale > width || poster.height/scale > height) {
    scale++;
  }
  image(poster, 0, 0, poster.width/scale, poster.height/scale);
}
