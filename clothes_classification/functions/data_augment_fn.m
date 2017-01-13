function [ aug_features, aug_categories ] = data_augment_fn( features, categories, featlist )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

aug_features = features;
aug_categories = categories;

cursor = 1;

for modeind=1:length(featlist)
    modalita = featlist{modeind};
    if strcmp(modalita{1},'shapeprops')
        microdim = modalita{2};
        cursor = cursor + 3;
        new_masks = zeros( size(aug_features,1), microdim(1) * microdim(2));
        for i=1:size(aug_features,1)
            mask = aug_features(i, cursor:cursor + microdim(1) * microdim(2) - 1);
            mask = reshape(mask,microdim);
            mask = flip(mask,2);
            new_masks(i,:) = mask(:);
        end
        new_features = aug_features;
        new_features(:, cursor:cursor + microdim(1) * microdim(2) - 1) = new_masks;
        aug_features = [aug_features; new_features];
        aug_categories = [aug_categories; aug_categories];
        cursor = cursor + microdim(1) * microdim(2);
    elseif strcmp(modalita{1},'global_color')
        num_colors = modalita{2};
        colorspace = modalita{3};
        %dovrebbe essere sempre 3 per colore
        cursor = cursor + num_colors * 3;
    elseif strcmp(modalita{1},'color_text')
        num_patches = modalita{2};
        num_colors = modalita{3};
        color_mode = modalita{4};
        if strcmp(color_mode,'460')
            color_dim = 1;
        elseif strcmp(color_mode,'rgb')
            color_dim = 3;
        elseif strcmp(color_mode,'cielab')
            color_dim = 3;
        end
        
        single_patch_dim = (color_dim*num_colors+28);
        num_permutations = factorial(num_patches);
        permutations = perms(1:num_patches);
        new_patches = zeros(size(aug_features,1) * num_permutations, single_patch_dim * num_patches);
        for i=1:num_permutations
            for j=permutations(i,:)
                new_patches(((i-1)*size(aug_features,1))+1:(i*size(aug_features,1)),((j-1)*single_patch_dim)+1:j*single_patch_dim) = ...
                                aug_features(:,cursor+(j-1)*single_patch_dim:cursor-1+j*single_patch_dim);
            end
        end
        new_features = repmat(aug_features,num_permutations,1);
        new_features(:, cursor:cursor+(num_patches*single_patch_dim)-1) = new_patches;
        aug_features = new_features;
        aug_categories = repmat(aug_categories, num_permutations,1);
        cursor = cursor + (num_patches*single_patch_dim);
    end
end
    
end

