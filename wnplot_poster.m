function [] = wnplot_poster(y,m,d,h,sounding)
%%wnplot_poster
    %Function to display an altitude plot of an individual warmnose, given
    %a date and a sounding structure containing warmnose information. The
    %warm nose plot is generated with an eye towards being used on a
    %poster. A better version of this program, which requires MATLAB 2014b,
    %will be released shortly; therefore, wnplot_poster will be removed in
    %the next push.
    %
    %General form: wnplot_poster(y,m,d,h,sounding)
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
    %Version Date: 8/24/17
    %Last Major Revision: 7/5/17
    %Written by : Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %

try %Embedded in try/catch in case the input time is not in the structure
    [numdex] = findsnd(y,m,d,h,sounding); %find the index of the sounding for the input time
catch ME; %#ok %If no sounding matches up to the input
    return %end the function; findsnd has an appropriate command window statement.
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

%% Plotting
figure(1); %altitude of warmnoses vs observation time for input year
%Concatenate lower bounds and depths; this will be plotted on a stacked bar
%
%Does not care if some entries are NaN
BoundDepth1 = cat(2,LowerBound1,Depth1);
BoundDepth2 = cat(2,LowerBound2,Depth2);
BoundDepth3 = cat(2,LowerBound3,Depth3);

barWN = bar([BoundDepth1; NaN(1,2)],'stacked','BarWidth',0.28); %bar data; the NaN part of this command is required for 'stacked' to operate on a single bar
hold on
barWN2 = bar([BoundDepth2; NaN(1,2)],'stacked','BarWidth',0.28);
hold on
barWN3 = bar([BoundDepth3; NaN(1,2)],'stacked','BarWidth',0.28);
set(barWN(2),'DisplayName','Warm Nose') %this sets the text in the legend entry
%set bars in between the noses to be invisible
set(barWN(1),'EdgeColor','none','FaceColor','none'); %fun fact: none is actually a valid color
set(barWN2(1),'EdgeColor','none','FaceColor','none');
set(barWN3(1),'EdgeColor','none','FaceColor','none');
%set noses to be a different color
set(barWN(2),'EdgeColor','none','FaceColor','b');
set(barWN2(2),'EdgeColor','none','FaceColor','b');
set(barWN3(2),'EdgeColor','none','FaceColor','b');
set(gca,'xtick',1) %set axis so there is only one tick mark
hold on
barBlank2 = bar([NaN;NaN]); %puts an invisible bar after the warm nose ranged graph, so that the data is plotted in the center of the figure (yeah, this is kind of a cheat)
xlim([0.5 2]) %aesthetics
ylim([0 5]) %noses are essentially never higher than 5km
hold on
mn = 00;
sc = 00;
date = [y m d h mn sc]; %for title and label
dateString = datestr(date,'mmm dd, yyyy HH'); %for title
suffix = ' UTC';
dateString = strcat(dateString,suffix);
d = ylabel('Height (km)');
set(d,'FontSize',14)
set(gca,'YMinorTick','on')
set(gca,'XTickLabel',dateString)
set(gca,'FontSize',14)
set(gca,'box','off') %disable Y tick marks on right side of figure

end