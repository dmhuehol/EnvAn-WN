function [lowerboundsg,upperboundsg] = wnaltplot(sounding,year,groundedplot,quick)
%%wnaltplot
    %function to make altitude plots of the physical locations of warmnoses
    %in the atmosphere.
    %
    %General form: wnaltplot(sounding,year,groundedplot,quick)
    %Simplest possible syntax: wnaltplot(sounding)
    %   will create only one figure (altitude plot for all years)
            %see description of inputs
    %
    %Figures:
    %A maximum of nine figures will be created
    %   altitude of warmnoses aloft vs sounding date/time for all years (always)
    %   altitude of warmnoses aloft vs sounding date/time for input year (if given a year)
    %   altitude of warmnoses aloft and grounded vs sounding date/time for all years (if groundedplot = 1)
    %   altitude of lowest warmnose aloft vs sounding date/time for all years (if quick ~= 1)
    %   altitude of second warmnose aloft vs sounding date/time for all years (if quick ~= 1)
    %   altitude of highest warmnose aloft vs sounding date/time for all years (if quick ~=1)
    %   altitude of warmnoses aloft and grounded vs sounding date for input year (if given a year, groundedplot = 1 and quick ~=1)
    %   altitude of grounded warmnoses vs sounding date for input year (if given a year, groundedplot = 1, and quick ~= 1)
    %   altitude of grounded warmnoses vs sounding date for all years (if groundedplot = 1 and quick ~= 1)
    %
    %Outputs:
    %lowerboundsg: contains height of all lowerbounds in km, regardless of number
    %upperboundsg: contains height of all upperbounds in km, regardless of number
    %
    %Inputs:
    %sounding: a sounding data structure--must have warmnose information
    %already determined (such as warmnosesfinal structure from IGRAimpfil).
    %This is the only mandatory input.
    %year: will plot figures for only the given input year. If not entered,
    %will only plot those figures that have information for all years.
    %groundedplot: controls whether or not figures pertaining to grounded
    %warmnoses are created or not. Will only create these figures for a value of 1.
    %If left blank, these figures will not be plotted.
    %quick: 1 to plot only the most important figures, any other value to
    %plot all. If left blank, will plot only the most important figures
    %(altitude for aloft all years and for given year, as well as any groundedplots)
    %
    % REQUIRES EXTERNAL FUNCTION: datetickzoom is used instead of datetick
    %
    %Version Date: 6/20/17
    %Last major revision: 6/20/17
    %Written by Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %
    %See also: IGRAimpfil, nosedetect, wnaltyearplot, newtip, datetickzoom
    %
    
%% Check for inputs
if ~exist('quick','var') %assume to plot as few figures as possible
    quick = 1;
end
if ~exist('groundedplot','var')
    groundedplot = 0; %disable groundplots by default
end
if ~exist('year','var')
    year = 3333; %missing year value; prevents the creation of yearplots when a no year input was given
end

%% Import data
fc = 1; %counter for building an overall array of bounds which cares not for ordinality
yc = 1; %year counter, prevents an army of zeros
ecount = 0; %error counter
datnum = zeros(length(sounding),4); %preallocate for construction of a date array
DataIssueShownAlready = 0; %controls whether or not to display message regarding data quality (see last part of loop)
for f = 1:length(sounding) %storage in nested structures means that loops are the only option for extracting large quantities of data
    try %in case something goes wrong
    datnum(f,1:4) = sounding(f).valid_date_num; %store all datenumbers in the date array
    lowerboundsg1(f) = sounding(f).warmnose.lowerboundg1; %HEIGHT collection of first lower bounds
    lowerboundsg(fc) = sounding(f).warmnose.lowerboundg1; %overall collection of lower bounds, not separated by ordinality of nose
    upperboundsg1(f) = sounding(f).warmnose.upperboundg1; %HEIGHT collection of first upper bounds
    upperboundsg(fc) = sounding(f).warmnose.upperboundg1; %overall collection of upper bounds, not separated by ordinality of nose
    fc = fc+1; %this makes sure that any second/third noses within the same sounding don't overwrite the first noses in the non-ordinal collection
    if isequal(sounding(f).year,year)==1 %check if the year is equal to the year input
        lbyear(yc) = sounding(f).warmnose.lowerboundg1; %make separate arrays for lower bound
        ubyear(yc) = sounding(f).warmnose.upperboundg1; %and upper bound of the given year
        yearnum(yc,1:4) = sounding(f).valid_date_num; %separate datenumber array, built for those functions with year matching the input year
        
    end
    if isfield(sounding(f).warmnose,'lowerbound2')
        %note that since the collections for first bounds occur outside of
        %any if statements, all first bounds are already caught without
        %adding anything to find them under this statement. This is also
        %true for the third bound.
        lowerboundsg2(f) = sounding(f).warmnose.lowerboundg2; %HEIGHT collection of second lower bounds
        lowerboundsg(fc) = sounding(f).warmnose.lowerboundg2; %overall collection of lower bounds, not separated by ordinality
        upperboundsg2(f) = sounding(f).warmnose.upperboundg2; %HEIGHT collection of second upper bounds
        upperboundsg(fc) = sounding(f).warmnose.upperboundg2; %overall collection of upper bounds, not separated by ordinality
        fc = fc+1;
        if isequal(sounding(f).year,year)==1
            lbyear2(yc) = sounding(f).warmnose.lowerboundg2;
            ubyear2(yc) = sounding(f).warmnose.upperboundg2;
        end
    end
    if isfield(sounding(f).warmnose,'lowerbound3')
        lowerboundsg3(f) = sounding(f).warmnose.lowerboundg3; %HEIGHT collection of third lower bounds
        lowerboundsg(fc) = sounding(f).warmnose.lowerboundg3; %overall collection of lower bounds, not separated by ordinality
        upperboundsg3(f) = sounding(f).warmnose.upperboundg3; %HEIGHT collection of third upper bounds
        upperboundsg(fc) = sounding(f).warmnose.upperboundg3; %overall collection of upper bounds, not separated by ordinality
        fc = fc+1; 
        if isequal(sounding(f).year,year)==1
            lbyear3(yc) = sounding(f).warmnose.lowerboundg3;
            ubyear3(yc) = sounding(f).warmnose.upperboundg3;
        end
    end
    if isequal(sounding(f).year,year)==1
        yc = yc+1; %once all bounds have been acquired, increment the year counter
    end
    catch ME; %errors are duly noted
        ecount = ecount+1; %keep track of how many errors there are
        if DataIssueShownAlready == 0;
            disp('If ecount is greater than 10, this data is likely corrupt!')
            DataIssueShownAlready = 1; %prevents the above message from appearing multiple times
        end
        disp(ecount) %in the IGRA v1 data from 2002 to 2016, this shouldn't be greater than 3
        if ecount>15
            msg = 'Something is wrong! Either the data is corrupt or the loop is improperly written.'
            error(msg); %this prevents the try/catch-continue from masking a dataset with true issues
        end
        continue %and now we move on with our lives
    end
end

%% Setup for plotting
[~,pay] = size(lowerboundsg1); %find size of the largest matrix - lowerbounds of first WN will contain entry for all WN soundings (as there can never be a second or third WN without there existing a first WN)

%fill out other matrices with NaNs; otherwise plotting is a total mess
lowerboundsg2(end:pay) = NaN;
lowerboundsg3(end:pay) = NaN;
upperboundsg2(end:pay) = NaN;
upperboundsg3(end:pay) = NaN;

[fro,fco] = find(lowerboundsg1<0.5); %find lowerbounds in first set which are in contact or close to in contact with the ground
[fro2,fco2] = find(lowerboundsg2<0.5); %find lowerbounds in second set which are in contact or close to the ground

%needs to be same size as original; NaNs ensure that plotting behaves properly
grounded = NaN(1,pay);
groundedupper = NaN(1,pay);
grounded2 = NaN(1,pay);
groundedupper2 = NaN(1,pay);

grounded(1,fco) = lowerboundsg1(1,fco); %save the grounded ones separately; this way the data can still be use without clogging up WN aloft figures
groundedupper(1,fco) = upperboundsg1(1,fco); %grounded upper bounds
grounded2(1,fco2) = lowerboundsg2(1,fco2); %near-grounded lower bounds
groundedupper2(1,fco2) = upperboundsg2(1,fco2); %near-grounded upper bounds
groundedDepth = groundedupper-grounded; %grounded depth
grounded2Depth = groundedupper2-grounded2; %near-grounded depth

%replace grounded bounds with NaN in original matrix so that the numbers stay intact
lowerboundsg1(fro,fco) = NaN;
upperboundsg1(fro,fco) = NaN;
lowerboundsg2(fro2,fco2) = NaN;
upperboundsg2(fro2,fco2) = NaN;
boundsdepth = upperboundsg1-lowerboundsg1;
boundsdepth2 = upperboundsg2-lowerboundsg2;
boundsdepth3 = upperboundsg3-lowerboundsg3;

%setup for time axis
[sndr,~] = size(datnum); %find the number of rows
datnum(:,5:6) = zeros(sndr,2); %fill with zeros, this serves as entries for minutes and hours so that datenum will understand them
datenumbers = datenum(datnum); %now make them true MATLAB datenums
[uniIndex] = find(unique(datenumbers)); %bar requires that there are no duplicates in the x-data - this finds the indices of all unique datenumbers
dateForBar = NaN(1,pay); %bar also requires that the X and Y have the same size
dateForBar(uniIndex) = unique(datenumbers); %this creates a set of datenumbers that is the same size as the data, and does not contain duplicates

%% Plotting

figure(1); %this is altitudes of all warmnoses aloft vs time for all years
barWN = bar(dateForBar,cat(2,lowerboundsg1',boundsdepth'),'stacked'); %bar the dates vs the amalgamation of the lowerbounds and depth
set(barWN(1),'EdgeColor','none','FaceColor','w'); %change the color of the bar from 0 to min altitude to be invisible
set(barWN(2),'EdgeColor','b','FaceColor','b');
hold on
barWN2 = bar(dateForBar,cat(2,lowerboundsg2',boundsdepth2'),'stacked');
set(barWN2(1),'EdgeColor','none','FaceColor','w');
set(barWN2(2),'EdgeColor','b','FaceColor','b');
hold on
barWN3 = bar(dateForBar,cat(2,lowerboundsg3',boundsdepth3'),'stacked');
set(barWN3(1),'EdgeColor','none','FaceColor','w');
set(barWN3(2),'EdgeColor','b','FaceColor','b');
line1 = ('Altitude of Warmnoses Aloft vs Sounding Date');
line2 = ('KOKX Soundings Data 2002-2016');
lines = {line1,line2};
title(lines)
xlabel('Observation Time (M/D/Y/H)')
ylabel('Height (km)')
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'XTick',dateForBar) %set where XTicks are; make sure they're in the same place as the date information
datetickzoom('x',2) %EXTERNAL FUNCTION - otherwise tick number is very inflexible
dcm_obj = datacursormode(figure(1));
    function [txt] = newtip(empt,event_obj)
        %See newtip for full function documentation
        % Customizes text of Data Cursor tooltips
        pos = get(event_obj,'Position'); %position has two values: one is maximum y value, one is the x value (time)
        [dex] = find(dateForBar == pos(1));
        if pos(2)-sounding(dex).warmnose.upperg(1)<=0.0005
            lowernum = pos(2)-sounding(dex).warmnose.gdepth1;
        elseif pos(2)-sounding(dex).warmnose.upperg(2)<=0.0005
            lowernum = pos(2)-sounding(dex).warmnose.gdepth2;
        elseif pos(2)-sounding(dex).warmnose.upperg(3)<=0.0005
            lowernum = pos(2)-sounding(dex).warmnose.gdepth3;
        else
            lowernum = 345678;
        end
        lowerstr = num2str(lowernum);
        txt = {['time: ',datestr(pos(1),'mm/dd/yy HH')],...
            ['Upper: ',num2str(pos(2))],['Lower: ',lowerstr]}; %this sets the tooltip format
    end
set(dcm_obj,'UpdateFcn',@newtip) %set the tooltips to use the newtip format

%% Years
if year~=3333 %if the user did not leave the year input blank
    [~,yearpay] = size(lbyear); %find size of the largest matrix for the input year
    %make sure sizes of all bounds matrices match; otherwise plotting is a disaster
    lbyear2(lbyear2==0) = NaN;
    ubyear2(ubyear2==0) = NaN;
    lbyear3(lbyear3==0) = NaN;
    ubyear3(ubyear3==0) = NaN;
    lbyear2(end:yearpay) = NaN;
    lbyear3(end:yearpay) = NaN;
    ubyear2(end:yearpay) = NaN;
    ubyear3(end:yearpay) = NaN;
    
    %find warmnoses which are truly grounded or close to it
    [gwnxyr,gwnyyr] = find(lbyear<0.5);
    [gwnxyr2,gwnyyr2] = find(lbyear2<0.5);
    %separate out the grounded/near-grounded warmnoses
    groundedyear = NaN(1,yearpay);
    groundedupperyear = NaN(1,yearpay);
    groundedyear2 = NaN(1,yearpay);
    groundedupperyear2 = NaN(1,yearpay);
    groundedyear(1,gwnyyr) = lbyear(1,gwnyyr);
    groundedupperyear(1,gwnyyr) = ubyear(1,gwnyyr);
    groundedyear2(1,gwnyyr2) = lbyear2(1,gwnyyr2);
    groundedupperyear2(1,gwnyyr2) = ubyear2(1,gwnyyr2);
    groundedDepthyear = groundedupperyear-groundedyear;
    grounded2Depthyear = groundedupperyear2-groundedyear2;
    %replace grounded/near-grounded entries with NaNs in the original matrices
    lbyear(gwnxyr,gwnyyr) = NaN;
    ubyear(gwnxyr,gwnyyr) = NaN;
    lbyear2(gwnxyr2,gwnyyr2) = NaN;
    ubyear2(gwnxyr2,gwnyyr2) = NaN;
    %calculate depths
    boundsdepthyear = ubyear-lbyear;
    boundsdepthyear2 = ubyear2-lbyear2;
    boundsdepthyear3 = ubyear3-lbyear3;
    
    [yrr,~] = size(yearnum); %find number of time entries
    yearnum(:,5:6) = zeros(yrr,2); %make fake zero entries
    yrnumbers = datenum(yearnum); %now make them true MATLAB datenums
    [uniIndexY] = find(unique(yrnumbers)); %bar requires that there are no duplicates in the x-data - this finds the indices of all unique datenumbers
    dateForBarY = NaN(1,yearpay); %bar also requires that the X and Y have the same size
    dateForBarY(uniIndexY) = unique(yrnumbers); %this creates a set of datenumbers that is the same size as the data, and does not contain duplicates

    figure(2); %this is the plot of altitudes of all warmnoses aloft vs sounding date for the input year
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
    ylim([0 5]) %warmnoses do not occur above 5 km at KOKX in the IGRA v1 dataset
    line1 = ('Altitude of Warmnoses Aloft vs Sounding Date');
    yearstr = num2str(year);
    line2 = (['KOKX Soundings Data ' yearstr]);
    lines = {line1,line2};
    title(lines)
    xlabel('Observation Time (M/D/Y/H)')
    ylabel('Height (km)')
    set(gca,'XMinorTick','on','YMinorTick','on')
    set(gca,'XTick',dateForBarY) %set where XTicks are; make sure they're in the same place as the date information
    datetickzoom('x',2) %EXTERNAL FUNCTION - otherwise tick number is very inflexible
    dcm_obj = datacursormode(figure(2));
    set(dcm_obj,'UpdateFcn',@newtip)
else
    suppressant = 'Shh';
end

%% Grounded Warmnoses
switch groundedplot %check the entdoaisn bcoci
    case 1 %this is the only time that groundedplots should be shown
        figure(3); %this is all warmnoses vs date, both grounded and aloft, for all years
        barWN = bar(dateForBar,cat(2,lowerboundsg1',boundsdepth'),'stacked');
        set(barWN(1),'EdgeColor','none','FaceColor','w');
        set(barWN(2),'EdgeColor','b','FaceColor','b');
        hold on
        barWN2 = bar(dateForBar,cat(2,lowerboundsg2',boundsdepth2'),'stacked');
        set(barWN2(1),'EdgeColor','none','FaceColor','w');
        set(barWN2(2),'EdgeColor','g','FaceColor','g');
        hold on
        barWN3 = bar(dateForBar,cat(2,lowerboundsg3',boundsdepth3'),'stacked');
        set(barWN3(1),'EdgeColor','none','FaceColor','w');
        set(barWN3(2),'EdgeColor','r','FaceColor','r');
        barGN = bar(dateForBar,cat(2,grounded',groundedDepth'),'stacked');
        set(barGN(1),'EdgeColor','none','FaceColor','w');
        set(barGN(2),'EdgeColor','k','FaceColor','k');
        barGN2 = bar(dateForBar,cat(2,grounded2',grounded2Depth'),'stacked');
        set(barGN2(1),'EdgeColor','none','FaceColor','w');
        set(barGN2(1),'EdgeColor','k','FaceColor','k');
        line1 = ('Altitude of WN Aloft and Grounded WN vs Sounding Date');
        line2 = ('KOKX Soundings Data 2002-2016');
        fig3key = ('black=grounded, blue=first, green=second, red=third')
        lines = {line1,line2};
        title(lines)
        xlabel('Observation Time (M/D/Y/H)')
        ylabel('Height (km)')
        set(gca,'XMinorTick','on','YMinorTick','on')
        set(gca,'XTick',dateForBar)
        datetickzoom('x',2)
        dcm_obj = datacursormode(figure(3));
        set(dcm_obj,'UpdateFcn',@newtip)
    otherwise %this is a switch/case mostly just in case there's more to do with this in the future
        disp('Grounded warmnoses were not plotted') %this ensures that the user knows that it's possible to plot grounded warmnoses (in case they skimmed the help)
end

if quick == 1 %if the user requested only the most essential plots
    return %stop right now, we're done here
end

%% Quick

figure(4); %this is altitude of lowest warmnose aloft vs date for all years
barWN = bar(dateForBar,cat(2,lowerboundsg1',boundsdepth'),'stacked');
set(barWN(1),'EdgeColor','none','FaceColor','w');
set(barWN(2),'EdgeColor','b','FaceColor','b');
xlabel('Observation Time (M/D/Y/H)')
ylabel('Height (km)')
line1 = ('Altitude of Lowest Warmnose Aloft vs Sounding Date');
line2 = ('KOKX Soundings Data 2002-2016');
lines = {line1,line2};
title(lines)
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'XTick',dateForBar)
box off
datetickzoom('x',2) %NOTE: requires external function DATETICKZOOM
dcm_obj = datacursormode(figure(4));
set(dcm_obj,'UpdateFcn',@newtip)

figure(5); %this is the altitude of the second warmnose aloft vs date for all years
barWN = bar(dateForBar,cat(2,lowerboundsg2',boundsdepth2'),'stacked');
set(barWN(1),'EdgeColor','none','FaceColor','w');
set(barWN(2),'EdgeColor','b','FaceColor','b');
xlabel('Observation Time (M/D/Y/H)')
ylabel('Height (km)')
line1 = ('Altitude of Second Warmnose Aloft vs Sounding Date');
line2 = ('KOKX Soundings Data 2002-2016');
lines = {line1,line2};
title(lines)
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'XTick',dateForBar)
box off
datetickzoom('x',2) %NOTE: requires external function DATETICKZOOM
dcm_obj = datacursormode(figure(5));
set(dcm_obj,'UpdateFcn',@newtip)

figure(6); %this is the altitude of the highest warmnose aloft vs date for all years
barWN = bar(dateForBar,cat(2,lowerboundsg3',boundsdepth3'),'stacked');
set(barWN(1),'EdgeColor','none','FaceColor','w');
set(barWN(2),'EdgeColor','b','FaceColor','b');
xlabel('Observation Time (M/D/Y/H)')
ylabel('Height (km)')
line1 = ('Altitude of Highest Warmnose Aloft vs Sounding Date');
line2 = ('KOKX Soundings Data 2002-2016');
lines = {line1,line2};
title(lines)
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'XTick',dateForBar)
box off
datetickzoom('x',2) %NOTE: requires external function DATETICKZOOM
dcm_obj = datacursormode(figure(6));
set(dcm_obj,'UpdateFcn',@newtip)

switch groundedplot
    case 1
        figure(7); %this is the altitude of grounded warmnoses against date for all years
        barGN = bar(dateForBar,cat(2,grounded',groundedDepth'),'stacked');
        set(barGN(1),'EdgeColor','none','FaceColor','w');
        set(barGN(2),'EdgeColor','k','FaceColor','k');
        hold on
        barGN2 = bar(dateForBar,cat(2,grounded2',grounded2Depth'),'stacked');
        set(barGN(1),'EdgeColor','none','FaceColor','w');
        set(barGN(2),'EdgeColor','k','FaceColor','k');
        line1 = ('Altitude of Grounded Warmnoses vs Sounding Date');
        line2 = ('KOKX Soundings Data 2002-2016');
        lines = {line1,line2};
        title(lines)
        xlabel('Observation Time (M/D/Y/H)')
        ylabel('Height (km)')
        set(gca,'XMinorTick','on','YMinorTick','on')
        set(gca,'XTick',dateForBar)
        datetickzoom('x',2)
        dcm_obj = datacursormode(figure(7));
        set(dcm_obj,'UpdateFcn',@newtip)
    otherwise
        %do nothing
end

if year~=3333
    switch groundedplot %this is for those plots which include grounded warmnoses according to the input year
        case 1
            figure(8); %this is altitude of all warmnoses, aloft and grounded, for input year
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
            xlabel('Observation Time (M/D/Y/H)')
            ylabel('Height (km)')
            set(gca,'XMinorTick','on','YMinorTick','on')
            set(gca,'XTick',dateForBarY) %set where XTicks are; make sure they're in the same place as the date information
            datetickzoom('x',2) %EXTERNAL FUNCTION - otherwise tick number is very inflexible
            dcm_obj = datacursormode(figure(8));
            set(dcm_obj,'UpdateFcn',@newtip)
            
            figure(9); %this is the altitude of the grounded warmnoses against date for only the input year
            barGN = bar(dateForBarY,cat(2,groundedyear',groundedDepthyear'),'stacked');
            set(barGN(1),'EdgeColor','none','FaceColor','w');
            set(barGN(2),'EdgeColor','g','FaceColor','g');
            hold on
            barGN2 = bar(dateForBarY,cat(2,groundedyear2',grounded2Depthyear'),'stacked');
            set(barGN2(1),'EdgeColor','none','FaceColor','w');
            set(barGN2(2),'EdgeColor','g','FaceColor','g');
            hold on
            ylim([0 5])
            line1 = ('Altitude of Grounded Warmnoses vs Sounding Date');
            yearstr = num2str(year);
            line2 = (['KOKX Soundings Data ' yearstr]);
            lines = {line1,line2};
            title(lines)
            xlabel('Observation Time (M/D/Y/H)')
            ylabel('Height (km)')
            set(gca,'XMinorTick','on','YMinorTick','on')
            set(gca,'XTick',dateForBarY) %set where XTicks are; make sure they're in the same place as the date information
            datetickzoom('x',2) %EXTERNAL FUNCTION - otherwise tick number is very inflexible
            dcm_obj = datacursormode(figure(9));
            set(dcm_obj,'UpdateFcn',@newtip)
        otherwise %no need to make a fuss
    end
end

end