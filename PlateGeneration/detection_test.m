clear all;
image = imread('back_mask_slam447.png');
figure(1);


s = regionprops(image,'centroid');
centroids = cat(1,s.Centroid);
imshow(image)
hold on
plot(centroids(:,1),centroids(:,2),'b*')
hold off