function [wnoutput,preciptrue] = precipfilter(warmnosesfinal,dat,spread)
%Note that Mesowest surface data only extends back to August 2002
%spread = 15 searches roughly one day of records
%sets how many adjacent entries to look for precipitation in; higher values are more lenient and lower values are more stringent--this basically sets the strength of the filter
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
errorcount = 0;
wnoutput = warmnosesfinal;
sc = 1;
tc = length(warmnosesfinal);
while sc<tc %loop through all warmnose soundings
    datevector = wnoutput(sc).valid_date_num;
    [foundit] = find(ismember(dat.valid_date_num,datevector,'rows')==1); %finds index of entry in Mesowest table that corresponds to sounding
    closerlook = dat((foundit-spread):(foundit+spread),:); %extracts the section of the Mesowest table to entries +/- spread from the foundit index
    [cx,~] = size(nonzeros(closerlook.HrPrecip)); %find size of the precip data
    checkNaN = NaN(cx,1); %make a NaN of the same size
    try
        if isequaln(nonzeros(closerlook.HrPrecip),checkNaN)~=1 %if there was no precipitation, then every entry will be NaN or zero. Therefore, nonzeros(section) will only have no precipitation if it is equal to a NaN array of the same size.
            preciptrue = 1; %if there was precipitation
        else %any other case
            wnoutput(sc) = []; %destroy
            preciptrue = 0;
            tc = tc-1;
        end
    catch ME;
        errorcount = errorcount+1;
        disp('SCREAMING')
        continue
    end
    sc = sc+1;
end
disp('You made it!')
if ~exist('foundit','var') %rarely, the input time isn't in the Mesowest table
    msg = 'Cannot find requested entry in data table! Check input and try again.';
    error(msg) %in this case, warn the user and end the function
end

end