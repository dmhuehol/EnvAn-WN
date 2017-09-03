function [] = wnplot(y,m,d,h,sounding)
%%wnplot
    %Function to display a warm nose plot of an individual warmnose, given
    %a date and a sounding structure containing warmnose information.
    %
    %General form: wnplot(y,m,d,h,sounding)
    %
    %Outputs: none
    %
    %Inputs:
    %y: year
    %m: month
    %d: day
    %h: hour (always 00 or 12 for IGRA v1 data)
    %sounding: a soundings data structure--must have already been processed for warmnoses
    %
    %Generates a single altitude plot for all warmnoses
    %
    %
    %Version Date: 8/24/17
    %Last Major Revision: 7/5/17
    %Written by : Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %

%% Setup
% Look for the sounding number that corresponds to the desired time
try
    [numdex] = findsnd(y,m,d,h,sounding); %Call to findsnd
catch ME; %#ok
    disp([y m d h]);
    return %findsnd will take care of giving a warning message
end
    
% Min and sec are fake times, added to make the date usable with datestr
% near the end of the function
min = 0; 
sec = 0;
t = [y,m,d,h,min,sec];
dateNumber = datenum(t); %Make the date into a true datenumber

%% Warm nose operations 

numwarmnose = sounding(numdex).warmnose.numwarmnose; %Find how many noses there are
lowerBound1 = (sounding(numdex).warmnose.lowerboundg1); %Lower bound of first warmnose; there will always be a first warmnose
depth1 = sounding(numdex).warmnose.gdepth1; %First depth

% Populate other nose variables with NaNs
lowerBound2 = NaN;
depth2 = NaN;
lowerBound3 = NaN;
depth3 = NaN;

% If present, replace NaNs with real data
if numwarmnose == 2
    lowerBound2 = sounding(numdex).warmnose.lowerboundg2; %second
    depth2 = sounding(numdex).warmnose.upperboundg2-lowerBound2; %second depth
elseif numwarmnose == 3
    lowerBound2 = sounding(numdex).warmnose.lowerboundg2; %second
    depth2 = sounding(numdex).warmnose.upperboundg2-lowerBound2; %second depth
    lowerBound3 = sounding(numdex).warmnose.lowerboundg3; %third
    depth3 = sounding(numdex).warmnose.upperboundg3-lowerBound3; %third depth
end

% Upper bounds
upperBound1 = lowerBound1+depth1;
upperBound2 = lowerBound2+depth2;
upperBound3 = lowerBound3+depth3;

% If enabled, the following block can add estimated cloud base to the warm nose plot
% [LCL] = cloudbaseplot(sounding,numdex,0,0); %locate cloud base (if possible)
% try
%     if isnan(LCL(2))~=1 %if the cloudbase exists
%         cloudbase = LCL(2); %this is the cloud base in km
%     elseif isnan(LCL(2))==1
%         %do nothing
%     else %in case there's something weird
%         disp('Cloud base calculation failed!')
%     end
% catch ME; %in case there's something REALLY weird
%     disp('Cloud base calculation failed DRAMATICALLY!')
% end

%% Plotting
%Plot settings
theColorRed = [1 0 0]; %#%ok
theColorOrange = [255,154,0]./255; %#ok
theColorYellow = [255,244,0]./255; %#ok
theColorGreen = [0 1 0]; %#ok
theColorBlue = [0 0 1]; %#ok
theColorTurquoise = [0 255 255]./255; %#ok
theColorIndigo = [75,0,130]./255; %#ok
theColorPurple = [163,0,255]./255; %#ok
theColorDustyBlue = [0, 0.447, 0.741]; %#ok
transparency = 0.8;
noseWidth = 16; %Controls the size of the bar

figure(284); %Use a probably-unused figure handle

xAllNoses = [dateNumber dateNumber]; %x is the same for all noses
%Nose 1
yN1 = [lowerBound1 upperBound1]; %Define lower and upper bounds for the nose
nose1 = patch('xdata',xAllNoses,'ydata',yN1); %Use patch to draw a rectangle using the specified bounds
set(nose1,'FaceColor',theColorRed); %Nose color
set(nose1,'EdgeColor',theColorRed); %Nose edge color
set(nose1,'FaceAlpha',transparency); %Nose transparency
set(nose1,'EdgeAlpha',transparency); %Nose edge transparency
set(nose1,'LineWidth',noseWidth); %Nose width

%Nose 2
yN2 = [lowerBound2 upperBound2];
nose2 = patch('xdata',xAllNoses,'ydata',yN2);
set(nose2,'FaceColor',theColorRed);
set(nose2,'EdgeColor',theColorRed);
set(nose2,'FaceAlpha',transparency);
set(nose2,'EdgeAlpha',transparency);
set(nose2,'LineWidth',noseWidth);

%Nose 3
yN3 = [lowerBound3 upperBound3];
nose3 = patch('xdata',xAllNoses,'ydata',yN3);
set(nose3,'FaceColor',theColorRed);
set(nose3,'EdgeColor',theColorRed);
set(nose3,'FaceAlpha',transparency);
set(nose3,'EdgeAlpha',transparency);
set(nose3,'LineWidth',noseWidth);

% Figure settings
titleString = 'Warm nose plot for ';
titleMsg = [titleString datestr(dateNumber)];
title(titleMsg);
set(gca,'xTickLabel','')
set(gca,'xTick',[])
xlabel(datestr(dateNumber))
end