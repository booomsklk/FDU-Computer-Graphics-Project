import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;          //声明了mimin
AudioPlayer player;   //声明了一个AudioPlayer类型的变量player
FFT fft;              //傅里叶变换

int low_amp;     //低强度
int medium_amp;  //中等强度
float high_amp;  //高强度
int threshold;   //阈值

int option;      //“选项”变量，用于选择特效

// 正方形特效变量
int x_offset;
float rotate_random;

// 三角形特效变量
int triangle_loc;

// 螺旋特效变量
float arc_len;

//计数变量
int count;

void setup() {  //只在程序开始时运行一次
  //size(360, 300, P3D);
  fullScreen(P3D);  //设置全屏
  frameRate(60);    //每秒运行的帧数
  background(0);    //设置背景色为0
  noCursor();       //隐藏鼠标
 
  minim = new Minim(this);  //对mimin进行实例化
  player = minim.loadFile("Immortals.mp3", 1024); //加载音频文件的变量  1024：提取的频率
  fft = new FFT(player.bufferSize(), player.sampleRate());  //对傅里叶变换的变量进行实例化
  option = 1; //初始化选项
  threshold = 150;
  //正方形特效
  x_offset = 0;
  rotate_random = random(1, 24);
  stroke(255);
  //三角特效
  triangle_loc = width/2;  
  //螺旋特效
  arc_len = 0.0005;         
  count = 0;
}

void draw() {  //循环执行的绘图函数
  fft.forward(player.mix); //对音频文件进行傅里叶变换
  low_amp = int(fft.getFreq(50));
  medium_amp = int(fft.getFreq(2000));
  high_amp = map(fft.getFreq(20000), 0, 1, 0, 500); // map(value, start1, stop1, start2, stop2)
                                                    // value：当前值  start1：当前值下届  stop1：当前值上界  start2：目标值下届  start3：目标值上界
  count += 1;
  if(count >= 3){
    if (low_amp>threshold && frameCount>240) {   //frameCount:程序自启动以来已显示的帧数
      option = floor(random(1, 3.99));           //对option做随机处理
    }
     count = 0;
  }
  
  if (option==1) {
    trianglepop();
    rain();
  }
  if (option==2) {
    squaregroup(20);
  }
  if (option==3) {
    spiral();
  }

  //当前mp3文件被替换时，加载新的文件
  if (player.isPlaying() == false) {
    option = 1;
    player = minim.loadFile("Immortals.mp3", 1024);
    player.rewind();
    player.play();
  }
}


// 螺旋特效
void spiral() {
  background(0);  //背景设置为黑
  noFill();       //对几何图形不进行填充
  stroke(255);     //选择线条颜色为白色
  
  arc_len += 0.0001;
  if (arc_len == 10) {
    arc_len = 0.0005;
  }
  
  translate(width/2, height/2);   //translate(x平移,y平移)以应用一个平移变换。
  for (int r=50; r<650; r=r+5) {
    rotate(millis()/1200.0);      //millis()：启动程序以来的毫秒数
                                  //rotate：根据指定的弧度进行旋转
    strokeWeight(3);
    arc(0, 0, r*low_amp/10, r*low_amp/10, 0, arc_len);     //arc(a, b, c, d, start, stop, mode)
                                                           //a：圆弧椭圆的x坐标   b：圆弧椭圆的y坐标   c：弧的椭圆宽度   d：弧的椭圆高度
                                                           //start：弧开始的角度   stop：弧停止的角度
  }
}


// 三角特效
void trianglepop() {
  if (triangle_loc==width) {
    triangle_loc = 0;
  } else { 
    triangle_loc = triangle_loc + 1;
  }
  pushMatrix();
  background(0);
  translate(triangle_loc, height/2);
  fill(255);

  for(int i=0;i<player.bufferSize()-1;i++){
   strokeWeight(abs(player.left.get(i)*10));
  }
  //line(x1, y1, x2, y2)    x1、y1：第一个点的横纵坐标   x2、y2：第二个点的横纵坐标
  line(-width, 0, -width*7/8, -height/8-high_amp);
  line(-width*3/4, 0, -width*7/8, -height/8-high_amp);
  line(-width/2, 0, -width*3/8, -height/8-high_amp);
  line(-width/4, 0, -width*3/8, -height/8-high_amp);
  line(0, 0, width/8, -height/8-high_amp);
  line(width/4, 0, width/8, -height/8-high_amp);
  line(width/2, 0, width*5/8, -height/8-high_amp);
  line(width*3/4, 0, width*5/8, -height/8-high_amp);
  
  popMatrix();
}


// 雨点特效
void rain() {
  fill(255);
  textSize(random(0, high_amp));
  text("l", random(width), random(height));   //text(c, x, y)  c：要显示的字符  x：横坐标  y：纵坐标  这里横纵坐标选择random(width)与random(height)，是为了使雨点特效布满整个屏幕
}


// 正方形特效
void squaregroup(int square_wid) {
  background(0);
  pushMatrix();
  x_offset -= 3;
  if (x_offset<-width*3) {
    x_offset = 0;
  }
  strokeWeight(3);
  if (low_amp>threshold) {
    rotate_random = random(1, 24);
    stroke(random(125, 255), random(125, 255), random(125, 255));
  }
  translate(x_offset, 0);
  for (int i_x=0; i_x<width*12; i_x+=50) {
    for (int i_y=0; i_y<height; i_y+=50) {
      noFill();
      rotateY(rotate_random);        //rotateY：沿Y轴转动的角度
      square(i_x, i_y, square_wid);
    }
  }
  popMatrix();
}
