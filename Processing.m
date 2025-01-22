% Load the JPG Image
original_image = imread('image.jpg');
image_original = original_image;

% Wiener Filter 3 x 3
image_fwiener = wiener2(original_image, [3 3]);
image_td = wiener2(original_image, [3 3]);

% Wavelet Denoising and Thresholding
wavelet_name = 'coif5'; % Wavelet function name, e.g., 'coif5'

% Perform Wavelet decomposition
[approximation, horizontal, vertical, diagonal] = dwt2(original_image, wavelet_name);
thresh_constant = 3; % Constant for thresholding

% Threshold calculation using Rayleigh distribution
var_horizontal = var(horizontal(:));
mean_rayleigh_h = sqrt(var_horizontal) * sqrt(pi / 2);
std_rayleigh_h = sqrt(((4 - pi) / 2) * var_horizontal);
threshold_h = mean_rayleigh_h + (thresh_constant * std_rayleigh_h);

var_vertical = var(vertical(:));
mean_rayleigh_v = sqrt(var_vertical) * sqrt(pi / 2);
std_rayleigh_v = sqrt(((4 - pi) / 2) * var_vertical);
threshold_v = mean_rayleigh_v + (thresh_constant * std_rayleigh_v);

var_diagonal = var(diagonal(:));
mean_rayleigh_d = sqrt(var_diagonal) * sqrt(pi / 2);
std_rayleigh_d = sqrt(((4 - pi) / 2) * var_diagonal);
threshold_d = mean_rayleigh_d + (thresh_constant * std_rayleigh_d);

% Perform Denoising
HR = wdencmp('gbl', horizontal, wavelet_name, 1, threshold_h, 's', 1);
VR = wdencmp('gbl', vertical, wavelet_name, 1, threshold_v, 's', 1);
DR = wdencmp('gbl', diagonal, wavelet_name, 1, threshold_d, 's', 1);

% Wavelet reconstruction
wavelet_denoised_image = idwt2(approximation, HR, VR, DR, wavelet_name);

% Ensure pixel values are within range
if max(wavelet_denoised_image(:)) > 4095
    wavelet_denoised_image(wavelet_denoised_image > 4095) = 4095;
end
wavelet_denoised_image = uint16(wavelet_denoised_image);

% Apply CLAHE
normalized_approximation = approximation - min(approximation(:));
clahe_result = adapthisteq(normalized_approximation / max(normalized_approximation(:)), 'NumTiles', [15 15]);
clahe_result = clahe_result * max(normalized_approximation(:)) + min(approximation(:));

% Reconstruct image using CLAHE and Wavelet inverse
wavelet_clahe_image = idwt2(clahe_result, HR, VR, DR, wavelet_name);
if max(wavelet_clahe_image(:)) > 4095
    wavelet_clahe_image(wavelet_clahe_image > 4095) = 4095;
end
wavelet_clahe_image = uint16(wavelet_clahe_image);

% Process the second filtered image (TD)
[approximation, horizontal, vertical, diagonal] = dwt2(image_td, wavelet_name);

% Repeat similar thresholding and denoising process for image_td
% ... (Repeat the steps shown above for thresholds, denoising, and reconstruction)

% Segment regions interactively
message = 'Click to select the initial contour location. Double-click to confirm.';
title(message, 'Color', 'b', 'FontSize', 12);
mask = roipoly;

% Active Contour Segmentation
segmented_ac = activecontour(original_image, mask, 200);
segmented_fw = activecontour(image_fwiener, mask, 200);
segmented_wc = activecontour(wavelet_clahe_image, mask, 200);
segmented_td = activecontour(image_td, mask, 200);

% Plot Results
figure, imshow(segmented_ac);
title('Segmented Contour: AC');
figure, imshow(segmented_fw);
title('Segmented Contour: Wiener Filter');
figure, imshow(segmented_wc, 'DisplayRange', []);
title('Segmented Contour: Wavelet + CLAHE');
figure, imshow(segmented_td, 'DisplayRange', []);
title('Segmented Contour: TD');

figure, imshow(original_image);
title('Segmented Image: AC');
hold on;
visboundaries(segmented_ac, 'Color', 'y');
figure, imshow(image_fwiener);
title('Segmented Image: Wiener Filter');
hold on;
visboundaries(segmented_fw, 'Color', 'y');
figure, imshow(wavelet_clahe_image, 'DisplayRange', []);
title('Segmented Image: Wavelet + CLAHE');
hold on;
visboundaries(segmented_wc, 'Color', 'y');
figure, imshow(image_td, 'DisplayRange', []);
title('Segmented Image: TD');
hold on;
visboundaries(segmented_td, 'Color', 'y');