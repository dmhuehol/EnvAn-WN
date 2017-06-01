%%findsnd - function to find the index of a sounding given a specific date.
%
%General form: [numdex] = findsnd(y,m,d,h,sndstructure,sndstructure2,sndstructure3)
%
%Output:
%numdex: the index within the structure (sndstructure) where the input date
%is found.
%
%Inputs:
%y: a 4-digit year
%m: a 2-digit month
%d: a 1 or 2-digit day
%h: a 1 or 2-digit time
%sndstructure: a structure of soundings data
%Up to two additional soundings structures can be input; numdex will
%contain as many indices as there are soundings, and will display NaN for
%structures where the date is not present.
%
%If inputting a table, input with table2struct(input)
%
%See also FWOKXh6
%

function [numdex] = findsnd(y,m,d,h,sndstructure,sndstructure2,sndstructure3)
datenumber = [y,m,d,h]
for k = 1:length(sndstructure)
    if isequal(sndstructure(k).valid_date_num,datenumber)==1
        disp(k)
        numdex = k;
        break
    end
end
for k2 = 1:length(sndstructure2)
    try
        if isequal(sndstructure2(k2).valid_date_num,datenumber)==1
            disp(k2)
            numdex(2) = k2;
            break
        end
    catch ME;
    end
end
for k3 = 1:length(sndstructure3)
    try
        if isequal(sndstructure3(k3).valid_date_num,datenumber)==1
            disp(k3)
            numdex(3) = k3;
            break
        end
    catch ME;
    end
end
if ~exist('numdex','var')
    disp('The input time was not found in the structure!')
end
if ~exist('sndstructure2','var')
    disp('One soundings structure was input.')
end
if exist('sndstructure2','var') && ~exist('sndstructure3','var')
    disp('Two soundings structures were input.')
end
if exist('sndstructure3','var')
    disp('Three soundings structures were input.')
end
numdex(numdex==0) = NaN;
end