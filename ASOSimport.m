function [ASOSstruct] = ASOSimport(input_file)
%%ASOSimport
    %Function to import ASOS one-minute surface data, remove useless
    %elements, and place the useful data into a structure.
    %
    %General form: [ASOSstruct] = ASOSimport(input_file)
    %
    %Output: 
    %ASOSstruct: a length(data)x1 structure, which contains date, time
    %(UTC), precip ID, precip amount, freezing sensor frequency, pressure
    %(3 fields, as measured on 3 sensors), temperature, and dewpoint
    %
    %Input:
    %input_file: file path for ASOS one minute data
    %
    %Station ID, 3-letter ID, time (local), unknown data column (possibly
    %thunder obs), and two trailing blank columns are removed. If any of
    %these are needed, the last place they are present is at the textscan
    %command.
    %
    %
    %Written by: Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %Version date: 8/29/2017
    %Last major revision: 7/6/17
    %

formatSpec = '%9s%4s%8s%4s%4s%5s%9s%5s%19s%9s%8s%8s%5s%5s%s%[^\n\r]'; %Format for textscan call (I'll admit, this line was MATLAB generated)
fileID = fopen(input_file,'r'); %Open the input file in readable format

dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'ReturnOnError', false); %Read in the data to a cell array
fclose(fileID); %Close the file

fields = {'StationID','ISP','Date','EST','UTC','PrecipID','Unknown','PrecipAmt','FrzPrecipFreq','Pressure1','Pressure2','Pressure3','Temp','Dewpoint','Blank1','Blank2'}; %Full list of field names (not used in output)
realfields = {'Date','UTC','PrecipID','PrecipAmt','FrzFreq','Pressure1','Pressure2','Pressure3','Temp','Dewpoint'}; %Actual fieldnames; not used in the output
dataExtract = {dataArray{3} dataArray{5} dataArray{6} dataArray{8} dataArray{9} dataArray{10} dataArray{11} dataArray{12} dataArray{13} dataArray{14}}; %These are the parts of the cell array that will be used (these line up to the names in realfields)

datemat = cell2mat(dataExtract{1}); %Fonvert date strings into chars
ASOSstruct.date = str2num(datemat); %#ok %Sometimes str2num is just better, and the code analyzer can go suck a lemon

% The same general process is followed for all data columns: convert the
% string into chars, then convert the chars to doubles
UTCmat = cell2mat(dataExtract{2});
ASOSstruct.UTC = str2num(UTCmat); %#ok

ASOSstruct.precipID = cell2mat(dataExtract{3}); %precip ID is a text code, so it's left as text

precipAmtmat = cell2mat(dataExtract{4});
for c = 1:length(precipAmtmat) %For loops are not fun, but neither are the [] outputs that str2double, str2num, and sscanf all give when used on the vector form
    ASOSstruct.precipAmt(c,1) = str2double(precipAmtmat(c,1:5));
end

FrzFreqmat = cell2mat(dataExtract{5});
for c = 1:length(FrzFreqmat) %see above
    ASOSstruct.FrzFreq(c,1) = str2double(FrzFreqmat(c,1:end));
end

Pres1mat = cell2mat(dataExtract{6});
Pres2mat = cell2mat(dataExtract{7});
Pres3mat = cell2mat(dataExtract{8});
for c = 1:length(Pres1mat) %see above
    ASOSstruct.Pres1(c,1) = str2double(Pres1mat(c,1:end));
    ASOSstruct.Pres2(c,1) = str2double(Pres2mat(c,1:end));
    ASOSstruct.Pres3(c,1) = str2double(Pres3mat(c,1:end));
end

Tempmat = cell2mat(dataExtract{9});
ASOSstruct.Temp = str2num(Tempmat); %#ok

Dewpointmat = cell2mat(dataExtract{10});
ASOSstruct.Dewpoint = str2num(Dewpointmat); %#ok

thisIsDumb = struct2table(ASOSstruct); %Convert the structure to a table
butItWorks = table2struct(thisIsDumb); %and now convert the table to a structure
%The above is v dumb, but it gets the structure format so that individual lines are accessed at ASOSstruct(ELEMENT).variable without using loops

ASOSstruct = butItWorks; %output

end