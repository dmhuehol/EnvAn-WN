function [dat,decoded] = wnumport(input_file,todecode)
%%wnumport
    %function to process surface observation data from the Mesowest
    %dataset. Given a csv data file from Mesowest (usually covering a span of 1
    %month to 1 year), the function will create a data array containing the
    %time (month, day, year, hour, minute) of the observation and the
    %associated weather condition codes, temperature, dewpoint, relative
    %humidity, wind speed, wind direction, pressure, and 1-hour precipitation
    %totals. If todecode input is 1, the weather condition codes are decoded
    %and added to the end of the table.
    %This function will only work if the data has been downloaded with Temperature, 
    %Dew Point, Relative Humidity, Wind Speed, Wind Direction, Pressure, 
    %Precipitation 1hr, and Weather Conditions fields.
    %
    %General form: [dat,decoded] = wnumport(input_file,todecode)
    %
    %Outputs
    %dat: output table with data
    %decoded: decoded weather condition codes
    %
    %Inputs
    %input_file: file path to Mesowest csv data file
    %todecode: input as 1 or 0--1 will cause the function to decode the weather
    %conditions, 0 will leave them as numerical codes
    %
    %Written by: Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %Version date: 6/14/2017
    %Last major revision: 5/31/17
    %
    %See also surfconfind
    %

%% File import
da = readtable(input_file,'HeaderLines',7); %import csv data file
try
    warning('off','MATLAB:table:ModifiedVarNames'); %disable MATLAB's warning about modified variable names
catch ME;
end

%% Data processing
%Select times, convert from cells into matrix, convert to double using
%fastest possible method.
month = sscanf(cell2mat(cellfun(@(c) c(1:2),da{:,2},'UniformOutput',false))','%2f');
day = sscanf(cell2mat(cellfun(@(c) c(4:5),da{:,2},'UniformOutput',false))','%2f');
year = sscanf(cell2mat(cellfun(@(c) c(7:10),da{:,2},'UniformOutput',false))','%4f');
hour = sscanf(cell2mat(cellfun(@(c) c(12:13),da{:,2},'UniformOutput',false))','%2f');
minute = sscanf(cell2mat(cellfun(@(c) c(15:16),da{:,2},'UniformOutput',false))','%2f');

%Select and convert surface conditions other than weather codes
pressureHg = da{:,3}; %pressure in inches mercury
pressurePa = da{:,3}*3386.38816; %pressure converted to Pascal
tempF = da{:,4}; %temperature in deg F
tempC = (da{:,4}-32)*5/9; %temperature in deg C
rhum = da{:,5}; %relative humidity in %
wspd = da{:,6}; %wind speed in miles per hour
wspdmps = da{:,6}*1609.344/60/60; %wind speed in meters per second
wdir = da{:,7}; %wind direction in angular degrees
hrpre = da{:,9}; %one-hour precipitation total in inches
dew = da{:,10}; %dewpoint in deg F

%Process weather codes
wnum = da{:,8}; %eighth column is weather conditions
con = {month;day;year;hour;minute;wnum;pressurePa;tempC;dew;rhum;wspdmps;wdir;hrpre}; %combine all data into a single cell array

%% Dealing with weather condition codes
%There are three categories of weather condition codes:
%category 1 (code less than 80): in this case, there is a single condition
%category 2 (code greater than or equal to 80 and less than 6340): in this 
%case, there were two conditions
%category 3 (code greater than or equal to 6340): in this case, there were
%three conditions
%There is a fourth option: the weather code is frequently NaN. In this
%case, the conditions were not reported. NaN is decoded by wnumport as "No reading."
[nindex] = find(isnan(wnum)==1); %find indices where the readings were NaN
[rindex] = find(wnum<80); %find indices with weather codes less than 80
[r2index] = find(wnum>=80); %find indices with weather codes greater than or equal to 80
[r3index] = find(wnum>6399); %find indices with weather codes greater than 6399
[oin,oinr2,oinr3] = intersect(r2index,r3index); %find the overlap of greater than or equal to 80 and greater than 6399
r2index(oinr2) = []; %destroy said overlap - this prevents the presence of codes greater than 6399 in the greater than or equal to 80 code array

%all operations come from Mesowest's online documentation
dcode = wnum(r2index); %select all two-condition codes
dcode1 = floor(dcode/80); %this is the first condition
dcode2 = dcode-dcode1*80; %this is the second condition
dcoded = horzcat(dcode1,dcode2); %concatenate into an rx2 array

tcode = wnum(r3index); %select all three-condition codes
tcode1 = floor(tcode/6400); %this is the first condition
tcode2 = floor((tcode-tcode1*6400)/80); %this is the second condition
tcode3 = tcode-tcode1*6400-tcode2*80; %this is the third condition
tcoded = horzcat(tcode1,tcode2,tcode3); %concatenate into an rx3 array

[r,~] = size(wnum); %how many observations are there
con{6} = Inf(r,3); %Inf instead of NaN to distinguish between missing data and fields that were unfilled (e.g. because only one condition was present)
con{6}(nindex,1) = NaN; %fill with NaNs as appropriate
con{6}(rindex,1) = wnum(rindex); %fill with one-conditions as appropriate
con{6}(r2index,1:2) = dcoded; %fill with two-conditions as appropriate
con{6}(r3index,1:3) = tcoded; %fill with three-conditions as appropriate

%% Create output
VariableNames = {'Month' 'Day' 'Year' 'Hour' 'Minute' 'WxCode' 'Pressure' 'Temperature' 'Dewpoint' 'RHumidity' 'WindSpeed' 'WindDir' 'HrPrecip'}; %will become column names in output table
st = cell2struct(con,VariableNames,1); %fastest way to make the correct dimensions and column names of table
dat = struct2table(st); %output

%% Decode weather conditions
willdecode = con{6}; %weather condition codes to be decoded
decoded = cell(r,3); %blank cell array to contain weather condition codes
if todecode==1 %input if user wants the codes to be decoded
    for dc = 1:3 %loop through all columns
        for dr = 1:r %and all rows
            %Following code is a replication of the table in online
            %Mesowest documentation. Blank entries on table (e.g. for code
            %of 12) are assumed to be missing data (entered here as "No
            %reading").
            if isnan(willdecode(dr,dc))==1
                decoded{dr,dc} = 'No reading';
            elseif willdecode(dr,dc)==Inf
                decoded{dr,dc} = 'No reading (added field)';
            elseif willdecode(dr,dc)==0
                decoded{dr,dc} = 'No reading';
            elseif willdecode(dr,dc)==1
                decoded{dr,dc} = 'Moderate rain';
            elseif willdecode(dr,dc)==2
                decoded{dr,dc} = 'Moderate drizzle';
            elseif willdecode(dr,dc)==3
                decoded{dr,dc} = 'Moderate snow';
            elseif willdecode(dr,dc)==4
                decoded{dr,dc} = 'Moderate hail';
            elseif willdecode(dr,dc)==5
                decoded{dr,dc} = 'Thunder';
            elseif willdecode(dr,dc)==6
                decoded{dr,dc} = 'Haze';
            elseif willdecode(dr,dc)==7
                decoded{dr,dc} = 'Smoke';
            elseif willdecode(dr,dc)==8
                decoded{dr,dc} = 'Dust';
            elseif willdecode(dr,dc)==9
                decoded{dr,dc} = 'Fog';
            elseif willdecode(dr,dc)==10
                decoded{dr,dc} = 'Squalls';
            elseif willdecode(dr,dc)==11
                decoded{dr,dc} = 'Volcanic ash';
            elseif willdecode(dr,dc)==12
                decoded{dr,dc} = 'No reading';
            elseif willdecode(dr,dc)==13
                decoded{dr,dc} = 'Light rain';
            elseif willdecode(dr,dc)==14
                decoded{dr,dc} = 'Heavy rain';
            elseif willdecode(dr,dc)==15
                decoded{dr,dc} = 'Moderate freezing rain';
            elseif willdecode(dr,dc)==16
                decoded{dr,dc} = 'Moderate rain shower';
            elseif willdecode(dr,dc)==17
                decoded{dr,dc} = 'Light drizzle';
            elseif willdecode(dr,dc)==18
                decoded{dr,dc} = 'Heavy drizzle';
            elseif willdecode(dr,dc)==19
                decoded{dr,dc} = 'Freezing drizzle';
            elseif willdecode(dr,dc)==20
                decoded{dr,dc} = 'Light snow';
            elseif willdecode(dr,dc)==21
                decoded{dr,dc} = 'Heavy snow';
            elseif willdecode(dr,dc)==22
                decoded{dr,dc} = 'Moderate snow shower';
            elseif willdecode(dr,dc)==23
                decoded{dr,dc} = 'Moderate ice pellets';
            elseif willdecode(dr,dc)==24
                decoded{dr,dc} = 'Moderate snow grains';
            elseif willdecode(dr,dc)==25
                decoded{dr,dc} = 'Moderate snow pellets';
            elseif willdecode(dr,dc)==26
                decoded{dr,dc} = 'Light hail';
            elseif willdecode(dr,dc)==27
                decoded{dr,dc} = 'Heavy hail';
            elseif willdecode(dr,dc)==28
                decoded{dr,dc} = 'Light thunder';
            elseif willdecode(dr,dc)==29
                decoded{dr,dc} = 'Heavy thunder';
            elseif willdecode(dr,dc)==30
                decoded{dr,dc} = 'Ice fog';
            elseif willdecode(dr,dc)==31
                decoded{dr,dc} = 'Ground fog';
            elseif willdecode(dr,dc)==32
                decoded{dr,dc} = 'Blowing snow';
            elseif willdecode(dr,dc)==33
                decoded{dr,dc} = 'Blowing dust';
            elseif willdecode(dr,dc)==34
                decoded{dr,dc} = 'Blowing spray';
            elseif willdecode(dr,dc)==35
                decoded{dr,dc} = 'Blowing sand';
            elseif willdecode(dr,dc)==36
                decoded{dr,dc} = 'Moderate ice crystals';
            elseif willdecode(dr,dc)==37
                decoded{dr,dc} = 'Ice needles';
            elseif willdecode(dr,dc)==38
                decoded{dr,dc} = 'Small hail';
            elseif willdecode(dr,dc)==39
                decoded{dr,dc} = 'Smoke, haze';
            elseif willdecode(dr,dc)==40
                decoded{dr,dc} = 'Dust whirls';
            elseif willdecode(dr,dc)==41
                decoded{dr,dc} = 'Unknown precipitation';
            elseif willdecode(dr,dc)==42
                decoded{dr,dc} = 'Unknown precipitation';
            elseif willdecode(dr,dc)==43
                decoded{dr,dc} = 'Unknown precipitation';
            elseif willdecode(dr,dc)==44
                decoded{dr,dc} = 'Unknown precipitation';
            elseif willdecode(dr,dc)==45
                decoded{dr,dc} = 'Unknown precipitation';
            elseif willdecode(dr,dc)==46
                decoded{dr,dc} = 'Unknown precipitation';
            elseif willdecode(dr,dc)==47
                decoded{dr,dc} = 'Unknown precipitation';
            elseif willdecode(dr,dc)==48
                decoded{dr,dc} = 'Unknown precipitation';
            elseif willdecode(dr,dc)==49
                decoded{dr,dc} = 'Light freezing rain';
            elseif willdecode(dr,dc)==50
                decoded{dr,dc} = 'Heavy freezing rain';
            elseif willdecode(dr,dc)==51
                decoded{dr,dc} = 'Light rain shower';
            elseif willdecode(dr,dc)==52
                decoded{dr,dc} = 'Heavy rain shower';
            elseif willdecode(dr,dc)==53
                decoded{dr,dc} = 'Light freezing drizzle';
            elseif willdecode(dr,dc)==54
                decoded{dr,dc} = 'Heavy freezing drizzle';
            elseif willdecode(dr,dc)==55
                decoded{dr,dc} = 'Light snow shower';
            elseif willdecode(dr,dc)==56
                decoded{dr,dc} = 'Heavy snow shower';
            elseif willdecode(dr,dc)==57
                decoded{dr,dc} = 'Light ice pellets';
            elseif willdecode(dr,dc)==58
                decoded{dr,dc} = 'Heavy ice pellets';
            elseif willdecode(dr,dc)==59
                decoded{dr,dc} = 'Light snow grains';
            elseif willdecode(dr,dc)==60
                decoded{dr,dc} = 'Heavy snow grains';
            elseif willdecode(dr,dc)==61
                decoded{dr,dc} = 'Light snow pellets';
            elseif willdecode(dr,dc)==62
                decoded{dr,dc} = 'Heavy snow pellets';
            elseif willdecode(dr,dc)==63
                decoded{dr,dc} = 'Moderate ice pellet shower';
            elseif willdecode(dr,dc)==64
                decoded{dr,dc} = 'Light ice crystals';
            elseif willdecode(dr,dc)==65
                decoded{dr,dc} = 'Heavy ice crystals';
            elseif willdecode(dr,dc)==66
                decoded{dr,dc} = 'Moderate thundershower';
            elseif willdecode(dr,dc)==67
                decoded{dr,dc} = 'Snow pellet shower';
            elseif willdecode(dr,dc)==68
                decoded{dr,dc} = 'Heavy blowing dust';
            elseif willdecode(dr,dc)==69
                decoded{dr,dc} = 'Heavy blowing sand';
            elseif willdecode(dr,dc)==70
                decoded{dr,dc} = 'Heavy blowing snow';
            elseif willdecode(dr,dc)==71
                decoded{dr,dc} = 'No reading';
            elseif willdecode(dr,dc)==72
                decoded{dr,dc} = 'No reading';
            elseif willdecode(dr,dc)==73
                decoded{dr,dc} = 'No reading';
            elseif willdecode(dr,dc)==74
                decoded{dr,dc} = 'No reading';
            elseif willdecode(dr,dc)==75
                decoded{dr,dc} = 'Light ice pellet shower';
            elseif willdecode(dr,dc)==76
                decoded{dr,dc} = 'Heavy ice pellet shower';
            elseif willdecode(dr,dc)==77
                decoded{dr,dc} = 'Light rain thundershower';
            elseif willdecode(dr,dc)==78
                decoded{dr,dc} = 'Heavy rain thundershower';
            elseif willdecode(dr,dc)==79
                decoded{dr,dc} = 'No reading';
            else
               disp('Unknown code!') %This likely means something has gone wrong, as all 79 codes from the Mesowest documentation are implemented
               disp(dr,dc) %index of unknown code
            end
        end
    end
    dat.Decoded = decoded; %add decoded conditions to the output array
elseif todecode == 0
    suppressant = 'shh'; %do nothing
elseif ~exist(todecode) %if todecode hasn't been entered
    disp('todecode must be 1 or 0') %there are only two options
end
dat.valid_date_num = [dat.Year,dat.Month,dat.Day,dat.Hour];

end







