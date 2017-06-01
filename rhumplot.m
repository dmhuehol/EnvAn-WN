%%rhumplot--function to generate figure with charts of relative humidity vs pressure
%and relative humidity vs height, given a sounding number and a sounding
%data structure. Note that this functionality is also present alongside T
%and skew-T plotting in the soundplots function; this should be used if
%only a relative humidity plot is wanted.
%
%General form: [LCL] = rhumplot(snum,sounding)
%Outputs:
%LCL - estimated level of cloud base
%
%Inputs:
%snum: a sounding number (sounding number for a specific date can be found
%   using findsnd or soundplots)
%sounding: a soundings data structure
%
%Version Date: 6/1/17
%Last major revision: 6/1/17
%Written by: Daniel Hueholt
%North Carolina State University
%Undergraduate Researcher at Environment Analytics
%
%See also: soundplots, findsnd, IGRAimpf, ESRLn
%

function [LCL] = rhumplot(snum,sounding)
[r,~] = size(sounding); %find the number of soundings
if r==1 %if it's oriented the other way
    [~,r] = size(sounding); %find it this way instead
end

check = fieldnames(sounding);

if isempty(nonzeros(ismember(check,'rhum'))) == 1 %check if the sounding has a relative humidity field, named rhum if generated by dewrelh or FWOKXh line
    for a = 1:r
        [sounding(a).dewpoint,sounding(a).relative_humidity] = dewrelh(sounding(a).temp,sounding(a).dew_point_dep); %call to dewrelh to add dewpoint and relative humidity
    end
end

mb200 = find(sounding(snum).pressure >= 20000); %find indices of readings where the pressure is greater than 20000 Pa
presheight = sounding(snum).pressure(mb200); %select readings greater than 20000 Pa
presheightvector = presheight/100; %convert Pa to hPa (mb)

%first geopotential height entry should be straight from the data
if isnan(sounding(snum).geopotential(1))==0
    geoheightvector(1) = sounding(snum).geopotential(1)/1000;
    %disp('1 is good')
elseif isnan(sounding(snum).geopotential(1))==1 && isnan(sounding(snum).geopotential(2))==0
    geoheightvector(1) = sounding(snum).geopotential(2)/1000;
    disp('2 is good')
    disp(snum)
elseif isnan(sounding(snum).geopotential(1))==1 && isnan(sounding(snum).geopotential(2))==1 && isnan(sounding(snum).geopotential(3))==0
    geoheightvector(1) = sounding(snum).geopotential(3)/1000;
    disp('all the way to 3')
    disp(snum)
else
    disp('This data is really bad! Wow!')
    disp(snum)
end

geoheightvector = geoheightvector'; %transpose to match shape of others, important for polyxpoly

%define rhum and temp as humidities and temp from surface to 200mb
%(temp is not plotted, but still needed to calculate geopotential height)
rhum = sounding(snum).rhum(mb200);
geotemp = sounding(snum).temp(mb200);

R = 287.75; %dry air constant J/(kgK)
grav = 9.81; %gravity m/s^2

for z = 2:length(presheightvector')
    geoheightvector(z) = (R/grav*(((geotemp(1)+273.15)+(geotemp(z)+273.15))/2)*log(presheightvector(1)/presheightvector(z)))/1000; %much more accurate equation to calculate geopotential height
end

%extra quality control to prevent jumps in the graphs
geoheightvector(geoheightvector<-150) = NaN;
geoheightvector(geoheightvector>100) = NaN;
presheightvector(presheightvector<0) = NaN;
sounding(snum).rhum(sounding(snum).rhum<0) = NaN;
sounding(snum).dewpt(sounding(snum).dewpt<-150) = NaN;


%find LCL (estimated as first height where RH=100)
[r,~] = find(rhum(rhum==100));
lcl = NaN; %assume there isn't a cloud
if ~isempty(nonzeros(r))
    lcl = r(1);
end
if isnan(lcl)==1
    LCL(1) = NaN; %pressure level
    LCL(2) = NaN; %height
else
    LCL(1) = presheightvector(lcl); %pressure level
    LCL(2) = geoheightvector(lcl); %height
end

f92034 = figure(92034); %new figure
g = subplot(1,2,1); %subplot left
plot(rhum,presheightvector) %RHvP
g2 = subplot(1,2,2); %subplot right
plot(rhum,geoheightvector) %RHvz
datenum = num2str(sounding(snum).valid_date_num);
title(g,['Sounding for ' datenum])
title(g2,['Sounding for ' datenum])
xlabel(g,'Relative Humidity in %')
xlabel(g2,'Relative Humidity in %')
ylabel(g,'Pressure in mb')
ylabel(g2,'Height in km')
set(g,'YDir','reverse');
ylim(g,[200 nanmax(presheightvector)]);
ylim(g2,[0 13]);
set(g2,'yaxislocation','right')
hold off
end