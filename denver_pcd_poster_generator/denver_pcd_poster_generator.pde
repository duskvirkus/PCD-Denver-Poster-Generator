// press s to save 1 poster
// press d to save 10 posters (won't render between them and may take a second)

float exportWidth = 8.5; // inches
float exportHeight = 11; // inches
int exportDPI = 300; // dots per inch
PGraphics poster;

color bgColor;


PImage pcdText;
PImage pcdInfo;

int saveCounter = 0;
boolean posterGenerated = false;

void setup() {
  size(500, 600);
  loadImages();
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
  poster.save("export/PCD-Denver-Poster-" + exportWidth + "-" + exportHeight + "-" + saveCounter + ".png");
  saveCounter++;
  generatePoster();
}

void loadImages() {
  pcdText = loadImage("pcdtext.png");
  pcdInfo = loadImage("pcdinfo.png");
}

void setColors() {
  bgColor = color(48, 73, 89);
  primaryColor = color(80, 128, 132);
  secondaryColor = color(184, 219, 202);
}

void generatePoster() {
  poster = createGraphics(int(exportWidth * exportDPI), int(exportHeight * exportDPI));
  noiseSeed((long)random(Integer.MAX_VALUE));
  poster.beginDraw();
  poster.background(bgColor);
  poster.fill(primaryColor);
  poster.stroke(secondaryColor);
  randomCircles(300);
  addImagesToPoster();
  poster.endDraw();
  posterGenerated = true;
}

void randomCircles(int numberOfCircles) {
  float previousX = 0;
  float previousY = 0;
  for (int i = 0; i <= numberOfCircles; i++) {
    float x = map(noise(i * 0.05, 0), .25, .75, 0, poster.width);
    float y = map(noise(i * 0.05, 100), .25, .75, 0, poster.height);
    if (i == 0) {
      previousX = x;
      previousY = y;
      continue;
    }
    float speed = abs(x - previousX) + abs(y - previousY);
    poster.strokeWeight(speed / 100);
    poster.ellipse(x, y, speed, speed);
    previousX = x;
    previousY = y;
  }
}

void addImagesToPoster() {
  int offset = 100;
  float pcdTextWidth = 2*poster.width/3;
  float pcdTextHeight = calculateHeight(pcdText, pcdTextWidth);
  poster.image(pcdText, offset, offset, pcdTextWidth, pcdTextHeight);
  float pcdInfoWidth = 2*poster.width/3;
  float pcdInfoHeight = calculateHeight(pcdInfo, pcdInfoWidth);
  poster.image(pcdInfo, offset, poster.height - (pcdInfoHeight + offset), pcdInfoWidth, pcdInfoHeight);
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
