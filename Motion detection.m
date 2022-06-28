clc
clear all
%加载视频和相机参数
load('cametaParams.mat');
video=VideoReader('xuexiao.mp4');
%总帧数
M=round(video.FrameRate)*round(vi
deo.Duration);
%建立视频对象
vedio = VideoWriter('demo.avi');
%设置帧率
vedio.FrameRate = 30;
open(vedio);
loc=[];
for m=30:M-10
%使用帧差法对每一帧图像进行分
析
if(m==380)
loc(1,1)=GetMoveingObject(m,video);
loc(1,2)=GetMoveingObject(m,video);
else if(m==950)
loc(2,1)=GetMoveingObject(m,video);
loc(2,2)=GetMoveingObject(m,video);
else
GetMoveingObject(m,video);
end
%保存图像并写入新视频的一帧
frame = imread('save.jpg');
writeVideo(vedio,frame);
clc
end
close(vedio);
%计算速度
v=(sqrt((loc(1,1)-
loc(2,1))^2+((loc(1,2)-
loc(2,2))^2)*110/(950-380);
fprintf(' 右 下 角 行 人 运 动 的 速 度
为: %fm/s',v)
%三帧法函数
function
loc=GetMoveingObject(m,video)
%按顺序都三帧图像
frame1=rgb2gray(read(video, m));
frame2=rgb2gray(read(video, m+5));
frame3=rgb2gray(read(video,
m+10));
%作差
frame21=frame2-frame1;
frame32=frame3-frame2;
%二值化
frame21=im2bw(frame21,0.5);
frame32=im2bw(frame32,0.5);
%或操作
frame=frame21|frame32;
%去除较小的噪点
frame=bwareaopen(frame,5);
%图像线性膨胀
se=strel('line',80,0);
frame=imdilate(frame,se);
se=strel('line',80,90);
frame=imdilate(frame,se);
%获取连通域并用矩形画出
img_reg = regionprops(frame,
'area', 'boundingbox');
rects = cat(1,
img_reg.BoundingBox);
5
%画矩形和几何中心
if(size(rects, 1)<5)
imshow(frame1);
hold on;
for i = 1:size(rects, 1)
rectangle('position',
rects(i, :), 'EdgeColor', 'r');
scatter(rects(i,1)+rects(i,3)/2,rects
(i,2)+rects(i,4)/2,50,'r','+');
end
saveas(gcf, 'save.jpg');
else
imshow(frame1);
hold on;
end
%获取位置
if(m==380&&m==950)
loc(1,1)=rects(end,1)+rects(end,3);
loc(1,2)=rects(end,2)+rects(end,4);
else
loc(1,1)=0;
loc(1,2)=0;
end
%关闭当前图像
close all;
end