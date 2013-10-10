function [ surpressed ] = non_max( image )
%NON_MAX Summary of this function goes here
%   Detailed explanation goes here
    filter_size = size(image);
    [row_max col_max ] = find(image==max(image(:)));
    filter = zeros(filter_size);
    filter(row_max, col_max) = 1;
    surpressed = image .* filter;

end

