sounding = warmnosesfinal;
yc = 1; %counter for picking out years
fc = 1; %counter for building an overall array of bounds which cares not for ordinality
year = 2010;
vnum = zeros(length(sounding),4);
for f = 1:length(sounding) %unfortunately, nested structures means loops are the only option for extracting large quantities of data
    try %just in case something goes wrong
    vnum(f,1:4) = sounding(f).valid_date_num;
    lowerboundsg1(f) = sounding(f).warmnose.lowerboundg1; %HEIGHT collection of first lower bounds
    lowerboundsg(fc) = sounding(f).warmnose.lowerboundg1; %overall collection of lower bounds, not separated by ordinality
    upperboundsg1(f) = sounding(f).warmnose.upperboundg1; %HEIGHT collection of first upper bounds
    upperboundsg(fc) = sounding(f).warmnose.upperboundg1; %overall collection of upper bounds, not separated by ordinality
    fc = fc+1; %this makes sure that any second/third noses within the same sounding don't overwrite the first noses in the non-ordinal collection
    if isequal(sounding(f).year,year)==1
        lbyear(f) = sounding(f).warmnose.lowerboundg1; %easy to add this functionality to the function, just add an optional 'year' input
        ubyear(f) = sounding(f).warmnose.upperboundg1;
        yc = yc+1; 
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
            lb20142(f) = sounding(f).warmnose.lowerboundg2;
            ub20142(f) = sounding(f).warmnose.upperboundg2;
            yc = yc+1;
        end
    end
    if isfield(sounding(f).warmnose,'lowerbound3')
        lowerboundsg3(f) = sounding(f).warmnose.lowerboundg3; %HEIGHT collection of third lower bounds
        lowerboundsg(fc) = sounding(f).warmnose.lowerboundg3; %overall collection of lower bounds, not separated by ordinality
        upperboundsg3(f) = sounding(f).warmnose.upperboundg3; %HEIGHT collection of third upper bounds
        upperboundsg(fc) = sounding(f).warmnose.upperboundg3; %overall collection of upper bounds, not separated by ordinality
        fc = fc+1; 
        if isequal(sounding(f).year,year)==1
            lb20143(f) = sounding(f).warmnose.lowerboundg3;
            ub20143(f) = sounding(f).warmnose.upperboundg3;
            yc = yc+1;
        end
    end
    catch ME; %duly noted
        continue %and ignored
    end
end

[fro,fco] = find(lowerboundsg1<0.5); %find lowerbounds in first set which are in contact or close to in contact with the ground
[fro2,fco2] = find(lowerboundsg2<0.5); %find lowerbounds in second set which are in contact or close to in contact with the ground
grounded = lowerboundsg1(1,fco); %save the grounded ones separately
groundedupper = upperboundsg1(1,fco); %save the grounded upper bounds separately
groundbeef = horzcat(grounded',groundedupper'); %horzcat them so they're ready for boxplot
lowerboundsg1(fro,fco) = NaN; %replace grounded bounds with NaN so that sounding number stays intact
upperboundsg1(fro,fco) = NaN;
lowerboundsg2(fro2,fco2) = NaN;
upperboundsg2(fro2,fco2) = NaN;

figure
boundsdepth = upperboundsg1-lowerboundsg1;
boundsdepth2 = upperboundsg2-lowerboundsg2;
boundsdepth3 = upperboundsg3-lowerboundsg3;
barWN = bar(cat(2,lowerboundsg1',boundsdepth'),'stacked');
set(barWN(1),'EdgeColor','none','FaceColor','w');
set(barWN(2),'EdgeColor','b','FaceColor','b');
hold on
barWN2 = bar(cat(2,lowerboundsg2',boundsdepth2'),'stacked');
set(barWN2(1),'EdgeColor','none','FaceColor','w');
set(barWN2(2),'EdgeColor','g','FaceColor','g');
hold on
barWN3 = bar(cat(2,lowerboundsg3',boundsdepth3'),'stacked');
set(barWN3(1),'EdgeColor','none','FaceColor','w');
set(barWN3(2),'EdgeColor','r','FaceColor','r');


figure
boundsdepth = upperboundsg1-lowerboundsg1;
boundsdepth2 = upperboundsg2-lowerboundsg2;
boundsdepth3 = upperboundsg3-lowerboundsg3;
barWN = bar(cat(2,lowerboundsg1',boundsdepth'),'stacked');
set(barWN(1),'EdgeColor','none','FaceColor','w');
set(barWN(2),'EdgeColor','b','FaceColor','b');
hold on
barWN2 = bar(cat(2,lowerboundsg2',boundsdepth2'),'stacked');
set(barWN2(1),'EdgeColor','none','FaceColor','w');
set(barWN2(2),'EdgeColor','g','FaceColor','g');
hold on
barWN3 = bar(cat(2,lowerboundsg3',boundsdepth3'),'stacked');
set(barWN3(1),'EdgeColor','none','FaceColor','w');
set(barWN3(2),'EdgeColor','r','FaceColor','r');