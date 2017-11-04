//Author: Joshua Nelson 
//Purpose: To represent orbiting planets
object[] planet;
int number_of_planet= 30;
// This is only a boundary for the speed.
int start_speed=200;
// dt controls the passage of time
float dt=.000015;
// This constant contorls how powerful gravity is. 
//The reason it isn't as small as the actuall gravitational constant is because it would be to weak.
float grav_const=190000.03;
//The next 4 variables are used for making new planets with the mouse.
float mouseXStart;
float mouseYStart;
float mouseXFinal;
float mouseYFinal;
//controls whether the begining and end line is drawn in the planet creation process
boolean Pressed=false;
void setup(){
  size(2000,1000);
  //creates any array of planets
  planet=new object[number_of_planet];
  //Establishes random values for all planets
  for(int i=0;i!=number_of_planet;i++){
    planet[i]=new object(random(-start_speed,start_speed),random(-start_speed,start_speed),random(500,1500),random(250,750),random(3000,5000));
  }


}
void draw(){
background(0);
for(int i=0;i!=number_of_planet;i++){
    for(int j=0;j!=number_of_planet;j++){
        //this keeps a planet from calulating a distance of 0 which will crash the program when it tries to calulate the acceleration
        if (i!=j){
           //This ensures that an absorbed planet does not effect the motion of a none aborbsered planet motion
           if (planet[i].drawn && planet[j].drawn){
              planet[i].distance(planet[j].x_pos,planet[j].y_pos);
              planet[i].calculate_accleration(planet[j].x_pos,planet[j].y_pos,planet[j].mass);
              // tests for collision
              if (planet[i].distance<(planet[i].diameter+planet[j].diameter)/2){ 
                  //erasers one of the two planets that collides
                  planet[j].drawn=false;
                  //Calculates new x and y velocities after a collision using the law of conservation of momentum
                  //The collision can be classified as perfectly inelastic
                  planet[i].x_vel=((planet[i].x_vel*planet[i].mass+planet[j].x_vel*planet[j].mass)/(planet[i].mass+planet[j].mass));
                  planet[i].y_vel=((planet[i].y_vel*planet[i].mass+planet[j].y_vel*planet[j].mass)/(planet[i].mass+planet[j].mass));
                  // adds mass of collides planets
                  planet[i].mass=planet[i].mass+planet[j].mass;
                  // Finds the mid point of the two planets and assaigns that into  the planets 
                  planet[i].x_pos=(planet[i].x_pos+planet[j].x_pos)/2;
                  planet[i].y_pos=(planet[i].y_pos+planet[j].y_pos)/2;
                  //Recalculates the diameters of the planet
                  planet[i].recalculate_size();
                }
            }    
      else{
        planet[i].x_acc=0; 
        planet[i].y_acc=0; 
      }
      //"bounce" allows planets to bounce off the edges.
      //planet[i].bounce();
      //This recalculates position and velocity.
      planet[i].intergrate();
    
      }
    }
    //Makes sure only planets that are not already absorbed are drawn
    if (planet[i].drawn && planet[i].x_pos>0 && planet[i].x_pos<2000 && planet[i].y_pos>0 && planet[i].y_pos<1000){
        ellipse(planet[i].x_pos,planet[i].y_pos,planet[i].diameter,planet[i].diameter);
    }
    //draw line only between start and current point when mouse is pressed
    if (Pressed){
      stroke(255,255,255);
      line(mouseXStart,mouseYStart,mouseX,mouseY);
    }
    
}

//This allows one to save the frames from running the program 
//to turn those frames into a video later
//saveFrame("gravity_6/pic_#########.png");

}

// starts planet creation process
void mousePressed(){
  Pressed=true;
  // THe planets intial points
  mouseXStart=mouseX;
  mouseYStart=mouseY;
}

//ends planet creation process
void mouseReleased(){
  Pressed=false;
  // This finds a unused spot in the array and puts the new planet there.
  for(int i=0;i!=number_of_planet;i++){
    if (!planet[i].drawn){
      planet[i].remake(30*(mouseX-mouseXStart),30*(mouseY-mouseYStart),mouseXStart,mouseYStart,random(500,1000));
      break;
    }
  }
}

class object 
{
  
 float x_acc=0;
 float y_acc=0;
 float x_vel;
 float y_vel;
 float x_pos;
 float y_pos;

 float distance=0;
 float whole_acc=0;
 float angle=0;
 float x_acc_possible=0;
 float mass=0;
 float diameter=0;
 float y_acc_possible;
 boolean drawn=true;
 
   object( float temp_x_vel,float temp_y_vel,float temp_x_pos,float temp_y_pos,float temp_mass)
   {
       x_vel=temp_x_vel;
       y_vel=temp_y_vel;
       x_pos=temp_x_pos;
       y_pos=temp_y_pos;
       mass=temp_mass;
       diameter=2*pow(temp_mass*.5,.3);
       drawn=true;
   }
   
   // This is used when new planets are made. It establishes all the new values and allow it to be drawn.
   void remake (float temp_x_vel,float temp_y_vel,float temp_x_pos,float temp_y_pos,float temp_mass)
   {
       x_vel=temp_x_vel;
       y_vel=temp_y_vel;
       x_pos=temp_x_pos;
       y_pos=temp_y_pos;
       mass=temp_mass;
       diameter=2*pow(temp_mass*.5,.3);
       drawn=true;
   }
   
   //According to physics integrating accleration yields velocity and doing the same for velocity yields position
   //This integrates using rieman summations
   void intergrate(){
     y_vel=y_vel+y_acc*dt;
     y_pos=y_pos+y_vel*dt;
     x_vel=x_vel+x_acc*dt;
     x_pos=x_pos+x_vel*dt;
   }
   
   //This will bounce the planets off the edges if that is desired
   void bounce(){
     if (y_pos<0 || y_pos>1000){
       y_vel=-y_vel;
     
     }
     if (x_pos<0 || x_pos>2000){
       x_vel=-x_vel;
     
     }
     
     
   }
   
   // This is used when planet collide
   void recalculate_size(){
     diameter=2*pow(mass*.5,.3);   
   }
   
   //x_other and y_other are other objects x and y values
   void distance(float x_other, float y_other){
     //uses the pythagorean theoreom to
     distance=sqrt(pow((x_pos-x_other),2)+pow((y_pos-y_other),2));
   }
   
   void calculate_accleration(float x_other, float y_other,float mass)
   {
     //This calulates the acceleration vector 
     whole_acc=(mass*grav_const)/pow((distance),2);
     //This decomposes the acceleration vector using unit vectors
     x_acc=(((x_other-x_pos)/distance)*whole_acc);
     y_acc=(((y_other-y_pos)/distance)*whole_acc);
   }
   
}