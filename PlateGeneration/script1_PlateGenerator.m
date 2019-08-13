
clear all;

%% Parameter
nop = 20; % Anzahl Nummernschilder

mode = 5; % Art des Nummernschildes:
%   MODE=1-> Comlete Random 
%   MODE=2-> FL_restempty 
%   MODE=3-> SL_restempty
%   MODE=4-> FL_random
%   Mode=5-> SL_random

%Range to randomly offset on Plate
randomX_range = 5; %(fx 5-> -5 to 5):
randomY_range = 5;

%Range in wich to randomly rotate
randomDeg_range_tuev = 30; %(fx 30 -> -30 to 30):
randomDeg_range_land = 12;
randomDeg_range_chars = 4;


%% Kennzeicheeelemente+alphamaske laden und in double konvertieren
[sheet, sheetmap, sheetalpha] = imread('platesheet.png');
sheet = double(sheet)/255; sheetalpha = double(sheetalpha)/255;
% sheetalpha = repmat(sheetalpha,3);

%% Thresholding
sheetth = sum(sheet.*sheetalpha,3)>0.1;
sheetth = imfill(sheetth,'holes');

%% BoundingBoxen mit regionprops erhalten
labels = bwlabel(sheetth,8);
% figure(1), imshow(labels);
s = regionprops(sheetth,'BoundingBox');
boxes = cat(1,s.BoundingBox); %<- array of 65 bounding boxes
boxes(:,[1 2]) = ceil(boxes(:,[1 2])); %rount up left, top
boxes(:,[3 4]) = floor(boxes(:,[3 4])); %round down width, height

%% Zeichen-RegionIndex-Paare
zname = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p"...
    ,"q","r","s","t","u","v","w","x","y","z","ae","oe","ue","0","1","2","3"...
    ,"4","5","6","7","8","9","eu","plate","tuev1","tuev2","tuev3","tuev4"...
    ,"tuev5","tuev6","land1","land2","land3","land4","land5","land6"...
    ,"land7","land8","land9","land10","land11","land12","land13"...
    ,"land14","land15","land16", "", " "];

index = [1 13 20 24 28 32 36 40 44 48 52 57 60 2 15 21 25 29 33 37 41 45 49 53 58 61 54 56 62 3 16 22 26 30 34 38 42 46 50 8 4 6 11 17 7 12 18 9 14 19 23 27 31 35 39 43 47 51 55 59 63 64 65];
%% ColorLabeling for SegNet
labelname = ["Background" zname(1:39)]; %<- name a-z + ae,oe,ue +1-9
colorMat = (dec2base(0:39,4)-'0') .* 85;

for i=1:nop %<- anzahl nummernschilder
    % Beispiel Kennzeichen
    % Vor dem letzten Nummernblock muss ein "" eingefuegt werden.
    % text = ["f" "l" "tuev1" "land15" "x" "y" "" "9" "9"];

    % Random Kennzeichen
    % returns fx: "z"    "l"    "tuev1"    "land5"    "k"    "p"    ""    "2"    "6"    "7"
    % randi([1 26], [1 2]) -> z l (a-z)
    % randi([42 47], 1) -> tuev1 (tuev1-tuev6)
    % randi([48 63, 1) -> land5 (land 1 - land 16)
    % randi([1 26],[1 2]) -> k p (a-z)
    % 64 = "" 65 = " "<- empty
    % randi([30 39],[1 3])]-> 2 6 9(0-9)
    
    %für "f" "l" ####### -> 6 12, "s" "l" -> 19 12
    if mode==1
        is = [randi([1 26],[1 2]) randi([42 47],1) randi([48 63],1) randi([1 26],[1 2]) 64 randi([30 39],[1 3])];
    elseif mode==2
         is = [6 12 randi([42 47],1) 53 65 65 64 65 65 65];
    elseif mode==3
         is = [19 12 randi([42 47],1) 53 65 65 64 65 65 65];
    elseif mode==4
        is = [6 12 randi([42 47],1) 53 randi([1 26],[1 2]) 64 randi([30 39],[1 3])];
    elseif mode==5
        is = [19 12 randi([42 47],1) 53 randi([1 26],[1 2]) 64 randi([30 39],[1 3])];
    end
    
    text = zname(is);
    
    if mode==1 || mode==4 ||mode==5
    savename = [text([1 2 5 6 8 9 10])];
    elseif mode==2 || mode== 3
    savename = [text([1 2]) "#" i];
    end
    
    %% Hintergrundblech
    kennzeichen=zeros(200,1200,3);

    % Einfuegeposition
    xos = 1;
    yos = 1;

    % Eu-Schild
    box = boxes(index(find(zname=="eu")), :);
    x = sheet(box(2):box(2)+box(4)-1, box(1):box(1)+box(3)-1,:);
    xalpha = sheetalpha(box(2):box(2)+box(4)-1, box(1):box(1)+box(3)-1,:);
    kennzeichen(yos:yos+box(4)-1, xos:xos+box(3)-1,:) = ...
        (1-xalpha).*kennzeichen(yos:yos+box(4)-1, xos:xos+box(3)-1,:)...
        + ...
        xalpha.*x;
    xos = xos+box(3);

    % restliches Blech
    box = boxes(index(find(zname=="plate")), :);
    x = sheet(box(2):box(2)+box(4)-1, box(1):box(1)+box(3)-1,:);
    xalpha = sheetalpha(box(2):box(2)+box(4)-1, box(1):box(1)+box(3)-1,:);
    kennzeichen(yos:yos+box(4)-1, xos:xos+box(3)-1,:) = ...
        (1-xalpha).*kennzeichen(yos:yos+box(4)-1, xos:xos+box(3)-1,:)...
        + ...
        xalpha.*x;

    xos = xos+10;
    yos = yos+15;

    %% Kennzeichen generieren
    tuevy = -5; tuevx = 10;
    landy = 40; landx = 3;
    zeichenabstand = 7;
    space = 20;
    empty_char_space = 63;
    
    for i=1:numel(text)
        if text(i)== ""
            xos = xos + space;
        elseif text(i) == " "
                xos = xos + empty_char_space;
        else
            box = boxes(index(find(zname==text(i))), :);
     
            x = sheet(box(2):box(2)+box(4)-1, box(1):box(1)+box(3)-1,:);
            xalpha = sheetalpha(box(2):box(2)+box(4)-1, box(1):box(1)+box(3)-1,:);
            
                %RANDOM Y/X OFFSET Range
                rY = floor((rand()-1/2)* (randomY_range*2)); 
                rX = floor((rand()-1/2)* (randomX_range*2));
            
                %RANDOM ROTATION DEG Range
                rDeg_tuev = floor((rand()-1/2)*(randomDeg_range_tuev*2)); 
                rDeg_land = floor((rand()-1/2)*(randomDeg_range_land*2));
                rDeg_chars = floor((rand()-1/2)*(randomDeg_range_chars*2));
                
                
                
            if startsWith(text(i),'tuev')
                x=imrotate(x,rDeg_tuev, 'bicubic','crop');%random rotation in set range
               
                kennzeichen(yos+rY+tuevy:yos+rY+tuevy+box(4)-1, xos+rX+tuevx:xos+rX+tuevx+box(3)-1,:) = ...
                ((1-xalpha).*kennzeichen(yos+rY+tuevy:yos+rY+tuevy+box(4)-1, xos+rX+tuevx:xos+rX+tuevx+box(3)-1,:)...
                + ...
                xalpha.*x);
               
                
            
            elseif startsWith(text(i),'land')
                x=imrotate(x,rDeg_land, 'bicubic', 'crop');%random rotation in set range
                
                kennzeichen(yos+rY+landy:yos+rY+landy+box(4)-1, xos+rX+landx:xos+rX+landx+box(3)-1,:) = ...
                (1-xalpha).*kennzeichen(yos+rY+landy:yos+rY+landy+box(4)-1, xos+rX+landx:xos+rX+landx+box(3)-1,:)...
                + ...
                xalpha.*x;
                xos = xos+box(3)+zeichenabstand;
            else
                
                %random rotation of char in set range
                x=imrotate(x,rDeg_chars, 'bicubic');
                xalpha=imrotate(xalpha,rDeg_chars, 'bicubic');
                [xWidth, xHeight, m] = size(x);
                box(3) = xHeight;
                box(4) = xWidth;
                   
                kennzeichen(yos+rY:yos+rY+box(4)-1, xos+rX:xos+rX+box(3)-1,:) = ...
                (1-xalpha).*kennzeichen(yos+rY:yos+rY+box(4)-1, xos+rX:xos+rX+box(3)-1,:)...
                + ...
                xalpha.*x;
                xos = xos+box(3)+zeichenabstand;
          
            end
        end
    end
    kennzeichen(:, xos:xos+12,:) = kennzeichen(:, 1005:1017,:);
    kennzeichen(:, xos+12+1:end,:) = 0;
    fertig = kennzeichen(1:120, 1:xos+12,:);
    
    
    folder = char("plates/");
    if ~exist(folder, 'dir')
       mkdir(folder)
    end
        imwrite(fertig, char("plates/"+[strjoin(savename,"")+".png"]), 'PNG');
end

fprintf('%s files written... done ',num2str(nop));
