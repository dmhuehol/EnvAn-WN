function [presheightvector,geoheightvector,goodtemp,warmnosesfinal,nowarmnosesfinal,freezingx,freezingxg,freezingy,freezingyg,x,y,gx,gy] = nosedetect(soundstruct,first,last,freezeT,top)
%%nosedetect
    %Function which detects the presence of warmnoses within a given
    %soundings data structure and compiles a number of statistics about them;
    %returns two output structures, one of which contains only soundings with warmnoses and
    %one of which contains those with no warmnoses.
    %
    %General form:
    %[presheightvector,geoheightvector,goodtemp,warmnosesfinal,nowarmnosesfinal,freezingx,freezingxg,freezingy,freezingyg,x,y,gx,gy] = nosedetect(soundstruct,first,last,freezeT,top)
    %
    %Outputs:
    %presheightvector: vector of pressure levels in hPa (useful mostly for
    %   use with other functions/scripts, such as FWOKXh line and noseplot)
    %geoheightvector: vector of geopotential height levels in km, same size as
    %   presheight vector
    %goodtemp: vector of temperatures, mostly for use for calls that need
    %   plotting, same size as presheightvector
    %warmnosesfinal: structure containing soundings data and warmnose data for
    %   only those soundings which contain warmnoses
    %nowarmnosesfinal: structure containing soundings data for only those
    %   soundings which do not contain warmnoses
    %freezingx: range for pressure
    %freezingxg:range for height
    %freezingy: for freezing line pressure
    %freezingyg: for freezing line height
    %freezing set of variables is output on behalf of noseplot
    %x: pressure level of warmnose
    %y: temperature of warmnose
    %gx: height of warmnose
    %gy: temperature of warmnose
    %
    %Inputs:
    %soundstruct: structure containing IGRA v1 soundings data
    %first: sounding number for beginning of loop, defaults to 1
    %last: sounding number for end of loop, defaults to length(soundstruct)
    %freezeT: value (in deg C) for freezing line--crossing this line designates
    %   the warmnose. Defaults to 0.5 deg C.
    %top: maximum height/pressure level to be examined, defaults to 200mb/15km
    %
    %Future: combine some outputs into single structure
    %Version Date: 6/13/17
    %Last major edit: 6/1/17
    %Written by: Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %
    %See also IGRAimpf, FWOKXh7, noseplot, prestogeo
    %


warmnose = zeros(length(soundstruct),1); %preallocation

%for creation of a freezing line in the plots (see within the loop)
if ~exist('freezeT','var')
    freezeT = 0; %set default value of freezing temperature to 0 deg C
end

freezingx = 0:1200; %for pressure
freezingxg = 0:16; %for height
freezingy = ones(1,length(freezingx)).*freezeT; %for freezing line (P)
freezingyg = ones(1,length(freezingxg)).*freezeT; %for freezing line (z)

%set defaults to loop through soundstruct
if ~exist('first','var')
    first = 1;
end
if ~exist('last','var')
    last = length(soundstruct);
end

for k = first:last
    mbtop = find(soundstruct(k).pressure >= top); %find indices of readings where the pressure is greater than 20000 Pa
    presheight = soundstruct(k).pressure(mbtop); %select readings greater than 20000 Pa
    goodtemp = soundstruct(k).temp(mbtop); %temperatures from surface to 200mb

    try %very rarely, things go wrong here--usually because of instrument error
        [presheightvector,geoheightvector] = prestogeo(presheight,goodtemp,1,soundstruct,k,0); %call to prestogeo to calculate geopotential heights
    catch ME;
        continue %skip and move on
    end
    
    %Quality control - replace -999.9 entries  with NaN
    goodtemp(goodtemp==-999.9) = NaN; 
    
    %find missing values in pressure levels, geopotential heights, and temperatures
    presheightnans = isnan(presheightvector);
    geoheightnans = isnan(geoheightvector);
    goodtempnans = isnan(goodtemp);
    
    %sync up the missing values so NaNs in one array are present in the
    %others as well; otherwise polyxpoly will freak out
    presheightvector(or(presheightnans,goodtempnans)) = NaN;
    goodtemp(or(presheightnans,goodtempnans)) = NaN;
    geoheightvector(or(geoheightnans,goodtempnans)) = NaN;
    goodtemp(or(geoheightnans,goodtempnans)) = NaN;
    
    % polyxpoly function finds intersection between plot of sounding
    % (temperature versus pressure) and plot of freezing line.  The
    % function returns x which represents the height (in mb) of the
    % intersection and y which represents the temperature (in C) of the
    % intersection. The second run of polyxpoly returns gx which represents the
    % height (in km) of the intersection and gy which represents the
    % temperature (in C) of the intersection.
    [x,y] = polyxpoly(presheightvector,goodtemp,freezingx,freezingy);
    [gx,gy] = polyxpoly(geoheightvector,goodtemp,freezingx,freezingy);
    
    if numel(x)~=numel(gx) %very rarely, there will be a mismatch in the number of warmnoses calculated by pressure and calculated by height, usually because of extremely shallow warmnoses at the base
        continue %if this is the case, skip and move on to the next sounding
    end
    
    soundstruct(k).warmnose.lclheight = (0.125.*(soundstruct(k).dew_point_dep(1))); %find the LCL in km
    soundstruct(k).warmnose.maxtemp = max(goodtemp); %find maximum temperature (corresponding to warm nose in pressure coordinates)
    soundstruct(k).warmnose.geotemp = max(goodtemp); %find maximum temperature (corresponding to warm nose in geopotential height coordinates)
  
    if isempty(x) %if x is empty, then there isn't a warm nose
        warmnose(k) = 0; %set index within warmnose to logical false
        %xintersect(e) = NaN; %xintersect does not exist
        soundstruct(k).warmnose.numwarmnose = 0; %and the warmnose entry within goodfinal is blank
    else %in ANY other circumstance, there is at least one warmnose
        warmnose(k) = 1;
        if length(x) == 1
            soundstruct(k).warmnose.x = x; %PRESSURE x value from polyxpoly
            soundstruct(k).warmnose.gx = gx; %HEIGHT x value from polyxpoly
            soundstruct(k).warmnose.numwarmnose = 1; %number of warm nose is one; since the T profile only crosses the freezing line once, it is implied that it is in contact with the ground
            soundstruct(k).warmnose.lowerbound1 = presheightvector(1); %PRESSURE lower bound (this is the lowest pressure reading)
            soundstruct(k).warmnose.lowerboundg1 = geoheightvector(1); %HEIGHT lower bound (this is the lowest height reading)
            soundstruct(k).warmnose.upperbound1 = x(1); %PRESSURE upper bound (this is the pressure level where the T profile crosses the freezing line)
            soundstruct(k).warmnose.upperboundg1 = gx(1); %HEIGHT upper bound (this is the height where the T profile crosses the freezing line)
            soundstruct(k).warmnose.lower(1) = presheightvector(1); %PRESSURE
            soundstruct(k).warmnose.lowerg(1) = geoheightvector(1); %HEIGHT
            soundstruct(k).warmnose.upper(1) = x(1); %PRESSURE
            soundstruct(k).warmnose.upperg(1) = gx(1); %HEIGHT (these second instances form a matrix of the lower/upper bounds, providing an easier way to see this information)
            soundstruct(k).warmnose.depth1 = soundstruct(k).warmnose.lowerbound1 - soundstruct(k).warmnose.upperbound1; %PRESSURE depth calculation; pressure decreases with height so this is lower minus upper
            soundstruct(k).warmnose.gdepth1 = soundstruct(k).warmnose.upperboundg1 - soundstruct(k).warmnose.lowerboundg1; %HEIGHT depth calculation; height increases with height so this is upper minus lower
        elseif length(x) == 2
            soundstruct(k).warmnose.x = x; %PRESSURE x value from polyxpoly
            soundstruct(k).warmnose.gx = gx; %HEIGHT x value from polyxpoly
            soundstruct(k).warmnose.numwarmnose = 1; %number of warm nose is one; since the T profile crosses the freezing line twice, it can be inferred that it is aloft
            soundstruct(k).warmnose.lowerbound1 = x(2); %PRESSURE lower bound
            soundstruct(k).warmnose.lowerboundg1 = gx(1); %HEIGHT lower bound; note that the indices are reversed because pressure decreases with height and height increases with height
            soundstruct(k).warmnose.upperbound1 = x(1); %PRESSURE upper bound
            soundstruct(k).warmnose.upperboundg1 = gx(2); %HEIGHT upper bound
            soundstruct(k).warmnose.lower(1) = x(2);
            soundstruct(k).warmnose.lowerg(1) = gx(1);
            soundstruct(k).warmnose.upper(1) = x(1);
            soundstruct(k).warmnose.upperg(1) = gx(2);
            soundstruct(k).warmnose.depth1 = soundstruct(k).warmnose.lowerbound1 - soundstruct(k).warmnose.upperbound1; %PRESSURE depth calculation; pressure decreases with height so this is lower minus upper
            soundstruct(k).warmnose.gdepth1 = soundstruct(k).warmnose.upperboundg1 - soundstruct(k).warmnose.lowerboundg1; %HEIGHT depth calculation; height increases with height so this is upper minus lower
        elseif length(x) == 3
            soundstruct(k).warmnose.x = x; %PRESSURE x value from polyxpoly
            soundstruct(k).warmnose.gx = gx; %HEIGHT x value from polyxpoly
            soundstruct(k).warmnose.numwarmnose = 2; %number of warm noses is two; since the T profile crosses the freezing line three times, it is clear that both a warmnose aloft and a warmnose in contact with the ground are present
            soundstruct(k).warmnose.lowerbound1 = presheightvector(1); %PRESSURE lower bound; this is the lowest pressure reading (since there is a warmnose at ground level)
            soundstruct(k).warmnose.lowerboundg1 = geoheightvector(1); %HEIGHT lower bound; this is the lowest height reading
            soundstruct(k).warmnose.upperbound1 = x(3); %PRESSURE upper bound of grounded warmnose
            soundstruct(k).warmnose.upperboundg1 = gx(1); %HEIGHT upper bound of grounded warmnose
            soundstruct(k).warmnose.upperbound2 = x(1); %PRESSURE upper bound of warmnose aloft
            soundstruct(k).warmnose.upperboundg2 = gx(3); %HEIGHT upper bound of warmnose aloft
            soundstruct(k).warmnose.lowerbound2 = x(2); %PRESSURE lower bound of warmnose aloft
            soundstruct(k).warmnose.lowerboundg2 = gx(2); %HEIGHT lower bound of warmnose aloft
            soundstruct(k).warmnose.lower(1) = presheightvector(1); 
            soundstruct(k).warmnose.lowerg(1) = geoheightvector(1);
            soundstruct(k).warmnose.upper(1) = x(3);
            soundstruct(k).warmnose.upperg(1) = gx(1);
            soundstruct(k).warmnose.lower(2) = x(2);
            soundstruct(k).warmnose.lowerg(2) = gx(2);
            soundstruct(k).warmnose.upper(2) = x(1);
            soundstruct(k).warmnose.upperg(2) = gx(3);
            soundstruct(k).warmnose.depth1 = soundstruct(k).warmnose.lowerbound1 - soundstruct(k).warmnose.upperbound1; %PRESSURE depth of grounded warmnose is lower minus upper
            soundstruct(k).warmnose.gdepth1 = soundstruct(k).warmnose.upperboundg1 - soundstruct(k).warmnose.lowerboundg1; %HEIGHT depth of grounded warmnose is upper minus lower
            soundstruct(k).warmnose.depth2 = soundstruct(k).warmnose.lowerbound2 - soundstruct(k).warmnose.upperbound2; %PRESSURE depth of warmnose aloft is lower minus upper
            soundstruct(k).warmnose.gdepth2 = soundstruct(k).warmnose.upperboundg2 - soundstruct(k).warmnose.lowerboundg2; %HEIGHT depth of warmnose aloft is upper minus lower
        elseif length(x) == 4
            soundstruct(k).warmnose.x = x; %PRESSURE x value from polyxpoly
            soundstruct(k).warmnose.gx = gx; %HEIGHT x value from polyxpoly
            soundstruct(k).warmnose.numwarmnose = 2; %number of warm noses is two; since the T profile croses the freezing line four times, it is clear that there are two warmnoses aloft
            soundstruct(k).warmnose.upperbound1 = x(3); %PRESSURE upper bound of lowest warmnose aloft
            soundstruct(k).warmnose.upperboundg1 = gx(2); %HEIGHT upper bound of lowest warmnose aloft
            soundstruct(k).warmnose.lowerbound1 = x(4); %PRESSURE lower bound of lowest warmnose aloft
            soundstruct(k).warmnose.lowerboundg1 = gx(1); %HEIGHT lower bound of lowest warmnose aloft
            soundstruct(k).warmnose.upperbound2 = x(1); %PRESSURE upper bound of highest warmnose aloft
            soundstruct(k).warmnose.upperboundg2 = gx(4); %HEIGHT upper bound of highest warmnose aloft
            soundstruct(k).warmnose.lowerbound2 = x(2); %PRESSURE lower bound of highest warmnose aloft
            soundstruct(k).warmnose.lowerboundg2 = gx(3); %HEIGHT lower bound of highest warmnose aloft
            soundstruct(k).warmnose.lower(1) = x(4);
            soundstruct(k).warmnose.lowerg(1) = gx(1);
            soundstruct(k).warmnose.upper(1) = x(3);
            soundstruct(k).warmnose.upperg(1) = gx(2);
            soundstruct(k).warmnose.lower(2) = x(2);
            soundstruct(k).warmnose.lowerg(2) = gx(3);
            soundstruct(k).warmnose.upper(2) = x(1);
            soundstruct(k).warmnose.upperg(2) = gx(4);
            soundstruct(k).warmnose.depth1 = soundstruct(k).warmnose.lowerbound1 - soundstruct(k).warmnose.upperbound1; %PRESSURE depth of lowest warmnose
            soundstruct(k).warmnose.gdepth1 = soundstruct(k).warmnose.upperboundg1 - soundstruct(k).warmnose.lowerboundg1; %HEIGHT depth of lowest warmnose
            soundstruct(k).warmnose.depth2 = soundstruct(k).warmnose.lowerbound2 - soundstruct(k).warmnose.upperbound2; %PRESSURE depth of highest warmnose
            soundstruct(k).warmnose.gdepth2 = soundstruct(k).warmnose.upperboundg2 - soundstruct(k).warmnose.lowerboundg2; %HEIGHT depth of highest warmnose
        elseif length(x) == 5
            soundstruct(k).warmnose.x = x; %PRESSURE x from polyxpoly
            soundstruct(k).warmnose.gx = gx; %HEIGHT x from polyxpoly
            soundstruct(k).warmnose.numwarmnose = 3; %number of warmnoses is three; since T profile crosses freezing line 5 times there are two warmnoses aloft and a grounded warmnose present
            soundstruct(k).warmnose.lowerbound1 = presheightvector(1); %PRESSURE lower bound of grounded warmnose
            soundstruct(k).warmnose.lowerboundg1 = geoheightvector(1); %HEIGHT lower bound of grounded warmnose
            soundstruct(k).warmnose.upperbound1 = x(5); %PRESSURE upper bound of grounded warmnose
            soundstruct(k).warmnose.upperboundg1 = gx(1); %HEIGHT upper bound of grounded warmnose
            soundstruct(k).warmnose.upperbound2 = x(3); %PRESSURE upper bound of lowest warmnose aloft
            soundstruct(k).warmnose.upperboundg2 = gx(3); %HEIGHT upper bound of lowest warmnose aloft
            soundstruct(k).warmnose.lowerbound2 = x(4); %PRESSURE lower bound of lowest warmnose aloft
            soundstruct(k).warmnose.lowerboundg2 = gx(2); %HEIGHT lower bound of lowest warmnose aloft
            soundstruct(k).warmnose.upperbound3 = x(1); %PRESSURE upper bound of highest warmnose aloft
            soundstruct(k).warmnose.upperboundg3 = gx(5); %HEIGHT upper bound of highest warmnose aloft
            soundstruct(k).warmnose.lowerbound3 = x(2); %PRESSURE lower bound of highest warmnose aloft
            soundstruct(k).warmnose.lowerboundg3 = gx(4); %HEIGHT lower bound of highest warmnose aloft
            soundstruct(k).warmnose.lower(1) = presheightvector(1); %disabled for now
            soundstruct(k).warmnose.lowerg(1) = geoheightvector(1); %hi
            soundstruct(k).warmnose.upper(1) = x(5);
            soundstruct(k).warmnose.upperg(1) = gx(1);
            soundstruct(k).warmnose.lower(2) = x(4);
            soundstruct(k).warmnose.lowerg(2) = gx(2);
            soundstruct(k).warmnose.upper(2) = x(3);
            soundstruct(k).warmnose.upperg(2) = gx(3);
            soundstruct(k).warmnose.lower(3) = x(2);
            soundstruct(k).warmnose.lowerg(3) = gx(4);
            soundstruct(k).warmnose.upper(3) = x(1);
            soundstruct(k).warmnose.upperg(3) = gx(5);
            soundstruct(k).warmnose.depth1 = soundstruct(k).warmnose.lowerbound1 - soundstruct(k).warmnose.upperbound1; %PRESSURE depth of grounded warmnose
            soundstruct(k).warmnose.gdepth1 = soundstruct(k).warmnose.upperboundg1 - soundstruct(k).warmnose.lowerboundg1; %HEIGHT depth of grounded warmnose
            soundstruct(k).warmnose.depth2 = soundstruct(k).warmnose.lowerbound2 - soundstruct(k).warmnose.upperbound2; %PRESSURE depth of lowest warmnose aloft
            soundstruct(k).warmnose.gdepth2 = soundstruct(k).warmnose.upperboundg2-soundstruct(k).warmnose.lowerboundg2; %HEIGHT depth of lowest warmnose aloft
            soundstruct(k).warmnose.depth3 = soundstruct(k).warmnose.lowerbound3 - soundstruct(k).warmnose.upperbound3; %PRESSURE depth of highest warmnose aloft
            soundstruct(k).warmnose.gdepth3 = soundstruct(k).warmnose.upperboundg3 - soundstruct(k).warmnose.lowerboundg3; %HEIGHT depth of highest warmnose aloft
        elseif length(x) == 6
            soundstruct(k).warmnose.x = x; %PRESSURE x from polyxpoly
            soundstruct(k).warmnose.gx = gx; %HEIGHT x from polyxpoly
            soundstruct(k).warmnose.numwarmnose = 3; %number of warmnoses is three; since T profile crosses the freezing line six times there are three warmnoses aloft
            soundstruct(k).warmnose.upperbound1 = x(5); %PRESSURE upper bound of lowest warmnose aloft
            soundstruct(k).warmnose.upperboundg1 = gx(2); %HEIGHT upper bound of lowest warmnose aloft
            soundstruct(k).warmnose.lowerbound1 = x(6); %PRESSURE lower bound of lowest warmnose aloft
            soundstruct(k).warmnose.lowerboundg1 = gx(1); %HEIGHT lower bound of lowest warmnose aloft
            soundstruct(k).warmnose.upperbound2 = x(3); %PRESSURE upper bound of middle warmnose aloft
            soundstruct(k).warmnose.upperboundg2 = gx(4); %HEIGHT upper bound of middle warmnose aloft
            soundstruct(k).warmnose.lowerbound2 = x(4); %PRESSURE lower bound of middle warmnose aloft
            soundstruct(k).warmnose.lowerboundg2 = gx(3); %HEIGHT lower bound of middle warmnose aloft
            soundstruct(k).warmnose.upperbound3 = x(1); %PRESSURE upper bound of highest warmnose aloft
            soundstruct(k).warmnose.upperboundg3 = gx(6); %HEIGHT upper bound of highest warmnose aloft
            soundstruct(k).warmnose.lowerbound3 = x(2); %PRESSURE lower bound of highest warmnose aloft
            soundstruct(k).warmnose.lowerboundg3 = gx(5); %HEIGHT lower bound of highest warmnose aloft
            soundstruct(k).warmnose.lower(1) = x(6);
            soundstruct(k).warmnose.lowerg(1) = gx(1);
            soundstruct(k).warmnose.upper(1) = x(5);
            soundstruct(k).warmnose.upperg(1) = gx(2);
            soundstruct(k).warmnose.lower(2) = x(4);
            soundstruct(k).warmnose.lowerg(2) = gx(3);
            soundstruct(k).warmnose.upper(2) = x(3);
            soundstruct(k).warmnose.upperg(2) = gx(4);
            soundstruct(k).warmnose.lower(3) = x(2);
            soundstruct(k).warmnose.lowerg(3) = gx(5);
            soundstruct(k).warmnose.upper(3) = x(1);
            soundstruct(k).warmnose.upperg(3) = gx(6);
            soundstruct(k).warmnose.depth1 = soundstruct(k).warmnose.lowerbound1 - soundstruct(k).warmnose.upperbound1; %PRESSURE depth of lowest warmnose
            soundstruct(k).warmnose.gdepth1 = soundstruct(k).warmnose.upperboundg1 - soundstruct(k).warmnose.lowerboundg1; %HEIGHT depth of lowest warmnose
            soundstruct(k).warmnose.depth2 = soundstruct(k).warmnose.lowerbound2 - soundstruct(k).warmnose.upperbound2; %PRESSURE depth of middle warmnose
            soundstruct(k).warmnose.gdepth2 = soundstruct(k).warmnose.upperboundg2 - soundstruct(k).warmnose.lowerboundg2; %HEIGHT depth of middle warmnose
            soundstruct(k).warmnose.depth3 = soundstruct(k).warmnose.lowerbound3 - soundstruct(k).warmnose.upperbound3; %PRESSURE depth of highest warmnose
            soundstruct(k).warmnose.gdepth3 = soundstruct(k).warmnose.upperboundg3 - soundstruct(k).warmnose.lowerboundg3; %HEIGHT depth of highest warmnose
        else
            soundstruct(k).warmnose.numwarmnose = NaN; %situations with any more six freezing line crosses are discarded as instrument error
            soundstruct(k).warmnose.x = NaN; %but still need x and gx entries or loops using this code will choke
            soundstruct(k).warmnose.gx = NaN;
            soundstruct(k).warmnose.lowerbound = NaN;
        end
    end
end

warmnoses = logical(warmnose); %find all of the indices where warmnoses actually exist
warmnosesfinal = soundstruct(warmnoses); %create a structure that contains only the warmnose soundings
       
nowarmnoses = ~logical(warmnose); %also create a structure that contains the quality-controlled soundings sans warmnoses
nowarmnosesfinal = soundstruct(nowarmnoses);
end