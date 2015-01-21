% This Matlab file demomstrates the level set method in Li et al's paper
%    "Level Set Evolution Without Re-initialization: A New Variational Formulation"
%    in Proceedings of CVPR'05, vol. 1, pp. 430-436.
% Author: Chunming Li, all rights reserved.
% E-mail: li_chunming@hotmail.com
% URL:  http://www.engr.uconn.edu/~cmli/
function uuu = Demo3()
clear all;
close all;
Img = imread('aa.bmp');  % synthetic noisy image
Img=double(Img(:,:,1)); %ȡ��һ��ͼ��RGB�е�R������Gray�е�Gray������ת����double����
sigma=1.5;    % scale parameter in Gaussian kernel for smoothing
G=fspecial('gaussian',15,sigma);
Img_smooth=conv2(Img,G,'same');  % smooth image by Gaussiin convolution
[Ix,Iy]=gradient(Img_smooth);
f=Ix.^2+Iy.^2;  %�ݶ�ģ��ƽ��

g=1./(1+f);  %��ʽ[5.1] edge indicator function. %�ݶȵ��������ݶ�Խ��ֵԽС



timestep=200;  % time step
%[4]
mu=0.2/timestep;  %[4]��mu% coefficient of the internal (penalizing) energy term P(\phi) % Note: the product timestep*mu must be less than 0.25 for stability!
%[6]
lambda=5; %[6]��lambda % coefficient of the weighted length term Lg(\phi)
alf=-3;   %[6]��alf��v�� %+������-��ɢ % coefficient of the weighted area term Ag(\phi); % Note: Choose a positive(negative) alf if the initial contour is outside(inside) the object.
%[11]
epsilon=1.5; %[11]��epsilon % the papramater in the definition of smoothed Dirac function


% define initial level set function (LSF) as -c0, 0, c0 at points outside, on
% the boundary, and inside of a region R, respectively.
[nrow, ncol]=size(Img);  

c0=4;
initialLSF=c0*ones(nrow,ncol);
w=8;%��ʼ�ıպ϶�̬����λ�ã���߽�λ�ã�
initialLSF(400:450, 150:200)=0;
initialLSF(401:449, 151:199)=-c0;
% initialLSF(w+1:end-w, w+1:end-w)=0;  % zero level set is on the boundary of R. 
                                     % Note: this can be commented out. The intial LSF does NOT necessarily need a zero level set.
                                     
% initialLSF(w+2:end-w-1, w+2: end-w-1)=-c0; % negative constant -c0 inside of R, postive constant c0 outside of R.
% img = [7,8]  % ������ʼ��ˮƽ���պ�����(��ͼ�е�0���ڲ�-c0=-4���ⲿc0=4)
%           4  4  4  4  4  4  4  4
%           4  0  0  0  0  0  0  4
%           4  0 -4 -4 -4 -4  0  4
%   LSF =   4  0 -4 -4 -4 -4  0  4
%           4  0 -4 -4 -4 -4  0  4
%           4  0  0  0  0  0  0  4
%           4  4  4  4  4  4  4  4

u=initialLSF;
figure;imagesc(Img, [0, 255]);colormap(gray);hold on;%hold on �»��ƻ���ӵ�ԭ��ͼ����
[c,h] = contour(u,[0 0],'r');                          
title('Initial contour');


% start level set evolution
for n=1:1000
    u=EVOLUTION(u, g ,lambda, mu, alf, epsilon, timestep, 1);      
    if mod(n,20)==0     %ÿ20�ε�������һ��ͼ��
        pause(0.001);
%         imshow(u,[]); %%%%%%%%%%
        imagesc(Img, [0, 255]);colormap(gray);hold on;
        [c,h] = contour(u,[0 0],'r'); 
        iterNum=[num2str(n), ' iterations'];        
        title(iterNum);
        hold off;   %�»��ƻḲ��ԭ��ͼ�� 
    end
end
imagesc(Img, [0, 255]);colormap(gray);hold on;%hold on �»��ƻ���ӵ�ԭ��ͼ����
[c,h] = contour(u,[0 0],'r'); 
totalIterNum=[num2str(n), ' iterations'];  
title(['Final contour, ', totalIterNum]);
uuu=u;


function u = EVOLUTION(u0,           g,            lambda,   mu,   alf,  epsilon,  delt,  numIter)
%            EVOLUTION(���߾���  ��Ե������    5��   0.04��  3��    1.5��     5��     1   )
%
%  EVOLUTION(u0, g, lambda, mu, alf, epsilon, delt, numIter) updates the level set function 
%  according to the level set evolution equation in Chunming Li et al's paper: 
%      "Level Set Evolution Without Reinitialization: A New Variational Formulation"
%       in Proceedings CVPR'2005, 
%  Usage:
%   u0: level set function to be updated
%   g: edge indicator function
%   lambda: coefficient of the weighted length term L(\phi)
%   mu: coefficient of the internal (penalizing) energy term P(\phi)
%   alf: coefficient of the weighted area term A(\phi), choose smaller alf 
%   epsilon: the papramater in the definition of smooth Dirac function, default value 1.5
%   delt: time step of iteration, see the paper for the selection of time step and mu 
%   numIter: number of iterations. 
%
% Author: Chunming Li, all rights reserved.
% e-mail: li_chunming@hotmail.com
% http://vuiis.vanderbilt.edu/~licm/

% [mr,mc] = size(g);
% disp(mr);
% disp(mc);

u=u0;
[vx,vy]=gradient(g);
 
% ��ʽ[12]
for k=1:numIter

    u=NeumannBoundCond(u);%����߽磬��ֹ�����߽��������

    [ux,uy]=gradient(u); 

    normDu=sqrt(ux.^2 + uy.^2 + 1e-10);    % ����u���ݶ�ģ
    Nx=ux./normDu;
    Ny=uy./normDu;

    diracU=Dirac(u,epsilon); %��ʽ[11]

    K=curvature_central(Nx,Ny);   %[7]�е�div(u), k=divɢ��=Nxx+Nyy >0 ��ʾ����ðˮ��Դ�㣬<0 ��ʾ����ˮ�Ļ��

    weightedLengthTerm=lambda*diracU.*(vx.*Nx + vy.*Ny + g.*K);   %==��ʽ[7]

    penalizingTerm=mu*(4*del2(u)-K);

    weightedAreaTerm=alf.*diracU.*g;

    %��ʽ[10][13]
    u=u+delt*(weightedLengthTerm + weightedAreaTerm + penalizingTerm);  % update the level set function
    %=u+delt*L��[13]��L��

end

% the following functions are called by the main function EVOLUTION
% x �Ǿ���sigma������f�Ǿ���
function f = Dirac(x, sigma)        %��ʽ[11] �����˺���(�������)��ֻ����һ�����ݷ�Χ�ڵ�����
f=(1/2/sigma)*(1+cos(pi*x/sigma));
b = (x>=-sigma) & (x<=sigma);   % b ��bool ����  �жϾ���x��ÿ��Ԫ���ǲ����ڣ�-sigma,sigma����Χ��
f = f.*b;   %��f�� �ھ���b��λ��=false ��������0


% nx �Ǿ���  ny �Ǿ���
function K = curvature_central(nx,ny) %��������
[nxx,junk]=gradient(nx);  
[junk,nyy]=gradient(ny);
K=nxx+nyy;

% f �Ǿ���  g �Ǿ���
function g = NeumannBoundCond(f)
% Make a function satisfy Neumann boundary condition �߽紦��
[nrow,ncol] = size(f);
g = f;
% g([1 nrow],[1 ncol]) = g([3 nrow-2],[3 ncol-2]);  
% g([1 nrow],2:end-1) = g([3 nrow-2],2:end-1);          
% g(2:end-1,[1 ncol]) = g(2:end-1,[3 ncol-2]);     
g([1 nrow],[1 ncol]) = g([30 nrow-29],[30 ncol-29]);  
g([1 nrow],2:end-1) = g([30 nrow-29],2:end-1);          
g(2:end-1,[1 ncol]) = g(2:end-1,[30 ncol-29]);   

