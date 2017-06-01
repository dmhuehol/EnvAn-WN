%% FWOKX
%Based on the "FIND_WarmnoseOKX" script originally created by Megan
%Amanatides, this script uses soundings data to identify profiles with
%"warm noses." It then visualizes the data in both temperature v
%pressure and temperature v height space. Additionally, it processes
%surface conditions data which can be used to reference surface
%conditions with the corresponding soundings data.
%Version: 5/26/17
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

for c = 1:length(soundsh)
    soundsh(c).dewpt = (soundsh(c).temp - soundsh(c).dew_point_dep);
    soundsh(c).rhum = (100.*(((112 - (0.1.*(soundsh(c).temp)) + ...
        (soundsh(c).dewpt)) ./ (112 + (0.9 .*(soundsh(c).temp)))).^8));
end

% Define new arrays filled with zeros for surfacetemp, cold, and moist.
% The surfacetemp array will identify the temperature near the surface in
% each sounding.  The cold array will help to identify temperatures that
% meet the minimum temperature threshold, and the moist array will help to 
% identify relative humidity values that meet the minimum relative humidity
% threshold.  
surfacetemp = zeros(length(soundsh),1);
cold = zeros(length(soundsh),1);
moist = zeros(length(soundsh),1);

% Loop through each sounding to ensure that the surface temperature is at
% or below 4 degrees Celsius and Relative humidity is at or below 80%
for d = 1:length(soundsh)
    if ~ isempty(soundsh(d))
        surfacetemp1(d) = soundsh(d).temp(1);
        surfacetemp2(d) = soundsh(d).temp(2);
        surfacetemp3(d) = soundsh(d).temp(3);
        if ((surfacetemp1(d) <= 4)  && (surfacetemp2(d) <= 4) && (surfacetemp3(d) <= 4))
            cold(d) = 1;
        end
        rh1(d) = soundsh(d).rhum(1);
        rh2(d) = soundsh(d).rhum(2);
        rh3(d) = soundsh(d).rhum(3);
        if ((rh1(d) >= 80)  && (rh2(d) >= 80) && (rh3(d) >= 80))
            moist(d) = 1;
        end
    end
end

% Define a new structure that includes on those soundings that meet the
% minimum temperature and relative humidity threshold
gooddays = and(logical(cold), logical(moist));
goodfinal = soundsh(gooddays);

disp('Quality control complete! 4/8')

%% Step 4. Find Warm Noses

% Define a new array filled with zeros to help classify which soundings
% contain a warmnose
warmnose = zeros(length(goodfinal),1);

% Define x and y to be arrays or zeros.  In this section, x and y will be
% used to determine the location of the warmnoses
x = zeros(length(goodfinal),1);
y = zeros(length(goodfinal),1);

% Here, freezingx and freezingy are created to have a line near freezing on the
% plot of the sounding.  This is used in the polyxpoly function below to
% determine if and where the sounding passes the near freezing line thus
% producing a warmnose
freezingx = 0:1200;
freezingy = ones(1,length(freezingx)).*-0.2;
freezingxg = 0:16;
freezingyg = ones(1,length(freezingxg)).*-0.2;

jaja = 1;
R = 287.75;
grav = 9.81;
% Note, lcl value is km (Use 125 if m desired)
% The following loop runs through every sounding that meets the required
% temperature and relative humidity threshold
for e = 1:length(goodfinal) %to get information/plots for a specific sounding, change the "e" variable to be e = (a number)
    
    mb200 = find(goodfinal(e).pressure >= 20000); %find indices of readings where the pressure is greater than 20000 Pa
        
    presheight = goodfinal(e).pressure(mb200); %select readings greater than 20000 Pa
        
    presheightvector = presheight/100; %convert Pa to hPa (mb)
    
    if isnan(goodfinal(e).geopotential(1))==0
        geoheightvector(1) = goodfinal(e).geopotential(1)/1000;
        %disp('1 is good')
    elseif isnan(goodfinal(e).geopotential(1))==1 && isnan(goodfinal(e).geopotential(2))==0
        geoheightvector(1) = goodfinal(e).geopotential(2)/1000;
        disp('2 is good')
        disp(e)
    elseif isnan(goodfinal(e).geopotential(1))==1 && isnan(goodfinal(e).geopotential(2))==1 && isnan(goodfinal(e).geopotential(3))==0
        geoheightvector(1) = goodfinal(e).geopotential(3)/1000;
        disp('all the way to 3')
        disp(e)
    else
        disp('This data is really bad! Wow!')
        disp(e)
    end
    
  
    
    %define temp as the temperatures from the surface to 200 mb
    prestemp = goodfinal(e).temp(mb200);
    geotemp = goodfinal(e).temp(mb200);
    
    for z = 2:length(presheightvector')
        %geoheightvector(z) = 8*log(presheightvector(1)/presheightvector(z)); %calculate height data based on the pressure height; this prevents loss of warmnoses based on the sparse height readings available in the IGRA dataset
        geoheightvector(z) = (R/grav*(((geotemp(1)+273.15)+(geotemp(z)+273.15))/2)*log(presheightvector(1)/presheightvector(z)))/1000;
    end
    
    geoheightvector = geoheightvector'; %transpose to match shape of others, important for polyxpoly
    % Find any missing values in the height vectors
    presheightnans = isnan(presheightvector);
    geoheightnans = isnan(geoheightvector);
    
    % Find any missing values in the temperature vectors
    prestempnans = isnan(prestemp);
    geotempnans = isnan(geotemp);
    
    % If either height or temperature have missing values, set the other to
    % have missing values at that location as well (required for polyxpoly
    % function to run properly) 
    presheightvector(or(presheightnans,prestempnans)) = NaN;
    prestemp(or(presheightnans,prestempnans)) = NaN;
    geoheightvector(or(geoheightnans,geotempnans)) = NaN;
    geotemp(or(geoheightnans,geotempnans)) = NaN;
    
    % polyxpoly function finds intersection between plot of sounding
    % (temperature versus pressure) and plot of freezing line.  The
    % function returns x which represents the height (in mb) of the
    % intersection and y which represents the temperature (in C) of the
    % intersection. The second run of polyxpoly returns gx which represents the
    % height (in km) of the intersection and gy which represents the
    % temperature (in C) of the intersection.
    [x,y] = polyxpoly(presheightvector,prestemp,freezingx,freezingy);
    %disp(e)
    [gx,gy] = polyxpoly(geoheightvector,geotemp,freezingx,freezingy);
    
    %
%     height850 = find(goodfinal(e).pressure == 85000);
%     hpatemp850 = goodfinal(e).temp(height850);
%     hpadewpt850 = goodfinal(e).dewpt(height850);
%     height500 = find(goodfinal(e).pressure == 50000);
%     hpatemp500 = goodfinal(e).temp(height500);
%     height700 = find(goodfinal(e).pressure == 70000);
%     hpadewpt700 = goodfinal(e).dewpt(height700);
%     
%     goodfinal(e).warmnose.kindex = ((hpatemp850 - hpatemp500) + hpadewpt850 - hpadewpt700);

%   commented section is for TvP and TvZ plotting, uncomment only if those plots
%   are wanted (adds significantly to runtime)
    if numel(x)==1
        x1 = x(1); %PRESSURE
        y1 = y(1);
        gx1 = gx(1); %HEIGHT
        gy1 = gy(1);
        f59 = figure(59);
        g = subplot(1,2,1);
        plot(prestemp,presheightvector,freezingy,freezingx,'r',y1,x1,'*')
        g2 = subplot(1,2,2);
        plot(geotemp,geoheightvector,freezingyg,freezingxg,'r',gy1,gx1,'*')
    elseif numel(x)==2
        x1 = x(1);
        y1 = y(1);
        x2 = x(2);
        y2 = y(2);
        gx1 = gx(1); %HEIGHT
        gy1 = gy(1);
        gx2 = gx(2);
        gy2 = gy(2);
        f59 = figure(59);
        g = subplot(1,2,1);
        plot(prestemp,presheightvector,freezingy,freezingx,'r',y1,x1,'*',y2,x2,'*')
        g2 = subplot(1,2,2);
        plot(geotemp,geoheightvector,freezingyg,freezingxg,'r',gy1,gx1,'*',gy2,gx2,'*')
    elseif numel(x)==3
        x1 = x(1);
        y1 = y(1);
        x2 = x(2);
        y2 = y(2);
        x3 = x(3);
        y3 = y(3);
        gx1 = gx(1); %HEIGHT
        gy1 = gy(1);
        gx2 = gx(2);
        gy2 = gy(2);
        gx3 = gx(3);
        gy3 = gy(3);
        f59 = figure(59);
        g = subplot(1,2,1);
        plot(prestemp,presheightvector,freezingy,freezingx,'r',y1,x1,'*',y2,x2,'*',y3,x3,'*')
        g2 = subplot(1,2,2);
        plot(geotemp,geoheightvector,freezingyg,freezingxg,'r',gy1,gx1,'*',gy2,gx2,'*',gy3,gx3,'*')
    elseif numel(x)==4
        x1 = x(1);
        y1 = y(1);
        x2 = x(2);
        y2 = y(2);
        x3 = x(3);
        y3 = y(3);
        x4 = x(4);
        y4 = y(4);
        gx1 = gx(1); %HEIGHT
        gy1 = gy(1);
        gx2 = gx(2);
        gy2 = gy(2);
        gx3 = gx(3);
        gy3 = gy(3);
        gx4 = gx(4);
        gy4 = gy(4);
        f59 = figure(59);
        g = subplot(1,2,1);
        plot(prestemp,presheightvector,freezingy,freezingx,'r',y1,x1,'*',y2,x2,'*',y3,x3,'*',y4,x4,'*')
        g2 = subplot(1,2,2);
        plot(geotemp,geoheightvector,freezingyg,freezingxg,'r',gy1,gx1,'*',gy2,gx2,'*',gy3,gx3,'*',gy4,gx4,'*')
    elseif numel(x)==5
        x1 = x(1);
        y1 = y(1);
        x2 = x(2);
        y2 = y(2);
        x3 = x(3);
        y3 = y(3);
        x4 = x(4);
        y4 = y(4);
        x5 = x(5);
        y5 = y(5);
        gx1 = gx(1); %HEIGHT
        gy1 = gy(1);
        gx2 = gx(2);
        gy2 = gy(2);
        gx3 = gx(3);
        gy3 = gy(3);
        gx4 = gx(4);
        gy4 = gy(4);
        gx5 = gx(5);
        gy5 = gy(5);
        f59 = figure(59);
        g = subplot(1,2,1);
        plot(prestemp,presheightvector,freezingy,freezingx,'r',y1,x1,'*',y2,x2,'*',y3,x3,'*',y4,x4,'*',y5,x5,'*')
        g2 = subplot(1,2,2);
        plot(geotemp,geoheightvector,freezingyg,freezingxg,'r',gy1,gx1,'*',gy2,gx2,'*',gy3,gx3,'*',gy4,gx4,'*',gy5,gx5,'*')
    elseif numel(x)==6
        x1 = x(1);
        y1 = y(1);
        x2 = x(2);
        y2 = y(2);
        x3 = x(3);
        y3 = y(3);
        x4 = x(4);
        y4 = y(4);
        x5 = x(5);
        y5 = y(5);
        x6 = x(6);
        y6 = y(6);
        gx1 = gx(1); %HEIGHT
        gy1 = gy(1);
        gx2 = gx(2);
        gy2 = gy(2);
        gx3 = gx(3);
        gy3 = gy(3);
        gx4 = gx(4);
        gy4 = gy(4);
        gx5 = gx(5);
        gy5 = gy(5);
        gx6 = gx(6);
        gy6 = gy(6);
        f59 = figure(59);
        g = subplot(1,2,1);
        plot(prestemp,presheightvector,freezingy,freezingx,'r',y1,x1,'*',y2,x2,'*',y3,x3,'*',y4,x4,'*',y5,x5,'*',y6,x6,'*')
        g2 = subplot(1,2,2);
        plot(geotemp,geoheightvector,freezingyg,freezingxg,'r',gy1,gx1,'*',gy2,gx2,'*',gy3,gx3,'*',gy4,gx4,'*',gy5,gx5,'*',gy6,gx6,'*')
    elseif isempty(x)==1
        %disp('No warmnose!')
        f20303 = figure(20303);
        g = subplot(1,2,1);
        plot(prestemp,presheightvector,freezingy,freezingx,'r')
        g2 = subplot(1,2,2);
        plot(geotemp,geoheightvector,freezingyg,freezingxg,'r')
        hold off
        jaja = jaja+1; %tracks how many no-warmnose soundings there are
    else
        disp('Error!')
    end
    
    datenum = num2str(goodfinal(e).valid_date_num);
    title(g,['Sounding for ' datenum])
    title(g2,['Sounding for ' datenum])
   % legend('Temp vs Pressure','Freezing line','Lower Bound #1','Upper Bound #1','Lower Bound #2','Upper Bound #2','Lower Bound #3','Upper Bound #3')
    xlabel(g,'Temperature in C')
    xlabel(g2,'Temperature in C')
    ylabel(g,'Pressure in mb')
    ylabel(g2,'Height in km')
    set(g,'YDir','reverse');
    ylim(g,[200 nanmax(presheightvector)]);
    ylim(g2,[0 13]);
    set(g2,'yaxislocation','right')
    hold off %otherwise skew-T will plot in the subplot
%     if goodfinal(e).warmnose.kindex >= 20
%        goodfinal(e).warmnose.convection = 1;
%     else
%        goodfinal(e).warmnose.convection = 0;
%     end
    [f9999] = FWOKXskew(goodfinal(e).rhum,goodfinal(e).temp,goodfinal(e).pressure,goodfinal(e).temp-goodfinal(e).dew_point_dep); %uncomment this line for skew-T plotting
    hold off
    goodfinal(e).warmnose.lclheight = (0.125.*(goodfinal(e).dew_point_dep(1))); %find the LCL in km
    goodfinal(e).warmnose.maxtemp = max(prestemp); %find maximum temperature (corresponding to warm nose in pressure coordinates)
    goodfinal(e).warmnose.geotemp = max(geotemp); %find maximum temperature (corresponding to warm nose in geopotential height coordinates)
  
    if isempty(x) %if x is empty, then there isn't a warm nose
        warmnose(e) = 0; %set index within warmnose to logical false
        %xintersect(e) = NaN; %xintersect does not exist
        goodfinal(e).warmnose.numwarmnose = 0; %and the warmnose entry within goodfinal is blank
    else %in ANY other circumstance, there is at least one warmnose
        warmnose(e) = 1;
        if length(x) == 1
            goodfinal(e).warmnose.x = x; %PRESSURE x value from polyxpoly
            goodfinal(e).warmnose.gx = gx; %HEIGHT x value from polyxpoly
            goodfinal(e).warmnose.numwarmnose = 1; %number of warm nose is one; since the T profile only crosses the freezing line once, it is implied that it is in contact with the ground
            goodfinal(e).warmnose.lowerbound1 = presheightvector(1); %PRESSURE lower bound (this is the lowest pressure reading)
            goodfinal(e).warmnose.lowerboundg1 = geoheightvector(1); %HEIGHT lower bound (this is the lowest height reading)
            goodfinal(e).warmnose.upperbound1 = x(1); %PRESSURE upper bound (this is the pressure level where the T profile crosses the freezing line)
            goodfinal(e).warmnose.upperboundg1 = gx(1); %HEIGHT upper bound (this is the height where the T profile crosses the freezing line)
            goodfinal(e).warmnose.lower(1) = presheightvector(1); %PRESSURE
            goodfinal(e).warmnose.lowerg(1) = geoheightvector(1); %HEIGHT
            goodfinal(e).warmnose.upper(1) = x(1); %PRESSURE
            goodfinal(e).warmnose.upperg(1) = gx(1); %HEIGHT (these second instances form a matrix of the lower/upper bounds, providing an easier way to see this information)
            goodfinal(e).warmnose.depth1 = goodfinal(e).warmnose.lowerbound1 - goodfinal(e).warmnose.upperbound1; %PRESSURE depth calculation; pressure decreases with height so this is lower minus upper
            goodfinal(e).warmnose.gdepth1 = goodfinal(e).warmnose.upperboundg1 - goodfinal(e).warmnose.lowerboundg1; %HEIGHT depth calculation; height increases with height so this is upper minus lower
        elseif length(x) == 2
            goodfinal(e).warmnose.x = x; %PRESSURE x value from polyxpoly
            goodfinal(e).warmnose.gx = gx; %HEIGHT x value from polyxpoly
            goodfinal(e).warmnose.numwarmnose = 1; %number of warm nose is one; since the T profile crosses the freezing line twice, it can be inferred that it is aloft
            goodfinal(e).warmnose.lowerbound1 = x(2); %PRESSURE lower bound
            goodfinal(e).warmnose.lowerboundg1 = gx(1); %HEIGHT lower bound; note that the indices are reversed because pressure decreases with height and height increases with height
            goodfinal(e).warmnose.upperbound1 = x(1); %PRESSURE upper bound
            goodfinal(e).warmnose.upperboundg1 = gx(2); %HEIGHT upper bound
            goodfinal(e).warmnose.lower(1) = x(2);
            goodfinal(e).warmnose.lowerg(1) = gx(1);
            goodfinal(e).warmnose.upper(1) = x(1);
            goodfinal(e).warmnose.upperg(1) = gx(2);
            goodfinal(e).warmnose.depth1 = goodfinal(e).warmnose.lowerbound1 - goodfinal(e).warmnose.upperbound1; %PRESSURE depth calculation; pressure decreases with height so this is lower minus upper
            goodfinal(e).warmnose.gdepth1 = goodfinal(e).warmnose.upperboundg1 - goodfinal(e).warmnose.lowerboundg1; %HEIGHT depth calculation; height increases with height so this is upper minus lower
        elseif length(x) == 3
            goodfinal(e).warmnose.x = x; %PRESSURE x value from polyxpoly
            goodfinal(e).warmnose.gx = gx; %HEIGHT x value from polyxpoly
            goodfinal(e).warmnose.numwarmnose = 2; %number of warm noses is two; since the T profile crosses the freezing line three times, it is clear that both a warmnose aloft and a warmnose in contact with the ground are present
            goodfinal(e).warmnose.lowerbound1 = presheightvector(1); %PRESSURE lower bound; this is the lowest pressure reading (since there is a warmnose at ground level)
            goodfinal(e).warmnose.lowerboundg1 = geoheightvector(1); %HEIGHT lower bound; this is the lowest height reading
            goodfinal(e).warmnose.upperbound1 = x(3); %PRESSURE upper bound of grounded warmnose
            goodfinal(e).warmnose.upperboundg1 = gx(1); %HEIGHT upper bound of grounded warmnose
            goodfinal(e).warmnose.upperbound2 = x(1); %PRESSURE upper bound of warmnose aloft
            goodfinal(e).warmnose.upperboundg2 = gx(3); %HEIGHT upper bound of warmnose aloft
            goodfinal(e).warmnose.lowerbound2 = x(2); %PRESSURE lower bound of warmnose aloft
            goodfinal(e).warmnose.lowerboundg2 = gx(2); %HEIGHT lower bound of warmnose aloft
            goodfinal(e).warmnose.lower(1) = presheightvector(1); 
            goodfinal(e).warmnose.lowerg(1) = geoheightvector(1);
            goodfinal(e).warmnose.upper(1) = x(3);
            goodfinal(e).warmnose.upperg(1) = gx(1);
            goodfinal(e).warmnose.lower(2) = x(2);
            goodfinal(e).warmnose.lowerg(2) = gx(2);
            goodfinal(e).warmnose.upper(2) = x(1);
            goodfinal(e).warmnose.upperg(2) = gx(3);
            goodfinal(e).warmnose.depth1 = goodfinal(e).warmnose.lowerbound1 - goodfinal(e).warmnose.upperbound1; %PRESSURE depth of grounded warmnose is lower minus upper
            goodfinal(e).warmnose.gdepth1 = goodfinal(e).warmnose.upperboundg1 - goodfinal(e).warmnose.lowerboundg1; %HEIGHT depth of grounded warmnose is upper minus lower
            goodfinal(e).warmnose.depth2 = goodfinal(e).warmnose.lowerbound2 - goodfinal(e).warmnose.upperbound2; %PRESSURE depth of warmnose aloft is lower minus upper
            goodfinal(e).warmnose.gdepth2 = goodfinal(e).warmnose.upperboundg2 - goodfinal(e).warmnose.lowerboundg2; %HEIGHT depth of warmnose aloft is upper minus lower
        elseif length(x) == 4
            goodfinal(e).warmnose.x = x; %PRESSURE x value from polyxpoly
            goodfinal(e).warmnose.gx = gx; %HEIGHT x value from polyxpoly
            goodfinal(e).warmnose.numwarmnose = 2; %number of warm noses is two; since the T profile croses the freezing line four times, it is clear that there are two warmnoses aloft
            goodfinal(e).warmnose.upperbound1 = x(3); %PRESSURE upper bound of lowest warmnose aloft
            goodfinal(e).warmnose.upperboundg1 = gx(2); %HEIGHT upper bound of lowest warmnose aloft
            goodfinal(e).warmnose.lowerbound1 = x(4); %PRESSURE lower bound of lowest warmnose aloft
            goodfinal(e).warmnose.lowerboundg1 = gx(1); %HEIGHT lower bound of lowest warmnose aloft
            goodfinal(e).warmnose.upperbound2 = x(1); %PRESSURE upper bound of highest warmnose aloft
            goodfinal(e).warmnose.upperboundg2 = gx(4); %HEIGHT upper bound of highest warmnose aloft
            goodfinal(e).warmnose.lowerbound2 = x(2); %PRESSURE lower bound of highest warmnose aloft
            goodfinal(e).warmnose.lowerboundg2 = gx(3); %HEIGHT lower bound of highest warmnose aloft
            goodfinal(e).warmnose.lower(1) = x(4);
            goodfinal(e).warmnose.lowerg(1) = gx(1);
            goodfinal(e).warmnose.upper(1) = x(3);
            goodfinal(e).warmnose.upperg(1) = gx(2);
            goodfinal(e).warmnose.lower(2) = x(2);
            goodfinal(e).warmnose.lowerg(2) = gx(3);
            goodfinal(e).warmnose.upper(2) = x(1);
            goodfinal(e).warmnose.upperg(2) = gx(4);
            goodfinal(e).warmnose.depth1 = goodfinal(e).warmnose.lowerbound1 - goodfinal(e).warmnose.upperbound1; %PRESSURE depth of lowest warmnose
            goodfinal(e).warmnose.gdepth1 = goodfinal(e).warmnose.upperboundg1 - goodfinal(e).warmnose.lowerboundg1; %HEIGHT depth of lowest warmnose
            goodfinal(e).warmnose.depth2 = goodfinal(e).warmnose.lowerbound2 - goodfinal(e).warmnose.upperbound2; %PRESSURE depth of highest warmnose
            goodfinal(e).warmnose.gdepth2 = goodfinal(e).warmnose.upperboundg2 - goodfinal(e).warmnose.lowerboundg2; %HEIGHT depth of highest warmnose
        elseif length(x) == 5
            goodfinal(e).warmnose.x = x; %PRESSURE x from polyxpoly
            goodfinal(e).warmnose.gx = gx; %HEIGHT x from polyxpoly
            goodfinal(e).warmnose.numwarmnose = 3; %number of warmnoses is three; since T profile crosses freezing line 5 times there are two warmnoses aloft and a grounded warmnose present
            goodfinal(e).warmnose.lowerbound1 = presheightvector(1); %PRESSURE lower bound of grounded warmnose
            goodfinal(e).warmnose.lowerboundg1 = geoheightvector(1); %HEIGHT lower bound of grounded warmnose
            goodfinal(e).warmnose.upperbound1 = x(5); %PRESSURE upper bound of grounded warmnose
            goodfinal(e).warmnose.upperboundg1 = gx(1); %HEIGHT upper bound of grounded warmnose
            goodfinal(e).warmnose.upperbound2 = x(3); %PRESSURE upper bound of lowest warmnose aloft
            goodfinal(e).warmnose.upperboundg2 = gx(3); %HEIGHT upper bound of lowest warmnose aloft
            goodfinal(e).warmnose.lowerbound2 = x(4); %PRESSURE lower bound of lowest warmnose aloft
            goodfinal(e).warmnose.lowerboundg2 = gx(2); %HEIGHT lower bound of lowest warmnose aloft
            goodfinal(e).warmnose.upperbound3 = x(1); %PRESSURE upper bound of highest warmnose aloft
            goodfinal(e).warmnose.upperboundg3 = gx(5); %HEIGHT upper bound of highest warmnose aloft
            goodfinal(e).warmnose.lowerbound3 = x(2); %PRESSURE lower bound of highest warmnose aloft
            goodfinal(e).warmnose.lowerboundg3 = gx(4); %HEIGHT lower bound of highest warmnose aloft
            goodfinal(e).warmnose.lower(1) = presheightvector(1); %disabled for now
            goodfinal(e).warmnose.lowerg(1) = geoheightvector(1); %hi
            goodfinal(e).warmnose.upper(1) = x(5);
            goodfinal(e).warmnose.upperg(1) = gx(1);
            goodfinal(e).warmnose.lower(2) = x(4);
            goodfinal(e).warmnose.lowerg(2) = gx(2);
            goodfinal(e).warmnose.upper(2) = x(3);
            goodfinal(e).warmnose.upperg(2) = gx(3);
            goodfinal(e).warmnose.lower(3) = x(2);
            goodfinal(e).warmnose.lowerg(3) = gx(4);
            goodfinal(e).warmnose.upper(3) = x(1);
            goodfinal(e).warmnose.upperg(3) = gx(5);
            goodfinal(e).warmnose.depth1 = goodfinal(e).warmnose.lowerbound1 - goodfinal(e).warmnose.upperbound1; %PRESSURE depth of grounded warmnose
            goodfinal(e).warmnose.gdepth1 = goodfinal(e).warmnose.upperboundg1 - goodfinal(e).warmnose.lowerboundg1; %HEIGHT depth of grounded warmnose
            goodfinal(e).warmnose.depth2 = goodfinal(e).warmnose.lowerbound2 - goodfinal(e).warmnose.upperbound2; %PRESSURE depth of lowest warmnose aloft
            goodfinal(e).warmnose.gdepth2 = goodfinal(e).warmnose.upperboundg2-goodfinal(e).warmnose.lowerboundg2; %HEIGHT depth of lowest warmnose aloft
            goodfinal(e).warmnose.depth3 = goodfinal(e).warmnose.lowerbound3 - goodfinal(e).warmnose.upperbound3; %PRESSURE depth of highest warmnose aloft
            goodfinal(e).warmnose.gdepth3 = goodfinal(e).warmnose.upperboundg3 - goodfinal(e).warmnose.lowerboundg3; %HEIGHT depth of highest warmnose aloft
        elseif length(x) == 6
            goodfinal(e).warmnose.x = x; %PRESSURE x from polyxpoly
            goodfinal(e).warmnose.gx = gx; %HEIGHT x from polyxpoly
            goodfinal(e).warmnose.numwarmnose = 3; %number of warmnoses is three; since T profile crosses the freezing line six times there are three warmnoses aloft
            goodfinal(e).warmnose.upperbound1 = x(5); %PRESSURE upper bound of lowest warmnose aloft
            goodfinal(e).warmnose.upperboundg1 = gx(2); %HEIGHT upper bound of lowest warmnose aloft
            goodfinal(e).warmnose.lowerbound1 = x(6); %PRESSURE lower bound of lowest warmnose aloft
            goodfinal(e).warmnose.lowerboundg1 = gx(1); %HEIGHT lower bound of lowest warmnose aloft
            goodfinal(e).warmnose.upperbound2 = x(3); %PRESSURE upper bound of middle warmnose aloft
            goodfinal(e).warmnose.upperboundg2 = gx(4); %HEIGHT upper bound of middle warmnose aloft
            goodfinal(e).warmnose.lowerbound2 = x(4); %PRESSURE lower bound of middle warmnose aloft
            goodfinal(e).warmnose.lowerboundg2 = gx(3); %HEIGHT lower bound of middle warmnose aloft
            goodfinal(e).warmnose.upperbound3 = x(1); %PRESSURE upper bound of highest warmnose aloft
            goodfinal(e).warmnose.upperboundg3 = gx(6); %HEIGHT upper bound of highest warmnose aloft
            goodfinal(e).warmnose.lowerbound3 = x(2); %PRESSURE lower bound of highest warmnose aloft
            goodfinal(e).warmnose.lowerboundg3 = gx(5); %HEIGHT lower bound of highest warmnose aloft
            goodfinal(e).warmnose.lower(1) = x(6);
            goodfinal(e).warmnose.lowerg(1) = gx(1);
            goodfinal(e).warmnose.upper(1) = x(5);
            goodfinal(e).warmnose.upperg(1) = gx(2);
            goodfinal(e).warmnose.lower(2) = x(4);
            goodfinal(e).warmnose.lowerg(2) = gx(3);
            goodfinal(e).warmnose.upper(2) = x(3);
            goodfinal(e).warmnose.upperg(2) = gx(4);
            goodfinal(e).warmnose.lower(3) = x(2);
            goodfinal(e).warmnose.lowerg(3) = gx(5);
            goodfinal(e).warmnose.upper(3) = x(1);
            goodfinal(e).warmnose.upperg(3) = gx(6);
            goodfinal(e).warmnose.depth1 = goodfinal(e).warmnose.lowerbound1 - goodfinal(e).warmnose.upperbound1; %PRESSURE depth of lowest warmnose
            goodfinal(e).warmnose.gdepth1 = goodfinal(e).warmnose.upperboundg1 - goodfinal(e).warmnose.lowerboundg1; %HEIGHT depth of lowest warmnose
            goodfinal(e).warmnose.depth2 = goodfinal(e).warmnose.lowerbound2 - goodfinal(e).warmnose.upperbound2; %PRESSURE depth of middle warmnose
            goodfinal(e).warmnose.gdepth2 = goodfinal(e).warmnose.upperboundg2 - goodfinal(e).warmnose.lowerboundg2; %HEIGHT depth of middle warmnose
            goodfinal(e).warmnose.depth3 = goodfinal(e).warmnose.lowerbound3 - goodfinal(e).warmnose.upperbound3; %PRESSURE depth of highest warmnose
            goodfinal(e).warmnose.gdepth3 = goodfinal(e).warmnose.upperboundg3 - goodfinal(e).warmnose.lowerboundg3; %HEIGHT depth of highest warmnose
        else
            goodfinal(e).warmnose.numwarmnose = NaN; %situations with any more than six warmnoses are discarded as instrument error
        end
    end
    geoheightvector = []; %clear geoheightvector, otherwise old indices will hang around
end

warmnoses = logical(warmnose); %find all of the indices where warmnoses actually exist
warmnosesfinal = goodfinal(warmnoses); %create a structure that contains only the warmnose soundings
       
nowarmnoses = ~logical(warmnose); %also create a structure that contains the quality-controlled soundings sans warmnoses
nowarmnosefinal = goodfinal(nowarmnoses);

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
