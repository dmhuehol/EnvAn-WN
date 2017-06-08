function [sndng,filtered,soundsh,goodfinal,warmnosesfinal,nowarmnosesfinal] = IGRAimpfil(input_file)
tic
input_file = 'C:\Users\danielholt\Documents\MATLAB\Project 1 - Warm Noses\Soundings Data\Upton\72501.dat';

[sndng] = IGRAimpf(input_file); %read the soundings data into MATLAB; this produces a structure of soundings data

disp('Data import complete! 1/8')

filter_settings.year = [2002 2016]; %settings to remove all data that does not lie between 2002 and 2016, inclusive
[filtered] = yearfilterfs(sndng,filter_settings); %create a new table with only the data needed
disp('Time filtering complete! 2/8')
[soundsh] = levfilters(filtered,3); %remove all data with level type 3 (corresponding to extra wind layers, which throw off geopotential height and other variables)
disp('Level filtering complete! 3/8')
soundsh = soundsh';

%call function to add dewpoint and temperature
for scnt  = 1:length(soundsh)
[soundsh(scnt).dewpt,soundsh(scnt).rhum] = dewrelh(soundsh(scnt).temp,soundsh(scnt).dew_point_dep);
end

%call function to filter by surface temperature
surfcon.temp = 6;
[gooddays,goodfinal] = surfconfilter(soundsh,surfcon);

disp('Quality control complete! 4/8')

[~,~,~,warmnosesfinal,nowarmnosesfinal,~,~,~,~,~,~,~,~] = nosedetect(goodfinal,1,length(goodfinal),0.5,20000);

disp('Warmnose detection and soundings plots complete! 5/8')
disp(toc);
end