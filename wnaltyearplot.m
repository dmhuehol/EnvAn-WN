function [] = wnaltyearplot(soundings,year,grounded)
if ~exist('grounded','var')
    grounded = 0;
end

fc = 1; %counter for building an overall array of bounds which cares not for ordinality
yc = 1; %year counter, prevents an army of zeros
ecount = 0;
datnum = zeros(length(soundings),4);
for f = 1:length(soundings) %unfortunately, nested structures means loops are the only option for extracting large quantities of data
    try %just in case something goes wrong
    datnum(f,1:4) = soundings(f).valid_date_num;
    if isequal(soundings(f).year,year)==1
        lbyear(yc) = soundings(f).warmnose.lowerboundg1; %easy to add this functionality to the function, just add an optional 'year' input
        ubyear(yc) = soundings(f).warmnose.upperboundg1;
        yearnum(yc,1:4) = soundings(f).valid_date_num;
        fc = fc+1;
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
        yc = yc+1;
    end
    catch ME; %duly noted
        ecount = ecount+1;
        disp('If ecount is greater than 10, this data is likely corrupt!')
        disp(ecount)
        if ecount>15
            msg = 'Something is wrong! Either the data is corrupt or the loop is improperly written.'
            error(msg);
        end
        continue
    end
end

[~,yearpay] = size(lbyear); %find size of the largest matrix for the input year
lbyear2(lbyear2==0) = NaN;
ubyear2(ubyear2==0) = NaN;
lbyear3(lbyear3==0) = NaN;
ubyear3(ubyear3==0) = NaN;
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

[yrr,~] = size(yearnum); %find number of time entries
yearnum(:,5:6) = zeros(yrr,2); %make fake zero entries 
yrnumbers = datenum(yearnum); %now make them true MATLAB datenums
[uniIndexY] = find(unique(yrnumbers)); %bar requires that there are no duplicates in the x-data - this finds the indices of all unique datenumbers
dateForBarY = NaN(1,yearpay); %bar also requires that the X and Y have the same size
dateForBarY(uniIndexY) = unique(yrnumbers); %this creates a set of datenumbers that is the same size as the data, and does not contain duplicates

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

switch grounded
    case 1
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
        
        figure
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
        xlabel('Time')
        set(gca,'XMinorTick','on','YMinorTick','on')
        set(gca,'XTick',dateForBarY) %set where XTicks are; make sure they're in the same place as the date information
        datetickzoom('x',2) %EXTERNAL FUNCTION - otherwise tick number is very inflexible
    otherwise
        disp('Grounded warmnoses were not plotted')
        return
end

end