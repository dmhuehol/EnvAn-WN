function [] = wnaltplot(sounding,quick)
%%wnaltplot
    %function to make altitude plots of the physical locations of warmnoses
    %in the atmosphere.
    %
    %General form: wnaltplot(sounding,quick)
    %
    %Outputs:
    %none
    %
    %Inputs:
    %sounding: a sounding data structure--must have warmnose information
    %already determined (such as warmnosesfinal structure from IGRAimpfil)
    %quick: 1 to plot only the most important figures, any other value to
    %plot all
    %
    %Written by Daniel Hueholt
    %Version Date: 6/14/17
    %Last major revision: 6/14/17
    %
    %See also: IGRAimpfil, nosedetect
    %
    
    
if ~exist('quick','var')
    quick = 0;
end

fc = 1; %counter for building an overall array of bounds which cares not for ordinality
year = 2010;
datnum = zeros(length(sounding),4);
for f = 1:length(sounding) %unfortunately, nested structures means loops are the only option for extracting large quantities of data
    try %just in case something goes wrong
    datnum(f,1:4) = sounding(f).valid_date_num;
    lowerboundsg1(f) = sounding(f).warmnose.lowerboundg1; %HEIGHT collection of first lower bounds
    lowerboundsg(fc) = sounding(f).warmnose.lowerboundg1; %overall collection of lower bounds, not separated by ordinality
    upperboundsg1(f) = sounding(f).warmnose.upperboundg1; %HEIGHT collection of first upper bounds
    upperboundsg(fc) = sounding(f).warmnose.upperboundg1; %overall collection of upper bounds, not separated by ordinality
    fc = fc+1; %this makes sure that any second/third noses within the same sounding don't overwrite the first noses in the non-ordinal collection
    if isequal(sounding(f).year,year)==1
        lbyear(f) = sounding(f).warmnose.lowerboundg1; %easy to add this functionality to the function, just add an optional 'year' input
        ubyear(f) = sounding(f).warmnose.upperboundg1;
        yearnum(f,1:4) = sounding(f).valid_date_num;
        
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
            lbyear2(f) = sounding(f).warmnose.lowerboundg2;
            ubyear2(f) = sounding(f).warmnose.upperboundg2;
        end
    end
    if isfield(sounding(f).warmnose,'lowerbound3')
        lowerboundsg3(f) = sounding(f).warmnose.lowerboundg3; %HEIGHT collection of third lower bounds
        lowerboundsg(fc) = sounding(f).warmnose.lowerboundg3; %overall collection of lower bounds, not separated by ordinality
        upperboundsg3(f) = sounding(f).warmnose.upperboundg3; %HEIGHT collection of third upper bounds
        upperboundsg(fc) = sounding(f).warmnose.upperboundg3; %overall collection of upper bounds, not separated by ordinality
        fc = fc+1; 
        if isequal(sounding(f).year,year)==1
            lbyear3(f) = sounding(f).warmnose.lowerboundg3;
            ubyear3(f) = sounding(f).warmnose.upperboundg3;
        end
    end
    catch ME; %duly noted
        continue %and ignored
    end
end

[~,pay] = size(lowerboundsg1); %find size of the largest matrix - lowerbounds of first WN will contain entry for all WN soundings
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

%replace grounded bounds with NaN in original matrix so that numbers stays intact
lowerboundsg1(fro,fco) = NaN;
upperboundsg1(fro,fco) = NaN;
lowerboundsg2(fro2,fco2) = NaN;
upperboundsg2(fro2,fco2) = NaN;
boundsdepth = upperboundsg1-lowerboundsg1;
boundsdepth2 = upperboundsg2-lowerboundsg2;
boundsdepth3 = upperboundsg3-lowerboundsg3;

%setup for time axis
datstr = num2str(datnum(:,1:3)); %change date stamps to string
datenumbers = datenum(datstr); %now make them true MATLAB datenums
[uniIndex] = find(unique(datenumbers)); %bar requires that there are no duplicates in the x-data - this finds the indices of all unique datenumbers
dateForBar = NaN(1,pay); %bar also requires that the X and Y have the same size
dateForBar(uniIndex) = unique(datenumbers); %this creates a set of datenumbers that is the same size as the data, and does not contain duplicates

figure
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
xlabel('Time')
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'XTick',dateForBar) %set where XTicks are; make sure they're in the same place as the date information
datetickzoom('x',2) %EXTERNAL FUNCTION - otherwise tick number is very inflexible

figure
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
barGN = bar(dateForBar,cat(2,grounded',groundedupper'),'stacked');
set(barGN(1),'EdgeColor','none','FaceColor','w');
set(barGN(2),'EdgeColor','none','FaceColor','k');
barGN2 = bar(dateForBar,cat(2,grounded2',groundedupper2'),'stacked');
set(barGN2(1),'EdgeColor','none','FaceColor','w');
set(barGN2(1),'EdgeColor','none','FaceColor','k');
line1 = ('Altitude of WN Aloft and Grounded WN vs Sounding Date');
line2 = ('KOKX Soundings Data 2002-2016');
lines = {line1,line2};
title(lines)
xlabel('Time')
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'XTick',dateForBar)
datetickzoom('x',2)

if quick == 1
    return
end

figure
barGN = bar(dateForBar,cat(2,grounded',groundedupper'),'stacked');
set(barGN(1),'EdgeColor','none','FaceColor','w');
set(barGN(2),'EdgeColor','k','FaceColor','k');
line1 = ('Altitude of Grounded Warmnoses vs Sounding Date');
line2 = ('KOKX Soundings Data 2002-2016');
lines = {line1,line2};
title(lines)
xlabel('Time')
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'XTick',dateForBar)
datetickzoom('x',2)

figure
boundsdepth = upperboundsg1-lowerboundsg1;
barWN = bar(dateForBar,cat(2,lowerboundsg1',boundsdepth'),'stacked');
set(barWN(1),'EdgeColor','none','FaceColor','w');
set(barWN(2),'EdgeColor','b','FaceColor','b');
ylabel('Altitude (km)')
xlabel('Time')
line1 = ('Altitude of Lowest Warmnose Aloft vs Sounding Date');
line2 = ('KOKX Soundings Data 2002-2016');
lines = {line1,line2};
title(lines)
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'XTick',dateForBar)
box off
datetickzoom('x',2) %NOTE: requires external function DATETICKZOOM

figure
barWN = bar(dateForBar,cat(2,lowerboundsg2',boundsdepth2'),'stacked');
set(barWN(1),'EdgeColor','none','FaceColor','w');
set(barWN(2),'EdgeColor','b','FaceColor','b');
ylabel('Altitude (km)')
xlabel('Time')
line1 = ('Altitude of Second Warmnose Aloft vs Sounding Date');
line2 = ('KOKX Soundings Data 2002-2016');
lines = {line1,line2};
title(lines)
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'XTick',dateForBar)
box off
datetickzoom('x',2) %NOTE: requires external function DATETICKZOOM

figure
barWN = bar(dateForBar,cat(2,lowerboundsg3',boundsdepth3'),'stacked');
set(barWN(1),'EdgeColor','none','FaceColor','w');
set(barWN(2),'EdgeColor','b','FaceColor','b');
ylabel('Altitude (km)')
xlabel('Time')
line1 = ('Altitude of Highest Warmnose Aloft vs Sounding Date');
line2 = ('KOKX Soundings Data 2002-2016');
lines = {line1,line2};
title(lines)
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'XTick',dateForBar)
box off
datetickzoom('x',2) %NOTE: requires external function DATETICKZOOM
end