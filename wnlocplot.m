%%wnlocplot
    %NOTE: THIS FUNCTION IS DEFUNCT AS OF 6/12/17. SEE wnaltplot OR
    %wnaltyearplot FOR CURRENT VERSIONS.
    %
    %function to make plots of the vertical location of warmnoses
    %aloft in the atmosphere. Produces figures for individual warmnoses aloft (first,
    %second, third), all warmnoses aloft (stacked as in reality), all warmnoses
    %(divided by number), all warmnoses (included grounded, stacked), and
    %grounded warmnoses. Grounded warmnose figures are commented out by
    %default; see note at the end of this function.
    %
    %Unfortunately, this function is somewhat slow (usually takes 90-100
    %seconds to run), but this is because of the use of boxplot and can't
    %really be improved on while maintaining the current level of completeness.
    %
    %General form: [sounding] = wnlocplot(sounding,year)
    %
    %Output:
    %sounding: sounding data structure, same as input
    %
    %Input:
    %sounding - sounding data structure; MUST contain warmnose substructure and
    %only contain warmnose data. 
    %year - an individual year, will load a stacked all-warmnose aloft profile
    %and stacked all-warmnose profile for the input year. CURRENTLY A MANDATORY
    %INPUT.
    %
    %Version Date: 6/9/17
    %Written by: Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %
    %NOTE: As of 6/12/17, wnlocplot is DEFUNCT and has been superseded by
    %wnaltplot, which uses stacked bars instead of boxplot. This implementation
    %is quicker and does not require the use of the Statistics toolbox. No
    %further development will take place on wnlocplot.
    %
    %See also wnaltplot, IGRAimpfil
    %

%% OBSOLETE -- FOR REVIEW PURPOSES ONLY
function [sounding,vnum] = wnlocplot(sounding,year,simple)
if ~exist('simple') %if no simple argument
    simple = 0; %assume all figures are to be loaded
end

yc = 1; %counter for picking out years
fc = 1; %counter for building an overall array of bounds which cares not for ordinality
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

%repeat the above process, but for individual years
[fro2,fcoyo] = find(lbyear<0.5);
groundedy = lbyear(1,fcoyo);
groundedu = ubyear(1,fcoyo);
lbyear(fro2,fcoyo) = NaN;
ubyear(fro2,fcoyo) = NaN;
lb2c = [groundedy lb20142 lb20143];
ub2c = [groundedu ub20142 ub20143];
lbeba = horzcat(lbyear',ubyear');
lbebb = horzcat(lb20142',ub20142');
lbebc = horzcat(lb20143',ub20143');

figure
boxplot(lbeba','colors','b')
set(gca,'XTickLabel',{'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h'})
hold on
boxplot(lbebb','colors','g')
set(gca,'XTickLabel',{'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h'})
hold on
boxplot(lbebc','colors','r')
set(gca,'XTickLabel',{'vnum'})
yearin = num2str(year);
title(['Warmnose Altitude (Red: Nose 3, Green: Nose 2, Blue: Nose 1) by Sounding for input' yearin])
xlabel('Sounding')
ylabel('Height (km)')
ylim([0 4]) %no warmnoses are above 4km
[~,zd] = find(isnan(lbeba')==0);
xlim([zd(1)-90 length(sounding)]) 
h = findobj(gca,'tag','Median'); %find the median line
set(h,'visible','off') %and shut it off
%set(gca,'XTickLabel',{' '})
hold off

if simple==1
    return
end

lcombined = [lowerboundsg1 lowerboundsg2 lowerboundsg3]; %combine all lower bounds
ucombined = [upperboundsg1 upperboundsg2 upperboundsg3]; %combine all upper bounds
bounds = horzcat(lcombined',ucombined'); %combine lower and upper bounds for all warmnoses in proper dimension to be plotted

figure %make a new one
boxplot(bounds','Labels',{'2002','2003','2004','2005','2006','2007','2008','2009','2010','2011','2012','2013','2014','2015','2016'}) %boxplot is usually used to find median and interquartile range for statistical data, but it also is the only MATLAB function to generate a bar chart without forcing the base of the bar to be at the origin
title('Warmnose Altitude by Sounding in 3 groups: lowest warmnose, second warmnose, third warmnose')
xlabel('Sounding')
ylabel('Height (km)')
ylim([0 4]) %no warmnoses are above 4km
h = findobj(gca,'tag','Median'); %find the median line
set(h,'visible','off') %and shut it off

if simple == 2
    return
end

bound = horzcat(lowerboundsg1',upperboundsg1'); %combine lower and upper bounds just for the first warmnose
figure
boxplot(bound')
title('H v S: Location of First Warm Nose')
xlabel('Sounding')
ylabel('Height (km)')
ylim([0 4])
h = findobj(gca,'tag','Median');
set(h,'visible','off')

boundt = horzcat(lowerboundsg2',upperboundsg2'); %combine lower and upper bounds just for the second warmnose
figure
boxplot(boundt')
title('H v S: Location of Second Warm Nose')
ylim([0 4])
xlabel('Sounding')
ylabel('Height (km)')
h = findobj(gca,'tag','Median');
set(h,'visible','off')

boundth = horzcat(lowerboundsg3',upperboundsg3'); %combine lower and upper bounds just for the third warmnose
figure
boxplot(boundth')
title('H v S: Location of Third Warm Nose')
ylim([0 4])
xlabel('Sounding')
ylabel('Height (km)')
h = findobj(gca,'tag','Median');
set(h,'visible','off')

figure
%plot all warmnoses
boxplot(boundth','colors','r') %third in red
hold on
boxplot(boundt','colors','g') %second in green
hold on
boxplot(bound','colors','b') %first in blue
hold on
title('H v S: Location of All Warm Noses (Red: Nose 3, Green: Nose 2, Blue: Nose 1)')
ylim([0 4])
h = findobj(gca,'tag','Median');
xlabel('Sounding')
ylabel('Height')
set(h,'visible','off')

%ENABLE THIS SECTION TO PLOT GROUNDED WARMNOSES AS WELL; disabled to save
%time for now
% figure
% %plot all warmnoses
% boxplot(boundth','colors','r') %third in red
% hold on
% boxplot(boundt','colors','g') %second in green
% hold on
% boxplot(bound','colors','b') %first in blue
% hold on
% boxplot(groundbeef','colors','k') %grounded in black
% title('H v S: Location of All Warm Noses (Red: Nose 3, Green: Nose 2, Blue: Nose 1')
% ylim([0 4])
% ylabel('Height (km)')
% xlabel('Sounding')
% h = findobj(gca,'tag','Median');
% set(h,'visible','off')
% 
% figure
% boxplot(groundbeef','colors','k')
% title('H v S: Location of all grounded warmnoses')
% ylim([0 3.9])
% ylabel('Height (km)')
% xlabel('Sounding')
% h = findobj(gca,'tag','Median');
% set(h,'visible','off')

end
