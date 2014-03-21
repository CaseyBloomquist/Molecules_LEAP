//Import libraries
import com.onformative.leap.*;
import com.leapmotion.leap.*;
import com.leapmotion.leap.SwipeGesture;
import com.leapmotion.leap.Gesture.State;
import com.leapmotion.leap.Gesture.Type;
import com.leapmotion.leap.Hand;

// LEAP Setup
LeapMotionP5 leap;

int numMol = 1000;
ArrayList<Molecule> molecules;
ArrayList<Hand> handList;
ArrayList<Finger> fingerList;
PVector swipeAccel;

void setup() {
  size(1280, 720);
  //background(0); - paint mode
  leap = new LeapMotionP5(this);
  enableGesture();
  swipeAccel = new PVector(0, 0);
  //translate(width/2, height/2);
  //Init molecules
  molecules = new ArrayList<Molecule>();
  for (int i = 0; i < numMol; i++) {
    molecules.add(new Molecule());
  }
}

void draw() {
  background(0);
  //translate(width/2, height/2);
  handList = leap.getHandList();
  fingerList = leap.getFingerList();
  PVector handPos = leap.getPosition(leap.getHand(0));
  float handSize = leap.getSphereRadius(leap.getHand(0));

  for (int i = 0; i < molecules.size()-1; i++) {
    Molecule m = molecules.get(i);

    // NO HANDS, NO FORCE
    if (handList.size() < 1) {
      PVector f = new PVector(0, 0);
      m.applyForce(f);
    }

    //FREEZE: TWO HANDS
    if (handList.size() == 2) {
      m.freeze();
    }

    //GRAV ATTRACTOR: TWO FINGERS
    if (fingerList.size() == 2) {
      PVector f = m.attract(handPos);
      m.applyForce(f);
    }
    
    //CENTER ATTRACTOR: 1 FINGER + DEPTH
    if (fingerList.size() == 1 && handPos.z < -100) {
      m.poke();
    }

    //SPREAD MOLECULES: FULL HAND
    if (fingerList.size() > 4 && handSize > 130) {
      PVector f = m.flee();
      m.applyForce(f);
    }

    m.update(swipeAccel); //NEEDS WORK
    m.move();
    m.display();
    m.checkEdges(); //THINK ABOUT MOVING THIS, MAKES SENSE AT END?
  }
  swipeAccel = new PVector(0, 0);
}

public void swipeGestureRecognized(SwipeGesture gesture) {
  if (gesture.state() == State.STATE_STOP) {
    PVector direction = leap.vectorToPVector(gesture.direction());
    PVector swipeDir = new PVector(direction.x - 400, direction.y-800);
    swipeDir.normalize();
    swipeAccel = swipeDir.get();
    swipeAccel.mult(gesture.speed()/60);
  } 
  else if (gesture.state() == State.STATE_START) {
    //swipeAccel = new PVector(0,0);
  } 
  else if (gesture.state() == State.STATE_UPDATE) {
    //swipeAccel = new PVector(0,0);
  }
}



void enableGesture() {
  //leap.enableGesture(Type.TYPE_SCREEN_TAP);
  //leap.enableGesture(Type.TYPE_CIRCLE);
  leap.enableGesture(Type.TYPE_SWIPE);
  //leap.enableGesture(Type.TYPE_KEY_TAP);
}

public void stop() {
  leap.stop();
}

