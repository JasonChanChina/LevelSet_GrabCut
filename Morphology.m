function LSF=getContour(mask)

[m n]=size(mask);

binG=255*ones(m,n);     %全白
roi=mask>0;       
mold=zeros(m,n);         %黑色模板
binG(roi)=mold(roi);      %获取黑色目标



B=[0,1,0;
    1,1,1;
    0,1,0];
B2=[1,1,1;
    1,1,1;
    1,1,1];
B3=[1,1,1,1,1,1,1,1,1,1,1;
    1,1,1,1,1,1,1,1,1,1,1;
    1,1,1,1,1,1,1,1,1,1,1;
    1,1,1,1,1,1,1,1,1,1,1;
    1,1,1,1,1,1,1,1,1,1,1;
    1,1,1,1,1,1,1,1,1,1,1;
    1,1,1,1,1,1,1,1,1,1,1;
    1,1,1,1,1,1,1,1,1,1,1;
    1,1,1,1,1,1,1,1,1,1,1;
    1,1,1,1,1,1,1,1,1,1,1;
    1,1,1,1,1,1,1,1,1,1,1];

%填充孔洞 imerode  默认是对白色区域进行腐蚀，对黑色就是膨胀
k=8;
binG2=binG;
for i=1:1:k
   binG2=imerode(binG2,B2);         %实际是对白色腐蚀，对黑色就是膨胀
end

% figure;
% imshow(binG2); title('binG2')
% figure;


binG3=binG2;
for i=1:1:k+7
    binG3=imdilate(binG3,B2);          %%实际是对白色膨胀，对黑色就是腐蚀
end

% figure;
% imshow(binG3); title('binG3')
% figure;



roi= binG3>128;   %取白色
LSF=ones(m,n);
LSF(roi)=-1;
 
end
 
 
 
 
