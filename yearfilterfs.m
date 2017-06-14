function [sounding] = yearfilterfs(sding,filter_settings)
%%yearfilterfs
    %function to filter a soundings data structure (as created by
    %the IGRAimpf function). Given a soundings data structure and a 1x1 structure containing
    %a span of years as input, yearfilterf will destroy all data within the
    %structure that lies outside of the given year range. yearfilterf returns a
    %structure identical to the original table in format, except that the requested
    %data has been removed.
    %
    %General form: [sounding] = yearfilterf(sounding,filter_settings)
    %   
    %See also IGRAimpfil

soundingt = struct2table(sding);
low = filter_settings.year(1,1); %lower bound
high = filter_settings.year(1,2); %upper bound
[hindex] = find(soundingt.year>high); %find all indices above upper bound
[lindex] = find(soundingt.year<low); %find all indices below lower bound
if isempty(hindex) == 1 %if there are no elements with values greater than the upper bound
    disp('All elements fall within the upper bound')
else
    soundingt(hindex,:) = []; %destroy all elements across all variables later than the given year
end
if isempty(lindex) == 1 %if there are no elements with values lower than the lower bound
    disp('All elements fall within the given lower bound')
else
    soundingt(lindex,:) = []; %destroy all elements across all variables earlier than the given year
end
sounding = table2struct(soundingt)
end