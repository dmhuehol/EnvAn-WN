function [] = wnaltyearplot(soundings,year,grounded)
%%wnaltyearplot
    %function to plot altitude of warmnoses against observation time given
    %an input year. Additionally, the estimated cloud base is plotted as
    %well.
    %
    %General form: wnaltyearplot(soundings,year,grounded)
    %Minimum acceptable form: wnaltyearplot(soundings,year)
    %
    %Figures:
    %   a maximum of three figures are produced:
    %       altitude of warmnoses aloft vs observation time for input year
    %       altitude of warmnoses grounded and aloft vs observation time for input year
    %       altitude of grounded warmnoses vs observation time for input year
    %   note that all figures also plot estimated cloud base
    %
    %
    %Inputs:
    %soundings: soundings data structure - must already be processed for
    %warmnoses (such as warmnosesfinal structure produced by IGRAimpfil).
    %year: an input year corresponding to a year of data within soundings.
    %grounded: optional input specifying whether to produce figures
    %pertaining to grounded warmnoses. If no value is input, grounded
    %figures will not be created. Input value of 1 to create grounded
    %figures.
    %
    %REQUIRES EXTERNAL FUNCTION: datetickzoom is used instead of MATLAB-native datetick
    %
    %Version Date: 6/28/17
    %Last major revision: 6/28/17
    %Written by Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %
    %See also IGRAimpfil, wnaltplot, newtip, datetickzoom
    %

if ~exist('grounded','var')
    grounded = 0;
end

fc = 1; %counter for building an overall array of bounds which cares not for ordinality
yc = 1; %year counter, prevents an army of zeros
ecount = 0; %error counter
datnum = zeros(length(soundings),4); %preallocate datenumber array
for f = 1:length(soundings) %unfortunately, nested structures means loops are the only option for extracting large quantities of data
    try %just in case something goes wrong
    datnum(f,1:4) = soundings(f).valid_date_num; %populate datenumber array with datenumbers from soundings structure
    if isequal(soundings(f).year,year)==1
        lbyear(yc) = soundings(f).warmnose.lowerboundg1; %grab upper bounds
        ubyear(yc) = soundings(f).warmnose.upperboundg1; %and lowerbounds
        yearnum(yc,1:4) = soundings(f).valid_date_num; %and times corresponding to the input year
        fc = fc+1; %this ensures that succeeding simultaneous warmnoses don't overwrite each other
    end
    if isfield(soundings(f).warmnose,'lowerbound2')
        %note that since the collections for first bounds occur outside of
        %any if statements, all first bounds are already caught without
        %adding anything to find them under this statement. This is also
        %true for the third bound.
        if isequal(soundings(f).year,year)==1
            lbyear2(yc) = soundings(f).warmnose.lowerboundg2;
            ubyear2(yc) = soundings(f).warmnose.upperboundg2;
            fc = fc+1;
        end
    end
    if isfield(soundings(f).warmnose,'lowerbound3')
        if isequal(soundings(f).year,year)==1
            lbyear3(yc) = soundings(f).warmnose.lowerboundg3;
            ubyear3(yc) = soundings(f).warmnose.upperboundg3;
            fc = fc+1;
        end
    end
    if isequal(soundings(f).year,year)==1
        yc = yc+1; %after grabbing all warmnose bounds, increment this to be sure that the array sizes stay consistent
    end
    catch ME; %duly noted
        ecount = ecount+1; %keep track of how many errors
        disp('If ecount is greater than 15, this data is likely corrupt!') %warn the user not to ignore errors
        disp(ecount) %doom approacheth
        if ecount>15 %prevent the user from ignoring the warnings
            msg = 'Something is wrong! Either the data is corrupt or the loop is improperly written.'
            error(msg); %IGRA v1 dataset rarely has an ecount>3
        end
        continue %and let's go on with our lives
    end
end

[~,yearpay] = size(lbyear); %find size of the largest matrix for the input year
if ~exist('lbyear3','var') %it happens
    ubyear3 = 0; %this way there don't need to be a billion exist checks
    lbyear3 = 0; %for lbyear and ubyear
end
%adjust size of other matrices to match
lbyear2(lbyear2==0) = NaN;
ubyear2(ubyear2==0) = NaN;
lbyear3(lbyear3==0) = NaN;
ubyear3(ubyear3==0) = NaN;
lbyear2(end:yearpay) = NaN;
lbyear3(end:yearpay) = NaN;
ubyear2(end:yearpay) = NaN;
ubyear3(end:yearpay) = NaN;
%detect grounded or near-grounded warmnoses
[gwnxyr,gwnyyr] = find(lbyear<0.5);
[gwnxyr2,gwnyyr2] = find(lbyear2<0.5);
[awnxyr,awnyyr] = find(lbyear>=0.5);
[awnxyr2,awnyyr2] = find(lbyear2>=0.5);
[awnxyr3,awnyyr3] = find(lbyear3>=0.5);
%save grounded/near-grounded data separately
groundedyear = NaN(1,yearpay);
groundedupperyear = NaN(1,yearpay);
groundedyear2 = NaN(1,yearpay);
groundedupperyear2 = NaN(1,yearpay);
groundedyear(1,gwnyyr) = lbyear(1,gwnyyr);
groundedupperyear(1,gwnyyr) = ubyear(1,gwnyyr);
groundedyear2(1,gwnyyr2) = lbyear2(1,gwnyyr2);
groundedupperyear2(1,gwnyyr2) = ubyear2(1,gwnyyr2);
%calculate grounded depths
groundedDepthyear = groundedupperyear-groundedyear;
grounded2Depthyear = groundedupperyear2-groundedyear2;
%replace grounded/near-grounded entries with NaN to keep sizes consistent
lbyear(gwnxyr,gwnyyr) = NaN;
ubyear(gwnxyr,gwnyyr) = NaN;
lbyear2(gwnxyr2,gwnyyr2) = NaN;
ubyear2(gwnxyr2,gwnyyr2) = NaN;
%calculate depths
boundsdepthyear = ubyear-lbyear;
boundsdepthyear2 = ubyear2-lbyear2;
boundsdepthyear3 = ubyear3-lbyear3;

%setup for time
[yrr,~] = size(yearnum); %find number of time entries
yearnum(:,5:6) = zeros(yrr,2); %make fake zero entries 
yrnumbers = datenum(yearnum); %now make them true MATLAB datenums
[uniIndexY] = find(unique(yrnumbers)); %bar requires that there are no duplicates in the x-data - this finds the indices of all unique datenumbers
dateForBarY = NaN(1,yearpay); %bar also requires that the X and Y have the same size
dateForBarY(uniIndexY) = unique(yrnumbers); %this creates a set of datenumbers that is the same size as the data, and does not contain duplicates

%This section is necessary to create the tooltip - dateForBar corresponds
%to location within warmnosesfinal; dateForBarY only designates a location
%within the year's worth of data
[~,pay] = size(soundings); %find size of the largest matrix - lowerbounds of first WN will contain entry for all WN soundings (as there can never be a second or third WN without there existing a first WN)
[sndr,~] = size(datnum); %find the number of rows
datnum(:,5:6) = zeros(sndr,2); %fill with zeros, this serves as entries for minutes and hours so that datenum will understand them
datenumbers = datenum(datnum); %now make them true MATLAB datenums
[uniIndex] = find(unique(datenumbers)); %bar requires that there are no duplicates in the x-data - this finds the indices of all unique datenumbers
dateForBar = NaN(1,pay); %bar also requires that the X and Y have the same size
dateForBar(uniIndex) = unique(datenumbers); %this creates a set of datenumbers that is the same size as the data, and does not contain duplicates

[firstdex] = find(dateForBar == dateForBarY(1)); %first index corresponding to the input year
[lastdex] = find(dateForBar == dateForBarY(end)); %last index corresponding to the input year
ggc = 1; %counter to create cloud base plot
ggd = 1;
cloudbase = NaN(1,length(dateForBarY)); %preallocate an array based on number of indices
moveon = 0;
for gg = firstdex:lastdex
    try %very rarely, a single sounding will be corrupt enough to cause this part of the function to fail
        %if this happens, this statement prevents it from ruining the entire function
        %error function within catch statement stops this from ignoring
        %true problems in the dataset
        [LCL] = cloudbaseplot(soundings,gg,0,0); %see cloudbaseplot function
        if isnan(LCL(2))~=1 %if there isn't a cloud
            cloudbase(ggc) = LCL(2); %LCL(2) is the LCL in height coordinates
            ggc = ggc+1; %increase counter
        else
            ggc = ggc+1; %keeps the size of the matrix correct
        end
    catch ME; %if there's a problem
        moveon = moveon+1; %keep track of how many problems there are
        if moveon>9 %if there's ten or more problems
            msg = 'Cloud base calculation failed 10 times! Check dataset for errors and try again.';
            error(msg) %stop everything
        end
        continue %otherwise move on
    end
end
disp(moveon); %let the user know how many errors were passed over while calculating cloud base

for gga = 1:length(dateForBarY)
    %cloud base is plotted as a horizontal line on the altitude plot; these
    %represent the left and right boundaries of said line
    lhb(gga) = dateForBarY(gga)-0.4; %left bounds
    rhb(gga) = dateForBarY(gga)+0.4; %right bounds
end
%replace zeroes with NaN; otherwise plotting gets screwed up as datenumbers
%should always be above 7*10^5
lhb(lhb==0) = NaN;
rhb(rhb==0) = NaN;
cloudbasealoft = NaN(1,length(cloudbase)); %cloud base for WN aloft is same size as grounded
%filter so cloud bases corresponding to grounded warmnoses are not plotted
cloudbasealoft(awnxyr,awnyyr) = cloudbase(awnxyr,awnyyr); %aloft in first
cloudbasealoft(awnxyr2,awnyyr2) = cloudbase(awnxyr2,awnyyr2); %aloft in second
cloudbasealoft(awnxyr3,awnyyr3) = cloudbase(awnxyr3,awnyyr3); %aloft in third
%extra time assets for plotting
firstnum = datenum([year,1,1,00,00,00]);
lastnum = datenum([year,12,31,00,00,00]);

%% Plotting
figure(1); %altitude of warmnoses aloft vs observation time for input year
barWN = bar(dateForBarY,cat(2,lbyear',boundsdepthyear'),'stacked'); %bar the dates vs the amalgamation of the lowerbounds and depth
set(barWN(1),'EdgeColor','none','FaceColor','w'); %change the color of the bar from 0 to min altitude to be invisible
set(barWN(2),'EdgeColor','b','FaceColor','b');
hold on
barWN2 = bar(dateForBarY,cat(2,lbyear2',boundsdepthyear2'),'stacked');
set(barWN2(1),'EdgeColor','none','FaceColor','w');
set(barWN2(2),'EdgeColor','b','FaceColor','b');
hold on
barWN3 = bar(dateForBarY,cat(2,lbyear3',boundsdepthyear3'),'stacked');
set(barWN3(1),'EdgeColor','none','FaceColor','w');
set(barWN3(2),'EdgeColor','b','FaceColor','b');
hold on
for gg = 1:length(dateForBarY)
    plot([lhb(gg),rhb(gg)],[cloudbasealoft(gg),cloudbasealoft(gg)],'r','LineWidth',1.5) %plot cloudbase as a horizontal line
    hold on
end
ylim([0 5])
xlim([firstnum-1,lastnum+1])
line1 = ('Altitude of Warmnoses Aloft vs Sounding Date');
yearstr = num2str(year);
line2 = (['KOKX Soundings Data ' yearstr]);
lines = {line1,line2};
title(lines)
xlabel('Observation Time (D/M/Y/H)')
ylabel('Height (km)')
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'XTick',dateForBarY) %set where XTicks are; make sure they're in the same place as the date information
datetickzoom('x',2,'keeplimits') %EXTERNAL FUNCTION - otherwise tick number is very inflexible
dcm_obj = datacursormode(figure(1));
    function [txt] = newtip(empt,event_obj)
        %%newtip
        % Customizes text of Data Cursor tooltips. This function should be nested
        % inside of another function; otherwise the only variables it can
        % access are empt and event_obj, which limits one's options to
        % basically zilch.
        %
        pos = get(event_obj,'Position'); %position has two values: one is maximum y value, one is the x value
        [dex] = find(dateForBar == pos(1)); %find the index corresponding to the datenumber; this is also the sounding's index in warmnosesfinal
        if pos(2)-soundings(dex).warmnose.upperg(1)<=0.0005 %the upper bound is either the first
            lowernum = pos(2)-soundings(dex).warmnose.gdepth1; %value of lower bound
        elseif pos(2)-soundings(dex).warmnose.upperg(2)<=0.0005 %second
            lowernum = pos(2)-soundings(dex).warmnose.gdepth2;
        elseif pos(2)-soundings(dex).warmnose.upperg(3)<=0.0005 %or third
            lowernum = pos(2)-soundings(dex).warmnose.gdepth3;
        else
            lowernum = 9999999; %go crazy
        end
        lowerstr = num2str(lowernum); %change to string
        txt = {['time: ',datestr(pos(1),'mm/dd/yy HH')],...
            ['Upper: ',num2str(pos(2))],['Lower: ',lowerstr]}; %this sets the tooltip format
    end
set(dcm_obj,'UpdateFcn',@newtip) %set the tooltips to use the newtip format
hold off


switch grounded %switch/case instead of if/elseif/else so adding new functionality later is easier
    case 1 %only show grounded plots if grounded = 1
        figure(2); %altitude of warmnoses grounded and aloft against observation time for input year
        barGN = bar(dateForBarY,cat(2,groundedyear',groundedDepthyear'),'stacked');
        set(barGN(1),'EdgeColor','none','FaceColor','w');
        set(barGN(2),'EdgeColor','g','FaceColor','g');
        hold on
        barGN2 = bar(dateForBarY,cat(2,groundedyear2',grounded2Depthyear'),'stacked');
        set(barGN2(1),'EdgeColor','none','FaceColor','w');
        set(barGN2(2),'EdgeColor','g','FaceColor','g');
        hold on
        barWN = bar(dateForBarY,cat(2,lbyear',boundsdepthyear'),'stacked'); %bar the dates vs the amalgamation of the lowerbounds and depth
        set(barWN(1),'EdgeColor','none','FaceColor','w'); %change the color of the bar from 0 to min altitude to be invisible
        set(barWN(2),'EdgeColor','b','FaceColor','b');
        hold on
        barWN2 = bar(dateForBarY,cat(2,lbyear2',boundsdepthyear2'),'stacked');
        set(barWN2(1),'EdgeColor','none','FaceColor','w');
        set(barWN2(2),'EdgeColor','b','FaceColor','b');
        hold on
        barWN3 = bar(dateForBarY,cat(2,lbyear3',boundsdepthyear3'),'stacked');
        set(barWN3(1),'EdgeColor','none','FaceColor','w');
        set(barWN3(2),'EdgeColor','b','FaceColor','b');
        ylim([0 5])
        line1 = ('Altitude of Warmnoses Aloft vs Sounding Date');
        yearstr = num2str(year);
        line2 = (['KOKX Soundings Data ' yearstr]);
        lines = {line1,line2};
        title(lines)
        xlabel('Observation Time (D/M/Y/H)')
        ylabel('Height (km)')
        set(gca,'XMinorTick','on','YMinorTick','on')
        set(gca,'XTick',dateForBarY) %set where XTicks are; make sure they're in the same place as the date information
        hold on
        for gg = 1:length(dateForBarY)
            plot([lhb(gg),rhb(gg)],[cloudbase(gg),cloudbase(gg)],'r','LineWidth',1.5) %plot cloudbase as a horizontal line
            hold on
        end
        for gg = 1:length(dateForBarY)
            plot([lhb(gg),rhb(gg)],[cloudbasealoft(gg),cloudbasealoft(gg)],'r','LineWidth',1.5) %plot cloudbase as a horizontal line
            hold on
        end
        datetickzoom('x',2) %EXTERNAL FUNCTION - otherwise tick number is very inflexible
        dcm_obj = datacursormode(figure(2));
        set(dcm_obj,'UpdateFcn',@newtip) %set the tooltips to use the newtip format
        
        figure(3); %altitude of grounded warmnoses vs observation time for input year
        barGN = bar(dateForBarY,cat(2,groundedyear',groundedDepthyear'),'stacked');
        set(barGN(1),'EdgeColor','none','FaceColor','w');
        set(barGN(2),'EdgeColor','g','FaceColor','g');
        hold on
        barGN2 = bar(dateForBarY,cat(2,groundedyear2',grounded2Depthyear'),'stacked');
        set(barGN2(1),'EdgeColor','none','FaceColor','w');
        set(barGN2(2),'EdgeColor','g','FaceColor','g');
        hold on
        for gg = 1:length(dateForBarY)
            plot([lhb(gg),rhb(gg)],[cloudbase(gg),cloudbase(gg)],'-r','LineWidth',1.5) %plot cloudbase as a horizontal line
            hold on
        end
        ylim([0 5])
        line1 = ('Altitude of Grounded Warmnoses vs Sounding Date');
        yearstr = num2str(year);
        line2 = (['KOKX Soundings Data ' yearstr]);
        lines = {line1,line2};
        title(lines)
        xlabel('Obsevation Time (D/M/Y/H)')
        ylabel('Height (km)')
        set(gca,'XMinorTick','on','YMinorTick','on')
        set(gca,'XTick',dateForBarY) %set where XTicks are; make sure they're in the same place as the date information
        datetickzoom('x',2) %EXTERNAL FUNCTION - otherwise tick number is very inflexible
        dcm_obj = datacursormode(figure(3));
        set(dcm_obj,'UpdateFcn',@newtip) %set the tooltips to use the newtip format
    otherwise
        disp('Grounded warmnoses were not plotted')
        return
end

end