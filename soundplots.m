%soundplots -- function to chart soundings for a specific date, given a
%sounding data structure such as that created by FWOKXh6 or IGRAimpf.
%prefers if levfilter has been run
%best to just run FWOKXh[vnumber] and use with goodfinal or warmnosesfinal
%General form: [foundit] = soundplots(y,m,d,t,sounding)
%Output:
%foundit: index of the sounding with the datenumber requested
%generates a skew-T, a zT and a PT plot of the sounding
%Inputs: y (4-digit year), m (2 digit month), d (2 digit day), t (either 00
%or 12), sounding (a sounding data structure).
%Version date: 5/26/17

function [foundit] = soundplots(y,m,d,t,sounding)
if ~exist('sounding.rhum') %make sure that rhum and dewpoint are present
    for c = 1:length(sounding) %if they aren't then use the same code as FWOKXh6 does to add dewpoint and relative humidity
    sounding(c).dewpt = (sounding(c).temp - sounding(c).dew_point_dep);
    sounding(c).rhum = (100.*(((112 - (0.1.*(sounding(c).temp)) + (sounding(c).dewpt)) ./ (112 + (0.9 .*(sounding(c).temp)))).^8)); %I still think this is a wacky humidity calculation
    end
end

[r,~] = size(sounding); %find the number of soundings
if r==1 %if it's oriented the other way
    [~,r] = size(sounding); %find it this way instead
end
for as = 1:r %loop through everything
    datenum{as} = sounding(as).valid_date_num;
    if isequal(datenum{as},[y,m,d,t])==1 %look for the requested date
        foundit = as; %here it is!
        disp(foundit) %show it just in case there wasn't an output call
        break %don't loop longer than necessary
    else %do nothing
    end
end

if ~exist('foundit','var') %if the date doesn't have a corresponding entry in the sounding structure, foundit won't exist
    disp('No data available for this date!')
    return %stop the function from running
end

mb200 = find(sounding(foundit).pressure >= 20000); %find indices of readings where the pressure is greater than 20000 Pa
presheight = sounding(foundit).pressure(mb200); %select readings greater than 20000 Pa
presheightvector = presheight/100; %convert Pa to hPa (mb)

%first geopotential height entry should be straight from the data
if isnan(sounding(foundit).geopotential(1))==0
    geoheightvector(1) = sounding(foundit).geopotential(1)/1000;
    %disp('1 is good')
elseif isnan(sounding(foundit).geopotential(1))==1 && isnan(sounding(foundit).geopotential(2))==0
    geoheightvector(1) = sounding(foundit).geopotential(2)/1000;
    disp('2 is good')
    disp(foundit)
elseif isnan(sounding(foundit).geopotential(1))==1 && isnan(sounding(foundit).geopotential(2))==1 && isnan(sounding(foundit).geopotential(3))==0
    geoheightvector(1) = sounding(foundit).geopotential(3)/1000;
    disp('all the way to 3')
    disp(foundit)
else
    disp('This data is really bad! Wow!')
    disp(foundit)
end

geoheightvector = geoheightvector'; %transpose to match shape of others, important for polyxpoly

%define temp as the temperatures from the surface to 200 mb
prestemp = sounding(foundit).temp(mb200);
geotemp = sounding(foundit).temp(mb200);

R = 287.75; %dry air constant J/(kgK)
grav = 9.81; %gravity m/s^2

for z = 2:length(presheightvector')
    %geoheightvector(z) = 8*log(presheightvector(1)/presheightvector(z)); %calculate height data based on the pressure height; this prevents loss of warmnoses based on the sparse height readings available in the IGRA dataset
    geoheightvector(z) = (R/grav*(((geotemp(1)+273.15)+(geotemp(z)+273.15))/2)*log(presheightvector(1)/presheightvector(z)))/1000; %much more accurate equation to calculate geopotential height
end

%extra quality control to prevent jumps in the graphs
geoheightvector(geoheightvector<-150) = NaN;
geoheightvector(geoheightvector>100) = NaN;
presheightvector(presheightvector<0) = NaN;
prestemp(prestemp<-150) = NaN;
prestemp(prestemp>100) = NaN;
geotemp(geotemp<-150) = NaN;
geotemp(geotemp>100) = NaN;
sounding(foundit).rhum(sounding(foundit).rhum<0) = NaN;
sounding(foundit).dewpt(sounding(foundit).dewpt<-150) = NaN;
sounding(foundit).temp(sounding(foundit).temp<-150) = NaN;

%freezing lines for Tvz and TvP charts
freezingx = 0:1200;
freezingy = ones(1,length(freezingx)).*-0.2;
freezingxg = 0:16;
freezingyg = ones(1,length(freezingxg)).*-0.2;

%plotting
f9034 = figure(9034); %new figure
g = subplot(1,2,1); %subplot left
plot(prestemp,presheightvector,freezingy,freezingx,'r') %TvP
g2 = subplot(1,2,2); %subplot right
plot(geotemp,geoheightvector,freezingyg,freezingxg,'r') %Tvz
datenum = num2str(sounding(foundit).valid_date_num);
title(g,['Sounding for ' datenum])
title(g2,['Sounding for ' datenum])
xlabel(g,'Temperature in C')
xlabel(g2,'Temperature in C')
ylabel(g,'Pressure in mb')
ylabel(g2,'Height in km')
set(g,'YDir','reverse');
ylim(g,[200 nanmax(presheightvector)]);
ylim(g2,[0 13]);
set(g2,'yaxislocation','right')
hold off
[f999] = FWOKXskew(sounding(foundit).rhum,sounding(foundit).temp,sounding(foundit).pressure,sounding(foundit).temp-sounding(foundit).dew_point_dep); %Skew-T


end