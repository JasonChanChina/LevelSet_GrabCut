function[bandTrimap]=ExpandBand(mountainImage)

global M N P   %RGBͼ��(M*N*P)=(512*512*3)
%{0:bg, 1:fg, 2:probably-bg, 3:probably-fg}

%mountainImage  -n  -1  +1  +n

%����խ������ͼ
roi=(mountainImage<=1);
bandTrimap=ones(M,N);  %bg=0 
bandTrimap=uint8(bandTrimap);
bandTrimap(roi)=255;  %���ñ߽��ǰ��=255 
roi=(mountainImage<-1);
bandTrimap(roi)=0;  %fg=1

% figure;
% imshow(bandTrimap);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%����߽�����ͼ(����֮����չ��խ��)
trimap=zeros(M,N);
roi=(mountainImage>=-1 & mountainImage<=1);
trimap(roi)=255;  %���ñ߽�Ϊ255    ��

% figure;
% imshow(trimap);

%������չ��ģ��
K=3; %����ģ���С(=2K+1)
Model=ones(2*K+1,2*K+1);

%��չ�߽�����ͼ
expandTrimap=conv2(trimap,Model);  %������� �ߴ���
% trimap=zeros(M,N);
trimap=expandTrimap(K+1:M+K , K+1:M+K);  %�ָ��ߴ�

%����չ��ı߽���ӵ�խ������ͼ��
roi=(trimap>=200);  
bandTrimap(roi)=3;  %pfg=3


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%����Բ������Ϊ����bg=0
r=min(M,N)/2;
[x,y]=meshgrid(-r+1:r);
circle=(x.^2 + y.^2) >= r^2;
% roi=find(circle>=1); 
roi=(circle>=1);
bandTrimap(roi)=0;  %bg=0


% 
% figure;
% imshow(bandTrimap,[]);
end