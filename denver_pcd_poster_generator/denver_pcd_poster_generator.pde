// press s to save 1 poster
// press d to save 10 posters (won't render between them and may take a second)

float exportWidth = 11; // inches
float exportHeight = 17; // inches
int exportDPI = 300; // dots per inch
PGraphics poster;

color bgColor;
ArrayList<Color> colors = new ArrayList<Color>();

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
  colors.add(new Color(color(232, 146, 146)));
  colors.add(new Color(color(255, 110, 74)));
  colors.add(new Color(color(242, 187, 75)));
  colors.add(new Color(color(96, 168, 60)));
  colors.add(new Color(color(103, 178, 199)));
  colors.add(new Color(color(192, 68, 150)));
}

void generatePoster() {
  poster = createGraphics(int(exportWidth * exportDPI), int(exportHeight * exportDPI));
  noiseSeed((long)random(Integer.MAX_VALUE));
  poster.beginDraw();
  poster.background(bgColor);
  poster.noStroke();
  randomCircles(250);
  addImagesToPoster();
  poster.endDraw();
  posterGenerated = true;
}

void randomCircles(int numberOfCircles) {
  float previousX = 0;
  float previousY = 0;
  for (int i = 0; i <= numberOfCircles; i++) {
    poster.fill(colors.get(int(random(colors.size()))).c);
    float x = map(noise(i * 0.05, 0), .25, .75, 0, poster.width);
    float y = map(noise(i * 0.05, 100), .25, .75, 0, poster.height);
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
