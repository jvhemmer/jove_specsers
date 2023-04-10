% Johann Hemmer
% 4 April 2023
% Plot transient profile of with three different applied potentials and
% compare
clear
close all
clc

%% Load raw data files
% Get experiment and background data file paths
exp_file{1} = 'Donut (E2 Ag@CS_9B) 0.2s 160f 2023 March 31 14_51_53.csv';
exp_file{2} = 'Donut (E4 Ag@CS_9B) 0.2s 175f-Rep3 2023 March 31 15_01_47.csv';
exp_file{3} = 'Donut (E5 Ag@CS_9B) 0.2s 175f-Rep3 2023 March 31 15_03_46.csv';

bkg_file = 'Dark current (Ag@CS_9B) 1s 50f 2023-04-06 10_31_55.csv';

%% Read data files
% Read experiment data as matrix
for k = 1:length(exp_file)
    exp_data{k} = readmatrix(exp_file{k});

    % Frame data
    xwidth{k} = exp_data{1}(end, 6) + 1; % total number of wl values (all measurements must have the same)
    frames{k} = exp_data{k}(length(exp_data{k}), 4); % total number of frames
end

bkg_data = readmatrix(bkg_file);

%% Basic parameters
% Raman shift calculation
wl = flip(exp_data(:,1));
laser_wl = 642.675; % laser wavelength in nm
raman_shift = (10^7)*((1/laser_wl) - 1./exp_data{1}(1:1024,1)); % convert wavelengths to raman shift

bkg_xwidth = 1024; % from instrument
bkg_frames = 50; % from file name

% Time data
fps = 4.56;
frame_time = 1/fps;
exp_time = 35; % experiment time, in s

total_time = exp_time * fps;
quiet_time = 5;
delay = 0.5;

for h = 1:length(exp_data)
    time{h} = 0:frame_time:(frames{h} - 1)*frame_time;
    time{h} = time{h} - quiet_time - delay;
end

%% Bkg processing
bkg_intensity = bkg_data(:,2); % all intensities
bkg_spectrum = [raman_shift(1:bkg_xwidth) bkg_intensity(1:bkg_xwidth)]; % first spectrum

for f = 2:1:bkg_frames
    y = (f - 1)*bkg_xwidth + 1;
    bkg_spectrum = [bkg_spectrum bkg_intensity(y:y + bkg_xwidth - 1)]; % appending intensities
end

summed_bkg_spectrum = raman_shift(1:bkg_xwidth); % first column (raman shift)

for j = 1:1:bkg_xwidth
    summed_bkg_spectrum(j, 2) =  sum(bkg_spectrum(j, 2:bkg_frames+1)); % summing intensities of each wavenumber
end

avg_bkg = summed_bkg_spectrum(:, 2)/bkg_frames;

%% Exp processing
% Organizing the intensity data into individual columns for each frame
for l = 1:length(exp_data)
    intensity{l} = exp_data{l}(:,2);

    spectra{l} = intensity{l}(1:1024) - avg_bkg; % get the first column of intensities in the new spec matrix
    for i = 1:(frames{l} - 1)
        specnum{l} = intensity{l}(((1024 * i) + 1):(1024 * (i + 1))) - avg_bkg; % get the next 'intensity' array
        spectra{l} = [spectra{l} specnum{l}]; % append spectra matrix with the next 'intensity' array
        clear specnum
    end

    % Integration
    peak_start = 572;
    peak_end = 602;
    
    [~, idx1] = min(abs(peak_start - raman_shift));
    [~, idx2] = min(abs(peak_end - raman_shift));
    
    for f = 1:frames{l}
        A{l}(f) = abs(trapz(raman_shift(idx2:idx1), spectra{l}(idx2:idx1,f)));
    end
    
    [~, t0] = min(abs(0 - time{l}));
    
    AN{l} = A{l}./A{l}(t0);
end

%% Plots
LABEL_SIZE = 20;
NUMBER_SIZE = 18;
FONT = 'Arial';
LINE_WIDTH = 2;

fig = figure;

% Colors
blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290 0.6940 0.1250];
green = [0.4660 0.6740 0.1880];

colors = {blue; green; orange};

for m = 1:length(exp_data)
    plot(time{m}, AN{m}, ...
        'LineWidth', 2, ...
        'Color', colors{m})
    hold on
end

set(gca,'FontSize', NUMBER_SIZE, ...
    'Layer', 'top', ...
    'FontName', FONT, ...
    'LineWidth', LINE_WIDTH)

xlabel('Time (s)')

ylabel('Normalized {\it A}_{592}')

xlim([-5 30])

ylim([-0.1 1])

plot([0 0], ylim, ...
    'k--', ...
    'LineWidth', 2)

% %% Saving data
% Save figures
disp("Saving figures, don't close until finished.")

% .fig files
savefig(gcf, 'Figure7B.fig')

% .png files
exportgraphics(gcf, ...
    'Figure7B.png', ...
    'Resolution', 600)

disp("Done.")