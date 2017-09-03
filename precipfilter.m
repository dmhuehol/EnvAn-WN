%%precipfilter
    %Function to filter a warm nose soundings data structure to only
    %include the soundings from days where precipitation occurred.
    %THIS IS A VERY ROUGH FILTER. This filter is set to be fairly lenient because
    %Mesowest data does not always accurately represent precipitation
    %start/end time, particularly for winter storms. In short, this filter works as a
    %tool to automatically remove a large number of no precip soundings,
    %but falls well, well short of perfection.
    %
    %General form: [wnoutput,preciptrue] = precipfilter(warmnosesfinal,dat,spread)
    %Inputs:
    %warmnosesfinal: a warm nose soundings data structure; see nosedetect
    %dat: a Mesowest data table; see wnumport
    %spread: the desired spread to look for precipitation in the surface
    %data; 10 is (very) roughly one day of records
    %
    %Outputs:
    %wnoutput: a soundings data structure containing only soundings where
    %precipitation occurred within the spread
    %
    %Known problems: this function is fairly slow, requiring a few minutes
    %of runtime; additionally, large values of spread will cause the
    %function to fail entirely.
    %However, further development of this function is not a particularly high
    %priority as Mesowest is no longer preferred for surface precip
    %data.
    %
    %Version date: 8/19/17
    %Last major revision: 8/19/17
    %Written by: Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %

function [wnoutput] = precipfilter(warmnosesfinal,dat,spread)
%Note that Mesowest surface data only extends back to August 2002

errorCount = 0;
wnoutput = warmnosesfinal;
sc = 1;
tc = length(warmnosesfinal);

while sc<tc %Loop through all warmnose soundings; a while loop is used because the size of the soundings structure will change, and the loop needs to change with it.
    datevector = wnoutput(sc).valid_date_num; %Date from soundings structure
    [foundit] = find(ismember(dat.valid_date_num,datevector,'rows')==1); %Finds index of entry in Mesowest table that corresponds to sounding
    closerlook = dat((foundit-spread):(foundit+spread),:); %Extracts the section of the Mesowest table to entries +/- spread from the foundit index
    %spread = 10 works well, usually grabbing slightly under 24 hours of data
    [cx,~] = size(nonzeros(closerlook.HrPrecip)); %Find size of the precip data
    checkNaN = NaN(cx,1); %Make a NaN matrix of the same size
    try %Cut down on pointless failures
        if isequaln(nonzeros(closerlook.HrPrecip),checkNaN)~=1 %If there was no precipitation, then every entry will be NaN or zero. Therefore, nonzeros(section) will only have no precipitation if it is equal to a NaN array of the same size.
            preciptrue = 1; %If there was precipitation
        else %Any other case
            wnoutput(sc) = []; %Destroy
            preciptrue = 0; %If there was not precipitation
            tc = tc-1; %Reduce size of tc
        end
    catch ME; %If some kind of error occurs
        errorCount = errorCount+1; %Note
        disp('An error has occurred!')
        continue
    end
    sc = sc+1;
end
if ~exist('foundit','var') %rarely, the input time isn't in the Mesowest table
    msg = 'Cannot find requested entry in data table! Check input and try again.';
    error(msg) %in this case, warn the user and end the function
end
disp('You made it!')
if errorCount~=0;
    errorStringPart1 = 'The following number of errors occurred';
    errorStringPart2 = num2str(errorCount); %Display the number of errors
    errorString = strcat(errorStringPart1,errorStringPart2);
    disp(errorString);
end
end