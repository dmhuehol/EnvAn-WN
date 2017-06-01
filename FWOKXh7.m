%% FWOKX
%Based on the "FIND_WarmnoseOKX" script originally created by Megan
%Amanatides, this script uses soundings data to identify profiles with
%"warm noses." It then visualizes the data in both temperature v
%pressure and temperature v height space. Additionally, it processes
%surface conditions data which can be used to reference surface
%conditions with the corresponding soundings data.
%Version: 5/31/17
%Last major edit: 5/31/17
%Written by: Daniel Hueholt, North Carolina State University
%Undergraduate Research Assistant at Environment Analytics
%
%See also: IGRAimpf, dewrelh, findsnd, levfilters, SkewT, soundplots,
%wnumport, yearfilterfs
%
tic

addpath('C:\Users\danielholt\Documents\MATLAB\Project 1 - Warm Noses\Soundings Data\Upton') %add path which contains soundings data
addpath('C:\Users\danielholt\Documents\MATLAB\Project 1 - Warm Noses') %add the path which contains auxiliary functions
addpath('C:\Users\danielholt\Documents\MATLAB\Project 1 - Warm Noses\Surface Obs') %more auxiliary functions

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
[soundsh(scnt).dewpt,soundsh(scnt).rhum] = dewrelh(soundsh(scnt).temp,soundsh(scnt).dew_point_dep)
end

%call function to filter by surface temperature
surfcon.temp = 6;
[gooddays,goodfinal] = surfconfilter(soundsh,surfcon);

disp('Quality control complete! 4/8')
current = toc

disp('Warmnose detection complete! 5/8')
%% Plotting heights

% Plot the height (in mb) of lowest lower bounds
f1 = figure(1); %PRESSURE figures are numbered from 1
for f = 1:length(warmnosesfinal)
    if length(warmnosesfinal(f).warmnose.x) == 1
        plot(f,warmnosesfinal(f).warmnose.lowerbound1,'*')
        title('Lower Bound of Lowest Warm Nose - P')
        xlabel('Sounding Number')
        ylabel('Height (in mb) of Bottom of Lowest Warm Nose')
        set(gca,'YDir','reverse'); %because pressure decreases with height, reverse y so it decreases upward
        xlim([0 length(warmnosesfinal)]); %set the bounds to show all data
        hold on  
    elseif length(warmnosesfinal(f).warmnose.x) == 2
        plot(f,warmnosesfinal(f).warmnose.lowerbound1,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 3
        plot(f,warmnosesfinal(f).warmnose.lowerbound1,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 4
        plot(f,warmnosesfinal(f).warmnose.lowerbound1,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 5
        plot(f,warmnosesfinal(f).warmnose.lowerbound1,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 6
        plot(f,warmnosesfinal(f).warmnose.lowerbound1,'*')
        %the idea for this figure is to plot the lowest bound (mb), regardless
        %of the number of warmnoses
    end
end
hold off

%plot the height (in km) of lowest lower bounds
fh1 = figure(91); %HEIGHT figures are numbered from 91
for f = 1:length(warmnosesfinal)
    if length(warmnosesfinal(f).warmnose.gx) == 1
        plot(f,warmnosesfinal(f).warmnose.lowerboundg1,'*')
        title('Lower Bound of Lowest Warm Nose - Z')
        xlabel('Sounding Number')
        ylabel('Height (in km) of Bottom of Lowest Warm Nose')
        xlim([0 length(warmnosesfinal)]);
        ylim([-0.2 2.5]);
        hold on  
    elseif length(warmnosesfinal(f).warmnose.gx) == 2
        plot(f,warmnosesfinal(f).warmnose.lowerboundg1,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 3
        plot(f,warmnosesfinal(f).warmnose.lowerboundg1,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 4
        plot(f,warmnosesfinal(f).warmnose.lowerboundg1,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 5
        plot(f,warmnosesfinal(f).warmnose.lowerboundg1,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 6
        plot(f,warmnosesfinal(f).warmnose.lowerboundg1,'*')
        %the idea for this figure is to plot the lowest bound (km),
        %regardless of the number of warmnoses
    end
end
hold off

% Plot the height (in mb) of all lower bounds
f2 = figure(2); %PRESSURE
for f = 1:length(warmnosesfinal)
    if length(warmnosesfinal(f).warmnose.x) == 1
        plot(f,warmnosesfinal(f).warmnose.lowerbound1,'*')
        title('Lower Bounds of All Warm Noses - P')
        xlabel('Sounding Number')
        ylabel('Height (in mb) of Bottom of Warm Nose')
        set(gca,'YDir','reverse');
        xlim([0 length(warmnosesfinal)]);
        hold on  
    elseif length(warmnosesfinal(f).warmnose.x) == 2
        plot(f,warmnosesfinal(f).warmnose.lowerbound1,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 3
        plot(f,warmnosesfinal(f).warmnose.lowerbound1,'*')
        plot(f,warmnosesfinal(f).warmnose.lowerbound2,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 4
        plot(f,warmnosesfinal(f).warmnose.lowerbound1,'*')
        plot(f,warmnosesfinal(f).warmnose.lowerbound2,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 5
        plot(f,warmnosesfinal(f).warmnose.lowerbound1,'*')
        plot(f,warmnosesfinal(f).warmnose.lowerbound2,'*')
        plot(f,warmnosesfinal(f).warmnose.lowerbound3,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 6
        plot(f,warmnosesfinal(f).warmnose.lowerbound1,'*')
        plot(f,warmnosesfinal(f).warmnose.lowerbound2,'*')
        plot(f,warmnosesfinal(f).warmnose.lowerbound3,'*')
        %this plot shows ALL lower bounds (mb), allowing multiple points
        %per sounding in case of multiple warmnoses
    end
end
hold off

% Plot the height (in km) of all lower bounds
fh2 = figure(92); %HEIGHT
for f = 1:length(warmnosesfinal)
    if length(warmnosesfinal(f).warmnose.gx) == 1
        plot(f,warmnosesfinal(f).warmnose.lowerboundg1,'*')
        title('Lower Bounds of All Warm Noses - Z')
        xlabel('Sounding Number')
        ylabel('Height (in km) of Bottom of Warm Nose')
        xlim([0 length(warmnosesfinal)]);
        hold on  
    elseif length(warmnosesfinal(f).warmnose.gx) == 2
        plot(f,warmnosesfinal(f).warmnose.lowerboundg1,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 3
        plot(f,warmnosesfinal(f).warmnose.lowerboundg1,'*')
        plot(f,warmnosesfinal(f).warmnose.lowerboundg2,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 4
        plot(f,warmnosesfinal(f).warmnose.lowerboundg1,'*')
        plot(f,warmnosesfinal(f).warmnose.lowerboundg2,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 5
        plot(f,warmnosesfinal(f).warmnose.lowerboundg1,'*')
        plot(f,warmnosesfinal(f).warmnose.lowerboundg2,'*')
        plot(f,warmnosesfinal(f).warmnose.lowerboundg3,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 6
        plot(f,warmnosesfinal(f).warmnose.lowerboundg1,'*')
        plot(f,warmnosesfinal(f).warmnose.lowerboundg2,'*')
        plot(f,warmnosesfinal(f).warmnose.lowerboundg3,'*')
        %this plot shows ALL lower bounds (km), allowing multiple poits per
        %sounding in case of multiple warmnoses
    end
end
hold off

% Graph height (in mb) of highest upper bounds 
f3 = figure(3); %PRESSURE
for f = 1:length(warmnosesfinal)
    if length(warmnosesfinal(f).warmnose.x) == 1
        plot(f,warmnosesfinal(f).warmnose.upperbound1,'*')
        title('Upper Bound of Highest Warm Nose - P')
        xlabel('Sounding Number')
        ylabel('Height (in mb) of Top of Warm Nose')
        set(gca,'YDir','reverse');
        xlim([0 length(warmnosesfinal)]);
        hold on  
    elseif length(warmnosesfinal(f).warmnose.x) == 2
        plot(f,warmnosesfinal(f).warmnose.upperbound1,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 3
        plot(f,warmnosesfinal(f).warmnose.upperbound2,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 4
        plot(f,warmnosesfinal(f).warmnose.upperbound2,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 5
        plot(f,warmnosesfinal(f).warmnose.upperbound3,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 6
        plot(f,warmnosesfinal(f).warmnose.upperbound3,'*')
        %this plot shows the upper bound of the HIGHEST warmnose only (mb),
        %regardless of the number of warmnoses present
    end
end
hold off

% Graph height (in km) of highest upper bounds 
fh3 = figure(93);
for f = 1:length(warmnosesfinal)
    if length(warmnosesfinal(f).warmnose.gx) == 1
        plot(f,warmnosesfinal(f).warmnose.upperboundg1,'*')
        title('Upper Bound of Highest Warm Nose - Z')
        xlabel('Sounding Number')
        ylabel('Height (in km) of Top of Warm Nose')
        xlim([0 length(warmnosesfinal)]);
        hold on  
    elseif length(warmnosesfinal(f).warmnose.gx) == 2
        plot(f,warmnosesfinal(f).warmnose.upperboundg1,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 3
        plot(f,warmnosesfinal(f).warmnose.upperboundg2,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 4
        plot(f,warmnosesfinal(f).warmnose.upperboundg2,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 5
        plot(f,warmnosesfinal(f).warmnose.upperboundg3,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 6
        plot(f,warmnosesfinal(f).warmnose.upperboundg3,'*')
        %this plot shows the upper bound of the HIGHEST warmnose only (km),
        %regardless of the number of warmnoses present
    end
end
hold off

% Graph height (in mb) of all upper bounds 
f4 = figure(4); %PRESSURE
for f = 1:length(warmnosesfinal)
    if length(warmnosesfinal(f).warmnose.x) == 1
        plot(f,warmnosesfinal(f).warmnose.upperbound1,'*')
        title('Upper Bounds of All Warm Noses - P')
        xlabel('Soundings with Warm Noses')
        ylabel('Height (in mb) of Top of Warm Nose')
        set(gca,'YDir','reverse');
        xlim([0 length(warmnosesfinal)]);
        hold on  
    elseif length(warmnosesfinal(f).warmnose.x) == 2
        plot(f,warmnosesfinal(f).warmnose.upperbound1,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 3
        plot(f,warmnosesfinal(f).warmnose.upperbound1,'*')
        plot(f,warmnosesfinal(f).warmnose.upperbound2,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 4
        plot(f,warmnosesfinal(f).warmnose.upperbound1,'*')
        plot(f,warmnosesfinal(f).warmnose.upperbound2,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 5
        plot(f,warmnosesfinal(f).warmnose.upperbound1,'*')
        plot(f,warmnosesfinal(f).warmnose.upperbound2,'*')
        plot(f,warmnosesfinal(f).warmnose.upperbound3,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 6
        plot(f,warmnosesfinal(f).warmnose.upperbound1,'*')
        plot(f,warmnosesfinal(f).warmnose.upperbound2,'*')
        plot(f,warmnosesfinal(f).warmnose.upperbound3,'*')
        %this plot displays the upper bound (mb) of ALL warmnoses present
    end
end
hold off

% Graph height (in km) of all upper bounds 
fh4 = figure(94); %HEIGHT
for f = 1:length(warmnosesfinal)
    if length(warmnosesfinal(f).warmnose.gx) == 1
        plot(f,warmnosesfinal(f).warmnose.upperboundg1,'*')
        title('Upper Bounds of All Warm Noses - Z')
        xlabel('Soundings with Warm Noses')
        ylabel('Height (in km) of Top of Warm Nose')
        xlim([0 length(warmnosesfinal)]);
        hold on  
    elseif length(warmnosesfinal(f).warmnose.gx) == 2
        plot(f,warmnosesfinal(f).warmnose.upperboundg1,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 3
        plot(f,warmnosesfinal(f).warmnose.upperboundg1,'*')
        plot(f,warmnosesfinal(f).warmnose.upperboundg2,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 4
        plot(f,warmnosesfinal(f).warmnose.upperboundg1,'*')
        plot(f,warmnosesfinal(f).warmnose.upperboundg2,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 5
        plot(f,warmnosesfinal(f).warmnose.upperboundg1,'*')
        plot(f,warmnosesfinal(f).warmnose.upperboundg2,'*')
        plot(f,warmnosesfinal(f).warmnose.upperboundg3,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 6
        plot(f,warmnosesfinal(f).warmnose.upperboundg1,'*')
        plot(f,warmnosesfinal(f).warmnose.upperboundg2,'*')
        plot(f,warmnosesfinal(f).warmnose.upperboundg3,'*')
        %this plot displays the upper bound (km) of ALL warmnoses present
    end
end
hold off

% Plot the depth (in mb) of lowest warm noses
f5 = figure(5); %PRESSURE
for f = 1:length(warmnosesfinal)
    if length(warmnosesfinal(f).warmnose.x) == 1
        plot(f,warmnosesfinal(f).warmnose.depth1,'*')
        title('Depth of Lowest Warm Noses - P')
        xlabel('Soundings with Warm Noses')
        ylabel('Depth (in mb) of All Warm Noses')
        %set(gca,'YDir','reverse'); %reversing the depth axis does not look good
        xlim([0 length(warmnosesfinal)]);
        hold on  
    elseif length(warmnosesfinal(f).warmnose.x) == 2
        plot(f,warmnosesfinal(f).warmnose.depth1,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 3
        plot(f,warmnosesfinal(f).warmnose.depth1,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 4
        plot(f,warmnosesfinal(f).warmnose.depth1,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 5
        plot(f,warmnosesfinal(f).warmnose.depth1,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 6
        plot(f,warmnosesfinal(f).warmnose.depth1,'*')
        %this plots the depth of only the lowest warm nose, (mb) regardless of 
        %the actual number of warmnoses present--usually (but not 
        %always) a grounded warmnose
    end
end
hold off

% Plot the depth (in km) of lowest warm noses
fh5 = figure(95); %HEIGHT
for f = 1:length(warmnosesfinal)
    if length(warmnosesfinal(f).warmnose.gx) == 1
        plot(f,warmnosesfinal(f).warmnose.gdepth1,'*')
        title('Depth of Lowest Warm Noses - Z')
        xlabel('Soundings with Warm Noses')
        ylabel('Depth (in km) of All Warm Noses')
        xlim([0 360]);
        hold on  
    elseif length(warmnosesfinal(f).warmnose.gx) == 2
        plot(f,warmnosesfinal(f).warmnose.gdepth1,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 3
        plot(f,warmnosesfinal(f).warmnose.gdepth1,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 4
        plot(f,warmnosesfinal(f).warmnose.gdepth1,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 5
        plot(f,warmnosesfinal(f).warmnose.gdepth1,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 6
        plot(f,warmnosesfinal(f).warmnose.gdepth1,'*')
        %this plots the depth of only the lowest warm nose (km) regardless of 
        %the actual number of warmnoses present--usually (but not 
        %always) a grounded warmnose
    end
end
hold off

% Plot the depth (in mb) of all warm noses
f6 = figure(6); %PRESSURE
for f = 1:length(warmnosesfinal)
    if length(warmnosesfinal(f).warmnose.x) == 1
        plot(f,warmnosesfinal(f).warmnose.depth1,'*')
        title('Depth of All Warm Noses - P')
        xlabel('Soundings with Warm Noses')
        ylabel('Depth (in mb) of All Warm Noses')
        %set(gca,'YDir','reverse');
        xlim([0 360]);
        hold on  
    elseif length(warmnosesfinal(f).warmnose.x) == 2
        plot(f,warmnosesfinal(f).warmnose.depth1,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 3
        plot(f,warmnosesfinal(f).warmnose.depth1,'*')
        plot(f,warmnosesfinal(f).warmnose.depth2,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 4
        plot(f,warmnosesfinal(f).warmnose.depth1,'*')
        plot(f,warmnosesfinal(f).warmnose.depth2,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 5
        plot(f,warmnosesfinal(f).warmnose.depth1,'*')
        plot(f,warmnosesfinal(f).warmnose.depth2,'*')
        plot(f,warmnosesfinal(f).warmnose.depth3,'*')
    elseif length(warmnosesfinal(f).warmnose.x) == 6
        plot(f,warmnosesfinal(f).warmnose.depth1,'*')
        plot(f,warmnosesfinal(f).warmnose.depth2,'*')
        plot(f,warmnosesfinal(f).warmnose.depth3,'*')
        %this plots the depth (mb) of all warmnoses present
    end
end
hold off

% Plot the depth (in km) of all warm noses
fh6 = figure(96); %HEIGHT
for f = 1:length(warmnosesfinal)
    if length(warmnosesfinal(f).warmnose.gx) == 1
        plot(f,warmnosesfinal(f).warmnose.gdepth1,'*')
        title('Depth of All Warm Noses - Z')
        xlabel('Soundings with Warm Noses')
        ylabel('Depth (in km) of All Warm Noses')
        xlim([0 360]);
        hold on  
    elseif length(warmnosesfinal(f).warmnose.gx) == 2
        plot(f,warmnosesfinal(f).warmnose.gdepth1,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 3
        plot(f,warmnosesfinal(f).warmnose.gdepth1,'*')
        plot(f,warmnosesfinal(f).warmnose.gdepth2,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 4
        plot(f,warmnosesfinal(f).warmnose.gdepth1,'*')
        plot(f,warmnosesfinal(f).warmnose.gdepth2,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 5
        plot(f,warmnosesfinal(f).warmnose.gdepth1,'*')
        plot(f,warmnosesfinal(f).warmnose.gdepth2,'*')
        plot(f,warmnosesfinal(f).warmnose.gdepth3,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 6
        plot(f,warmnosesfinal(f).warmnose.gdepth1,'*')
        plot(f,warmnosesfinal(f).warmnose.gdepth2,'*')
        plot(f,warmnosesfinal(f).warmnose.gdepth3,'*')
        %this plots the depth (km) of all warmnoses present
    end
end
hold off

%% Plotting frequency plots
% Combine all lower bounds into one giant warm nose array
for f = 1:length(warmnosesfinal)
    lowerbounds1(f) = warmnosesfinal(f).warmnose.lowerbound1;
    lowerboundsg1(f) = warmnosesfinal(f).warmnose.lowerboundg1; 
    if isfield(warmnosesfinal(f).warmnose,'lowerbound2')
        lowerbounds2(f) = warmnosesfinal(f).warmnose.lowerbound2;
        lowerboundsg2(f) = warmnosesfinal(f).warmnose.lowerboundg2;
    end
    if isfield(warmnosesfinal(f).warmnose,'lowerbound3')
        lowerbounds3(f) = warmnosesfinal(f).warmnose.lowerbound3;
        lowerboundsg3(f) = warmnosesfinal(f).warmnose.lowerboundg3;
    end
end

% eliminate zeros from lower bounds array
lowercombined = [lowerbounds1,lowerbounds2,lowerbounds3];
lowercombined = nonzeros(lowercombined);
lowergcombined = [lowerboundsg1,lowerboundsg2,lowerboundsg3]; %hi
lowergcombined = nonzeros(lowergcombined); %hi

% Graph frequency of all lower bounds
nbins = 30;
[counts,mb] = hist(lowercombined,nbins);
f7 = figure(7);
barh(mb,counts)
set(gca,'YDir','reverse');
title('Frequency of Warm Nose Lower Bound Heights - P')
xlabel('Frequency')
ylabel('Height (in mb) of Bottom of Warm Nose')

% Graph frequency of all lower bounds in height coordinates
nbins = 30;
[counts,km] = hist(lowergcombined,nbins);
fh7 = figure(97);
barh(km,counts)
title('Frequency of Warm Nose Lower Bound Heights - Z')
xlabel('Frequency')
ylabel('Height (in km) of Bottom of Warm Nose')

% Combine all upper bounds into one giant upper bound array
for f = 1:length(warmnosesfinal)
    upperbounds1(f) = warmnosesfinal(f).warmnose.upperbound1;
    upperboundsg1(f) = warmnosesfinal(f).warmnose.upperboundg1;
    if isfield(warmnosesfinal(f).warmnose,'upperbound2')
        upperbounds2(f) = warmnosesfinal(f).warmnose.upperbound2;
        upperboundsg2(f) = warmnosesfinal(f).warmnose.upperboundg2;
    end
    if isfield(warmnosesfinal(f).warmnose,'upperbound3')
        upperbounds3(f) = warmnosesfinal(f).warmnose.upperbound3;
        upperboundsg3(f) = warmnosesfinal(f).warmnose.upperboundg3;
    end
end

% eliminate zeros from upper bounds array
uppercombined = [upperbounds1,upperbounds2,upperbounds3];
uppercombined = nonzeros(uppercombined);
uppergcombined = [upperboundsg1,upperboundsg2,upperboundsg3]; %hi
uppergcombined = nonzeros(uppergcombined); %hi

% Graph frequency of all upper bounds
nbins = 30;
[counts,mb] = hist(uppercombined,nbins);
f8 = figure(8);
barh(mb,counts)
set(gca,'YDir','reverse');
title('Frequency of Warm Nose Upper Bound Heights - P')
xlabel('Frequency')
ylabel('Height (in mb) of Top of Warm Nose')

% Graph frequency of all upper bounds in height coordinates
nbins = 30;
[counts,km] = hist(uppergcombined,nbins);
fh8 = figure(98);
barh(km,counts)
title('Frequency of Warm Nose Upper Bound Heights - Z')
xlabel('Frequency')
ylabel('Height (in km) of Top of Warm Nose')


for f = 1:length(warmnosesfinal) %unfortunately nested structures require a loop to extract information
    %this loop grabs all of the warmnose depths out of the warmnosesfinal
    %structure, so that they can be concatenated into an array and used to
    %make depth plots
    depths1(f) = warmnosesfinal(f).warmnose.depth1;
    gdepths1(f) = warmnosesfinal(f).warmnose.gdepth1;
    if isfield(warmnosesfinal(f).warmnose,'depth2')
        depths2(f) = warmnosesfinal(f).warmnose.depth2;
        gdepths2(f) = warmnosesfinal(f).warmnose.gdepth2;
    end
    if isfield(warmnosesfinal(f).warmnose,'depth3')
        depths3(f) = warmnosesfinal(f).warmnose.depth3;
        gdepths3(f) = warmnosesfinal(f).warmnose.gdepth3;
    else 
        depths2(f) = 0;
        gdepths2(f) = 0;
        depths3(f) = 0;
        gdepths3(f) = 0;
    end
end

depthplot = [depths1;depths2;depths3];
width = 5;
f9 = figure(9);
bar(depthplot,width,'b')
title('Depth of First, Second, and Third Warm Noses - P')
xlabel('First, Second, and Third Warm Noses in Sounding')
ylabel('Depth (in mb) of Warm Nose')

gdepthplot = [gdepths1;gdepths2;gdepths3];
width = 5;
fh9 = figure(99);
bar(gdepthplot,width,'b')
title('Depth of First, Second, and Third Warm Noses - Z')
xlabel('First, Second, and Third Warm Noses in Sounding')
ylabel('Depth (in km) of Warm Nose')

%combine and take the nonzeros of the depth arrays in order to visualize
%the depths of all warmnoses
depthcombinedA = [depths1,depths2,depths3];
depthcombinedA = nonzeros(depthcombinedA);
depthgcombinedA = [gdepths1,gdepths2,gdepths3];
depthgcombinedA = nonzeros(depthgcombinedA);

f10 = figure(10);
stem(depthcombinedA)
title('Depth of All Warm Noses - P')
xlabel('Soundings with Warm Noses')
ylabel('Depth (in mb) of All Warm Nose')

fh10 = figure(100);
stem(depthgcombinedA)
title('Depth of All Warm Noses - Z')
xlabel('Soundings with Warm Noses')
ylabel('Depth (in km) of All Warm Nose')

disp('Plotting complete! 6/8')
%% Calculating the average number of warmnoses per sounding and the
% percentage of soundings with a warmnose

totalwarmnoses = 0;
for a = 1:length(warmnosesfinal)
    if ~ isnan(warmnosesfinal(a).warmnose.numwarmnose(1));
        totalwarmnoses = totalwarmnoses + (warmnosesfinal(a).warmnose.numwarmnose(1));
    end
end

avgwarmnoses = totalwarmnoses / length(warmnosesfinal);

perctsoundingswwarmnose = (length(warmnosesfinal) / length(goodfinal));
disp('Averages and percentages complete! 7/8')

%% Surface conditions
surdat02 = ('C:\Users\danielholt\Documents\MATLAB\Project 1 - Warm Noses\Surface Obs\KISP 2002.csv'); %2002 data
surdat03 = ('C:\Users\danielholt\Documents\MATLAB\Project 1 - Warm Noses\Surface Obs\KISP 2003.csv'); %2003 data
surdat04 = ('C:\Users\danielholt\Documents\MATLAB\Project 1 - Warm Noses\Surface Obs\KISP 2004.csv'); %2004 data
surdat05 = ('C:\Users\danielholt\Documents\MATLAB\Project 1 - Warm Noses\Surface Obs\KISP 2005.csv'); %2005 data
surdat06 = ('C:\Users\danielholt\Documents\MATLAB\Project 1 - Warm Noses\Surface Obs\KISP 2006.csv'); %2006 data
surdat07 = ('C:\Users\danielholt\Documents\MATLAB\Project 1 - Warm Noses\Surface Obs\KISP 2007.csv'); %2007 data
surdat08 = ('C:\Users\danielholt\Documents\MATLAB\Project 1 - Warm Noses\Surface Obs\KISP 2008.csv'); %2008 data
surdat09 = ('C:\Users\danielholt\Documents\MATLAB\Project 1 - Warm Noses\Surface Obs\KISP 2009.csv'); %2009 data
surdat10 = ('C:\Users\danielholt\Documents\MATLAB\Project 1 - Warm Noses\Surface Obs\KISP 2010.csv'); %2010 data
surdat11 = ('C:\Users\danielholt\Documents\MATLAB\Project 1 - Warm Noses\Surface Obs\KISP 2011.csv'); %2011 data
surdat12 = ('C:\Users\danielholt\Documents\MATLAB\Project 1 - Warm Noses\Surface Obs\KISP 2012.csv'); %2012 data
surdat13 = ('C:\Users\danielholt\Documents\MATLAB\Project 1 - Warm Noses\Surface Obs\KISP 2013.csv'); %2013 data
surdat14 = ('C:\Users\danielholt\Documents\MATLAB\Project 1 - Warm Noses\Surface Obs\KISP 2014.csv'); %2014 data
surdat15 = ('C:\Users\danielholt\Documents\MATLAB\Project 1 - Warm Noses\Surface Obs\KISP 2015.csv'); %2015 data

[surcon02] = wnumport(surdat02,1); %process surface conditions
[surcon03] = wnumport(surdat03,1); %process surface conditions
[surcon04] = wnumport(surdat04,1); %process surface conditions
[surcon05] = wnumport(surdat05,1); %process surface conditions
[surcon06] = wnumport(surdat06,1); %process surface conditions
[surcon07] = wnumport(surdat07,1); %process surface conditions
[surcon08] = wnumport(surdat08,1); %process surface conditions
[surcon09] = wnumport(surdat09,1); %process surface conditions
[surcon10] = wnumport(surdat10,1); %process surface conditions
[surcon11] = wnumport(surdat11,1); %process surface conditions
[surcon12] = wnumport(surdat12,1); %process surface conditions
[surcon13] = wnumport(surdat13,1); %process surface conditions
[surcon14] = wnumport(surdat14,1); %process surface conditions
[surcon15] = wnumport(surdat15,1); %process surface conditions
%[surcon16] = wnumport(surdat16,1); %process surface conditions
disp('Surface conditions import complete! 8/8')

totime = toc
