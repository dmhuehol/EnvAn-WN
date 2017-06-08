%%wnlocplot

function [sounding] = wnlocplot(sounding)

yc = 1; %counter for picking out years
fc = 1; %counter for building an overall array of bounds which cares note for ordinality

for f = 1:length(sounding) %unfortunately, nested structures means loops are the only option for extracting large quantities of data
    try %just in case something goes wrong
    lowerbounds1(f) = sounding(f).warmnose.lowerbound1; %PRESSURE collection of first lower bounds
    lowerboundsg1(f) = sounding(f).warmnose.lowerboundg1; %HEIGHT collection of first lower bounds
    lowerboundsg(fc) = sounding(f).warmnose.lowerboundg1; %overall collection of lower bounds, not separated by ordinality
    upperbounds1(f) = sounding(f).warmnose.upperbound1; %PRESSURE collection of first upper bounds
    upperboundsg1(f) = sounding(f).warmnose.upperboundg1; %HEIGHT collection of first upper bounds
    upperboundsg(fc) = sounding(f).warmnose.upperboundg1; %overall collection of upper bounds, not separated by ordinality
    fc = fc+1; %this makes sure that any second/third noses within the same sounding don't overwrite the first noses in the non-ordinal collection
    if isequal(sounding(f).year,2014)==1 %this isn't set up yet, really, but it's the right approach for having functionality to select individual years
        lb2014(yc) = sounding(f).warmnose.lowerboundg1; %easy to add this functionality to the function, just add an optional 'year' input
        ub2014(yc) = sounding(f).warmnose.upperboundg1;
        yc = yc+1; 
    end
    if isfield(sounding(f).warmnose,'lowerbound2') %seems like there should be a way to do this with elseif or switch
        %note that since the collections for first bounds occur outside of
        %any if statements, all first bounds are already caught without
        %adding anything to find them under this statement. This is also
        %true for the third bound.
        lowerbounds2(f) = sounding(f).warmnose.lowerbound2; %PRESSURE collection of second lower bounds
        lowerboundsg2(f) = sounding(f).warmnose.lowerboundg2; %HEIGHT collection of second lower bounds
        lowerboundsg(fc) = sounding(f).warmnose.lowerboundg2; %overall collection of lower bounds, not separated by ordinality
        upperbounds2(f) = sounding(f).warmnose.upperbound2; %PRESSURE collection of second upper bounds
        upperboundsg2(f) = sounding(f).warmnose.upperboundg2; %HEIGHT collection of second upper bounds
        upperboundsg(fc) = sounding(f).warmnose.upperboundg2; %overall collection of upper bounds, not separated by ordinality
        fc = fc+1;
        if isequal(sounding(f).year,2014)==1
            lb20142(yc) = sounding(f).warmnose.lowerboundg2;
            ub20142(yc) = sounding(f).warmnose.upperboundg2;
            yc = yc+1;
        end
    end
    if isfield(sounding(f).warmnose,'lowerbound3')
        lowerbounds3(f) = sounding(f).warmnose.lowerbound3; %PRESSURE collection of third lower bounds
        lowerboundsg3(f) = sounding(f).warmnose.lowerboundg3; %HEIGHT collection of third lower bounds
        lowerboundsg(fc) = sounding(f).warmnose.lowerboundg3; %overall collection of lower bounds, not separated by ordinality
        upperbounds3(f) = sounding(f).warmnose.upperbound3; %PRESSURE collecton of third upper bounds
        upperboundsg3(f) = sounding(f).warmnose.upperboundg3; %HEIGHT collection of third upper bounds
        upperboundsg(fc) = sounding(f).warmnose.upperboundg3; %overall collection of upper bounds, not separated by ordinality
        fc = fc+1; 
        if isequal(sounding(f).year,2014)==1
            lb20143(yc) = sounding(f).warmnose.lowerboundg3;
            ub20143(yc) = sounding(f).warmnose.upperbound(g3);
            yc = yc+1;
        end
    end
    catch ME; %duly noted
        continue %and ignored
    end
end

%combine = [lb2014 lb20142 lb20143];
lcombined = [lowerboundsg1 lowerboundsg2 lowerboundsg3]; %combine all lower bounds
ucombined = [upperboundsg1 upperboundsg2 upperboundsg3]; %combine all upper bounds
%HEY HEY HEY FUTURE ME I THINK THOSE CAN BE REPLACED BY THAT OVERALL ONE
%THAT YOU BUILD IN THE LOOP
% data:
bounds = horzcat(lcombined',ucombined');
%range = ucombined-lcombined;
%depth = [bounds(:,1)' range];

figure
boxplot(bounds')
title('Altitude vs Sounding: Warm Nose Location')
xlabel('Sounding')
ylabel('Height (km)')
ylim([0 4.5])
h = findobj(gca,'tag','Median')
set(h,'visible','off')

bound = horzcat(lowerboundsg1',upperboundsg1');
%rang = upperboundsg1-lowerboundsg1;
%depths  = [bound(:,1)' rang];

figure
boxplot(bound')
title('H v S: Location of First Warm Nose')
ylim([0 4.5])
h = findobj(gca,'tag','Median')
set(h,'visible','off')

boundt = horzcat(lowerboundsg2',upperboundsg2');
%rangt = upperboundsg2-lowerboundsg2;
%depthst  = [boundt(:,1)' rangt];

figure
boxplot(boundt')
title('H v S: Location of Second Warm Nose')
ylim([0 4.5])
h = findobj(gca,'tag','Median')
set(h,'visible','off')

boundth = horzcat(lowerboundsg3',upperboundsg3');
%rangeth = upperboundsg3-lowerboundsg3;
%depthsth  = [boundth(:,1)' rangeth];

figure
boxplot(boundth')
title('H v S: Location of Third Warm Nose')
ylim([0 4.5])
h = findobj(gca,'tag','Median')
set(h,'visible','off')



figure
boxplot(boundth')
hold on
boxplot(boundt')
hold on
boxplot(bound')
title('H v S: Location of All Warm Noses')
ylim([0 4.5])
h = findobj(gca,'tag','Median')
set(h,'visible','off')

end
