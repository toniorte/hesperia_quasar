/*###########################################################################
# Light curves animation generation for a mockup application                #
# Exoplanet                                                                 #
# Hesperia Cluster team, at Madrid NASA Space Apps Challenge - 2022         #
#############################################################################*/

import processing.sound.*;
SoundFile file;

int rad = 35;        // Width of the star circle
float xpos, ypos;
Table table, table2;
float flux[] = new float[100000];
float time[] = new float[100000];
float flux2[] = new float[100000];
float time2[] = new float[100000];
int fluxval; int phase; int phase_step;
float period_data; String period_data_unit;

// Run once
void setup() {
  size(640, 360); ellipseMode(RADIUS);
  frameRate(30);  // 30 fps

  // Circle star, top center position
  xpos = width/2; ypos = height/4;
  // Starting time
  phase = 0;
  
  // Load CSV files of TRAPPIST-1
  table = loadTable("exoplanet_TRAPPITS1.csv", "header");
  time = table.getFloatColumn("time");
  flux = table.getFloatColumn("flux");
  table2 = loadTable("exoplanet_TRAPPITS1_model.csv", "header");
  time2 = table2.getFloatColumn("time");
  flux2 = table2.getFloatColumn("flux");
  // Load audio file of TRAPPIST-1
  file = new SoundFile(this, "exoplanet_TRAPPITS1.wav");
  
  // Make the curve last 5 seconds (vector_len/fps/time)
  phase_step = time.length/30/5;
  
  // This should be read from file
  period_data = 1.51;
  period_data_unit = "days";

  // Play sound, wait for it to start (circa 300 ms)
  file.play();
  delay(650);
}

// Function that converts normalised flux to y-coord on the canvas chart
int mapflux(float flux) {
  return int((height-30)-flux*(height/2-30));
}

// Function that converts normalised time to x-coord on the canvas chart
int maptime(float times) {
  return int(30+times*((width-30)-30));
}

// Loop
void draw() {
  background(0); fill(255); stroke(255);
  // Paint axes
  strokeWeight(4);
  line(30, height-30, width-30, height-30);
  line(30, height-30, 30, height/2);
  
  // Write chart text (labels and period)
  strokeWeight(1); textSize(18);
  text("Time", width-30-20, height-10);
  text("Brightness", 30-3, height/2-15); 
  textSize(15);
  text(str(period_data), width-30-20, height-50);
  text(period_data_unit, width-30-20, height-38);
  line(width-30, height-70, width-30, height-80);
  
  // Plot light curve
  for (int i = 0; i < time.length; i++) {
    point(maptime(time[i]), mapflux(flux[i]));
  }
  
  // Draw moving point over light curve (take model)
  noStroke(); fill(255);
  circle(maptime(time2[phase]), mapflux(flux2[phase]), 5);
  
  // Draw star circle
  // Compute alpha value for the moment (phase) (take model)
  fluxval = int(flux2[phase]*255+100);
  // Draw circle with alpha (colour: reddish)
  // Colour (spectral type) should be read from file
  fill(206, 41, 41, fluxval);
  ellipse(xpos, ypos, rad, rad);
  // Increase time for next frame, loop the curve
  phase = phase + phase_step;
  if (phase>=flux.length) phase = 0;
  if (phase==0) file.play();
}
