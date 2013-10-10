% Local Feature Stencil Code
% CS 143 Computater Vision, Brown U.
% Written by James Hays

% Returns a set of interest points for the input image

% 'image' can be grayscale or color, your choice.
% 'feature_width', in pixels, is the local feature width. It might be
%   useful in this function in order to (a) suppress boundary interest
%   points (where a feature wouldn't fit entirely in the image, anyway)
%   or(b) scale the image filters being used. Or you can ignore it.

% 'x' and 'y' are nx1 vectors of x and y coordinates of interest points.
% 'confidence' is an nx1 vector indicating the strength of the interest
%   point. You might use this later or not.
% 'scale' and 'orientation' are nx1 vectors indicating the scale and
%   orientation of each interest point. These are OPTIONAL. By default you
%   do not need to make scale and orientation invariant local features.
function [x, y, confidence, scale, orientation] = get_interest_points(image, feature_width)

% Implement the Harris corner detector (See Szeliski 4.1.1) to start with.
% You can create additional interest point detector functions (e.g. MSER)
% for extra credit.

% If you're finding spurious interest point detections near the boundaries,
% it is safe to simply suppress the gradients / corners near the edges of
% the image.

% The lecture slides and textbook are a bit vague on how to do the
% non-maximum suppression once you've thresholded the cornerness score.
% You are free to experiment. Here are some helpful functions:
%  BWLABEL and the newer BWCONNCOMP will find connected components in 
% thresholded binary image. You could, for instance, take the maximum value
% within each component.
%  COLFILT can be used to run a max() operator on each sliding window. You
% could use this to ensure that every interest point is at a local maximum
% of cornerness.

my_filter_x = fspecial('sobel');
my_filter_y = my_filter_x';
my_gauss = fspecial('Gaussian');
%generate image derivatives
Ix = imfilter(image, my_filter_x);
Iy = imfilter(image, my_filter_y);

Ix2 = Ix .* Ix;
Iy2 = Iy .* Iy;
Ixy = Ix .* Iy;
%imshow(Iy2);
%imshow(Ixy);
cornerness = ...
    (imfilter(Ix2, my_gauss) .* imfilter(Iy2, my_gauss))...
    - (imfilter(Ixy, my_gauss).*imfilter(Ixy, my_gauss))...
    - (0.02 * ...
    ((imfilter(Ix2,my_gauss) + imfilter(Iy2, my_gauss))).^2);
imsize=size(cornerness);
no_edge_mask = zeros(imsize);
border_buffer=32;
no_edge_mask(border_buffer:imsize(1)-border_buffer, border_buffer:imsize(2)-border_buffer) = 1;
cornerness=cornerness .* no_edge_mask;

for y=1:imsize(1)
    for x=1:imsize(2)
        if abs(cornerness(y,x)) < 0.0001
            cornerness(y,x)=0;
        end
    end
end

suppressed = blkproc(cornerness, [feature_width feature_width], @non_max);

total_len = size(suppressed(:));
% a column of indices for use with ind2sub, e.g. [1;2;3...total_len]
suppressed_indices = [ 1:total_len(1) ]';
% a [total_len 2] matrix of cornerness scores w/ their indices in the 1 col
ind_val = horzcat(suppressed_indices, suppressed(:));
% sort the big matrix, so I can keep the rows I consider important
sorted = sortrows(ind_val, -2);
allzeros = find(sorted(:, 2)==0);
% allzeros(1)
% sorted(allzeros(1)-1:allzeros(1)+1, :)
best_indices = sorted(1:allzeros(1)-1, 1);
[y x] = ind2sub(size(image), best_indices); 

end

