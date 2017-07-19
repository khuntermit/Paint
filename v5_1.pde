

// Francisco Fuentes Oppliger - Pablo Ortiz Baeza - Alejandro Rebolledo anotaciones varias**** USO ACADEMICO ****+

import processing.video.*;
import controlP5.*;
import processing.serial.*;

Capture video;  //libreria
ControlP5 cp5; //libreria


PrintWriter output;
PImage img;  

int imageWidth  = 640;
int imageHeight = 480;
int origenX = 205;
int origenY = 215;

int grillaX  = 5;
int grillaY  = 5;

int gapX = 16;
int gapY = 16;

int sizeBox = 15;

int totalArrayPixels = imageWidth*imageHeight;

float suma;
float prevY;
float prevX;
float time = 0;
int valor;
float valPlot;
boolean overBox = false;
boolean grabando = false;

String fila = (" ");
String nombre;
float rPlot; 
float gPlot;
float bPlot;
String temp;
float C;

boolean notchanged = true;
boolean nothit = true;

Serial myPort; // Crea el objeto para el puerto

void setup() {
  
 // myPort = new Serial(this, "/dev/cu.usbmodem1421", 9600); //sensor nota en pc generalmente es com temperatura
    
  size(1280, 600);
  background(0);
  //video = new Capture(this, imageWidth, imageHeight);
  video = new Capture(this, imageWidth, imageHeight, "FaceTime HD Camera", 30); //dirección de la cámara "HD Pro Webcam C920" para la web o "FaceTime HD" Camera para muestra
  video.start();  
  loadPixels();
  grilla ();
  line (0, 480, 640, 480);

  cp5 = new ControlP5(this);
  cp5.addTextfield("Nombre archivo.txt").setPosition(20, 500).setSize(200, 20).setAutoClear(false);
}

/*public boolean testcolors(int r, int g, int b, int whiteval){
    if (r > whiteval && g > whiteval && b > whiteval){
       return true; }
    return false; 
    }*/
  
void draw() {
delay(100); //tiempo de muestra
  int s = second();  
  int m = minute();  
  int h = hour();
  
  int mili = millis();
  
  int prevMili = 0;
   
  
 // temp = myPort.readStringUntil('\n'); //temperatura \ ojo
   temp = "reemplace";
   if (temp != null) {
   temp = trim(temp);                   //descomentar para uso con arduino
    println(temp);                       //descomentar
    C = float(temp);                     //descomentar
                
   }
   
  
   stroke (0);
   
   
   fill (0);
   rect (390,500,510,540);
   fill (255);
   text ("TEMPERATURA:", 400,520); 
   text (temp, 500, 520);
   text ("HORA:",400,540);
   text (h, 500,540);
   text (":",520,540);
   text (m, 530,540);
   text (":",550,540);
   text (s, 560,540);
   text (":",550,540);
   text (":",570,540);
   text (mili, 580,540);
   
   //text(temp, 500, 520); //temp al mostrarse se pega en delay general mas rapido que el muestreo

  
 // println (C);
 
  
  //testea si el mouse esta sobre el boton
  if (mouseX >240 && mouseX < 320 && 
    mouseY > 500 && mouseY < 520 ) {
    stroke(255); 
    fill(153);
    overBox = true;
  } else {
    stroke(153);
    fill(153);
    overBox = false;
  }

  rect(240, 500, 80, 20);     // dibuja el boton de grabar
  if (grabando==true) {
    stroke (0);
    fill (0, 0, 0);
    rect (275, 505, 10, 10);
  } else { 
    fill(255, 0, 0);
    stroke (255, 0, 0);
    ellipse (280, 510, 10, 10);
  }
  if (video.available()) {
    video.read(); 
    image(video, 0, 0);


    for (int y=0; y < grillaY; y++) {
      if (grabando==true) {
        
        output.flush(); 
        
        output.println(fila);//graba los datos en el archivo
                  
        output.flush();    
        
        
        //println (fila);          
        fila = ("");     
        
        
      }

      for (int x=0; x < grillaX; x++) {
        drawRectangulo(x, y);
        fila =(fila + " " + valor);
        //stroke (255);
        //plot (x, y, valPlot);  //Promedio
        stroke(255, 0, 0);  //LINEAS DE COLORES
        plot (x, y, rPlot);
        stroke(0, 255, 0);
        plot (x, y, gPlot);
        stroke(0, 0, 255);
        plot (x, y, bPlot);


        if (prevX >= 640+(x*width/10)+(width/10)) // Reinicia el grafico cuando llega al final
        {
          time=0;
          fill (0);
          rect(640, 0, 640, 480);
          grilla ();
        }
      }
    }
   // println ("-------------------");
    if (grabando==true) {
     output.print ("-------------------   TEMP: ");
     output.print (C);
     output.print ("  HORA: ");
     output.print (h);
     output.print (":");
     output.print (m);
     output.print(":");
     output.print(s);
     output.print(":");
     output.println(mili);
     
    }
  }
}
  
void drawRectangulo(int boX, int boY) {

  int area = sizeBox*sizeBox;

  int colorsR = 0; 
  int colorsG = 0; 
  int colorsB = 0; 

  int r = 0;
  int g = 0;
  int b = 0;
  
  int whiteval = 220;
  boolean nothit = true;

  for (int y=0; y < sizeBox; y++) {
    for (int x=0; x < sizeBox; x++) {  

      //CALCULO POSICION ARRAY PIXELES VIDEO
      int pixelPosition = origenX + ( x + (gapX+sizeBox) * boX) + ((origenY + y + (gapY+sizeBox) * boY) * imageWidth) ;

      //FLIP IMAGEN
      /*
      int columnaY = origenY + y + ((gapY+sizeBox) * boY);
       pixelPosition =  imageWidth * (2* columnaY + 1) - (pixelPosition + 1);
      */ 
      if (pixelPosition < 0) {
        pixelPosition = 0;
      } else if (pixelPosition > totalArrayPixels) {
        pixelPosition = totalArrayPixels;
      }

      int pixelColor = video.pixels[pixelPosition];

      colorsR += (pixelColor >> 16) & 0xff;
      colorsG += (pixelColor >> 8) & 0xff;
      colorsB += pixelColor & 0xff;
    }
  }

  //COLOR EN BASE A PROMEDIO R-G-B

  r = int(colorsR/area);
  g = int(colorsG/area);
  b = int(colorsB/area);

  suma=(r+g+b)/3;
  valor =(r+g+b)/3;      //Calculo del promedio
  valPlot = map(suma, 0, 255, 0, 96);

  rPlot = map(r, 0, 255, 0, 96);
  gPlot = map(g, 0, 255, 0, 96);
  bPlot = map(b, 0, 255, 0, 96);


  fill(r, g, b);
  stroke(0);
  rect(origenX + (gapX+sizeBox) * boX, origenY + (gapY+sizeBox)*boY, sizeBox, sizeBox);
  fill(0);
  if(r > 220 && g > 220 && b > 220){
    text (valor, origenX + (gapX+sizeBox) * boX, origenY + (gapY+sizeBox)*boY-4);
    fill (255);
    nothit = false;
  }
   
  
  /* while(notchanged){
    boolean result = testcolors(r, g, b, whiteval);
    if (result==true){
      text (valor, origenX + (gapX+sizeBox) * boX, origenY + (gapY+sizeBox)*boY-4);
    fill (255);
    notchanged = false;
    }*/
    
    
  }
  





// GRILLA PARA LOS GRAFICOS

void grilla() {
  for (int i = 640; i <= width; i += width/10) {
    stroke(255);
    line(i, 480, i, 0);
  }
  for (int j =0; j <= 480; j += 480/5) {
    stroke(255);
    line(640, j, width, j);
  }
}



// GRAFICO

void plot (int x, int y, float valPlot) {
  prevX = 640+(x*width/10)+time;
  prevY =  96+(y*96);
  //stroke(255);
  point (prevX, prevY-valPlot);
  time=(time+0.005); // variable para escala de tiempo del gráfico
}


// GRABAR LOS DATOS AL ARCHIVO CUANDO SE PRESIONA EL BOTON 
// Y DEJA DE GRABAR CUANDO SE VUELEVE A PRESIONAR


void mousePressed() {
  if (overBox == true) {
    if (grabando == false) {
      grabando = true;
      nombre = cp5.get(Textfield.class, "Nombre archivo.txt").getText()+".txt"; 
      output = createWriter(nombre); //crea un archivo en el carpeta del sketch donde se guradan los datos

      // print("se esta guardando los datos en el archivo:  ");
      // print(nombre);
      // println();
    } else {
      grabando = false;
      output.flush(); 
      output.close(); 
      // exit();
    }
  }
}

int[] arrayOfLocation = {0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
int[] arrayOfRGB = {{r,g,b},{r,g,b},{r,g,b},{r,g,b},{r,g,b}};