%%surfconfind--function to find index of data in Mesowest table corresponding 
%to a given date and time. The function can optionally return the data
%at and surrounding the index to within a user-controllable bound of
%entries.
%
%General form: [sfound,closerlook] = surfconfind(y,m,d,t,surconyear,makeiteasy,spread)
%
%Outputs:
%sfound: index of data table row which contains the requested date number
%closerlook: section of data table displaying the sfound entry +/- spread
%   number of other entries - OPTIONAL output, will only display if makeiteasy
%   has been set to 1.
%
%Inputs:
%y: 4-digit year
%m: 1 or 2-digit month
%d: 1 or 2-digit day
%t: 1 or 2-digit time - NOTE: time is not restricted to 0 and 12
%surconyear: Mesowest data table for a year - NOTE: these tables only
%   contain one year of data at a time, be sure to aim the function at the
%   table corresponding to the requested year.
%makeiteasy: value which sets whether to find the closerlook table.
%   1 will return closerlook, all other inputs will suppress it. If not
%   specified, closerlook will not be returned.
%spread: distance from row sfound for rows to be included in the closerlook table.
%   If spread is not specified, it is assumed to be equal to 6, generating a
%   total of 13 entries in closerlook. spread does nothing if makeiteasy is
%   not set to 1.
%
%surfconfind was designed to be used in conjunction with soundplots,
%rhumplot, and, if necessary, findsnd to gain a complete picture of the
%surface conditions and atmospheric vertical cross-section at a given time.
%
%Version Date: 6/1/17
%Last major revision: 6/1/17
%Written by: Daniel Hueholt
%North Carolina State University
%Undergraduate Research Assistant at Environment Analytics
%

function [sfound,closerlook] = surfconfind(y,m,d,t,surconyear,makeiteasy,spread)

if ~exist('makeiteasy','var') %if makeiteasy was left off entirely
    makeiteasy = 0; %don't make it easy
end
if ~exist('spread','var') %if spread was left off
    spread = 6; %this is a healthy range of observations
end

datevec = [y,m,d,t]; %concatenate inputs into a date vector, which can be checked against the valid_date_num entry in the surface conditions table
datestring = num2str(datevec); %change to string for dynamic naming later on

for ad = 1:height(surconyear) %search through table data
    if isequal(surconyear.valid_date_num(ad,:),datevec)==1 %function is trying to find the index where the valid_date_num entry is the same as the input date and time
        sfound = ad; %the counter at this location is the index
        disp(ad); %display just in case its output was left off
        break %save time and run only as long as necessary
    else %do nothing
    end
end

if makeiteasy==1 %if the user wants it the easy way
    closerlook = surconyear((sfound-spread):(sfound+spread),:); %display the Mesowest data entries immediately around the requested entry
    disp(['Reminder: the input datevector was ' datestring]) %remind the user what they were looking for
else
end

if ~exist('sfound','var') %if no entry in the table matches the input
    disp('No data for this date and time! Check input and try again.') %it's likely an input error, especially if cross-referencing against soundings
    return %prevents warnings
end

end