function [img_features, labels] = ...
    get_sketch_tokens(train_img_dir, train_gt_dir, feature_params, num_sketch_tokens)

% 'img_features' is N x feature dimension. You probably want it to be
% 'single' precision to save memory.
% 'labels' is N x 1. labels(i) = 1 implies non-boundary, labels(i) = 2
% implies boundary or sketch token 1, labels(i) = 3 implies sketch token 2,
% etc... max(labels) should be num_sketch_tokens + 1;

%feature_params.CR = radius of the channel-derived patches. E.g. radius of
%7 would imply 15x15 features. The other entries of feature_params are for
%calling 'compute_daisy', but the starter code simply has the default
%DAISY values (which do work OK).

train_imgs = dir( fullfile( train_img_dir, '*.jpg' ));
% train_gts  = dir( fullfile( train_gt_dir,  '%.mat' )); %don't need to look them up, assume they exist for every image
num_imgs = length(train_imgs); % You don't need to sample them all while debugging.

num_samples = 30000;
pos_ratio   = 0.5; %The desired percentage of positive samples.
%It's not critical that your function find exactly this many samples.

%14 channels
%3 color
%3 gradient magnitude
%4(sig=0) + 4(sig=1.5) oriented magnitudes, 0, pi/4, pi/2, 3pi/4

% Don't bother with sampling / clustering the sketch patches initially.
daisy_feature_dims = feature_params.RQ * feature_params.TQ * feature_params.HQ + feature_params.HQ
sketch_features = zeros(num_samples, daisy_feature_dims, 'single');


% %DELETE THIS PLACEHOLDER
% labels = round(rand(num_samples,1))+1;
radius = feature_params.CR;
feat_size = 15 * 15 * 14;
img_features = zeros(num_samples,feat_size);
labels = zeros(num_samples, 1);
% img_features = single(img_features); %needs to be single precision
feats_logged = 0;
total_pos = 0;
for i = 1:num_imgs
    if radius ~= 7
        disp('shiiiiit');
    end
    fprintf(' Sampling patches / annotations from %s\n', train_imgs(i).name);
    [cur_pathstr,cur_name,cur_ext] = fileparts(train_imgs(i).name);
    cur_img = imread(fullfile(train_img_dir, train_imgs(i).name));
    
    annotation_struct  = load(fullfile(train_gt_dir, [cur_name '.mat']));
    
    
    % Pad the current image and then call 'channels = get_channels(cur_img)'
    cur_img = imPad(cur_img, (radius), 'replicate');
    cur_gt  = zeros(size(cur_img,1), size(cur_img,2));
    channels = get_channels(cur_img);
    ysize=size(cur_img, 1);
    xsize=size(cur_img, 2);
    num_pos=0;
    num_neg=0;
    pos = zeros([(num_samples/2), feat_size]);
    neg = zeros([(num_samples/2), feat_size]);
    if feats_logged >= num_samples
        fprintf('done after %i images', i);
        break;
    end
    for j = 1:length(annotation_struct.groundTruth)
        bound_pic = annotation_struct.groundTruth{j}.Boundaries;
        bound_pic = padarray(bound_pic, [7 7]);
        cur_gt = cur_gt + bound_pic;
    end
%     imshow(cur_gt);
%     waitforbuttonpress;
    for x=2:xsize-1
        for y=2:ysize-1
            if sum(sum(cur_gt(y-1:y+1,x-1:x+1))) < length(annotation_struct.groundTruth)-1
                cur_gt(y,x)=0;
            end
            if cur_gt(y,x) < length(annotation_struct.groundTruth)/3
                cur_gt(y,x)=0;
            end
        end
    end
%     
%     imshow(cur_gt);
%     waitforbuttonpress;
    %     imshow(cur_gt);
    %     waitforbuttonpress;
    dup=cur_img(:,:,:);
    freq=5;
    for y=1:size(cur_gt, 1)/freq
        for x=1:size(cur_gt, 2)/freq
            y2 = freq*y;
            x2 = freq*x;
            if y2 < radius+1 || y2 > size(cur_gt, 1)-radius || x2 < radius+1 || x2 > size(cur_gt, 2)-radius
                continue
            end
            if cur_gt(y2, x2)>length(annotation_struct.groundTruth)/3
                % at a boundary, add to pos examples
                if (num_pos < (num_samples)/num_imgs-1)
                    num_pos = num_pos + 1;
                    token = channels(y2-radius:y2+radius, x2-radius:x2+radius, :);
                    %                         imshow(bound_pic(y2-7:y2+7,x2-7:x2+7));
                    %                         waitforbuttonpress;
                    dup(y2-8:y2+8, x2-8, 2) = 255;
                    dup(y2-8, x2-8:x2+8, 2) = 255;
                    dup(y2-8:y2+8, x2+8, 2) = 255;
                    dup(y2+8, x2-8:x2+8, 2) = 255;
                    %                         imshow(dup);
                    %                         waitforbuttonpress;
                    %                         for i2=1:14
                    %                             imshow(token(:,:,i2));
                    %                             waitforbuttonpress;
                    %                         end
                    pos(num_pos, :) = reshape(token, 1, []);
                    edge=50;
                    %                         if x2 < edge || y2 < edge || y2 > ysize-edge || x2 > xsize-edge
                    %                             break
                    %                         end
                end
            else
                % not at a boundary, maybe add to negative examples
                if (num_neg < (num_samples/2)/num_imgs-1)
                    num_neg = num_neg + 1;
                    token = channels(y2-radius:y2+radius, x2-radius:x2+radius, :);
                    neg(num_neg, :) = reshape(token, 1, []);
                end
            end
        end
    end
%     imshow(dup);
%     waitforbuttonpress;
    %     end
    % Fill in some of the rows of img_features. Don't worry about filling
    % in sketch_features initially.
    for p=1:num_pos
        feat = pos(p, :);
        total_pos = total_pos +1;
        feats_logged = feats_logged + 1;
        img_features(feats_logged, :) = feat;
        labels(feats_logged, 1) = 2; %total_pos+1;
    end
    for n=1:num_neg
        feat = neg(n, :);
        feats_logged = feats_logged + 1;
        img_features(feats_logged, :) = feat;
        labels(feats_logged, 1) = 1;
    end
end
fprintf('%i feats logged\n', feats_logged);
% 'running kmeans'
if feats_logged < num_samples
    fprintf('only got %i feats logged\n', feats_logged);
    img_features = img_features(1:feats_logged, :);
    labels = labels(1:feats_logged, :);
end
% [centers, assignments] = vl_kmeans(img_features', num_sketch_tokens+1);
% labels = assignments';

% [centers, assignments] = vl_kmeans(X, K)
%  http://www.vlfeat.org/matlab/vl_kmeans.html
%   X is a d x M matrix of sampled SIFT features, where M is the number of
%    features sampled. M should be pretty large! Make sure matrix is of type
%    single to be safe. E.g. single(matrix).
%   'K' is the number of clusters desired (vocab_size)
%   'centers' is a d x K matrix of cluster centers
%   'assignments' is a 1 x M uint32 vector specifying which cluster every
%       feature was assigned to.
%
%   In project 3, we cared about the universal vocabulary specified by
%   'centers'. Here we don't. We care about 'assignments', telling us which
%   sketch tokens (and therefore which image features) correspond to the
%   same mid level boundary structure. We will keep 'centers' only for the
%   sake of visualization.

% Only cluster the Sketch Patches which have center pixel boundaries.




