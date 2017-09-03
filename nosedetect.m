function [presHeightVector,geoHeightVector,goodTemp,warmnosesfinal,nowarmnosesfinal,freezingx,freezingxg,freezingy,freezingyg,x,y,gx,gy] = nosedetect(soundStruct,first,last,freezeT,top)
%%nosedetect
    %Function which detects the presence of warmnoses within a given
    %soundings data structure and gathers data about their propertes;
    %returns two output structures, one of which contains only soundings with warmnoses and
    %one of which contains those with no warmnoses.
    %
    %General form:
    %[presheightvector,geoheightvector,goodtemp,warmnosesfinal,nowarmnosesfinal,freezingx,freezingxg,freezingy,freezingyg,x,y,gx,gy] = nosedetect(soundstruct,first,last,freezeT,top)
    %
    %Outputs:
    %presheightvector: vector of pressure levels in hPa (useful mostly for
    %   use with other functions/scripts, such as noseplot)
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
    %KNOWN ISSUES: this function has a ton of outputs; several cases are not
    %represented properly; soundings with x>5 are automatically
    % assumed to be instrument error and the (very) few soundings with
    % actual x>5 profiles are removed unjustly. These problems will be rectified 
    % soon, likely before the end of the September.
    %
    %KNOWN FLAWED CASES: cold ground and point nose outside of x = 5
    %
    %The flawed cases represent a high priority and will be the first bug
    %to be fixed after the next push. (8/24/17)
    %
    %Version Date: 8/24/17
    %Last major edit: 8/24/17
    %Written by: Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %
    %See also IGRAimpf, noseplot, prestogeo, fullIGRAimp
    %

% Set defaults
if ~exist('freezeT','var')
    freezeT = 0; %Set default value of freezing temperature to 0 deg C
end
if ~exist('first','var')
    first = 1;
end
if ~exist('last','var')
    last = length(soundStruct);
end
    
warmnose = zeros(length(soundStruct),1); %Preallocation to build the logical matrix used at the end to discern between warmnose and no warmnose soundings.

% Defines the freezing line used within the loops
freezingx = [0 1200]; %pressure
freezingxg = [0 16]; %height
freezingy = ones(1,length(freezingx)).*freezeT; %freezing line (P)
freezingyg = ones(1,length(freezingxg)).*freezeT; %freezing line (z)

errorCount = 0; %Unfortunately, there are a small number of bizarre errors that occur within the following loop,
%usually when an error-ridden sounding is encountered. try/catch->continue
%statements are used to prevent these from ruining the function, and this
%error counter keeps track of how many times the catch->continue is needed
%to save nosedetect's bacon.
%At the end of the function, the final value of errorCount is displayed.

for k = first:last
    mbtop = find(soundStruct(k).pressure >= top); %Find indices of readings where the pressure is greater than 20000 Pa
    presHeight = soundStruct(k).pressure(mbtop); %Select readings greater than 20000 Pa
    goodTemp = soundStruct(k).temp(mbtop); %Temperatures from surface to 200mb

    try %Very rarely, things go wrong here--usually because of instrument error
        [presHeightVector,geoHeightVector] = prestogeo(presHeight,goodTemp,1,soundStruct,k,0); %Call to prestogeo to calculate geopotential heights
    catch ME; %#ok %If they do go wrong
        errorCount = errorCount+1; %keep track of how many times they go wrong 
        continue %then skip and move on
    end
    
    % Quality control - replace -999.9 entries  with NaN
    goodTemp(goodTemp==-999.9) = NaN; 
    
    % Find missing values in pressure levels, geopotential heights, and
    % temperatures
    presHeightNans = isnan(presHeightVector);
    geoHeightNans = isnan(geoHeightVector);
    goodTempNans = isnan(goodTemp);
    
    % Sync up the missing values so NaNs in one array are present in the
    %others as well; otherwise, polyxpoly will fuss.
    presHeightVector(or(presHeightNans,goodTempNans)) = NaN;
    goodTemp(or(presHeightNans,goodTempNans)) = NaN;
    geoHeightVector(or(geoHeightNans,goodTempNans)) = NaN;
    goodTemp(or(geoHeightNans,goodTempNans)) = NaN;
    
    % polyxpoly function finds intersection between plot of sounding
    % (temperature versus pressure) and plot of freezing line.  The
    % function returns x which represents the height (in mb) of the
    % intersection and y which represents the temperature (in C) of the
    % intersection. The second run of polyxpoly returns gx which represents the
    % height (in km) of the intersection and gy which represents the
    % temperature (in C) of the intersection.
    try
        [x,y] = polyxpoly(presHeightVector,goodTemp,freezingx,freezingy);
        if ~isempty(x)
            [gx] = simple_prestogeo(presHeightVector(1),x,goodTemp(1),y); %Call to prestogeo to calculate geopotential heights; prestogeo needs Pa input instead of hPa
            gy = y;
        else %gx and gy must exist in some form or the function will fail
            gx = [];
            gy = [];
        end
    catch ME; %#ok
        errorCount = errorCount+1;
        continue
    end
    
    if numel(x)~=numel(gx) %Very rarely, there will be a mismatch in the number of warmnoses calculated by pressure and calculated by height, usually because of extremely shallow warmnoses at the base
        errorCount = errorCount+1; %If this happens, increase the error count
        continue %then skip and move on to the next sounding
    end
    
    soundStruct(k).warmnose.lclheight = (0.125.*(soundStruct(k).temp(1)-soundStruct(k).dew_point_dep(1))); %Estimate the LCL in km
    soundStruct(k).warmnose.maxtemp = max(goodTemp); %Find maximum temperature (corresponding to warm nose in pressure coordinates)
    soundStruct(k).warmnose.geotemp = max(goodTemp); %Find maximum temperature (corresponding to warm nose in geopotential height coordinates)
  
    if isempty(x) %If x is empty, then there isn't a warm nose
        warmnose(k) = 0; %Set index within warmnose to logical false
        %xintersect(e) = NaN; %xintersect does not exist
        soundStruct(k).warmnose.numwarmnose = 0; %and the warmnose entry within goodfinal is blank
    else %in ANY other circumstance, there is at least one warmnose
        warmnose(k) = 1;
        if length(x) == 1
            soundStruct(k).warmnose.x = x; %PRESSURE x value from polyxpoly
            soundStruct(k).warmnose.gx = gx; %HEIGHT x value from polyxpoly
            soundStruct(k).warmnose.numwarmnose = 1; %number of warm nose is one; since the T profile only crosses the freezing line once, it is implied that it is in contact with the ground
            soundStruct(k).warmnose.lowerbound1 = presHeightVector(1); %PRESSURE lower bound (this is the lowest pressure reading)
            soundStruct(k).warmnose.lowerboundg1 = geoHeightVector(1); %HEIGHT lower bound (this is the lowest height reading)
            soundStruct(k).warmnose.upperbound1 = x(1); %PRESSURE upper bound (this is the pressure level where the T profile crosses the freezing line)
            soundStruct(k).warmnose.upperboundg1 = gx(1); %HEIGHT upper bound (this is the height where the T profile crosses the freezing line)
            soundStruct(k).warmnose.lower(1) = presHeightVector(1); %PRESSURE
            soundStruct(k).warmnose.lowerg(1) = geoHeightVector(1); %HEIGHT
            soundStruct(k).warmnose.upper(1) = x(1); %PRESSURE
            soundStruct(k).warmnose.upperg(1) = gx(1); %HEIGHT (these second instances form a matrix of the lower/upper bounds, providing an easier way to see this information)
            soundStruct(k).warmnose.depth1 = soundStruct(k).warmnose.lowerbound1 - soundStruct(k).warmnose.upperbound1; %PRESSURE depth calculation; pressure decreases with height so this is lower minus upper
            soundStruct(k).warmnose.gdepth1 = soundStruct(k).warmnose.upperboundg1 - soundStruct(k).warmnose.lowerboundg1; %HEIGHT depth calculation; height increases with height so this is upper minus lower
        elseif length(x) == 2
            soundStruct(k).warmnose.x = x; %PRESSURE x value from polyxpoly
            soundStruct(k).warmnose.gx = gx; %HEIGHT x value from polyxpoly
            soundStruct(k).warmnose.numwarmnose = 1; %number of warm nose is one; since the T profile crosses the freezing line twice, it can be inferred that it is aloft
            soundStruct(k).warmnose.lowerbound1 = x(2); %PRESSURE lower bound
            soundStruct(k).warmnose.lowerboundg1 = gx(1); %HEIGHT lower bound; note that the indices are reversed because pressure decreases with height and height increases with height
            soundStruct(k).warmnose.upperbound1 = x(1); %PRESSURE upper bound
            soundStruct(k).warmnose.upperboundg1 = gx(2); %HEIGHT upper bound
            soundStruct(k).warmnose.lower(1) = x(2);
            soundStruct(k).warmnose.lowerg(1) = gx(1);
            soundStruct(k).warmnose.upper(1) = x(1);
            soundStruct(k).warmnose.upperg(1) = gx(2);
            soundStruct(k).warmnose.depth1 = soundStruct(k).warmnose.lowerbound1 - soundStruct(k).warmnose.upperbound1; %PRESSURE depth calculation; pressure decreases with height so this is lower minus upper
            soundStruct(k).warmnose.gdepth1 = soundStruct(k).warmnose.upperboundg1 - soundStruct(k).warmnose.lowerboundg1; %HEIGHT depth calculation; height increases with height so this is upper minus lower
        elseif length(x) == 3
            soundStruct(k).warmnose.x = x; %PRESSURE x value from polyxpoly
            soundStruct(k).warmnose.gx = gx; %HEIGHT x value from polyxpoly
            soundStruct(k).warmnose.numwarmnose = 2; %number of warm noses is two; since the T profile crosses the freezing line three times, it is clear that both a warmnose aloft and a warmnose in contact with the ground are present
            soundStruct(k).warmnose.lowerbound1 = presHeightVector(1); %PRESSURE lower bound; this is the lowest pressure reading (since there is a warmnose at ground level)
            soundStruct(k).warmnose.lowerboundg1 = geoHeightVector(1); %HEIGHT lower bound; this is the lowest height reading
            soundStruct(k).warmnose.upperbound1 = x(3); %PRESSURE upper bound of grounded warmnose
            soundStruct(k).warmnose.upperboundg1 = gx(1); %HEIGHT upper bound of grounded warmnose
            soundStruct(k).warmnose.upperbound2 = x(1); %PRESSURE upper bound of warmnose aloft
            soundStruct(k).warmnose.upperboundg2 = gx(3); %HEIGHT upper bound of warmnose aloft
            soundStruct(k).warmnose.lowerbound2 = x(2); %PRESSURE lower bound of warmnose aloft
            soundStruct(k).warmnose.lowerboundg2 = gx(2); %HEIGHT lower bound of warmnose aloft
            soundStruct(k).warmnose.lower(1) = presHeightVector(1); 
            soundStruct(k).warmnose.lowerg(1) = geoHeightVector(1);
            soundStruct(k).warmnose.upper(1) = x(3);
            soundStruct(k).warmnose.upperg(1) = gx(1);
            soundStruct(k).warmnose.lower(2) = x(2);
            soundStruct(k).warmnose.lowerg(2) = gx(2);
            soundStruct(k).warmnose.upper(2) = x(1);
            soundStruct(k).warmnose.upperg(2) = gx(3);
            soundStruct(k).warmnose.depth1 = soundStruct(k).warmnose.lowerbound1 - soundStruct(k).warmnose.upperbound1; %PRESSURE depth of grounded warmnose is lower minus upper
            soundStruct(k).warmnose.gdepth1 = soundStruct(k).warmnose.upperboundg1 - soundStruct(k).warmnose.lowerboundg1; %HEIGHT depth of grounded warmnose is upper minus lower
            soundStruct(k).warmnose.depth2 = soundStruct(k).warmnose.lowerbound2 - soundStruct(k).warmnose.upperbound2; %PRESSURE depth of warmnose aloft is lower minus upper
            soundStruct(k).warmnose.gdepth2 = soundStruct(k).warmnose.upperboundg2 - soundStruct(k).warmnose.lowerboundg2; %HEIGHT depth of warmnose aloft is upper minus lower
        elseif length(x) == 4
            soundStruct(k).warmnose.x = x; %PRESSURE x value from polyxpoly
            soundStruct(k).warmnose.gx = gx; %HEIGHT x value from polyxpoly
            soundStruct(k).warmnose.numwarmnose = 2; %number of warm noses is two; since the T profile croses the freezing line four times, it is clear that there are two warmnoses aloft
            soundStruct(k).warmnose.upperbound1 = x(3); %PRESSURE upper bound of lowest warmnose aloft
            soundStruct(k).warmnose.upperboundg1 = gx(2); %HEIGHT upper bound of lowest warmnose aloft
            soundStruct(k).warmnose.lowerbound1 = x(4); %PRESSURE lower bound of lowest warmnose aloft
            soundStruct(k).warmnose.lowerboundg1 = gx(1); %HEIGHT lower bound of lowest warmnose aloft
            soundStruct(k).warmnose.upperbound2 = x(1); %PRESSURE upper bound of highest warmnose aloft
            soundStruct(k).warmnose.upperboundg2 = gx(4); %HEIGHT upper bound of highest warmnose aloft
            soundStruct(k).warmnose.lowerbound2 = x(2); %PRESSURE lower bound of highest warmnose aloft
            soundStruct(k).warmnose.lowerboundg2 = gx(3); %HEIGHT lower bound of highest warmnose aloft
            soundStruct(k).warmnose.lower(1) = x(4);
            soundStruct(k).warmnose.lowerg(1) = gx(1);
            soundStruct(k).warmnose.upper(1) = x(3);
            soundStruct(k).warmnose.upperg(1) = gx(2);
            soundStruct(k).warmnose.lower(2) = x(2);
            soundStruct(k).warmnose.lowerg(2) = gx(3);
            soundStruct(k).warmnose.upper(2) = x(1);
            soundStruct(k).warmnose.upperg(2) = gx(4);
            soundStruct(k).warmnose.depth1 = soundStruct(k).warmnose.lowerbound1 - soundStruct(k).warmnose.upperbound1; %PRESSURE depth of lowest warmnose
            soundStruct(k).warmnose.gdepth1 = soundStruct(k).warmnose.upperboundg1 - soundStruct(k).warmnose.lowerboundg1; %HEIGHT depth of lowest warmnose
            soundStruct(k).warmnose.depth2 = soundStruct(k).warmnose.lowerbound2 - soundStruct(k).warmnose.upperbound2; %PRESSURE depth of highest warmnose
            soundStruct(k).warmnose.gdepth2 = soundStruct(k).warmnose.upperboundg2 - soundStruct(k).warmnose.lowerboundg2; %HEIGHT depth of highest warmnose
        elseif length(x) == 5 %Contains format for properly dealing with cold ground and point nose scenarios
            soundStruct(k).warmnose.x = x; %PRESSURE x from polyxpoly
            soundStruct(k).warmnose.gx = gx; %HEIGHT x from polyxpoly
            soundStruct(k).warmnose.numwarmnose = 3; %number of warmnoses is three; since T profile crosses freezing line 5 times there are two warmnoses aloft and a grounded warmnose present
            if goodTemp(1)<freezeT %If the sounding is a cold ground case
                [zeroDegreeInd] = find(goodTemp==0); %These are all the indices of the noses that could possibly be points.
                % Additionally, if x=5 and it is a cold ground case, the sounding
                % must also have a point nose to deal with. The following loop
                % checks all of the warm noses that could be point noses, and
                % destroys them if they are points.
                for zeroCount = 1:length(zeroDegreeInd); %Loop through all the noses
                    if goodTemp(zeroDegreeInd(zeroCount)-1)<freezeT && goodTemp(zeroDegreeInd(zeroCount)+1)<freezeT %If both the preceding and succeeding temperatures are subfreezing, then the nose is a point nose
                        evilPressure = soundStruct(k).pressure(zeroDegreeInd(zeroCount)); %This is the Abomination
                        [evilNose] = find(x==evilPressure/100); %Necessary to convert to hectopascal.
                        x(evilNose) = []; %exterminate
                        switch evilNose %Indices are reversed for height, because height increases with height but pressure decreases with height.
                            case 5 %yes I do the cookin/yes I do the cleanin/yes a switch-case is clumsy but gets the job done -Nicki Minaj
                                gx(1) = []; %exterminate
                            case 4
                                gx(2) = [];
                            case 3
                                gx(3) = [];
                            case 2
                                gx(4) = [];
                            case 1
                                gx(5) = [];
                            otherwise
                                msg = 'Somehow the point nose is not one of the five possible noses, despite the fact that this is logically impossible!';
                                error(msg); %Might as well! Life is meaningless anyways!
                        end
                    else
                        %do nothing
                    end
                end
                % x and gx are now equal to 4.
                % Now the cold ground needs to be dealt with.
                soundStruct(k).warmnose.lowerbound1 = x(4); %Since the ground is actually subfreezing, the lower bound is not the first entry of presheightvector
                soundStruct(k).warmnose.lowerboundg1 = gx(1); %or geoheightvector
                soundStruct(k).warmnose.upperbound1 = x(3);
                soundStruct(k).warmnose.upperboundg1 = gx(2);
                soundStruct(k).warmnose.lowerbound2 = x(2);
                soundStruct(k).warmnose.lowerboundg2 = gx(3);
                soundStruct(k).warmnose.upperbound2 = x(1);
                soundStruct(k).warmnose.upperboundg2 = gx(4);
                soundStruct(k).warmnose.lower(1) = x(4);
                soundStruct(k).warmnose.lowerg(1) = gx(1);
                soundStruct(k).warmnose.upper(1) = x(3);
                soundStruct(k).warmnose.upperg(1) = gx(2);
                soundStruct(k).warmnose.lower(2) = x(2);
                soundStruct(k).warmnose.lowerg(2) = gx(3);
                soundStruct(k).warmnose.upper(2) = x(1);
                soundStruct(k).warmnose.upperg(2) = gx(4);
                soundStruct(k).warmnose.depth1 = soundStruct(k).warmnose.lowerbound1 - soundStruct(k).warmnose.upperbound1; %PRESSURE depth of grounded warmnose
                soundStruct(k).warmnose.gdepth1 = soundStruct(k).warmnose.upperboundg1 - soundStruct(k).warmnose.lowerboundg1; %HEIGHT depth of grounded warmnose
                soundStruct(k).warmnose.depth2 = soundStruct(k).warmnose.lowerbound2 - soundStruct(k).warmnose.upperbound2; %PRESSURE depth of lowest warmnose aloft
                soundStruct(k).warmnose.gdepth2 = soundStruct(k).warmnose.upperboundg2-soundStruct(k).warmnose.lowerboundg2; %HEIGHT depth of lowest warmnose aloft
                soundStruct(k).warmnose.numwarmnose = 2; %Without this, the point nose is counted as a true nose, which will throw off most of the plotting functions (as well as being pointless).
            else %This is the standard type of sounding, a warm ground sounding.
                soundStruct(k).warmnose.lowerbound1 = presHeightVector(1); %PRESSURE lower bound of grounded warmnose
                soundStruct(k).warmnose.lowerboundg1 = geoHeightVector(1); %HEIGHT lower bound of grounded warmnose
                soundStruct(k).warmnose.upperbound1 = x(5); %PRESSURE upper bound of grounded warmnose
                soundStruct(k).warmnose.upperboundg1 = gx(1); %HEIGHT upper bound of grounded warmnose
                soundStruct(k).warmnose.upperbound2 = x(3); %PRESSURE upper bound of lowest warmnose aloft
                soundStruct(k).warmnose.upperboundg2 = gx(3); %HEIGHT upper bound of lowest warmnose aloft
                soundStruct(k).warmnose.lowerbound2 = x(4); %PRESSURE lower bound of lowest warmnose aloft
                soundStruct(k).warmnose.lowerboundg2 = gx(2); %HEIGHT lower bound of lowest warmnose aloft
                soundStruct(k).warmnose.upperbound3 = x(1); %PRESSURE upper bound of highest warmnose aloft
                soundStruct(k).warmnose.upperboundg3 = gx(5); %HEIGHT upper bound of highest warmnose aloft
                soundStruct(k).warmnose.lowerbound3 = x(2); %PRESSURE lower bound of highest warmnose aloft
                soundStruct(k).warmnose.lowerboundg3 = gx(4); %HEIGHT lower bound of highest warmnose aloft
                soundStruct(k).warmnose.lower(1) = presHeightVector(1);
                soundStruct(k).warmnose.lowerg(1) = geoHeightVector(1);
                soundStruct(k).warmnose.upper(1) = x(5);
                soundStruct(k).warmnose.upperg(1) = gx(1);
                soundStruct(k).warmnose.lower(2) = x(4);
                soundStruct(k).warmnose.lowerg(2) = gx(2);
                soundStruct(k).warmnose.upper(2) = x(3);
                soundStruct(k).warmnose.upperg(2) = gx(3);
                soundStruct(k).warmnose.lower(3) = x(2);
                soundStruct(k).warmnose.lowerg(3) = gx(4);
                soundStruct(k).warmnose.upper(3) = x(1);
                soundStruct(k).warmnose.upperg(3) = gx(5);
                soundStruct(k).warmnose.depth1 = soundStruct(k).warmnose.lowerbound1 - soundStruct(k).warmnose.upperbound1; %PRESSURE depth of grounded warmnose
                soundStruct(k).warmnose.gdepth1 = soundStruct(k).warmnose.upperboundg1 - soundStruct(k).warmnose.lowerboundg1; %HEIGHT depth of grounded warmnose
                soundStruct(k).warmnose.depth2 = soundStruct(k).warmnose.lowerbound2 - soundStruct(k).warmnose.upperbound2; %PRESSURE depth of lowest warmnose aloft
                soundStruct(k).warmnose.gdepth2 = soundStruct(k).warmnose.upperboundg2-soundStruct(k).warmnose.lowerboundg2; %HEIGHT depth of lowest warmnose aloft
                soundStruct(k).warmnose.depth3 = soundStruct(k).warmnose.lowerbound3 - soundStruct(k).warmnose.upperbound3; %PRESSURE depth of highest warmnose aloft
                soundStruct(k).warmnose.gdepth3 = soundStruct(k).warmnose.upperboundg3 - soundStruct(k).warmnose.lowerboundg3; %HEIGHT depth of highest warmnose aloft
            end
        elseif length(x) == 6
            soundStruct(k).warmnose.x = x; %PRESSURE x from polyxpoly
            soundStruct(k).warmnose.gx = gx; %HEIGHT x from polyxpoly
            soundStruct(k).warmnose.numwarmnose = 3; %number of warmnoses is three; since T profile crosses the freezing line six times there are three warmnoses aloft
            soundStruct(k).warmnose.upperbound1 = x(5); %PRESSURE upper bound of lowest warmnose aloft
            soundStruct(k).warmnose.upperboundg1 = gx(2); %HEIGHT upper bound of lowest warmnose aloft
            soundStruct(k).warmnose.lowerbound1 = x(6); %PRESSURE lower bound of lowest warmnose aloft
            soundStruct(k).warmnose.lowerboundg1 = gx(1); %HEIGHT lower bound of lowest warmnose aloft
            soundStruct(k).warmnose.upperbound2 = x(3); %PRESSURE upper bound of middle warmnose aloft
            soundStruct(k).warmnose.upperboundg2 = gx(4); %HEIGHT upper bound of middle warmnose aloft
            soundStruct(k).warmnose.lowerbound2 = x(4); %PRESSURE lower bound of middle warmnose aloft
            soundStruct(k).warmnose.lowerboundg2 = gx(3); %HEIGHT lower bound of middle warmnose aloft
            soundStruct(k).warmnose.upperbound3 = x(1); %PRESSURE upper bound of highest warmnose aloft
            soundStruct(k).warmnose.upperboundg3 = gx(6); %HEIGHT upper bound of highest warmnose aloft
            soundStruct(k).warmnose.lowerbound3 = x(2); %PRESSURE lower bound of highest warmnose aloft
            soundStruct(k).warmnose.lowerboundg3 = gx(5); %HEIGHT lower bound of highest warmnose aloft
            soundStruct(k).warmnose.lower(1) = x(6);
            soundStruct(k).warmnose.lowerg(1) = gx(1);
            soundStruct(k).warmnose.upper(1) = x(5);
            soundStruct(k).warmnose.upperg(1) = gx(2);
            soundStruct(k).warmnose.lower(2) = x(4);
            soundStruct(k).warmnose.lowerg(2) = gx(3);
            soundStruct(k).warmnose.upper(2) = x(3);
            soundStruct(k).warmnose.upperg(2) = gx(4);
            soundStruct(k).warmnose.lower(3) = x(2);
            soundStruct(k).warmnose.lowerg(3) = gx(5);
            soundStruct(k).warmnose.upper(3) = x(1);
            soundStruct(k).warmnose.upperg(3) = gx(6);
            soundStruct(k).warmnose.depth1 = soundStruct(k).warmnose.lowerbound1 - soundStruct(k).warmnose.upperbound1; %PRESSURE depth of lowest warmnose
            soundStruct(k).warmnose.gdepth1 = soundStruct(k).warmnose.upperboundg1 - soundStruct(k).warmnose.lowerboundg1; %HEIGHT depth of lowest warmnose
            soundStruct(k).warmnose.depth2 = soundStruct(k).warmnose.lowerbound2 - soundStruct(k).warmnose.upperbound2; %PRESSURE depth of middle warmnose
            soundStruct(k).warmnose.gdepth2 = soundStruct(k).warmnose.upperboundg2 - soundStruct(k).warmnose.lowerboundg2; %HEIGHT depth of middle warmnose
            soundStruct(k).warmnose.depth3 = soundStruct(k).warmnose.lowerbound3 - soundStruct(k).warmnose.upperbound3; %PRESSURE depth of highest warmnose
            soundStruct(k).warmnose.gdepth3 = soundStruct(k).warmnose.upperboundg3 - soundStruct(k).warmnose.lowerboundg3; %HEIGHT depth of highest warmnose
        else
            %AAAAA FUTURE ME HEADS UP YOU NEED ONE MORE CATEGORY
            %AAAAAHHHHHH panda_horse_screaming.gif
            soundStruct(k).warmnose.numwarmnose = NaN; %Situations with any more six freezing line crosses are discarded as instrument error
            soundStruct(k).warmnose.x = NaN; %but still need x and gx entries or loops using this code will choke
            soundStruct(k).warmnose.gx = NaN;
            soundStruct(k).warmnose.lowerbound = NaN;
        end
    end
end

% Make the output structures
warmnoses = logical(warmnose); %Find all of the indices where warmnoses actually exist
warmnosesfinal = soundStruct(warmnoses); %Create a structure that contains only the warmnose soundings
       
nowarmnoses = ~logical(warmnose); %Also create a structure that contains the quality-controlled soundings sans warmnoses
nowarmnosesfinal = soundStruct(nowarmnoses);

% Deal with errors
disp(errorCount); %Final error count is important!
lineInTheSand = 0.07; %Future me don't you even think about changing this
if errorCount>lineInTheSand*length(soundStruct)
    msg = 'Significant errors occurred on more than 5% of the data!';
    warning(msg);
end
    
%yayyyyy
end