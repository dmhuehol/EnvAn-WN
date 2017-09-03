function [lowerboundsg,upperboundsg] = wnAllPlot(sounding,year,groundedplot,quick)
%%wnAllPlot
    %Function to make a variety of warm nose plots of warm noses in the atmosphere.
    %wnAllPlot is aimed towards making plots which cover long periods of
    %time, generally greater than one year.
    %
    %General form: wnAllPlot(sounding,year,groundedplot,quick)
    %Simplest possible syntax: wnAllPlot(sounding)
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
    %To more easily plot warm noses by year, see wnYearPlot. To plot
    %individual warm noses, see wnplot.
    %
    %KNOWN PROBLEM: uses the stacked method of making warm nose plots
    
    %Note that since this method of investigating warm noses proved to be
    %less useful than investigation on smaller time scales, this function
    %is now a low-priority and will not be maintained for the foreseeable
    %future.
    %
    %Version Date: 8/24/17
    %Last major revision: 6/20/17
    %Written by Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %
    %See also: wnplot, wnYearPlot, datetickzoom, IGRAimpfil, nosedetect
    %
    
%% Check for inputs
if ~exist('quick','var') %Assume to plot as few figures as possible
    quick = 1;
end
if ~exist('groundedplot','var')
    groundedplot = 0; %Disable groundplots by default
end
if ~exist('year','var')
    year = 3333; %Missing year value; prevents the creation of yearplots when a no year input was given
end

%% Import data
fc = 1; %Counter for building an overall array of bounds which cares not for ordinality
yc = 1; %Year counter, prevents an army of zeros
ecount = 0; %Error counter
datnum = zeros(length(sounding),4); %Preallocate for construction of a date array
DataIssueShownAlready = 0; %Controls whether or not to display message regarding data quality (see last part of loop)
for f = 1:length(sounding) %Storage in nested structures means that loops are the only option for extracting large quantities of data
    try %In case something goes wrong
    datnum(f,1:4) = sounding(f).valid_date_num; %Store all datenumbers in the date array
    lowerboundsg1(f) = sounding(f).warmnose.lowerboundg1; %HEIGHT collection of first lower bounds
    lowerboundsg(fc) = sounding(f).warmnose.lowerboundg1; %Overall collection of lower bounds, not separated by ordinality of nose
    upperboundsg1(f) = sounding(f).warmnose.upperboundg1; %HEIGHT collection of first upper bounds
    upperboundsg(fc) = sounding(f).warmnose.upperboundg1; %Overall collection of upper bounds, not separated by ordinality of nose
    fc = fc+1; %This makes sure that any second/third noses within the same sounding don't overwrite the first noses in the non-ordinal collection
    if isequal(sounding(f).year,year)==1 %Check if the year is equal to the year input
        lbyear(yc) = sounding(f).warmnose.lowerboundg1; %Make separate arrays for lower bound
        ubyear(yc) = sounding(f).warmnose.upperboundg1; %and upper bound of the given year
        yearnum(yc,1:4) = sounding(f).valid_date_num; %Separate datenumber array, built for those functions with year matching the input year
        
    end
    if isfield(sounding(f).warmnose,'lowerbound2')
        %Note that since the collections for first bounds occur outside of
        %any if statements, all first bounds are already caught without
        %adding anything to find them under this statement. This is also
        %true for the third bound.
        lowerboundsg2(f) = sounding(f).warmnose.lowerboundg2; %HEIGHT collection of second lower bounds
        lowerboundsg(fc) = sounding(f).warmnose.lowerboundg2; %Overall collection of lower bounds, not separated by ordinality
        upperboundsg2(f) = sounding(f).warmnose.upperboundg2; %HEIGHT collection of second upper bounds
        upperboundsg(fc) = sounding(f).warmnose.upperboundg2; %Overall collection of upper bounds, not separated by ordinality
        fc = fc+1;
        if isequal(sounding(f).year,year)==1
            lbyear2(yc) = sounding(f).warmnose.lowerboundg2;
            ubyear2(yc) = sounding(f).warmnose.upperboundg2;
        end
    end
    if isfield(sounding(f).warmnose,'lowerbound3')
        lowerboundsg3(f) = sounding(f).warmnose.lowerboundg3; %HEIGHT collection of third lower bounds
        lowerboundsg(fc) = sounding(f).warmnose.lowerboundg3; %Overall collection of lower bounds, not separated by ordinality
        upperboundsg3(f) = sounding(f).warmnose.upperboundg3; %HEIGHT collection of third upper bounds
        upperboundsg(fc) = sounding(f).warmnose.upperboundg3; %Overall collection of upper bounds, not separated by ordinality
        fc = fc+1; 
        if isequal(sounding(f).year,year)==1
            lbyear3(yc) = sounding(f).warmnose.lowerboundg3;
            ubyear3(yc) = sounding(f).warmnose.upperboundg3;
        end
    end
    if isequal(sounding(f).year,year)==1
        yc = yc+1; %Once all bounds have been acquired, increment the year counter
    end
    catch ME; %Errors are duly noted
        ecount = ecount+1; %Keep track of how many errors there are
        if DataIssueShownAlready == 0;
            disp('If ecount is greater than 10, this data is likely corrupt!')
            DataIssueShownAlready = 1; %Prevents the above message from appearing multiple times
        end
        disp(ecount) %For IGRA v1 data from 2002 to 2016, this shouldn't be greater than 3
        if ecount>15
            msg = 'Something is wrong! Either the data is corrupt or the loop is improperly written.';
            error(msg); %This prevents the try/catch-continue from masking a dataset with true issues
        end
        continue %And now we move on with our lives
    end
end

%% Setup for plotting
[~,pay] = size(lowerboundsg1); %Find size of the largest matrix - lowerbounds of first WN will contain entry for all WN soundings (as there can never be a second or third WN without there existing a first WN)

% Fill out other matrices with NaNs; otherwise plotting is a total mess
lowerboundsg2(end:pay) = NaN;
lowerboundsg3(end:pay) = NaN;
upperboundsg2(end:pay) = NaN;
upperboundsg3(end:pay) = NaN;

[fro,fco] = find(lowerboundsg1<0.5); %Find lowerbounds in first set which are in contact or close to in contact with the ground
[fro2,fco2] = find(lowerboundsg2<0.5); %Find lowerbounds in second set which are in contact or close to the ground

% Needs to be same size as original; NaNs ensure that plotting behaves properly
grounded = NaN(1,pay);
groundedupper = NaN(1,pay);
grounded2 = NaN(1,pay);
groundedupper2 = NaN(1,pay);

grounded(1,fco) = lowerboundsg1(1,fco); %Save the grounded ones separately; this way the data can still be use without clogging up WN aloft figures
groundedupper(1,fco) = upperboundsg1(1,fco); %Grounded upper bounds
grounded2(1,fco2) = lowerboundsg2(1,fco2); %Near-grounded lower bounds
groundedupper2(1,fco2) = upperboundsg2(1,fco2); %Near-grounded upper bounds
groundedDepth = groundedupper-grounded; %Grounded depth
grounded2Depth = groundedupper2-grounded2; %Near-grounded depth

% Replace grounded bounds with NaN in original matrix so that the numbers stay intact
lowerboundsg1(fro,fco) = NaN;
upperboundsg1(fro,fco) = NaN;
lowerboundsg2(fro2,fco2) = NaN;
upperboundsg2(fro2,fco2) = NaN;
boundsdepth = upperboundsg1-lowerboundsg1;
boundsdepth2 = upperboundsg2-lowerboundsg2;
boundsdepth3 = upperboundsg3-lowerboundsg3;

% Setup for time axis
[sndr,~] = size(datnum); %Find the number of rows
datnum(:,5:6) = zeros(sndr,2); %Fill with zeros, this serves as entries for minutes and hours so that datenum will understand them
datenumbers = datenum(datnum); %Now make them true MATLAB datenums
[uniIndex] = find(unique(datenumbers)); %Bar requires that there are no duplicates in the x-data - this finds the indices of all unique datenumbers
dateForBar = NaN(1,pay); %Bar also requires that the X and Y have the same size
dateForBar(uniIndex) = unique(datenumbers); %this creates a set of datenumbers that is the same size as the data, and does not contain duplicates

%% Plotting
%NOTE: this uses the stacked bar method of making warm nose plots. This is
%known to fail in certain circumstances, and is thus inferior to the more
%robust patch method of making warm nose plots.

figure(1); %This is altitudes of all warmnoses aloft vs time for all years
barWN = bar(dateForBar,cat(2,lowerboundsg1',boundsdepth'),'stacked'); %Bar the dates vs the amalgamation of the lowerbounds and depth
set(barWN(1),'EdgeColor','none','FaceColor','w'); %Change the color of the bar from 0 to min altitude to be invisible
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
set(gca,'XTick',dateForBar) %Set where XTicks are; make sure they're in the same place as the date information
datetickzoom('x',2) %EXTERNAL FUNCTION - otherwise tick number is very inflexible
dcm_obj = datacursormode(figure(1));
    function [txt] = newtip(empt,event_obj)
        %See newtip for full function documentation
        % Customizes text of Data Cursor tooltips
        pos = get(event_obj,'Position'); %Position has two values: one is maximum y value, one is the x value (time)
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
            ['Upper: ',num2str(pos(2))],['Lower: ',lowerstr]}; %This sets the tooltip format
    end
set(dcm_obj,'UpdateFcn',@newtip) %Set the tooltips to use the newtip format

%% Years
if year~=3333 %If the user did not leave the year input blank
    [~,yearpay] = size(lbyear); %Find size of the largest matrix for the input year
    %Make sure sizes of all bounds matrices match; otherwise plotting is a disaster
    lbyear2(lbyear2==0) = NaN;
    ubyear2(ubyear2==0) = NaN;
    lbyear3(lbyear3==0) = NaN;
    ubyear3(ubyear3==0) = NaN;
    lbyear2(end:yearpay) = NaN;
    lbyear3(end:yearpay) = NaN;
    ubyear2(end:yearpay) = NaN;
    ubyear3(end:yearpay) = NaN;
    
    % Find warmnoses which are truly grounded or close to it
    [gwnxyr,gwnyyr] = find(lbyear<0.5);
    [gwnxyr2,gwnyyr2] = find(lbyear2<0.5);
    %Separate out the grounded/near-grounded warmnoses
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
    %Replace grounded/near-grounded entries with NaNs in the original matrices
    lbyear(gwnxyr,gwnyyr) = NaN;
    ubyear(gwnxyr,gwnyyr) = NaN;
    lbyear2(gwnxyr2,gwnyyr2) = NaN;
    ubyear2(gwnxyr2,gwnyyr2) = NaN;
    %Calculate depths
    boundsdepthyear = ubyear-lbyear;
    boundsdepthyear2 = ubyear2-lbyear2;
    boundsdepthyear3 = ubyear3-lbyear3;
    
    [yrr,~] = size(yearnum); %Find number of time entries
    yearnum(:,5:6) = zeros(yrr,2); %Make fake zero entries
    yrnumbers = datenum(yearnum); %Now make them true MATLAB datenums
    [uniIndexY] = find(unique(yrnumbers)); %Bar requires that there are no duplicates in the x-data - this finds the indices of all unique datenumbers
    dateForBarY = NaN(1,yearpay); %Bar also requires that the X and Y have the same size
    dateForBarY(uniIndexY) = unique(yrnumbers); %This creates a set of datenumbers that is the same size as the data, and does not contain duplicates

    figure(2); %This is the plot of altitudes of all warmnoses aloft vs sounding date for the input year
    barWN = bar(dateForBarY,cat(2,lbyear',boundsdepthyear'),'stacked'); %Bar the dates vs the amalgamation of the lowerbounds and depth
    set(barWN(1),'EdgeColor','none','FaceColor','w'); %Change the color of the bar from 0 to min altitude to be invisible
    set(barWN(2),'EdgeColor','b','FaceColor','b');
    hold on
    barWN2 = bar(dateForBarY,cat(2,lbyear2',boundsdepthyear2'),'stacked');
    set(barWN2(1),'EdgeColor','none','FaceColor','w');
    set(barWN2(2),'EdgeColor','b','FaceColor','b');
    hold on
    barWN3 = bar(dateForBarY,cat(2,lbyear3',boundsdepthyear3'),'stacked');
    set(barWN3(1),'EdgeColor','none','FaceColor','w');
    set(barWN3(2),'EdgeColor','b','FaceColor','b');
    ylim([0 5]) %Warmnoses rarely occur above 5km, at least at KOKX in IGRA v1
    line1 = ('Altitude of Warmnoses Aloft vs Sounding Date');
    yearstr = num2str(year);
    line2 = (['KOKX Soundings Data ' yearstr]);
    lines = {line1,line2};
    title(lines)
    xlabel('Observation Time (M/D/Y/H)')
    ylabel('Height (km)')
    set(gca,'XMinorTick','on','YMinorTick','on')
    set(gca,'XTick',dateForBarY) %Set where XTicks are; make sure they're in the same place as the date information
    datetickzoom('x',2) %EXTERNAL FUNCTION - otherwise tick number is very inflexible
    dcm_obj = datacursormode(figure(2));
    set(dcm_obj,'UpdateFcn',@newtip)
else
    %do nothing
end

%% Grounded Warmnoses
switch groundedplot %Check the grounded input
    case 1 %This is the only time that groundedplots should be shown
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
    otherwise %This is a switch/case to make it easy to expand in the future
        disp('Grounded warmnoses were not plotted') %This ensures that the user knows that it's possible to plot grounded warmnoses (in case they skimmed the help)
end

if quick == 1 %If the user requested only the most essential plots
    return %then stop right now, we're done here
end

%% Quick

figure(4); %This is altitude of lowest warmnose aloft vs date for all years
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

figure(5); %This is the altitude of the second warmnose aloft vs date for all years
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

figure(6); %This is the altitude of the highest warmnose aloft vs date for all years
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
        figure(7); %This is the altitude of grounded warmnoses against date for all years
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
    switch groundedplot %This is for those plots which include grounded warmnoses according to the input year
        case 1
            figure(8); %This is altitude of all warmnoses, aloft and grounded, for input year
            barGN = bar(dateForBarY,cat(2,groundedyear',groundedDepthyear'),'stacked');
            set(barGN(1),'EdgeColor','none','FaceColor','w');
            set(barGN(2),'EdgeColor','g','FaceColor','g');
            hold on
            barGN2 = bar(dateForBarY,cat(2,groundedyear2',grounded2Depthyear'),'stacked');
            set(barGN2(1),'EdgeColor','none','FaceColor','w');
            set(barGN2(2),'EdgeColor','g','FaceColor','g');
            hold on
            barWN = bar(dateForBarY,cat(2,lbyear',boundsdepthyear'),'stacked'); %Bar the dates vs the amalgamation of the lowerbounds and depth
            set(barWN(1),'EdgeColor','none','FaceColor','w'); %Change the color of the bar from 0 to min altitude to be invisible
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
            set(gca,'XTick',dateForBarY) %Set where XTicks are; make sure they're in the same place as the date information
            datetickzoom('x',2) %EXTERNAL FUNCTION - otherwise tick number is very inflexible
            dcm_obj = datacursormode(figure(8));
            set(dcm_obj,'UpdateFcn',@newtip)
            
            figure(9); %This is the altitude of the grounded warmnoses against date for only the input year
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
            set(gca,'XTick',dateForBarY) %Set where XTicks are; make sure they're in the same place as the date information
            datetickzoom('x',2) %EXTERNAL FUNCTION - otherwise tick number is very inflexible
            dcm_obj = datacursormode(figure(9));
            set(dcm_obj,'UpdateFcn',@newtip)
        otherwise %No need to make a fuss
    end
end

end