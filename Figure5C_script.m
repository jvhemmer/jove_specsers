% Johann Hemmer
% 15 February 2023
% Plot Raman spectrum
close all
clear
clc

file_name = 'Ag@CS_10A Electrolyte - Isolated Donut 2023 February 28 15_19_05.csv';

bkg1_name = 'Ag@CS_10A CV Electrolyte - Background 1 2023 February 28 16_17_57.csv';
bkg2_name = 'Ag@CS_10A CV Electrolyte - Background 2 2023 February 28 16_18_27.csv';
bkg3_name = 'Ag@CS_10A CV Electrolyte - Background 3 2023 February 28 16_18_58.csv';

full_data = readmatrix(file_name);

bkg1_data = readmatrix(bkg1_name);
bkg2_data = readmatrix(bkg2_name);
bkg3_data = readmatrix(bkg3_name);

wavenumber = full_data(:,1);
intensity = full_data(:,2);

bkg1_intentisty = bkg1_data(:,2);
bkg2_intentisty = bkg2_data(:,2);
bkg3_intentisty = bkg3_data(:,2);

xwidth = 1024;

data_size = size(full_data);

frames = full_data(data_size(1), 4); % total number of frames

laser_wl = 642.675; % laser wavelength in nm

raman_shift = (10^7)*((1/laser_wl) - 1./full_data(1:1024,1)); % convert wavelengths to raman shift

%% Sample processing
spectrum = [raman_shift(1:xwidth) intensity(1:xwidth)]; % first spectrum

for f = 2:1:frames
    x = (f - 1)*xwidth + 1;
    spectrum = [spectrum intensity(x:x+xwidth - 1)]; % appending intensities
end

summed_spectrum = raman_shift(1:xwidth); % first column (raman shift)

for x = 1:1:xwidth
    summed_spectrum(x, 2) =  sum(spectrum(x, 2:frames+1)); % summing intensities of each wavenumber
end

%% Bkg processing

% Bkg 1
bkg1_spectrum = [raman_shift(1:xwidth) bkg1_intentisty(1:xwidth)]; % first spectrum

for f = 2:1:frames
    x = (f - 1)*xwidth + 1;
    bkg1_spectrum = [bkg1_spectrum bkg1_intentisty(x:x+xwidth - 1)]; % appending intensities
end

summed_bkg1_spectrum = raman_shift(1:xwidth); % first column (raman shift)

for x = 1:1:xwidth
    summed_bkg1_spectrum(x, 2) =  sum(bkg1_spectrum(x, 2:frames+1)); % summing intensities of each wavenumber
end

% Bkg 2
bkg2_spectrum = [raman_shift(1:xwidth) bkg2_intentisty(1:xwidth)]; % first spectrum

for f = 2:1:frames
    x = (f - 1)*xwidth + 1;
    bkg2_spectrum = [bkg2_spectrum bkg2_intentisty(x:x+xwidth - 1)]; % appending intensities
end

summed_bkg2_spectrum = raman_shift(1:xwidth); % first column (raman shift)

for x = 1:1:xwidth
    summed_bkg2_spectrum(x, 2) =  sum(bkg2_spectrum(x, 2:frames+1)); % summing intensities of each wavenumber
end

% Bkg 3
bkg3_spectrum = [raman_shift(1:xwidth) bkg3_intentisty(1:xwidth)]; % first spectrum

for f = 2:1:frames
    x = (f - 1)*xwidth + 1;
    bkg3_spectrum = [bkg3_spectrum bkg3_intentisty(x:x+xwidth - 1)]; % appending intensities
end

summed_bkg3_spectrum = raman_shift(1:xwidth); % first column (raman shift)

for x = 1:1:xwidth
    summed_bkg3_spectrum(x, 2) =  sum(bkg3_spectrum(x, 2:frames+1)); % summing intensities of each wavenumber
end

%% Background correction

% Background average
bkg_spectrum = raman_shift;
bkg_spectrum = [bkg_spectrum (bkg1_spectrum(:,2) + bkg2_spectrum(:,2) + bkg3_spectrum(:,2))/4];

% Background subtraction
summed_spectrum(:,2) = summed_spectrum(:,2) - bkg_spectrum(:,2);

f = figure;
a = axes;

FONT_SIZE = 16;
LINE_WIDTH = 1.5;

plot(raman_shift, summed_spectrum(:,2), ...
    'LineWidth', LINE_WIDTH, ...
    'Color','red')

% Figure options
set(gca, ...
    'FontSize', FONT_SIZE, ...
    'FontName', 'Times New Roman', ...
    'LineWidth', LINE_WIDTH)

% Axes options
xlim([400 1600]) % crop x-axis 

set(a, ... 
    'Xdir', 'reverse')

xlabel('Wavenumber (cm^{-1})', ...
    'FontSize', FONT_SIZE, ...
    'FontName', 'Times New Roman')

ylabel('Intensity (counts)', ...
    'FontSize', FONT_SIZE, ...
    'FontName', 'Times New Roman')

% Save

savefig('Figure5C.fig')

exportgraphics(f, ...
    'Figure5C.png', ...
    'Resolution', 600)

