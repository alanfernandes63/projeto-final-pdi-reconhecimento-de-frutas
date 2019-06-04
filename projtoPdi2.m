clear all
close all

img = imread('20190525_175206.jpg');
figure,imshow(img);

%segmentacao
masc = img;
masc(:,:,:) = 255;
for i = 1: size(img,1)
    for j=1:size(img,2)
        if((img(i,j,1) < 126) && (img(i,j,2) < 126) && (img(i,j,3) > 126))
            masc(i,j,:) = 0;
        end
    end
end
figure,imshow(masc)

%binarizacao
bin = im2bw(masc);

%erosao seguida de dilatação para tirar os ruidos
se = strel('line',80,10);
erodedBW = imerode(bin,se);
BW2 = imdilate(erodedBW,se);
figure,imshow(BW2);
reg = regionprops(erodedBW,'Perimeter','Area','Centroid','BoundingBox','MajorAxisLength','MinorAxisLength');

%
allAreas = [reg.Area];
allPerimeters = [reg.Perimeter];
circularities = allPerimeters .^ 2 ./ (4 * pi * allAreas);

melanciaBoundingBox = [];
figure,imshow(img);
for i=1:length(reg)
    thisboundingbox = reg(i).BoundingBox;
    %verifica se é uma melancia
    if(reg(i).Area > 1000000)
        rectangle('Position',[thisboundingbox(1),thisboundingbox(2),thisboundingbox(3),thisboundingbox(4)],'EdgeColor','r','LineWidth',2);
        text(reg(i).Centroid(1), reg(i).Centroid(2),'Melancia','Color','r');
    end
    if(reg(i).Area < 120000 && reg(i).Area > 65000 && (reg(i).MajorAxisLength / 2) < reg(i).MinorAxisLength)
        rectangle('Position',[thisboundingbox(1),thisboundingbox(2),thisboundingbox(3),thisboundingbox(4)],'EdgeColor','r','LineWidth',2);
        %text(reg(i).Centroid(1),reg(i).Centroid(2),'laranja','Color','r');
        copia = img;
        imCrop = imcrop(copia,[thisboundingbox(1) thisboundingbox(2) thisboundingbox(3) thisboundingbox(4)]);
        %rotina para verificar se é uma maca através do canal rgb(red)
        maca = false;
        for x=1: size(imCrop,1)
            for y=1 :size(imCrop,2)
                if imCrop(x,y,1) > 165 && imCrop(x,y,2) < 126 && imCrop(x,y,3) < 126
                text(reg(i).Centroid(1),reg(i).Centroid(2),'maca','Color','r');
                maca = true;
                break;    
                end
            end
            if maca == true
                break;
            end
        end
        %se não for uma maca é uma laranja
        if maca == false && circularities(i) < 2.300
        text(reg(i).Centroid(1),reg(i).Centroid(2),'laranja','Color','r');
        end
    end
    
    %verifica se é um limao
    if(reg(i).Area < 65000 && reg(i).Area > 20000 && circularities(i) < 2.200)
        rectangle('Position',[thisboundingbox(1),thisboundingbox(2),thisboundingbox(3),thisboundingbox(4)],'EdgeColor','r','LineWidth',2);
        text(reg(i).Centroid(1),reg(i).Centroid(2),'limao','Color','r');
    end
    %verifica se é uma banana
    if(reg(i).Area < 150000 && reg(i).Area > 40000 && circularities(i) > 1.800 && (reg(i).MajorAxisLength / 2) > reg(i).MinorAxisLength)
        rectangle('Position',[thisboundingbox(1),thisboundingbox(2),thisboundingbox(3),thisboundingbox(4)],'EdgeColor','r','LineWidth',2);
        text(reg(i).Centroid(1),reg(i).Centroid(2),'banana','Color','r');
    end
end