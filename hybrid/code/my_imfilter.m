function output = my_imfilter(image, filter)
% This function is intended to behave like the built in function imfilter()
% See 'help imfilter' or 'help conv2'. While terms like "filtering" and
% "convolution" might be used interchangeably, and they are indeed nearly
% the same thing, there is a difference:
% from 'help filter2'
%    2-D correlation is related to 2-D convolution by a 180 degree rotation
%    of the filter matrix.

%find filter size
fSize = size(filter);
%store x & y edge space needed.
fxdist = (fSize(1)-1)/2;
fydist = (fSize(2)-1)/2;
%pad images
padded = padarray(image, [ fydist fxdist 0 ]);
imgsize = size(padded);

disp('padded image size');
disp(imgsize);

%initialize zeros array
newImage = zeros(imgsize);
disp('new image size');
disp(size(newImage));
sizeY=imgsize(1);
sizeX=imgsize(2);

for i=fydist+1:sizeY-fydist
    for j=fxdist+1:sizeX-fxdist
        for rgb=1:3
            tempMatrix=padded(i-fydist:i+fydist,j-fxdist:j+fxdist,rgb) .* filter;
            newImage(i,j,rgb)=sum(sum(tempMatrix));
        end
    end
end
disp(size(newImage))
originalSize=size(image);
output=newImage(fydist+1:originalSize(1)+(2*fydist), fxdist+1:originalSize(2)+(2*fxdist), :);
return;
% Your function should work for color images. Simply filter each color
% channel independently.

% Your function should work for filters of any width and height
% combination, as long as the width and height are odd (e.g. 1, 7, 9). This
% restriction makes it unambigious which pixel in the filter is the center
% pixel.

% Boundary handling can be tricky. The filter can't be centered on pixels
% at the image boundary without parts of the filter being out of bounds. If
% you look at 'help conv2' and 'help imfilter' you see that they have
% several options to deal with boundaries. You should simply recreate the
% default behavior of imfilter -- pad the input image with zeros, and
% return a filtered image which matches the input resolution. A better
% approach is to mirror the image content over the boundaries for padding.

% % Uncomment if you want to simply call imfilter so you can see the desired
% % behavior. When you write your actual solution, you can't use imfilter,
% % filter2, conv2, etc. Simply loop over all the pixels and do the actual
% % computation. It might be slow.
% output = imfilter(image, filter);


%%%%%%%%%%%%%%%%
% Your code here
%%%%%%%%%%%%%%%%





