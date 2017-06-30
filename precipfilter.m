function [preciptrue] = precipfilter(warmnosesfinal,dat)
%Note that Mesowest surface data only extends back to August 2002
spread = 15; %find roughly the whole day's worth of records
% for hs = 1:length(warmnosesfinal)
%     datevec = warmnosesfinal(hs).valid_date_num; %concatenate inputs into a date vector, which can be checked against the valid_date_num entry in the surface conditions table
%     for ad = 1:height(dat) %search through table data
%         if isequal(dat.valid_date_num(ad,:),datevec)==1 %function is trying to find the index where the valid_date_num entry is the same as the input date and time
%             sfound = ad; %the counter at this location is the index
%             closerlook = dat((sfound-spread):(sfound+spread),:);
%             if ~isempty(nonzeros(closerlook.HrPrecip))
%                 preciptrue(hs) = 1;
%             else
%             end
%         else %do nothing
%         end
%     end
% end
datevector = [2002,12,31,00];
lettuce = [dat.Year,dat.Month,dat.Day,dat.Hour,dat.Minute];
[yearcheck] = find(ismember(dat.valid_date_num(:,1),datevector(1)));
[monthcheck] = find(ismember(dat.valid_date_num(yearcheck,2),datevector(2)));
[daycheck] = find(ismember(dat.valid_date_num(monthcheck,3),datevector(3)));
[timecheck] = find(ismember(dat.valid_date_num(daycheck,4),datevector(4)));
sfound = yearcheck(monthcheck(daycheck(timecheck)));

[yr,~] = find(ismember(dat.Year,datevector(1)));
lettuce(yr,1) = 9999;
[mn,~] = find(ismember(dat.Month(yr),datevector(2)));
lettuce(mn,2) = 9999;
[dy,~] = find(ismember(dat.Day(mn),datevector(3)));
lettuce(dy,3) = 9999;
[hr,~] = find(ismember(dat.Hour(day),datevector(4)));
lettuce(hr,4) = 9999;

if ~exist('sfound','var') %rarely, the input time isn't in the Mesowest table
    msg = 'Cannot find requested entry in data table! Check input and try again.';
    error(msg) %in this case, warn the user and end the function
end

%col 13 is hrprecip, col 6 is weather code

end