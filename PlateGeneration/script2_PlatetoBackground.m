%Eike & Jonas
%Hausarbeit - Bild auf Bild setzen
%07.06.2019

%--------------------------------------------------------------------------
%------------------------------HAUSARBEIT----------------------------------
%--------------------------------------------------------------------------
clc;
clear;
close all;
%%Parameters:
%how often a background in background_images can be used:
repeat_background = 5;

%min/max resize amount of default plate size->120x630:
min_plate_size =0.5; 
max_plate_size = 1.6;

%%Read in Plate/background images: 
%get the directory path by double clicking on the folder struckure above
%the script Editor />Users>...
D_plates = '/Users/Jonas/Documents/MATLAB/PlateGeneration/plates/';
D_background = '/Users/Jonas/Documents/MATLAB/PlateGeneration/background_images/';
plates = dir(fullfile(D_plates,'*.png'));
background_files = dir(fullfile(D_background, '*.jpg'));

%%Iterate through each background file, and place a plate on it
% create a masked image for each combined image
background_counter = 0;
for ii = 1 : length(plates)
        %get back/plate and rezize them, create mask_back and mask_plate
        current_background = imread(fullfile(D_background,background_files(background_counter+1).name));
        current_plate = imread(fullfile(D_plates,plates(ii).name));
        current_background = imresize(current_background, [1536 2048]);
        current_plate = imresize(current_plate, [120 630]);
        combined = current_background;
        combined_mask=zeros(1536,2048,3,'uint8');
        current_plate_white =255* ones(120,630,3,'uint8');
        
        %%randomly resize plates in range:
        r_Size = min_plate_size + (max_plate_size - min_plate_size) .* rand();
        current_plate = imresize(current_plate,r_Size);
        current_plate_white = imresize(current_plate_white,r_Size);
        
        %%position of plate in image:
        %<-startcol => x |starts at 1 |ends at 2048- size(current_plate,2)
        %<-starrow => y |starts at 1 |ends at 1536 -size(current_plate,1)
        rX = floor((rand())* ((2048-size(current_plate,2)))); startcol = rX; 
        rY = floor((rand())* ((1536-size(current_plate,1)))); startrow = rY; 
        
        
        
        %%set plate onto background + set white plate onto black background
        combined(startrow:startrow+size(current_plate,1)-1,startcol:startcol+size(current_plate,2)-1, :) = current_plate;
        combined_mask(startrow:startrow+size(current_plate,1)-1,startcol:startcol+size(current_plate,2)-1, :) = current_plate_white;
        
        %%Name of written images
        savename_comb = ["back" "_" extractBefore(plates(ii).name,".") ".jpg"];
        savename_mask = ["back" "_" "mask" "_" extractBefore(plates(ii).name,".") ".jpg"];
        imwrite(combined,char("generated_combination/"+[strjoin(savename_comb,"")]), 'JPG');
        imwrite(combined_mask,char("generated_combination/"+[strjoin(savename_mask,"")]), 'JPG');
        
        %%Change background each 5 images::
        if(rem(ii,repeat_background) == 0) 
            fprintf("___newBackground: changeBackground... %d\n", ii);
            background_counter = background_counter +1;
        end
        
        %%End when last background file reached
        if(length(background_files)==background_counter)
            fprintf("___EndLoop: all Background files used -> End");
            return;
        end
        
        %%Display:::
        figure(1);
        subplot(1,2,1), imshow(combined), title("combined image");
        subplot(1,2,2), imshow(combined_mask), title("combined mask");
     
end
fprintf("___EndLoop: all Plate files used -> End");