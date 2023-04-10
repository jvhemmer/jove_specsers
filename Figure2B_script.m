% Johann Hemmer
% 15 February 2023
% Plot UV-Vis data

close all
clear
clc

%% Open experiment data file and reading data
file_name = 'Ag@CS_7A_edited.csv';

full_data = readmatrix(file_name);

x = full_data(:,1); % wavelength
y = full_data(:,2); % transmittance (%)


%% Plotting figure
f = figure(1);

p = plot(x, y, ...
    'LineWidth', 2, ...
    'Color', 'blue');

xlabel('Wavelength (nm)', ...
    'FontSize', 20, ...
    'Color', 'k', ...
    'FontName', 'Arial')
xlim([200 800])

ylabel('Transmittance (%)', ...
    'FontSize', 20, ...
    'Color', 'k', ...
    'FontName', 'Arial')
ylim([0 100])

set(gca, ...
    'FontSize', 18, ...
    'LineWidth', 2)

%% Saving figure
savefig('Figure2B.fig')

exportgraphics(f, ...
    'Figure2B.png', ...
    'Resolution', 600)