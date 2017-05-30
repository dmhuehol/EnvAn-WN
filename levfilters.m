%levfilters - function to remove levels from a structure of soundings data,
%such as that created by IGRAimpf. Given a sounding structure and a level
%type, levfilters will remove all data from the structure which corresponds
%to said level.
%General form: [fil] = levfilters(filtered,level_type)
%where fil is the output, a structure lacking the data of level_type,
%filtered is a structure of soundings data, and level_type is a number
%(0,1,2,3) corresponding to WMO standard level types.
%Usually used to remove additional wind level data (such data that only
%includes height and wind data) - in this case level_type equals 3.
%
%See also IGRAimpf
function [fil] = levfilters(filtered,level_type)
fil = filtered; %structure to be targeted
[r,~] = size(fil); %find number of soundings
for t = 1:r %loop through structure
    [index] = find(fil(t).level_type==level_type); %find indices of wind level
    %destroy all data corresponding to the given indices
    fil(t).level_type(index) = [];
    fil(t).minor_level_type(index) = [];
    fil(t).pressure(index) = [];
    fil(t).geopotential(index) = [];
    fil(t).temp(index) = [];
    fil(t).dew_point_dep(index) = [];
    fil(t).wind_dir(index) = [];
    fil(t).wind_spd(index) = [];
    fil(t).u_comp(index) = [];
    fil(t).v_comp(index) = [];
    fil(t).geopotential_flag(index) = [];
    fil(t).pressure_flag(index) = [];
    fil(t).temp_flag(index) = [];
end
end
