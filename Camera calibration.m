clc clear all;
format long
%读取图片并且转换为灰度图
a=rgb2gray(imread('qipan1.jpg'));
h1=solve_h(a);
a=rgb2gray(imread('qipan2.jpg'));
h2=solve_h(a);
a=rgb2gray(imread('qipan3.jpg'));
h3=solve_h(a);
%求解每张图片对应的 v 矩阵
v1=[solve_v(h1,1,2);
solve_v(h1,1,1)-solve_v(h1,2,2)];
v2=[solve_v(h2,1,2);
solve_v(h2,1,1)-solve_v(h2,2,2)];
v3=[solve_v(h1,1,2);
solve_v(h3,1,1)-solve_v(h3,2,2)];
%三张图对应的 v 矩阵
v=[v1;v2;v3];
%解齐次方程组求出 b 矩阵
b=null(v,rank(v));
b=b';
%相机的内参数
v0=(b(1,2)*b(1,4)-b(1,1)*b(1,5))/(b(1,1)*b(1,3)-
b(1,2)*b(1,2));
alpha=sqrt(1/b(1,1));
beta=sqrt(b(1,1)/(b(1,1)*b(1,3)-b(1,2)*b(1,2)));
gama=-b(1,2)*(alpha^2)*beta;
u0=gama*v0/beta-b(1,4)*(alpha^2);
A=[alpha gama u0;
0 beta v0;
0 0 1];
function v=solve_v(h,i,j)
%此函数用于快速得出 v 矩阵
v=[h(1,i)*h(1,j) h(1,i)*h(2,j)+h(2,i)*h(1,j)
h(2,i)*h(2,j) h(1,i)*h(3,j)+h(3,i)*h(1,j)
h(2,i)*h(3,j)+h(3,i)*h(2,j) h(3,i)*h(3,j)];
end
function H=solve_h(a)
%角点检测
[imagePoints,boardSize] =
detectCheckerboardPoints(a);
%将角点坐标存储在 b 矩阵中
b=round(imagePoints');
%获取 b 的大小
[H,W]=size(b);
%这个循环用于找到左上原点坐标，并储存在
con 中
smin=3000;
con=1;
for i=1:W
if(sqrt((b(1,i))^2+(b(2,i))^2)<smin)
smin=sqrt((b(1,i))^2+(b(2,i))^2);
con=i;
end
end
%算出每个角点离原点的距离，数值储存在 b
for i=1:W
b(3,i)=sqrt((b(1,i)-b(1,con))^2+(b(2,i)-
b(2,con))^2);
end
%转置后按距离排序
b=b';
b=sortrows(b,3);
b=b';
%移除距离数据
b(3,:)=[];
%下面的循环用于去除多余点，只取左上 4 个
点
i=10;
while(i<=W)
b(:,i)=[];
W=W-1;
end
b=b';
%以下再次排序，思路是先按 x 方向排序，后
按 y 方向排序，使角点顺序为从上到下，从左到
右， c 是中间变量
b=sortrows(b,1);
k=0;
c=[];
while(k<W)
for j=1:3
c(j,1)=b(j+k,1);
c(j,2)=b(j+k,2);
end
c=sortrows(c,2);
for j=1:3
b(j+k,1)=c(j,1);
b(j+k,2)=c(j,2);
end
k=k+3;
end
%排序完成后转置成列坐标向量
b=b';
%建立世界坐标系的坐标， 0.02 是棋盘格大
小，世界坐标存储在 s 中
s=[];
i=1;
x=0;
while(x<=0.04)
y=0;
while(y<=0.04)
s(1,i)=x;
s(2,i)=y;
s(3,i)=1;
b(3,i)=1;
y=y+0.02;
i=i+1;
end
x=x+0.02;
end
%构造系数矩阵
I=[];
for i=1:4
x1=s(1,i);
y1=s(2,i);
x=b(1,i);
y=b(2,i);
I=[I;
x1 y1 1 0 0 0 -x1*x -y1*x -x;
0 0 0 x1 y1 1 -x1*y -y1*y -y];
end
%求解齐次方程组，解出 h 矩阵， h 矩阵为 H
矩阵的列形式
h=null(I,rank(I));
%限定条件，参数平方和为 1
syms k
eq=(k^2)*(h(1,1)^2+h(2,1)^2+h(3,1)^2+h(4,1)^2+
h(5,1)^2+h(6,1)^2+h(7,1)^2+h(8,1)^2+h(9,1)^2)==1;
k=solve(eq,k>0,k);
h=h./k;
clear i j
%将 h 还原成 H 的形式（3X3）
for i=1:3
for j=1:3
H(i,j)=h(j+3*(i-1),1);
end
end
end