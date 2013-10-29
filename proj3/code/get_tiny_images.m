% Starter code prepared by James Hays for CS 143, Brown University

%This feature is inspired by the simple tiny images used as features in 
%  80 million tiny images: a large dataset for non-parametric object and
%  scene recognition. A. Torralba, R. Fergus, W. T. Freeman. IEEE
%  Transactions on Pattern Analysis and Machine Intelligence, vol.30(11),
%  pp. 1958-1970, 2008. http://groups.csail.mit.edu/vision/TinyImages/

function image_feats = get_tiny_images(image_paths)
% image_paths is an N x 1 cell array of strings where each string is an
%  image path on the file system.
% image_feats is an N x d matrix of resized and then vectorized tiny
%  images. E.g. if the images are resized to 16x16, d would equal 256.
read_images=cellfun(@imread, image_paths, 'UniformOutput', false);
cellfunc = @(img)imresize(img, [16 16]);
read_shrunken_images=cellfun(cellfunc, read_images, 'UniformOutput', false);
my_reshape = @(img)reshape(img, 1, 256);
feat_cells = cellfun(my_reshape, read_shrunken_images, 'UniformOutput', false);
image_feats = cell2mat(feat_cells);

% suggested functions: imread, imresize






