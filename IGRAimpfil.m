function [sndng,filtered,soundsh,goodfinal,warmnosesfinal,nowarmnosesfinal] = IGRAimpfil(input_file)
%%IGRAimpfil
    %Function which, given a file of raw IGRA v1 soundings data, will read
    %the data into MATLAB, filter it according to year, filter it according
    %to level type, add dewpoint and temperature, filter by surface
    %temperature, and detect and analyze warmnoses. At each step of the
    %way, a new soundings structure is created and can be output, making
    %this ideal for further investigation using functions like soundplots.
    %
    %General form:
    %[sndng,filtered,soundsh,goodfinal,warmnosesfinal,nowarmnosesfinal] = IGRAimpfil(input_file)
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
    %
    %Input:
    %input_file: file path of a *.dat IGRA v1 data file
    %
    %Eventually it is planned to have the various filters controlled at the
    %inputs, but for now it is necessary to change such settings within the
    %function. New filters for surface conditions and month of year are
    %also in development.
    %
    %Written by Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %Version Date: 6/13/17
    %Last major revision: 6/13/17
    %
    %See also IGRAimpf, yearfilterfs, levfilter, dewrelh, surfconfilter,
    %nosedetect
    %

[sndng] = IGRAimpf(input_file); %read the soundings data into MATLAB; this produces a structure of soundings data

disp('Data import complete! 1/5')

filter_settings.year = [2002 2016]; %settings to remove all data that does not lie between 2002 and 2016, inclusive
[filtered] = yearfilterfs(sndng,filter_settings); %create a new table with only the data needed
disp('Time filtering complete! 2/5')
[soundsh] = levfilters(filtered,3); %remove all data with level type 3 (corresponding to extra wind layers, which throw off geopotential height and other variables)
disp('Level filtering complete! 3/5')
soundsh = soundsh';

%call function to add dewpoint and temperature
for scnt  = 1:length(soundsh)
[soundsh(scnt).dewpt,soundsh(scnt).rhum] = dewrelh(soundsh(scnt).temp,soundsh(scnt).dew_point_dep);
end

%call function to filter by surface temperature
surfcon.temp = 6;
[~,goodfinal] = surfconfilter(soundsh,surfcon);

disp('Quality control complete! 4/5')

disp('Detecting warmnoses - please be patient!')
[~,~,~,warmnosesfinal,nowarmnosesfinal,~,~,~,~,~,~,~,~] = nosedetect(goodfinal,1,length(goodfinal),0.5,20000);

disp('Warmnose detection and soundings plots complete! 5/5')
end