// Molecule Class

class Molecule {

  color c;
  int radius;
  PVector position;
  PVector velocity;
  PVector acceleration;
  float wallFriction = 1; // 1 = no friction, 0 = total friction
  float G = 10;

  Molecule() {
    c = color(random(50, 255));
    radius = int(random(5, 10));
    position = new PVector(random(20, width-20), random(20, height-20));
    velocity = new PVector(random(-3, 3), random(-3, 3));
    //velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
  }

  void display() {
    noStroke();
    fill(c);
    ellipse(position.x, position.y, 2*radius, 2*radius);
  }

  void applyForce(PVector force) {
    PVector f = force.get();
    f.div(radius);
    acceleration.add(f);
  }

  void move() {
    velocity.add(acceleration);
    position.add(velocity);
    acceleration.mult(0);
  }

  void checkEdges() {
    // Boundary conditions @ walls
    if ((position.x < radius) || (position.x > width - radius)) {
      velocity.x *= -1;
      velocity.mult(wallFriction);
    }
    if ((position.y < radius) || (position.y > height - radius)) {
      velocity.y *= -1;
      velocity.mult(wallFriction);
    }
  }

  void update(PVector swipeAccel) {
    acceleration.add(swipeAccel);
  }

  // GENERAL ATTRACTION
  PVector attract(PVector handPos) {
    PVector force = PVector.sub(handPos, position);
    float distance = force.mag();
    distance = constrain(distance, 10, 50);
    force.normalize();
    float strength = (G * radius) / (distance);
    force.mult(strength);
    return force;
  }

  //RAPID CENTER ATTRACTION
  void poke() {
    PVector center = new PVector(width/2, height/2);
    PVector direction = PVector.sub(center, position);
    float distance = direction.mag();
    direction.normalize();
    float strength = 0.01 * distance;
    direction.mult(strength);
    velocity = direction.get();
  }  

  //FLEE
  PVector flee() {
    PVector center = new PVector(width/2, height/2);
    PVector direction = PVector.sub(position, center);
    float distance = direction.mag();
    direction.normalize();
    float strength = 0.001 * distance;
    direction.mult(strength);
    acceleration = direction.get();
    return acceleration;
  }  

  //Freeze
  void freeze() {
    velocity = new PVector(0, 0);
  }
}

