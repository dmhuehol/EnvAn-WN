function [sounding] = timefilter(sding,filter_settings)
%%timefilter
    %Filters a sounding data structure by year and month. Given a soundings
    %data structure and a structure containing a span of years and an array
    %of months, timefilter destroys all data within the soundings
    %structure that lies outside the span of years, and destroys all data
    %that corresponds to the months within the settings structure.
    %timefilter returns as output a structure identical to the original
    %structure, except that the requested data has been removed.
    %
    %General form: [sounding] = yearfilterf(sding,filter_settings)
    %
    %Outputs:
    %sounding: a soundings data structure filtered by years and months
    %
    %Inputs:
    %sding: a sounding data structure as created by IGRAimpf
    %filter_settings: a structure with two fields; one which is a 1x2 array
    %giving a SPAN OF YEARS which will be RETAINED, and one which is a 1xX
    %array giving the INDIVIDUAL MONTHS which will be REMOVED
    %
    %Example of filter_settings:
    %filter_settings.year = [2002 2016] removes all data outside of 2002-2016 (inclusive)
    %filter_settings.month = [5,6,7,8,9] removes all data from May, June, July, August, and September
    %
    % Version Date: 8/19/17
    % Last major revision: 6/29/17
    % Written by: Daniel Hueholt
    % North Carolina State University
    % Undergraduate Research Assistant at Environment Analytics
    %
    %To-do: change to work with structures from start to finish, instead of
    %the current struct2table/table2struct setup.
    %
    %See also IGRAimpf, fullIGRAimp
    %

%% Check for missing inputs
fields = fieldnames(filter_settings);
if ismember('month',fields)~=1 %If no month was entered
    filter_settings.month = 9999; %this will prevent any months from being removed
end
if ismember('year',fields)~=1 %If no year was entered
    filter_settings.year = [-9999 9999]; %this prevents any years from being removed
end
    
soundingt = struct2table(sding); %Change structure to table--it's easier to select large numbers of entries with tables than nested structures, because nested structures can't use : notation

%% Year Filter
firstYear = filter_settings.year(1,1); %First year
finalYear = filter_settings.year(1,2); %Last year
[finalIndex] = find(soundingt.year>finalYear); %Find all indices after the final year
[firstIndex] = find(soundingt.year<firstYear); %find all indices before the first year
if isempty(finalIndex) == 1 %If there are no elements from years after the final year
    disp('All data comes before the final year')
else
    soundingt(finalIndex,:) = []; %Destroy all elements across all variables later than the given year
end
if isempty(firstIndex) == 1 %If there are no elements from years before the first year
    disp('All data comes after the first year')
else
    soundingt(firstIndex,:) = []; %Destroy all elements across all variables earlier than the given year
end

%% Month Filter
mindex = cell(1,length(filter_settings.month)); %Preallocate cell array (which will contain indices) to save time

for mcount = 1:length(filter_settings.month) %Check every entry that has been requested to be removed
    [mindex{mcount}] = find(soundingt.month == filter_settings.month(mcount)); %Store the indices of entries corresponding to month mcount in a cell array
end
mnindex = vertcat(mindex{1:end}); %String all of the cells into a single column vector

if isempty(mnindex) == 1 %If there's somehow no entries corresponding to the input month, report that to the user
    disp('No entries were found for the input month.')
    disp('(Note that this could indicate something is wrong with either the input month or with the data itself.)')
else
    soundingt(mnindex,:) = []; %Destroy all elements across all variables corresponding to the indices of the input month(s)
end

sounding = table2struct(soundingt); %Convert back to a structure

end