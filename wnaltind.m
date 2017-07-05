function [] = wnaltind(y,m,d,h,sounding)
%%wnaltind
    %function to display an altitude plot of an individual warmnose, given
    %a date and a sounding structure containing warmnose information.
    %
    %General form: wnaltind(y,m,d,h,sounding)
    %
    %Outputs: none
    %
    %Inputs:
    %y: year
    %m: month
    %d: day
    %h: hour (always 00 or 12 for IGRA v1 data)
    %sounding: a soundings data structure--must be processed for warmnoses
    %
    %Generates a single altitude plot for all warmnoses; also displays
    %estimated cloud base.
    %
    %Version Date: 7/5/17
    %Last Major Revision: 7/5/17
    %Written by : Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %


[numdex] = findsnd(y,m,d,h,sounding); %find the index of the sounding for the input time

if ~exist('numdex','var') %if the index doesn't exist
    return %end the function; findsnd will take care of the warning message
end

numwarmnose = sounding(numdex).warmnose.numwarmnose; %find how many noses there are
LowerBound1 = sounding(numdex).warmnose.lowerboundg1; %lower bound of first warmnose; there will always be a first warmnose
Depth1 = sounding(numdex).warmnose.gdepth1; %first depth
%populate other nose variables with
LowerBound2 = NaN;
Depth2 = NaN;
LowerBound3 = NaN;
Depth3 = NaN;
if numwarmnose == 2
    LowerBound2 = sounding(numdex).warmnose.lowerboundg2; %second
    Depth2 = sounding(numdex).warmnose.upperboundg2-LowerBound2; %second depth
elseif numwarmnose == 3
    LowerBound2 = sounding(numdex).warmnose.lowerboundg2; %second
    Depth2 = sounding(numdex).warmnose.upperboundg2-LowerBound2; %second depth
    LowerBound3 = sounding(numdex).warmnose.lowerboundg3; %third
    Depth3 = sounding(numdex).warmnose.upperboundg3-LowerBound3; %third depth
end

[LCL] = cloudbaseplot(sounding,numdex,0,0); %locate cloud base (if possible)
try
    if isnan(LCL(2))~=1 %if the cloudbase exists
        cloudbase = LCL(2); %this is the cloud base in km
    elseif isnan(LCL(2))==1
        %do nothing
    else %in case there's something weird
        disp('Cloud base calculation failed!')
    end
catch ME; %in case there's something REALLY weird
    disp('Cloud base calculation failed!')
end

%% Plotting
figure(1); %altitude of warmnoses vs observation time for input year
%Concatenate lower bounds and depths; this will be plotted on a stacked bar
%
%Does not care if some entries are NaN
BoundDepth1 = cat(2,LowerBound1',Depth1');
BoundDepth2 = cat(2,LowerBound2',Depth2');
BoundDepth3 = cat(2,LowerBound3',Depth3');

barBlank = bar([NaN;NaN]); %puts an invisible bar before the warm nose ranged graph, so that the data is plotted in the center of the figure (yeah, this is kind of a cheat)
hold on
barWN = bar([BoundDepth1 BoundDepth2 BoundDepth3;NaN(1,6)],'stacked','BarWidth',0.28); %bar data; the NaN(1,6) command is required for 'stacked' to operate on a single bar
set(barWN(2),'DisplayName','Warm Nose') %this sets the text in the legend entry
%set bars in between the noses to be invisible
set(barWN(1),'EdgeColor','none','FaceColor','none'); %fun fact: none is actually a valid color
set(barWN(3),'EdgeColor','none','FaceColor','none');
set(barWN(5),'EdgeColor','none','FaceColor','none');
%set noses to be a different color
set(barWN(2),'EdgeColor','none','FaceColor','b');
set(barWN(4),'EdgeColor','none','FaceColor','b');
set(barWN(6),'EdgeColor','none','FaceColor','b');
set(gca,'xtick',1) %set axis so there is only one tick mark
hold on
barBlank2 = bar([NaN;NaN]); %puts an invisible bar after the warm nose ranged graph, so that the data is plotted in the center of the figure (yeah, this is kind of a cheat)
xlim([0 2]) %aesthetics
ylim([0 6]) %noses are essentially never higher than 5km
hold on
if exist('cloudbase','var')
    CBase = plot([0.7,1.3],[cloudbase cloudbase],'g','LineWidth',1.5,'DisplayName','Cloud Base') %plot cloudbase as a red horizontal line, with legend entry
end
line1 = ('Altitude of Warmnose(s) vs Sounding Date');
date = [y m d h]; %for title and label
dateString = num2str(date); %for title
line2 = (['KOKX Soundings Data ' dateString]);
lines = {line1,line2};
title(lines)
xlabel('Observation Time')
ylabel('Height (km)')
set(gca,'YMinorTick','on')
set(gca,'XTickLabel',dateString)
set(gca,'box','off') %disable Y tick marks on right side of figure
if exist('cloudbase','var') %check whether cloud base exists before creating legend
    legend([barWN(2),CBase]) %if there is a cloud, it deserves a legend entry
else
    legend(barWN(2)) %otherwise no
end


end