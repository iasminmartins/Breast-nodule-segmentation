%% Load images and process ground truth
% Load binary segmented images and the ground truth image
binary_image_ac = imread('53586896_ACCONTORNO.jpg');
binary_image_fw = imread('53586896_FWCONTORNO.jpg');
binary_image_wc = imread('53586896_WCCONTORNO.jpg');
binary_image_td = imread('53586896_TDCONTORNO.jpg');
ground_truth_image = imread('53586896_binarymudada.tif');

% Define the binarization threshold
threshold = 0.9;

% Binarize the segmented images
binary_image_ac = imbinarize(binary_image_ac, threshold);
binary_image_fw = imbinarize(binary_image_fw, threshold);
binary_image_wc = imbinarize(binary_image_wc, threshold);
binary_image_td = imbinarize(binary_image_td, threshold);

% Binarize and fill holes in the ground truth image
binary_image_gt = imbinarize(ground_truth_image, threshold);
binary_image_gt = imfill(binary_image_gt, 'holes');

% Convert to grayscale for display
binary_gt_gray = uint8(binary_image_gt) * 255;
imshow(binary_gt_gray);
title('Ground Truth');

%% Eccentricity Calculation
% Function to calculate and display eccentricity for a binary image
function calculate_eccentricity(binary_image, label)
    [rows, cols] = find(binary_image); % Extract pixel coordinates
    covariance = cov(rows, cols); % Compute covariance matrix
    [~, eigenvalues] = eig(covariance); % Extract eigenvalues
    major_axis = 2 * sqrt(max(diag(eigenvalues))); % Major axis length
    minor_axis = 2 * sqrt(min(diag(eigenvalues))); % Minor axis length
    eccentricity = sqrt(1 - (minor_axis / major_axis)^2); % Compute eccentricity
    disp(['Eccentricity ' label ': ' num2str(eccentricity)]);
end

% Calculate eccentricity for each segmented image and the ground truth
calculate_eccentricity(binary_image_ac, 'ac');
calculate_eccentricity(binary_image_fw, 'fw');
calculate_eccentricity(binary_image_wc, 'wc');
calculate_eccentricity(binary_image_td, 'td');
calculate_eccentricity(binary_image_gt, 'gt');

%% Hausdorff Distance Calculation
% Function to calculate and display Hausdorff distance
function calculate_hausdorff(binary_image, binary_gt, label)
    hausdorff_distance = HausdorffDist(binary_image, binary_gt);
    disp(['Hausdorff Distance ' label ': ' num2str(hausdorff_distance)]);
end

% Calculate Hausdorff distance for each segmented image
calculate_hausdorff(binary_image_ac, binary_image_gt, 'ac');
calculate_hausdorff(binary_image_fw, binary_image_gt, 'fw');
calculate_hausdorff(binary_image_wc, binary_image_gt, 'wc');
calculate_hausdorff(binary_image_td, binary_image_gt, 'td');

%% Area Calculation (number of white pixels)
% Function to calculate and display the segmented area
function calculate_area(binary_image, label)
    segmented_area = sum(binary_image(:) == 1); % Count white pixels
    disp(['Segmented Area ' label ': ' num2str(segmented_area)]);
end

% Calculate segmented area for each image and the ground truth
calculate_area(binary_image_ac, 'ac');
calculate_area(binary_image_fw, 'fw');
calculate_area(binary_image_wc, 'wc');
calculate_area(binary_image_td, 'td');
calculate_area(binary_image_gt, 'gt');