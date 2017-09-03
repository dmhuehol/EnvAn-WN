function [sndng,filtered,soundsh,goodfinal,warmnosesfinal,nowarmnosesfinal,wnoutput] = fullIGRAimp(input_file,input_file_meso)
%%IGRAimpfil
    %Function which, given a file of raw IGRA v1 soundings data, will read
    %the data into MATLAB, filter it according to year, filter it according
    %to level type, add dewpoint and temperature, filter by surface
    %temperature, detect and analyze warmnoses, and filter by precipitation. 
    %At each step of the way, a new soundings structure is created and can
    %be output, making this ideal for further investigation using functions 
    %like soundplots.
    %
    %General form:
    %[sndng,filtered,soundsh,goodfinal,warmnosesfinal,nowarmnosesfinal,wnoutput] = IGRAimpfil(input_file,input_file_meso)
    %
    %Outputs:
    %sndng - raw soundings data read into MATLAB and separated into different
    %readings, unfiltered.
    %filtered - soundings data filtered by year
    %soundsh - soundings data filtered by level type (usually to remove extra wind levels)
    %goodfinal - soundings data filtered by surface temperature
    %warmnosesfinal - soundings structure containing data only from
    %soundings with warmnoses
    %nowarmnosesfinal - soundings structure containing data only from
    %soundings without warmnoses
    %wnoutput - soundings structure which has been filtered to contain only
    %data from days with precipitation
    %
    %For unclear reasons, all outputs must be called.
    %
    %Input:
    %input_file: file path of a *.dat IGRA v1 data file
    %input_file_meso: file path of a Mesowest data table
    %
    %Eventually it is planned to have the various filters controlled at the
    %inputs, but for now it is necessary to change such settings within the
    %function.
    %
    %KNOWN ISSUES: breaks when outputs are omitted, more accurate progress bar is needed,
    % runtime is relatively slow. These will be improved shortly.
    %
    %Written by Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %Version Date: 8/19/17
    %Last major revision: 6/30/17
    %
    %See also IGRAimpf, timefilter, levfilter, dewrelh, surfconfilter,
    %nosedetect, precipfilter, wnumport
    %

% Read soundings data into MATLAB
[sndng] = IGRAimpf(input_file); %This produces a structure of soundings data with minimal quality control.
disp('Successfully created raw soundings structure! 1/5')

% Filter soundings by time
filter_settings.year = [2002 2016]; %Settings to remove all data that does not lie between 2002 and 2016, inclusive
filter_settings.month = [5 6 7 8 9]; %Settings to remove all data that occurs in the months of May through September, inclusive
[filtered] = timefilter(sndng,filter_settings); %Create a new structure with only the data needed
disp('Time filtering complete! 2/5')

% Filter soundings by level
[soundsh] = levfilter(filtered,3); %Remove all level type 3 data (corresponding to extra wind layers, which throw off geopotential height and other variables)
disp('Level filtering complete! 3/5')

soundsh = soundsh'; %Correct shape of structure

% Add dewpoint and temperature to the soundings data
for scnt  = 1:length(soundsh)
[soundsh(scnt).dewpt,soundsh(scnt).rhum] = dewrelh(soundsh(scnt).temp,soundsh(scnt).dew_point_dep); %Call to dewrelh function
end

% Filter soundings by surface temperature
surfcon.temp = 19;
%surfconfilter also supports filtration by relative humidity (not used by default)
[~,goodfinal] = surfconfilter(soundsh,surfcon);

disp('Quality control complete! 4/5')

% Detect warm noses
disp('Detecting warmnoses - please be patient!') %This is one of the longest portions of the function
[~,~,~,warmnosesfinal,nowarmnosesfinal,~,~,~,~,~,~,~,~] = nosedetect(goodfinal,1,length(goodfinal),0,20000); %Function to detect noses

% Filter soundings by precipitation presence
switch nargin %Precipitation filtration is not always wanted
    case 2
        disp('Warmnose detection complete! 5/7') %SURPRISE now there's 7 parts
        [dat,~] = wnumport(input_file_meso); %Import surface conditions from Mesowest data
        disp('Mesowest data import complete! 6/7')
        disp('Precipitation filtration in process - please be patient!')
[wnoutput] = precipfilter(warmnosesfinal,dat,10); %Only include soundings from days with precipitation (spread of 10 is approximately one day)
        disp('Precipitation filtration completed! 7/7') %yay!
    otherwise
        wnoutput = [];
        disp('Warmnose detection complete! 5/5') %woo!
end

end