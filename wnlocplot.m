%%wnlocplot - function to make plots of the vertical location of warmnoses
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
%
%See also IGRAimpfil
%

function [sounding] = wnlocplot(sounding,year)
yc = 1; %counter for picking out years
fc = 1; %counter for building an overall array of bounds which cares not for ordinality

for f = 1:length(sounding) %unfortunately, nested structures means loops are the only option for extracting large quantities of data
    try %just in case something goes wrong
    %lowerbounds1(f) = sounding(f).warmnose.lowerbound1; %PRESSURE collection of first lower bounds
    lowerboundsg1(f) = sounding(f).warmnose.lowerboundg1; %HEIGHT collection of first lower bounds
    lowerboundsg(fc) = sounding(f).warmnose.lowerboundg1; %overall collection of lower bounds, not separated by ordinality
    %upperbounds1(f) = sounding(f).warmnose.upperbound1; %PRESSURE collection of first upper bounds
    upperboundsg1(f) = sounding(f).warmnose.upperboundg1; %HEIGHT collection of first upper bounds
    upperboundsg(fc) = sounding(f).warmnose.upperboundg1; %overall collection of upper bounds, not separated by ordinality
    fc = fc+1; %this makes sure that any second/third noses within the same sounding don't overwrite the first noses in the non-ordinal collection
    if isequal(sounding(f).year,year)==1 %this isn't set up yet, really, but it's the right approach for having functionality to select individual years
        lb2014(f) = sounding(f).warmnose.lowerboundg1; %easy to add this functionality to the function, just add an optional 'year' input
        ub2014(f) = sounding(f).warmnose.upperboundg1;
        yc = yc+1; 
    end
    if isfield(sounding(f).warmnose,'lowerbound2') %seems like there should be a way to do this with elseif or switch
        %note that since the collections for first bounds occur outside of
        %any if statements, all first bounds are already caught without
        %adding anything to find them under this statement. This is also
        %true for the third bound.
    %    lowerbounds2(f) = sounding(f).warmnose.lowerbound2; %PRESSURE collection of second lower bounds
        lowerboundsg2(f) = sounding(f).warmnose.lowerboundg2; %HEIGHT collection of second lower bounds
        lowerboundsg(fc) = sounding(f).warmnose.lowerboundg2; %overall collection of lower bounds, not separated by ordinality
    %    upperbounds2(f) = sounding(f).warmnose.upperbound2; %PRESSURE collection of second upper bounds
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
    %    lowerbounds3(f) = sounding(f).warmnose.lowerbound3; %PRESSURE collection of third lower bounds
        lowerboundsg3(f) = sounding(f).warmnose.lowerboundg3; %HEIGHT collection of third lower bounds
        lowerboundsg(fc) = sounding(f).warmnose.lowerboundg3; %overall collection of lower bounds, not separated by ordinality
    %    upperbounds3(f) = sounding(f).warmnose.upperbound3; %PRESSURE collecton of third upper bounds
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
[fro2,fcoyo] = find(lb2014<0.5);
groundedy = lb2014(1,fcoyo);
groundedu = ub2014(1,fcoyo);
lb2014(fro2,fcoyo) = NaN;
ub2014(fro2,fcoyo) = NaN;
lb2c = [groundedy lb20142 lb20143];
ub2c = [groundedu ub20142 ub20143];
lbeba = horzcat(lb2014',ub2014');
lbebb = horzcat(lb20142',ub20142');
lbebc = horzcat(lb20143',ub20143');

figure
boxplot(lbeba','colors','b')
hold on
boxplot(lbebb','colors','g')
hold on
boxplot(lbebc','colors','r')
yearin = num2str(year);
title(['Warmnose Altitude (Red: Nose 3, Green: Nose 2, Blue: Nose 1) by Sounding for input' yearin])
xlabel('Sounding')
ylabel('Height (km)')
ylim([0 4]) %no warmnoses are above 4km
[~,zd] = find(isnan(lbeba')==0);
xlim([zd(1)-90 length(sounding)]) 
h = findobj(gca,'tag','Median'); %find the median line
set(h,'visible','off') %and shut it off
hold off

lcombined = [lowerboundsg1 lowerboundsg2 lowerboundsg3]; %combine all lower bounds
ucombined = [upperboundsg1 upperboundsg2 upperboundsg3]; %combine all upper bounds
bounds = horzcat(lcombined',ucombined'); %combine lower and upper bounds for all warmnoses in proper dimension to be plotted
%combounds = horzcat(lowerboundsg',upperboundsg');

figure %make a new one
boxplot(bounds') %boxplot is usually used to find median and interquartile range for statistical data, but it also is the only MATLAB function to generate a bar chart without forcing the base of the bar to be at the origin
title('Warmnose Altitude by Sounding in 3 groups: lowest warmnose, second warmnose, third warmnose')
xlabel('Sounding')
ylabel('Height (km)')
ylim([0 4]) %no warmnoses are above 4km
h = findobj(gca,'tag','Median'); %find the median line
set(h,'visible','off') %and shut it off

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
