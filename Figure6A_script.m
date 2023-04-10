% Read in, analyze, and plot cyclic voltammograms
close all
clear 
clc

startpath= 'C:\Users\hemme\OneDrive - University of Louisville\0. Lab & Projects\9. JoVE\Figures\Figure CV\';

filename = 'Current vs Potential_edited.csv';
pathname = startpath;

CV1=readmatrix(strcat(pathname,filename));

% create a new directory to save analysis
idx0=strfind(filename,'.');
savename=[filename(1:(idx0-1)) '_Analysis'];
newdir=mkdir(startpath,savename);
newpath=[startpath,savename,'\'];

% Define varibales
pot1=CV1(:,1);

% Current conversion 
curr1=CV1(:,2)*1e6; % from A to A

r = 0.1; % electrode radius in cm

ECGA = pi*r^2; % electrochemical geometrical area

j = curr1/ECGA; % current density in µA/cm^2

figure(1)
plot(pot1(241:length(pot1)), ... ignore first cycle
    j(241:length(j)), ... ignore first cycle
    'LineWidth', 2, ...
    'Color', 'blue')

% axis tight
xlabel('E (V vs. Ag/AgCl)', ...
    'FontSize', 20, ...
    'Color','k', ...
    'FontName','Arial')
xticks([-0.6 -0.4 -0.2 0])
xlim([-0.6 0])

set(gca,'FontSize',18,'Linewidth',2)
ylabel('{\it j} (µA/cm^{2})','FontSize',20,'color','k','FontName','Arial')
ylim([-155 50])
set(gca,'FontSize',18)

expname=strcat('CV Analysis');
savenamefig=strcat(newpath,'\',expname,'.jpg');
saveas(gcf,savenamefig,'jpg')
savenamefig=strcat(newpath,'\',expname,'.m');
saveas(gcf,savenamefig,'m')


