%%ESRL -- function to import geopotential height data from ESRL soundings data to
%supplement the IGRA soundings data used by functions and scripts such as
%soundplots, IGRAimpf, or FWOKXh[version number]. Given an ESRL input file,
%ESRL will import the file into MATLAB and extract all geopotential data
%that corresponds to IGRA level types 1 and 2. This data can then be
%concatenated into an IGRA soundings data structure (such as that created
%by IGRAimpf) by the user.
%Written by: Daniel Hueholt
%Version date: 5/26/17
%

addpath('C:\Users\danielholt\Documents\MATLAB\Project 1 - Warm Noses\Soundings Data\Upton') %add path which contains soundings data
input_file = 'C:\Users\danielholt\Documents\MATLAB\Project 1 - Warm Noses\Soundings Data\Upton\ESRL.txt'; %input file of ESRL data -- should cover the same time span as the IGRA soundings data structure if looking to concatenate the two

%% Read columns of data as strings:
formatSpec = '%7f%7f%7f%7f%7f%7f%s%[^\n\r]'; %format string of ESRL data, importing as strings to compensate for the mixed header/data
hline1 = '%7s%7s%7s%6s%7s%8s%s%[^\n\r]';
hline2 = '%7s%7s%7s%8s%8s%5s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(input_file,'r'); %generate a file ID to be used by textscan

%% Read columns of data according to format string.
% tic
% dataArray1 = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '',  'ReturnOnError', false); %generate a cell array with 8 columns corresponding to the 8 datatypes of ESRL soundings data
% toc
% [haba,jaba] = size(dataArray1{1});
record = 1;
while ~feof(fileID); %loop to count
    try
        header(record,:) = textscan(fileID, hline1,1); %first use of textscan, in order to identify headers
    %   input 1 at end of textscan call is number of times to read the header
        header2(record,:) = textscan(fileID, hline2, 3); %first use of textscan, in order to identify headers
        geodat{record} = textscan(fileID, formatSpec, str2double(header2{record,5}(2))-4);
        record = record+1;
        %second use of textscan, identifies data
    catch ME
    end
end

fclose(fileID); %close the file

[r,~] = size(header);

for klasudi = 1:r-1 %r-1 thanks to feof
    %disp(header{klasudi,4}{1});
    if strcmp(header{klasudi,4}{1},'JAN') == 1
        header{klasudi,4}{1} = '1';
    elseif strcmp(header{klasudi,4}{1},'FEB') == 1
        header{klasudi,4}{1} = '2';
    elseif strcmp(header{klasudi,4}{1},'MAR') == 1
        header{klasudi,4}{1} = '3';
    elseif strcmp(header{klasudi,4}{1},'APR') == 1
        header{klasudi,4}{1} = '4';
    elseif strcmp(header{klasudi,4}{1},'MAY') == 1
        header{klasudi,4}{1} = '5';
    elseif strcmp(header{klasudi,4}{1},'JUN') == 1
        header{klasudi,4}{1} = '6';
    elseif strcmp(header{klasudi,4}{1},'JUL') == 1
        header{klasudi,4}{1} = '7';
    elseif strcmp(header{klasudi,4}{1},'AUG') == 1
        header{klasudi,4}{1} = '8';
    elseif strcmp(header{klasudi,4}{1},'SEP') == 1
        header{klasudi,4}{1} = '9';
    elseif strcmp(header{klasudi,4}{1},'OCT') == 1
        header{klasudi,4}{1} = '10';
    elseif strcmp(header{klasudi,4}{1},'NOV') == 1
        header{klasudi,4}{1} = '11';
    elseif strcmp(header{klasudi,4}{1},'DEC') == 1
        header{klasudi,4}{1} = '12';
    else
        disp('The calendar is a LIE')
        disp(klasudi)
    end
    %disp(header{klasudi,4}{1})
end

time = [2002,1,13,12]
