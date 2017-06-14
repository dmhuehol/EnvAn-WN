function [numdex] = findsnd(y,m,d,h,sndstructure,sndstructure2,sndstructure3)
%%findsnd
    %Function to find the index of a sounding given a specific date.
    %
    %General form: [numdex] = findsnd(y,m,d,h,sndstructure,sndstructure2,sndstructure3)
    %
    %Output:
    %numdex: the index within the structure (sndstructure) where the input date
    %is found.
    %
    %Inputs:
    %y: a 4-digit year
    %m: a 1 or 2-digit month
    %d: a 1 or 2-digit day
    %h: a 1 or 2-digit time
    %sndstructure: a structure of soundings data
    %Up to two additional soundings structures can be input; numdex will
    %contain as many indices as there are soundings, and will display NaN for
    %structures where the date is not present.
    %
    %NOTE: If inputting a table, input with table2struct(input). Full table
    %support will be added later.
    %
    %Version Date: 6/1/17
    %Last major revision: 5/31/17
    %Written by: Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %
    %See also FWOKXh6
    %

datenumber = [y,m,d,h]; %concatenate into a datenumber

switch nargin
    case 7 %all possible inputs
        disp('Three soundings structures were entered.')
        %3 for loops to find the indices in all structures
        for k = 1:length(sndstructure)
            if isequal(sndstructure(k).valid_date_num,datenumber)==1 %looking for the datenumber which matches the input datenumber
                disp(k) %where the if statement is true, the counter is the index corresponding to the correct soundings entry
                numdex(1) = k; %index in first structure is first entry in output array
                break %move to the next loop as soon as the index is found
            end
        end
        for k2 = 1:length(sndstructure2)
            try %just in case
                if isequal(sndstructure2(k2).valid_date_num,datenumber)==1
                    disp(k2)
                    numdex(2) = k2; %index in second structure is second entry in output array
                    break
                end
            catch ME;
            end
        end
        for k3 = 1:length(sndstructure3)
            try
                if isequal(sndstructure3(k3).valid_date_num,datenumber)==1
                    disp(k3)
                    numdex(3) = k3; %index in third structure is third entry in output array
                    break
                end
            catch ME;
            end
        end
    case 6
        disp('Two soundings structures were entered.')
        %2 for loops to find the indices in all structures
        for k = 1:length(sndstructure)
            if isequal(sndstructure(k).valid_date_num,datenumber)==1
                disp(k)
                numdex(1) = k; %index in first structure is first entry in output array
                break
            end
        end
        for k2 = 1:length(sndstructure2)
            try
                if isequal(sndstructure2(k2).valid_date_num,datenumber)==1
                    disp(k2)
                    numdex(2) = k2; %index in second structure is second entry in output array
                    break
                end
            catch ME;
            end
        end
    case 5
        disp('One soundings structure was entered.')
        for k = 1:length(sndstructure)
            if isequal(sndstructure(k).valid_date_num,datenumber)==1
                disp(k)
                numdex = k; %index is output
                break
            end
        end
    otherwise %less than 5 entries implies that either a time entry was left off or there was no sounding data structure specified
        msg = 'Improper number of inputs! Please check syntax and try again.'; %either way
        error(msg) %it's very wrong
end

if ~exist('numdex','var') %if after switch/case there still is no numdex
    disp('The input time was not found in the structure(s)!')
    return
end

numdex(numdex==0) = NaN; %any 0 entries should be NaN to be clearer that the index is not present in the respective structure

disp(datenumber) %display the datenumber to make it easy for the user to know what they entered

end