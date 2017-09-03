function [sndng] = IGRAimpf(input_file)
%IGRAimpf 
    %Function to import IGRA v1 files. Given a .dat file of
    %soundings data, returns a structure ('sndng') which contains the following
    %fields:
    %valid_date_num - a MATLAB date serial number
    %year
    %month
    %day
    %hour
    %level_type - major level type (1 = standard level, 2 = additional thermodynamic, 3 = wind)
    %minor_level_type (1 = surface, 2 = tropopause, 3 = other)
    %pressure (Pascals)
    %geopotential (meters)
    %temp (air temperature, C)
    %dew_point_dep (dewpoint depression, C)
    %wind_dir (wind direction, angular degrees)
    %wind_spd (wind speed, meters/second)
    %u_comp (zonal component of wind, meters/second)
    %v_comp (meridional component of wind, meters/second)
    %geopotential flag (1 = value is within climatological limits based on all years and all days at the station, 2 = value is within climatological limits and limits based on specifics to the time of year and time of day at the station, 0 = no climatological check)
    %pressure flag (same meaning as geopotential flag)
    %temp_flag (same meaning as geopotential flag)
    %
    %General form of function call: [sndng] = IGRAimpf(input_file)
    %where input_file is a string containing the file path of the dat file
    %
    %Function created by Daniel Hueholt
    %Based on a script originally written by Megan Amanatides
    %Version date: 9/1/2017
    %Last major revision: 5/24/17
    %
    %See also: IGRAimpfil
    %

%% Import Data
data_for_length = fileread(input_file); %Read file into an array of arbitrary size
count = length(data_for_length(data_for_length == 35)); %Finds number of soundings
clear data_for_length;

header = zeros(count,7); %Preallocate header array
raw_data = cell(1,count); %Preallocate raw data array

fid = fopen(input_file); %Open input file

for record = 1:count %Loop to count
    header(record,:) = cell2mat(textscan(fid, '#%5f%4f%2f%2f%2f%4f %f', 1)); %first use of textscan, in order to identify headers
%    #%5f%4f%2f%2f%2f%4f %f - # at start of header, 5-digit station ID,
%    4-digit year, 2-digit month, 2-digit day, 2-digit hour, 4-digit
%    release time, and number of levels.
%   input 1 at end of textscan call is number of times to read the header
    raw_data{record} = cell2mat(textscan(fid, '%36c', header(record,7)));
    %Second use of textscan, identifies data raw as a lump of characters
    %IMPORTANT: header(record,7) uses the LEVEL NUMBER designator from the
    %IGRA file to determine how many times to run this second textscan call
    %rather than the first (header) textscan call
end
header(header == 9999) = NaN; %IGRA uses 9999 instead of NaN

%% Separate data
for record = 1:count
    record_date = [header(record,2) header(record,3) header(record,4), header(record,5)]; %comprehensive date for each sounding
               
    sndng(record).valid_date_num = datenum(record_date); %Convert date to serial number
    
    % Separate record into individual structure entries for year, month, day, hour
    sndng(record).year = int16(record_date(1));
    sndng(record).month = int16(record_date(2));
    sndng(record).day = int16(record_date(3));
    sndng(record).hour = int16(record_date(4));
    
    % Separate level type into major and minor level types
    sndng(record).level_type = sscanf((raw_data{record}(:,1)),'%1f');
    sndng(record).minor_level_type = sscanf((raw_data{record}(:,2)),'%1f');
    
    % Separate the pressure flag from the pressure
    sndng(record).pressure = sscanf((raw_data{record}(:,3:8))','%6f');
    press_flag = raw_data{record}(:,9); %leave as string for now
    
    % Separate the geopotential flag from the pressure
    sndng(record).geopotential = str2num((raw_data{record}(:,10:14))); %has to be str2num; for no apparent reason, sscanf won't format this properly
    geopot_flag = raw_data{record}(:,15); %leave as string for now
    
    % Separate the temperature flag from the temperature
    sndng(record).temp = sscanf((raw_data{record}(:,16:20))','%5f')/10; %convert from tenths degree C to degree C
    temp_flag = raw_data{record}(:,21); %leave as string for now
    
    sndng(record).dew_point_dep = sscanf((raw_data{record}(:,22:26))','%5f')/10; %Convert from tenths degree C to degree C
    
    sndng(record).wind_dir = sscanf((raw_data{record}(:,27:31))','%5f')/10; %Convert from tenths angular degree to angular degree
    sndng(record).wind_spd = sscanf((raw_data{record}(:,32:36))','%5f')/10; %Convert from tenths m/s to m/s
    
    % Change clearly invalid values to NaN
    sndng(record).wind_dir(sndng(record).wind_dir < -900) = NaN;
    sndng(record).wind_spd(sndng(record).wind_spd < -900) = NaN;
    
    % Split wind speed into zonal and meridional components
    sndng(record).u_comp = -sndng(record).wind_spd .* cos(-sndng(record).wind_dir - 90); %zonal
    sndng(record).v_comp = -sndng(record).wind_spd .* sin(-sndng(record).wind_dir - 90); %meridional
    
%% Basic Quality Control
    flags = [press_flag, geopot_flag, temp_flag]; %Collect pressure, geopotential height, and temperature data
    flags = double(flags); %Doubles; blank -> 32, A -> 65, B-> 66 
    flags(flags == 32) = 0; %Set every 32 (blank flag) to 0
    flags(flags == 65) = 1; %Set every 65 (A flag) to 1
    flags(flags == 66) = 2; %Set every 66 (B flag) to 2
    
    % Fill structures with pressure, geopotential height, and temperature converted from double to uint8
    sndng(record).geopotential_flag = int8(flags(:,1));
    sndng(record).pressure_flag = int8(flags(:,2));
    sndng(record).temp_flag = int8(flags(:,3));
     
    % Change any clearly invalid values to NaN
    sndng(record).pressure(sndng(record).pressure < 0) = NaN; %Negative pressure is not allowed
    sndng(record).geopotential(sndng(record).geopotential < 0) = NaN; %Negative height is not allowed
    sndng(record).temp(sndng(record).temp < -1000) = NaN; %Temperature below -1000 C is not allowed
    sndng(record).dew_point_dep(sndng(record).dew_point_dep < -1000) = NaN; %Dewpoint depression below -1000 C is not allowed
    
end
    

fclose('all'); %Close the file

end