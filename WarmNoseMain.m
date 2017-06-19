sounding = warmnosesfinal;
fc = 1; %counter for building an overall array of bounds which cares not for ordinality
yc = 1; %year counter, prevents an army of zeros
ecount = 0;
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
        lbyear(yc) = sounding(f).warmnose.lowerboundg1; %easy to add this functionality to the function, just add an optional 'year' input
        ubyear(yc) = sounding(f).warmnose.upperboundg1;
        yearnum(yc,1:4) = sounding(f).valid_date_num;
        
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
        yc = yc+1;
    end
    catch ME; %duly noted
        continue %and ignored
        ecount = ecount+1;
        disp('If ecount is greater than 10, this data is likely corrupt!')
        disp(ecount)
        if ecount>15
            msg = 'Something is wrong! Either the data is corrupt or the loop is improperly written.'
            error(msg);
        end
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

%replace grounded bounds with NaN in original matrix so that number of elements stays intact
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

figure
barWN = bar(dateForBar,cat(2,lowerboundsg1',boundsdepth'),'stacked','barwidth',16); %bar the dates vs the amalgamation of the lowerbounds and depth
set(barWN(1),'EdgeColor','none','FaceColor','w'); %change the color of the bar from 0 to min altitude to be invisible
set(barWN(2),'EdgeColor','b','FaceColor','b');
hold on
barWN2 = bar(dateForBar,cat(2,lowerboundsg2',boundsdepth2'),'stacked','barwidth',16);
set(barWN2(1),'EdgeColor','none','FaceColor','w');
set(barWN2(2),'EdgeColor','b','FaceColor','b');
hold on
barWN3 = bar(dateForBar,cat(2,lowerboundsg3',boundsdepth3'),'stacked','barwidth',16);
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






[~,yearpay] = size(lbyear); %find size of the largest matrix for the input year
lbyear2(end:yearpay) = NaN;
lbyear3(end:yearpay) = NaN;
ubyear2(end:yearpay) = NaN;
ubyear3(end:yearpay) = NaN;
[gwnxyr,gwnyyr] = find(lbyear<0.5);
[gwnxyr2,gwnyyr2] = find(lbyear2<0.5);
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
lbyear(gwnxyr,gwnyyr) = NaN;
ubyear(gwnxyr,gwnyyr) = NaN;
lbyear2(gwnxyr2,gwnyyr2) = NaN;
ubyear2(gwnxyr2,gwnyyr2) = NaN;
boundsdepthyear = ubyear-lbyear;
boundsdepthyear2 = ubyear2-lbyear2;
boundsdepthyear3 = ubyear3-lbyear3;


[yrr,~] = size(yrstr); %find number of time entries
yearnum(:,5:6) = zeros(yrr,2); %make fake zero entries 
yrnumbers = datenum(yearnum); %now make them true MATLAB datenums
[uniIndexY] = find(unique(yrnumbers)); %bar requires that there are no duplicates in the x-data - this finds the indices of all unique datenumbers
dateForBarY = NaN(1,yearpay); %bar also requires that the X and Y have the same size
dateForBarY(uniIndexY) = unique(yrnumbers); %this creates a set of datenumbers that is the same size as the data, and does not contain duplicates

figure
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
xlabel('Time')
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'XTick',dateForBarY) %set where XTicks are; make sure they're in the same place as the date information
datetickzoom('x',2) %EXTERNAL FUNCTION - otherwise tick number is very inflexible
