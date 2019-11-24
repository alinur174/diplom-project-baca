function [numberofTumours maxDiameter position] = Project(imagename)
% imagename = 'th.jpeg';

orgim = imread(imagename);

im = (orgim);

figure('Name','Original Image');
imshow(im);

%1 shag
im = rgb2gray(im);

%second step
im = im2double(im).^3;

%third step
im = medianfilter(im);
[row col] = size(im);


figure('Name','Scan after preprocessing');
imshow(im,[]);


%fourth step
segmentation = thresholdsegment(uint8(im*255));
% LPF = [1 1 1; 1 1 1; 1 1 1] * (1/9);
% im = imfilter(im,LPF);
% T = multithresh(im,1);
% segmentation = zeros(row,col);
% segmentation(im >= T) = 1;

ratio = 5.2941e-04 * 2;

[row col channel] = size(orgim);

radius = sqrt(ratio*row*col/pi);

figure('Name','Image After Segmentation')
imshow(segmentation,[]);

% 5 shag 
% surette ulken daqty tabady

imBw = im2bw(im);
 imBwLabel = bwlabel(imBw);
 s = regionprops(imBwLabel, 'Area');   
 area = cat(1, s.Area);
 index = find(area == max(area));

 img = ismember(imBwLabel, index);

 props = regionprops(img, 'BoundingBox');
 bbx = vertcat(props.BoundingBox); 
  
  figure('Name','ulken daqty korshau');
  imshow(im);hold on

  rectangle('Position',bbx,'EdgeColor','r', 'linewidth',2);
    
  s = regionprops(imBwLabel, 'Centroid');
 
 centroid = s(index,:);
 idx = centroid.Centroid(1);
 idy = centroid.Centroid(2);    
 
  % % LGDF 
Img = im;
Img = double(Img(:,:,1));
NumIter = 520; %iterations
timestep=0.1; %time step
mu= 2;% level set regularization term
sigma = 7;%size of kernel
epsilon = 1;
c0 = 2; % the constant value 
lambda1=1.03;
lambda2=1.0;
% if lambda1>lambda2; tend to inflate
% if lambda1<lambda2; tend to deflate
nu = 0.001*255*255;%length term
alf = 20;%data term weight

% figure,imagesc(uint8(Img),[0 255]),colormap(gray),axis off;axis equal
% [Height Wide] = size(Img);
% [xx yy] = meshgrid(1:Wide,1:Height);

% initialLSF = ones(size(Img(:,:,1))).*c0;
% initialLSF(190:240,80:240) = -c0;
% phi = initialLSF;

% phi = (sqrt(((xx - 48).^2 + (yy - 60).^2 )) - 11);
% phi = sign(phi).*c0;

 [Height Wide] = size(Img);
 [xx yy] = meshgrid(1:Wide,1:Height);
  r = bbx(4)/3;
phi = (sqrt(((xx - idx).^2 + (yy - idy).^2 )) - r);
phi = sign(phi).*c0;

BinaryLS = phi;
BinaryLS(BinaryLS>0) = 0;
BinaryLS(BinaryLS<0) = 1;
NHOOD = ones(5,5);
ErodeImg = imerode(BinaryLS,NHOOD);
DilateImg = imdilate(BinaryLS,NHOOD);
Narrowband = DilateImg - ErodeImg;
 
Ksigma=fspecial('gaussian',round(2*sigma)*2 + 1,sigma); %  kernel
ONE=ones(size(Img));
KONE = imfilter(ONE,Ksigma,'replicate');  
KI = imfilter(Img,Ksigma,'replicate');  
KI2 = imfilter(Img.^2,Ksigma,'replicate'); 

 figure,imagesc(im),colormap(gray),axis off;axis equal,
 title('Initial contour');
 hold on,[c,h] = contour(phi,[0 0],'r','linewidth',2); hold off
% % hold on,[cc,hh] = contour(DilateImg,[0 0],'b','linewidth',2); hold off
 pause(0.5)
 
for iter = 1:NumIter    
    [phi] = evolution(Img,phi,epsilon,Ksigma,KONE,KI,KI2,mu,nu,lambda1,lambda2,timestep,alf, Narrowband);
    BinaryLS = phi;
    BinaryLS(BinaryLS>0) = 0;
    BinaryLS(BinaryLS<0) = 1;
    ErodeImg = imerode(BinaryLS,NHOOD);
    DilateImg = imdilate(BinaryLS,NHOOD);
    Narrowband = double(phi.*double(DilateImg-BinaryLS)>0)+double(phi.*double(BinaryLS-ErodeImg)<0);    
    if(mod(iter,10) == 0)
        figure,
        imagesc(im),colormap(gray),axis off;axis equal,title(num2str(iter))
        hold on,[c,h] = contour(phi,[0 0],'r','linewidth', 2); hold off       
         hold on,[cc,hh] = contour(DilateImg,[0 0],'b','linewidth',2); hold off        
    end
end