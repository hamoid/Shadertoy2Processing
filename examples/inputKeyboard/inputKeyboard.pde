// https://www.shadertoy.com/view/Xds3Rr

import processing.sound.*;

PImage keyboardTexture;

PShader myShader;

// uniform float     iChannelTime[4];       // channel playback time (in seconds)
// uniform vec3      iChannelResolution[4]; // channel resolution (in pixels)

// uniform samplerXX iChannel0..3;          // input channel. XX = 2D/Cube

float previousTime = 0.0;

boolean mouseDragged = false;

PVector lastMousePosition;
float mouseClickState = 0.0;

void setup() {
  size(640, 360, P2D);

  keyboardTexture = createImage(256, 1, ARGB);

  // Load the shader file from the "data" folder
  myShader = loadShader("input_keyboard.glsl");

  // We assume the dimension of the window will not change over time,
  // therefore we can pass its values in the setup() function
  myShader.set("iResolution", float(width), float(height), 0.0);

  lastMousePosition = new PVector(float(mouseX), float(mouseY));
}


void draw() {
  myShader.set("iResolution", float(width), float(height), 0.0);

  myShader.set("iChannel0", keyboardTexture);

  // shader playback time (in seconds)
  float currentTime = millis()/1000.0;
  myShader.set("iTime", currentTime);

  // render time (in seconds)
  float timeDelta = currentTime - previousTime;
  previousTime = currentTime;
  myShader.set("iDeltaTime", timeDelta);

  // shader playback frame
  myShader.set("iFrame", frameCount);

  // mouse pixel coords. xy: current (if MLB down), zw: click
  if (mousePressed) {
    lastMousePosition.set(float(mouseX), float(mouseY));
    mouseClickState = 1.0;
  } else {
    mouseClickState = 0.0;
  }
  myShader.set( "iMouse", lastMousePosition.x, lastMousePosition.y, mouseClickState, mouseClickState);

  // Set the date
  // Note that iDate.y and iDate.z contain month-1 and day-1 respectively,
  // while x does contain the year (see: https://www.shadertoy.com/view/ldKGRR)
  float timeInSeconds = hour()*3600 + minute()*60 + second();
  myShader.set("iDate", year(), month()-1, day()-1, timeInSeconds );

  // This uniform is undocumented so I have no idea what the range is
  myShader.set("iFrameRate", frameRate);

  // Apply the specified shader to any geometry drawn from this point
  shader(myShader);

  // Draw the output of the shader onto a rectangle that covers the whole viewport.
  rect(0, 0, width, height);
  line(0, 0, width, height);
  resetShader();

  //image(audioDataTexture,0,0,width,height);
}

void keyPressed(KeyEvent ev) {
  keyboardTexture.loadPixels();
  keyboardTexture.pixels[ev.getKey() == CODED ? ev.getKeyCode() : ev.getKey()] = 0xFFFFFF;
  keyboardTexture.updatePixels();
}

void keyReleased(KeyEvent ev) {
  keyboardTexture.loadPixels();
  keyboardTexture.pixels[ev.getKey() == CODED ? ev.getKeyCode() : ev.getKey()] = 0;
  keyboardTexture.updatePixels();
}
