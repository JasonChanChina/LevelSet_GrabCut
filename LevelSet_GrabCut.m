function[]=LevelSet_GrabCut()

global M N P  %RGBͼ��(M*N*P)=(512*512*3)

Img=imread('1.jpg');
[M,N,P]=size(Img);
I=FillOutOfCircle(Img);
U=LevelSet(I);


trimap=ExpandBand(U);

% 
% 
% % GrabCut
% rgb(:,:,1)=I;
% rgb(:,:,2)=I;
% rgb(:,:,3)=I;
% outTrimap=GrabCut(rgb, trimap);
% 
% roi=(outTrimap==0 |/|| outTrimap==2);  %ȡbg/pbgλ��
% Img(roi)=255;
% imshow(Img);
end