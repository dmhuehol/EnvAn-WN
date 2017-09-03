%%rangebardemo -- script to demonstrate two methods of creating a ranged
%bar graph without the use of boxplot.
%
%See also wnplot, wnAllPlot, wnYearPlot
%

testThickTop = [1200 800 900 1000];
testThickBottom = [1000 700 888 500];
testThickDiff=testThickTop-testThickBottom;

%% Stacked Technique
%Strength: Better for plotting over time; deals with different x axis
%values better.
%Weakness: When multiple noses are stacked on top of each other, it's
%impossible to use this technique.
%Written by: Matthew Miller
%Version Date: 6/12/17

figure;
barH=bar(linspace(datenum('20120101','yyyymmdd'),datenum('20120701','yyyymmdd'),4)',cat(2,testThickBottom',testThickDiff'),'stacked');
datetick
set(barH(1),'EdgeColor','none','FaceColor','w');

%% Patch Technique
%Strength: Draws the shape given specified coordinates, so it can handle with
%multiple nose scenarios.
%Weakness: more difficult to use with varying x.
%Written by: Daniel Hueholt
%Version Date: 9/1/17

figure;
theColorOrange = [255,154,0]./255;
noseWidth = 16; %Controls the size of the bar
transparency = 0.9;

dateNumber = datenum(2031,1,23,12,00,00);
xAll = [dateNumber dateNumber]; %x is the same for all noses

b1 = [0.3 0.87]; %Define lower and upper bounds for the nose
rangeBar1 = patch('xdata',xAll,'ydata',b1); %Use patch to draw a rectangle using the specified bounds
set(rangeBar1,'FaceColor',theColorOrange); 
set(rangeBar1,'EdgeColor',theColorOrange); 
set(rangeBar1,'FaceAlpha',transparency); 
set(rangeBar1,'EdgeAlpha',transparency); 
set(rangeBar1,'LineWidth',noseWidth); 
b2 = [1.5 2.2];
rangeBar2 = patch('xdata',xAll,'ydata',b2);
set(rangeBar2,'FaceColor',theColorOrange);
set(rangeBar2,'EdgeColor',theColorOrange);
set(rangeBar2,'FaceAlpha',transparency);
set(rangeBar2,'EdgeAlpha',transparency);
set(rangeBar2,'LineWidth',noseWidth);

% Figure settings
set(gca,'xTickLabel','')
set(gca,'xTick',[])
xlabel(datestr(dateNumber))
set(gca,'xTick',[])
xlabel(datestr(dateNumber))
ylim([0 3])