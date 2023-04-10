% Johann Hemmer
% 1 March 2023
% Plot Raman waterfall for JoVE paper
close all
clear
clc

% ---
% LOADING RAW DATA FILES
% ---

file_name = 'Ag@CS_10A CV 50 mVps - Isolated Donut 2023 February 28 15_23_33.csv';

bkg1_name = 'Ag@CS_10A CV 50 mVps - Background 1 2023 February 28 15_52_36.csv';
bkg2_name = 'Ag@CS_10A CV 50 mVps - Background 2 2023 February 28 15_55_42.csv';
bkg3_name = 'Ag@CS_10A CV 50 mVps - Background 3 2023 February 28 15_58_34.csv';

full_data = readmatrix( ...
        strcat(data_path, file_name));

bkg1_data = readmatrix( ...
        strcat(data_path, bkg1_name));

bkg2_data = readmatrix( ...
        strcat(data_path, bkg2_name));

bkg3_data = readmatrix( ...
        strcat(data_path, bkg3_name));

% ---
% GENERAL PARAMETERS
% ---

data_size = size(full_data);

xwidth = 1024;

laser_wl = 642.675; % laser wavelength in nm

raman_shift = (10^7)*((1/laser_wl) - 1./full_data(1:1024,1)); % convert wavelengths to raman shift

% Calculating real time of each frame
frames = full_data(data_size(1), 4); % total number of frames

time_between_frames(1) = 0;
exposure_time(1) = full_data(1,6) - full_data(1,5);
for i = 1:1:length(full_data)/1024-1
    f = (i - 1)*1024 + 1;
    time_between_frames(i+1) = full_data(f+1024,5) - full_data(f,6);
    exposure_time(i+1) = full_data(f,6) - full_data(f,5);
end

avg_time_between_frames = mean(nonzeros(time_between_frames))/1e6; % in s
avg_exposure_time = mean(nonzeros(exposure_time))/1e6; % in s

frame_time = avg_time_between_frames + avg_exposure_time;

time = frame_time:frame_time:frames*frame_time;

% ---
% PERFORMING BACKGROUND CORRECTION
% ---

% Averaging background spectroelectrochemical measurements
for i = 1:3
    bkg1_int = bkg1_data(:, 2);
    bkg2_int = bkg2_data(:, 2);
    bkg3_int = bkg3_data(:, 2);

    bkg_avg = (bkg1_int + bkg2_int + bkg3_int)/3;
end

% Subtracting the background
intensity = full_data(:,2) - bkg_avg;


% ---
% ARRANGING SPECTRAL DATA FOR PLOTTING
% ---

spectra = intensity(1:1024); % get the first column of intensities in the new spec matrix
for i = 1:(frames - 1)
    specnum = intensity(((1024 * i) + 1):(1024 * (i + 1))); % get the next 'intensity' array
    spectra = [spectra specnum]; % append spectra matrix with the next 'intensity' array
    clear specnum
end

% ---
% PLOTTING DATA
% ---

LABEL_SIZE = 20;
NUMBER_SIZE = 18;
FONT = 'Arial';
LINE_WIDTH = 2;

f = figure;

axes1 = axes('Parent',f);
hold(axes1,'on');

mesh(raman_shift, time, spectra','Parent',axes1)
view(2)
colormap('jet') % colormap of the mesh, 'jet' is a rainbow spectrum

set(gca,'FontSize', NUMBER_SIZE, ...
    'Layer', 'top', ...
    'FontName', FONT, ...
    'YDir', 'reverse')

% x-axis configuration
xlabel('Raman shift (cm^-^1)', ...
    'FontSize', LABEL_SIZE, ...
    'FontName', FONT)
xticks([600 1000 1400])

% y-axis configuration
axis(axes1,'ij');
hold(axes1,'off');

ylabel('Time (s)', ...
    'FontSize', LABEL_SIZE, ...
    'FontName', FONT)

ylim(axes1,[0 96])
set(axes1,'YTick',[0 24 48 72 96],'XLimitMethod','tight','ZLimitMethod','tight')

h = colorbar('northoutside'); % colorbar is above the graph
set(h,'fontsize',18);

grid off

pbaspect([2,1,1])

% ---
% SAVING DATA AND PLOTS
% ---

[~, file_name, ~] = fileparts(strcat(data_path,file_name));

avg_bkg_spectrum = [bkg1_data(:,1) bkg_avg];

save('Average Background.txt', ... 
            'avg_bkg_spectrum', ... what variable to save
            '-ascii')

savefig('Figure6A_processed.fig')

exportgraphics(f, ...
    'Figure6A_processed.png', ...
    'Resolution', 600)
