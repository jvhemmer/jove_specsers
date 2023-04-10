% Johann Hemmer
% 3 April 2023
% Waterfall and waveform
clear
close all
clc

%% Load raw data files

% Get experiment data file path
exp_file = 'Donut (E4 Ag@CS_9B) 0.2s 175f-Rep3 2023 March 31 15_01_47.csv';
bkg_file = 'Dark current (Ag@CS_9B) 1s 50f 2023-04-06 10_31_55.csv';

%% Read data files

% Read experiment data as matrix
exp_data = readmatrix(exp_file);
bkg_data = readmatrix(bkg_file);

%% Basic parameters
% Raman shift calculation
wl = flip(exp_data(:,1));
laser_wl = 642.675; % laser wavelength in nm
raman_shift = (10^7)*((1/laser_wl) - 1./exp_data(1:1024,1)); % convert wavelengths to raman shift

% Frame data
xwidth = exp_data(end, 6) + 1; % total number of wl values (all measurements must have the same)
frames = exp_data(length(exp_data), 4); % total number of frames

bkg_xwidth = 1024;
bkg_frames = 50; % total number of frames of bkg file

fps = 4.56; % taken from LightView
frame_time = 1/fps;
exp_time = 35; % experiment time, in s

total_time = exp_time * fps;

time = 0:frame_time:(frames - 1)*frame_time;

offset = 6;
time = time - offset;

intensity = exp_data(:,2);
bkg_intensity = bkg_data(:,2);

%% Background processing
bkg_spectrum = [raman_shift(1:bkg_xwidth) bkg_intensity(1:bkg_xwidth)]; % first spectrum
for f = 2:1:bkg_frames
    y = (f - 1)*bkg_xwidth + 1;
    bkg_spectrum = [bkg_spectrum bkg_intensity(y:y + bkg_xwidth - 1)]; % appending intensities
end

summed_bkg_spectrum = raman_shift(1:bkg_xwidth); % first column (raman shift)

for j = 1:1:bkg_xwidth
    summed_bkg_spectrum(j, 2) =  sum(bkg_spectrum(j, 2:bkg_frames+1)); % summing intensities of each wavenumber
end

avg_bkg = summed_bkg_spectrum(:,2)/bkg_frames;

%% Exp processing
% Organizing the intensity data into individual columns for each frame
spectra = intensity(1:1024) - avg_bkg; % get the first column of intensities in the new spec matrix
for i = 1:(frames - 1)
    specnum = intensity(((1024 * i) + 1):(1024 * (i + 1))) - avg_bkg; % get the next 'intensity' array
    spectra = [spectra specnum]; % append spectra matrix with the next 'intensity' array
    clear specnum
end

%% Plots
LABEL_SIZE = 20;
NUMBER_SIZE = 18;
FONT = 'Arial';
LINE_WIDTH = 2;

f = figure;

pos = f.Position; % get figure position
pos(3) = pos(3)*2; % double the figure width to accommodate both plots
f.Position = pos; % set new figure position

% Plot Waterfall
p1 = subplot(1,2,1);

mesh(raman_shift, time, spectra')
view(2)
colormap('jet') % colormap of the mesh, 'jet' is a rainbow spectrum

set(gca,'FontSize', NUMBER_SIZE, ...
    'Layer', 'top', ...
    'FontName', FONT, ...
    'LineWidth', LINE_WIDTH, ...
    'YDir', 'reverse')

box on

% x-axis configuration
xlabel('Raman shift (cm^-^1)', ...
    'FontSize', LABEL_SIZE, ...
    'FontName', FONT)
xticks([600 1000 1400])

% y-axis configuration
ylabel('Time (s)', ...
    'FontSize', LABEL_SIZE, ...
    'FontName', FONT)

ylim([-5 30])
set(gca,'YTick',[0 10 20 30],'XLimitMethod','tight','ZLimitMethod','tight')

hold on

z = max(spectra(:)) + 0.1*max(spectra(:)); % increasing the value o z of the dashed line so it is visible
plot3(xlim, [0 0], [z z], 'w--', 'LineWidth', 1) % plotting horizontal white dashed line at t = 0

% ColorBar configuration
h = colorbar('northoutside', ... % colorbar is above the graph
    'FontSize', NUMBER_SIZE, ... % set font size
    'LineWidth', LINE_WIDTH); 

h.Ruler.Exponent = 4; % display values divided by 10^4

htitle = get(h, 'Title'); % getting title handle
htitle.FontSize = LABEL_SIZE; % changing font size of label
htitle.String = 'Intensity (counts)'; % adding title to label

grid off

pbaspect([2,1,1])

% Plot waveform
E1 = 0;
E2 = -0.4;

E = [];
for t = time
    if t < 0
        E = [E 0];
    else
        E = [E E2];
    end
end

p2 = subplot(1,2,2);
plot(E, time, ...
    'LineWidth', LINE_WIDTH, ...
    'Color', 'b');

set(gca,'FontSize', NUMBER_SIZE, ...
    'Layer', 'top', ...
    'FontName', FONT, ...
    'LineWidth', 2)

xlabel('E (V)', ...
    'FontSize', LABEL_SIZE, ...
    'FontName', FONT)

ylabel('Time (s)', ...
    'FontSize', LABEL_SIZE, ...
    'FontName', FONT)

set(gca, ...
    'YAxisLocation', 'right', ...
    'YDir', 'reverse')

margin = 0.2;

xlim([E2 * (1 + margin) (E1 - E2 * margin)]) % 10% margin
xticks([E2 E1])

ylim([-5 30])
yticks([0 10 20 30])

% adjust the height of the second subplot to match the first
p2.Position = [0.4753 0.2215 0.1034 0.4485];

%% Saving data
% Save figures
disp("Saving figures, don't close until finished.")

% .fig files
savefig(gcf, 'Figure7A.fig')

% .png files
exportgraphics(gcf, ...
    'Figure7A.png', ...
    'Resolution', 600)

disp("Done.")