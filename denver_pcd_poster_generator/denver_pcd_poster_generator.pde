// press s to save 1 poster
// press d to save 10 posters (won't render between them and may take a second)

// Mode
int PIXELS = 0;
int INCHES = 1;
int runningMode = PIXELS;

// Variables for Size in Pixels
int widthPixels = 1000;
int heightPixels = 1000;

// Variables for Size in Inches
float widthInches = 8.5;
float heightInches = 11;
int dotsPerInch = 300;

PGraphics poster;

color bgColor;
color textColor;
ArrayList<Color> colors = new ArrayList<Color>();

int saveCounter = 0;
boolean posterGenerated = false;

String typePathHeavy = "Mont-HeavyDEMO.otf";
String typePathLight = "Mont-ExtraLightDEMO.otf";
int typeScale = 18;

// Speakers
PImage ari;
PImage joshua;

void setup() {
  size(500, 600);
  loadImages();
  //setColors();
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

void loadImages() {
  ari = loadImage("AriMelenciano.jpg");
  joshua = loadImage("JoshuaDavis.jpg");
}

void setType(int size, String typePath) {
  PFont temp = createFont(typePath, size);
  poster.textFont(temp);
}

void setColors(int numberOfColors) {
  colorMode(RGB, 255);
  bgColor = color(255);
  textColor = color(0);
  colorMode(HSB, 100);
  float hue = random(100);
  for (int i = 0; i < numberOfColors; i++) {
    colors.add(new Color(color(hue, 75, 90)));
    hue = (hue + random(30, 60)) % 100;
  }
}

void generatePoster() {
  setColors(int(random(2, 3)));
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
  posterCircles();
  posterText();
  poster.endDraw();
  posterGenerated = true;
}

void posterCircles() {
  PVector ariLocation = new PVector(random(poster.width/6, poster.width/2), 3*poster.height/8);
  PVector joshuaLocation = new PVector(random(poster.width/6, poster.width/2), 5*poster.height/8);
  float noiseXPosition = 0;
  noiseXPosition = randomCircles(
    250,
    new PVector(random(poster.width), random(poster.height)),
    ariLocation,
    noiseXPosition,
    poster.width/2
  );
  if (poster.width < poster.height) {
    ellipseImage(poster, ari, ariLocation);
    noiseXPosition = randomCircles(
      5,
      ariLocation,
      joshuaLocation,
      noiseXPosition,
      poster.width/4
    );
    ellipseImage(poster, joshua, joshuaLocation);
    noiseXPosition = randomCircles(
      5,
      joshuaLocation,
      new PVector(random(poster.width), random(poster.height)),
      noiseXPosition,
      poster.width/8
    );
    speakerType(ariLocation, (shortSide(poster) / 8), "Ari Melenciano", "Designer, DJ/VJ and", "Cofounder of Afrotechtopia");
    speakerType(joshuaLocation, (shortSide(poster) / 8), "Joshua Davis", "Generative Artwork for everything", "from Buildings to Concerts", "for Deadmau5 and Taylor Swift");
  } else {
    //speakerType(new PVector(poster.width/12, poster.height/2 - poster.height/typeScale * 1.5), 0, "Featuring Special Guests:");
    speakerType(new PVector(poster.width/12, poster.height/2), 0, "Ari Melenciano", "Designer, DJ/VJ and", "Cofounder of Afrotechtopia");
    speakerType(new PVector(poster.width/2, poster.height/2), 0, "Joshua Davis", "Generative Artwork for everything", "from Buildings to Concerts", "for Deadmau5 and Taylor Swift");
  }
}

float randomCircles(int numberOfCircles, PVector start, PVector end, float noiseStart, float maxSize) {
  float noiseScale = 0.045;
  int threshold = numberOfCircles/5;
  float previousX = 0;
  float previousY = 0;
  for (int i = 0; i <= numberOfCircles - 1; i++) {
    color baseColor = colors.get(int(random(colors.size()))).c;
    float x = map(noise(i * noiseScale + noiseStart, 0), .25, .75, 0, poster.width);
    float y = map(noise(i * noiseScale + noiseStart, 100), .25, .75, 0, poster.height);
    //float lerpFactor = abs(map(height - y/4, 0, height, 0, 1));
    //println("y = " + y + " lerp = " + lerpFactor);
    poster.fill(lerpColor(baseColor, bgColor, getLerpFactor(y, poster.height)));
    //poster.stroke(0);
    if (i < threshold) {
      x = lerp(start.x, x, i/float(threshold));
      y = lerp(start.y, y, i/float(threshold));
    } else if (i > numberOfCircles - (threshold + 1)) {
      x = lerp(x, end.x, (i - (numberOfCircles - threshold)) / float(threshold));
      y = lerp(y, end.y, (i - (numberOfCircles - threshold)) / float(threshold));
    }
    if (i <= 1) {
      previousX = x;
      previousY = y;
      continue;
    }
    float speed = abs(x - previousX) + abs(y - previousY);
    if (speed > maxSize) speed = maxSize;
    poster.ellipse(x, y, speed, speed);
    previousX = x;
    previousY = y;
  }
  return numberOfCircles * noiseScale + noiseStart;
}

float getLerpFactor(float y, int h) {
  if (y < h/2) {
    return map(y, 0, h/2, 1, 0);
  }
  return map(y, h/2, h, 0, 1);
}

void posterText() {
  int boarder = poster.width/12;
  int x, y;

  poster.fill(textColor);
  int typeSize;
  if (poster.height > poster.width) {
    typeSize = poster.width/typeScale;
  } else {
    typeSize = poster.height/typeScale;
  }

  // Title Section
  setType(typeSize, typePathHeavy);
  x = boarder;
  y = boarder;
  poster.textAlign(LEFT, TOP);
  poster.text("Processing Community Day", x, y);
  y += typeSize * 1.2;
  poster.text("in Denver", x, y);
  y += typeSize * 1.2;
  setType(typeSize, typePathLight);
  poster.text("at The Commons on Champa", x, y);
  y += typeSize * 1.2;
  poster.text("Febuary 9, 2019", x, y);

  // Bottom - reverse order
  typeSize = typeSize / 2;
  setType(typeSize, typePathHeavy);
  y = poster.height - boarder;
  poster.textAlign(LEFT, BOTTOM);
  poster.text("More Information at ProcessingDayDenver.org", x, y);
  y -= typeSize * 1.8;
  setType(typeSize, typePathLight);
  poster.text("for learning how to code within the context of the visual arts.", x, y);
  y -= typeSize * 1.2;
  poster.text("Processing is a flexible software sketchbook and a language", x, y);
  y -= typeSize * 1.8;
  poster.text("to celebrate and explore art, code and community!", x, y);
  y -= typeSize * 1.2;
  poster.text("An inclusive event that will bring together people of all ages", x, y);
  y -= typeSize * 1.2;
}

void speakerType(PVector location, int offset, String type, String... description) {
  int x = int(location.x + offset * 1.2);
  int y = int(location.y - offset * 0.9);
  poster.fill(textColor);
  int typeSize;
  if (poster.height > poster.width) {
    typeSize = poster.width/typeScale;
  } else {
    typeSize = poster.height/typeScale;
  }
  typeSize = typeSize / 4 * 3;
  if (description.length == 0) {
    setType(typeSize, typePathLight);
  } else {
    setType(typeSize, typePathHeavy);
  }
  poster.textAlign(LEFT, TOP);
  poster.text(type, x, y);
  y += typeSize * 1.2;
  typeSize = typeSize / 2;
  setType(typeSize, typePathHeavy);
  for (int i = 0; i < description.length; i++) {
    poster.text(description[i], x, y);
    y += typeSize * 1.2;
  }
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

int shortSide(PGraphics pg) {
  if (pg.width < pg.height) {
    return pg.width;
  }
  return pg.height;
}

void ellipseImage(PGraphics pg, PImage img, PVector location) {
  PImage temp = img.get();
  temp.resize(shortSide(pg)/4, shortSide(pg)/4);
  temp.mask(circleMask(temp.width, temp.height));
  pg.imageMode(CENTER);
  pg.tint(colors.get(int(random(colors.size()))).c);
  pg.image(temp, location.x, location.y);
  pg.noTint();
}

PGraphics circleMask(int w, int h) {
  PGraphics pg = createGraphics(w, h);
  pg.beginDraw();
  pg.background(0);
  pg.noStroke();
  pg.fill(255, 255);
  pg.ellipse(pg.width/2, pg.height/2, pg.width, pg.height);
  pg.endDraw();
  return pg;
}
