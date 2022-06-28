clear all
clc
%读取图片
a=imread('shachepan.bmp');
%识别圆，返回圆心和半径
[centers,r]=imfindcircles(a,[25150],'Ob
jectPolarity','dark','Sensitivity',0.9);
%获取单位像素长度 delt
delt=get_delt(imcrop(a,[660,324,abs(762
-660),abs(370-324)]));
%圆的信息整合到 circles 里面
circles=centers';
circles(3,:)=r(:,1);
circles=sortrows(circles',3);
%顺时针排序
circle=round(sorts_circles(circles));
%获得距离
distance=get_distance(circle,delt);
%最小二乘法拟合圆
p=round(fit_circle(circles(1:6,1:2)));
format short
clc
fprintf('七个孔的直径分别为(左上角为第
一个，顺时针方向，中心孔最后，单位 mm,下
同):\n')
for i=1:7
fprintf(' %f',circles(i,3)*2)
end
fprintf('\n')
fprintf('相邻孔之间的距离分别为:\n')
for i=1:6
fprintf(' %f',distance(i,1)*2)
end
fprintf('\n')
fprintf('外围孔到中心的距离分别为:\n')
for i=1:6
fprintf(' %f',distance(i,2)*2)
end
fprintf('\n')
fprintf('外围 6 个小孔中心所在圆周的直径
为:\n %f\n',p(1,3)*2)
%最小二乘拟合圆
function p= fit_circle(circles)
N = 6;
x = circles(:,1);
y = circles(:,2);
sumx = 0;
sumy = 0;
sumxx = 0;
sumyy = 0;
sumxxx = 0;
sumyyy = 0;
sumxyy = 0;
sumxy = 0;
sumxxy = 0;
for i=1:N
sumx = sumx+x(i);
sumy = sumy+y(i);
sumxx = sumxx+x(i)*x(i);
sumyy = sumyy+y(i)*y(i);
sumxxx = sumxxx+x(i)*x(i)*x(i);
sumyyy = sumyyy+y(i)*y(i)*y(i);
sumxy = sumxy+x(i)*y(i);
sumxyy = sumxyy+x(i)*y(i)*y(i);
sumxxy = sumxxy+x(i)*x(i)*y(i);
end
D = N*sumxy-sumx*sumy;
C = N*sumxx-sumx*sumx;
E=N*sumxxx+N*sumxyy-(sumxx+sumyy)*sumx;
G = N*sumyy-sumy*sumy;
H=N*sumyyy+N*sumxxy-(sumxx+sumyy)*sumy;
a = (H*D-E*G)/(C*G-D*D);
b = (H*C-E*D)/(D*D-G*C);
c = -((sumxx+sumyy)+a*sumx+b*sumy)/N;
p(1,1) = -0.5*a;
p(1,2) = -0.5*b;
p(1,3) = 0.5*sqrt(a*a+b*b-4*c);
end
%获取距离
function
distance=get_distance(circles,delt)
%相邻距离
for i=1:5
distance(i,1)=sqrt((circles(i+1,1)-
circles(i,1))^2+(circles(i+1,2)-
circles(i,2))^2)*delt;
end
distance(6,1)=sqrt((circles(1,1)-
circles(6,1))^2+(circles(1,2)-
circles(6,2))^2)*delt;
%到中心孔距离
for i=1:6
distance(i,2)=sqrt((circles(i,1)-
circles(7,1))^2+(circles(i,2)-
circles(7,2))^2)*delt;
end
end
%顺时针排序孔
function circles=sorts_circles(a)
%顺时针排序
for i=1:6
temp(i,:)=a(i,:);
end
temp=sortrows(temp,2);
%第一行
for i=1:2
temp1(i,:)=temp(i,:);
end
temp1=sortrows(temp1,1);
for i=1:2
temp(i,:)=temp1(i,:);
end
clear temp1
%第二行
for i=3:4
temp1(i,:)=temp(i,:);
end
temp1=sortrows(temp1,1);
for i=3:4
temp(i,:)=temp1(i,:);
end
clear temp1
%第三行
for i=5:6
temp1(i,:)=temp(i,:);
end
temp1=sortrows(temp1,1);
for i=5:6
temp(i,:)=temp1(i,:);
end
%顺时针
circles(1,:)=temp(1,:);
circles(2,:)=temp(2,:);
circles(3,:)=temp(4,:);
circles(4,:)=temp(6,:);
circles(5,:)=temp(5,:);
circles(6,:)=temp(3,:);
circles(7,:)=a(7,:);
%
end
%获取单位像素的长度
function delt=get_delt(im_LiS)
im_resl = 1:1:ndims(im_LiS);
for i = 1:ndims(im_LiS)
im_resl(i) = size(im_LiS,i);
end
resolution_cropped_x = im_resl(2);
level_im_LiS = graythresh(im_LiS);
bw_im_LiS = im2bw(im_LiS,level_im_LiS);
mean_bw_LiS = mean(bw_im_LiS);
level_mean_bw_LiS =
graythresh(mean_bw_LiS);
bw_mean_bw_LiS =
im2bw(mean_bw_LiS,level_mean_bw_LiS);
line_order = 0;
i = 1;
line_info = [ ];
tic;
while i < resolution_cropped_x
if (bw_mean_bw_LiS(1,i+1) == 0) &&
(bw_mean_bw_LiS(1,i) ==1 )
line_order = line_order + 1;
line_width = 0;
index_sum = 0;
j = i+1;
while bw_mean_bw_LiS(j) == 0 &&
j<resolution_cropped_x
line_width = line_width + 1;
index_sum = index_sum + j;
j = j + 1;
end
line_center = index_sum / line_width;
line_info(line_order,1) = line_order;
line_info(line_order,2) = line_width;
line_info(line_order,3) = line_center;
i = j-1;
end;
i = i + 1;
end
line_distance = zeros(line_order-1,3);
for i = 1:line_order-1
line_distance(i,1) = i;
line_distance(i,2) = line_info(i+1,3)-
line_info(i,3);
line_distance(i,3) = 1 /
line_distance(i,2);
end
delt = mean(line_distance(:,3));
end