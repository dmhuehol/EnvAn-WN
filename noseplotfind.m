%%noseplotfind--function to plot TvP, Tvz, and skew-T charts of soundings
%data. Additionally, divides the given sounding structure into two
%output structures, one of which contains those soundings with warmnoses 
%(including statistics and information regarding the warmnose),
%the other one which contains soundings without warmnoses. noseplotfind
%allows for a great deal of control over its figures and calculations; see
%the discussion of inputs for a full understanding.
%
%General form: [warmnosesfinal,nowarmnosesfinal] = noseplotfind(soundstruct,first,last,newfig,skewT,freezeT,top)
%
%Outputs:
%warmnosesfinal: sounding structure containing the soundings with
%   warmnoses, as well as a nested structure with information about the warmnose(s).
%nowarmnosesfinal: sounding structure containing the soundings without warmnoses.
%
%Inputs:
%soundstruct: soundings data structure
%first: first soundings number wanted
%last: last soundings number wanted
%newfig: controls whether plots are opened on individual figures or overwrite
%   the previous figure. 0 for overwrite option, 1 for individual figures, all
%   other options suppress plotting entirely.
%skewT: controls whether skewT chart is loaded. 0 or 1 will load skewT, all
%   other options will suppress it.
%freezeT: value of freezing line; when temperature profile crosses this line it
%   is considered a warmnose. Default value is 0.5, see Yuter et al. (2006).
%top: highest pressure level/height considered, default value is 200mb (which 
%   corresponds to a geopotential height of roughly 15km.)
%
%
%The biggest advantage of noseplotfind over soundplots is the stars on the
%plot which denote the presence of warmnoses. Also, noseplotfind is easy to
%run in a large loop, such as 1:length(goodfinal). soundplots is, however,
%easier to use. If only the data import function of noseplotfind is
%desired, use nosedetect instead.
%
%Version Date: 6/1/17
%Last major edit: 6/1/17
%Written by: Daniel Hueholt
%North Carolina State University
%Undergraduate Research Assistant at Environment Analytics
%To be added: rhumvP, rhumvz, skew-T new figure plotting, switch to control
%presence of P subplot
%
%See also: IGRAimpf, nosedetect, soundplots
%

function [warmnosesfinal,nowarmnosesfinal] = noseplotfind(soundstruct,first,last,newfig,skewT,freezeT,top)
warmnose = zeros(length(soundstruct),1); %preallocation

%for creation of a freezing line in the plots (see within the loop)
if ~exist('freezeT','var')
    freezeT = 0.5; %set default value of freezing temperature to 0.5 deg C
    %rationale: Yuter et al. (2006)
    %(http://www4.ncsu.edu/~seyuter/pdfs/yuteretal2006JAMC.pdf)
end

freezingx = 0:1200;
freezingxg = 0:16;
freezingy = ones(1,length(freezingx)).*freezeT;
freezingyg = ones(1,length(freezingxg)).*freezeT;

%set default values of first and last to run through the entire input soundings structure
if ~exist('first','var')
    first = 1;
end
if ~exist('last','var')
    last = length(soundstruct);
end
%set default value of top level to 20000Pa
if ~exist('top','var')
    top = 20000;
end

for e = first:last
    mbtop = find(soundstruct(e).pressure >= top); %find indices of readings where the pressure is greater than 20000 Pa
    presheight = soundstruct(e).pressure(mbtop); %select readings greater than 20000 Pa
    goodtemp = soundstruct(e).temp(mbtop); %temperatures from surface to 200mb
    try %very rarely, this hiccups due to major recording errors in a sounding
        [presheightvector,geoheightvector] = prestogeo(presheight,goodtemp,1,soundstruct,e); %call to prestogeo to calculate geopotential heights
    catch ME
        continue %prevents this from stopping the run
    end
    %Quality control - remove 9999 entries 
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

    if numel(x)==1
        x1 = x(1); %PRESSURE
        y1 = y(1);
        gx1 = gx(1); %HEIGHT
        gy1 = gy(1);
        %Switches are used to choose whether the figures open anew for each
        %sounding or plot on the same figure. If the loop extends over a
        %large period, it's best to use case 1 or disable plotting.
        %Only this first switch has been commented, but the other six are
        %essentially identical.
        switch newfig 
            case 1
                f59 = figure(e);
                g = subplot(1,2,1);
                plot(goodtemp,presheightvector,freezingy,freezingx,'r',y1,x1,'*')
                g2 = subplot(1,2,2);
                plot(goodtemp,geoheightvector,freezingyg,freezingxg,'r',gy1,gx1,'*')
            case 0
                f59 = figure(59);
                g = subplot(1,2,1);
                plot(goodtemp,presheightvector,freezingy,freezingx,'r',y1,x1,'*')
                g2 = subplot(1,2,2);
                plot(goodtemp,geoheightvector,freezingyg,freezingxg,'r',gy1,gx1,'*')
            otherwise
                %disp('Plotting disabled!')
        end
        elseif numel(x)==2
        x1 = x(1);
        y1 = y(1);
        x2 = x(2);
        y2 = y(2);
        gx1 = gx(1); %HEIGHT
        gy1 = gy(1);
        gx2 = gx(2);
        gy2 = gy(2);
        switch newfig
            case 1
                f59 = figure(e);
                g = subplot(1,2,1);
                plot(goodtemp,presheightvector,freezingy,freezingx,'r',y1,x1,'*',y2,x2,'*')
                g2 = subplot(1,2,2);
                plot(goodtemp,geoheightvector,freezingyg,freezingxg,'r',gy1,gx1,'*',gy2,gx2,'*')
            case 0
                f59 = figure(59);
                g = subplot(1,2,1);
                plot(goodtemp,presheightvector,freezingy,freezingx,'r',y1,x1,'*',y2,x2,'*')
                g2 = subplot(1,2,2);
                plot(goodtemp,geoheightvector,freezingyg,freezingxg,'r',gy1,gx1,'*',gy2,gx2,'*')
            otherwise
                %disp('Plotting disabled')
        end
    elseif numel(x)==3
        x1 = x(1);
        y1 = y(1);
        x2 = x(2);
        y2 = y(2);
        x3 = x(3);
        y3 = y(3);
        gx1 = gx(1); %HEIGHT
        gy1 = gy(1);
        gx2 = gx(2);
        gy2 = gy(2);
        gx3 = gx(3);
        gy3 = gy(3);
        switch newfig
            case 1
                f59 = figure(e);
                g = subplot(1,2,1);
                plot(goodtemp,presheightvector,freezingy,freezingx,'r',y1,x1,'*',y2,x2,'*',y3,x3,'*')
                g2 = subplot(1,2,2);
                plot(goodtemp,geoheightvector,freezingyg,freezingxg,'r',gy1,gx1,'*',gy2,gx2,'*',gy3,gx3,'*')
            case 0
                f59 = figure(59);
                g = subplot(1,2,1);
                plot(goodtemp,presheightvector,freezingy,freezingx,'r',y1,x1,'*',y2,x2,'*',y3,x3,'*')
                g2 = subplot(1,2,2);
                plot(goodtemp,geoheightvector,freezingyg,freezingxg,'r',gy1,gx1,'*',gy2,gx2,'*',gy3,gx3,'*')
            otherwise
                %disp('Plotting disabled!')
        end
    elseif numel(x)==4
        x1 = x(1);
        y1 = y(1);
        x2 = x(2);
        y2 = y(2);
        x3 = x(3);
        y3 = y(3);
        x4 = x(4);
        y4 = y(4);
        gx1 = gx(1); %HEIGHT
        gy1 = gy(1);
        gx2 = gx(2);
        gy2 = gy(2);
        gx3 = gx(3);
        gy3 = gy(3);
        gx4 = gx(4);
        gy4 = gy(4);
        switch newfig
            case 1
                f59 = figure(e);
                g = subplot(1,2,1);
                plot(goodtemp,presheightvector,freezingy,freezingx,'r',y1,x1,'*',y2,x2,'*',y3,x3,'*',y4,x4,'*')
                g2 = subplot(1,2,2);
                plot(goodtemp,geoheightvector,freezingyg,freezingxg,'r',gy1,gx1,'*',gy2,gx2,'*',gy3,gx3,'*',gy4,gx4,'*')
            case 0
                f59 = figure(59);
                g = subplot(1,2,1);
                plot(goodtemp,presheightvector,freezingy,freezingx,'r',y1,x1,'*',y2,x2,'*',y3,x3,'*',y4,x4,'*')
                g2 = subplot(1,2,2);
                plot(goodtemp,geoheightvector,freezingyg,freezingxg,'r',gy1,gx1,'*',gy2,gx2,'*',gy3,gx3,'*',gy4,gx4,'*')
            otherwise
                %disp('Plotting disabled!')
        end
    elseif numel(x)==5
        x1 = x(1);
        y1 = y(1);
        x2 = x(2);
        y2 = y(2);
        x3 = x(3);
        y3 = y(3);
        x4 = x(4);
        y4 = y(4);
        x5 = x(5);
        y5 = y(5);
        gx1 = gx(1); %HEIGHT
        gy1 = gy(1);
        gx2 = gx(2);
        gy2 = gy(2);
        gx3 = gx(3);
        gy3 = gy(3);
        gx4 = gx(4);
        gy4 = gy(4);
        gx5 = gx(5);
        gy5 = gy(5);
        switch newfig
            case 1
                f59 = figure(e);
                g = subplot(1,2,1);
                plot(goodtemp,presheightvector,freezingy,freezingx,'r',y1,x1,'*',y2,x2,'*',y3,x3,'*',y4,x4,'*',y5,x5,'*')
                g2 = subplot(1,2,2);
                plot(goodtemp,geoheightvector,freezingyg,freezingxg,'r',gy1,gx1,'*',gy2,gx2,'*',gy3,gx3,'*',gy4,gx4,'*',gy5,gx5,'*')
            case 0
                f59 = figure(59);
                g = subplot(1,2,1);
                plot(goodtemp,presheightvector,freezingy,freezingx,'r',y1,x1,'*',y2,x2,'*',y3,x3,'*',y4,x4,'*',y5,x5,'*')
                g2 = subplot(1,2,2);
                plot(goodtemp,geoheightvector,freezingyg,freezingxg,'r',gy1,gx1,'*',gy2,gx2,'*',gy3,gx3,'*',gy4,gx4,'*',gy5,gx5,'*')
            otherwise
                %disp('Plotting disabled!')
        end
    elseif numel(x)==6
        x1 = x(1);
        y1 = y(1);
        x2 = x(2);
        y2 = y(2);
        x3 = x(3);
        y3 = y(3);
        x4 = x(4);
        y4 = y(4);
        x5 = x(5);
        y5 = y(5);
        x6 = x(6);
        y6 = y(6);
        gx1 = gx(1); %HEIGHT
        gy1 = gy(1);
        gx2 = gx(2);
        gy2 = gy(2);
        gx3 = gx(3);
        gy3 = gy(3);
        gx4 = gx(4);
        gy4 = gy(4);
        gx5 = gx(5);
        gy5 = gy(5);
        gx6 = gx(6);
        gy6 = gy(6);
        switch newfig
            case 1
                f59 = figure(e);
                g = subplot(1,2,1);
                plot(goodtemp,presheightvector,freezingy,freezingx,'r',y1,x1,'*',y2,x2,'*',y3,x3,'*',y4,x4,'*',y5,x5,'*',y6,x6,'*')
                g2 = subplot(1,2,2);
                plot(goodtemp,geoheightvector,freezingyg,freezingxg,'r',gy1,gx1,'*',gy2,gx2,'*',gy3,gx3,'*',gy4,gx4,'*',gy5,gx5,'*',gy6,gx6,'*')
            case 0
                f59 = figure(e);
                g = subplot(1,2,1);
                plot(goodtemp,presheightvector,freezingy,freezingx,'r',y1,x1,'*',y2,x2,'*',y3,x3,'*',y4,x4,'*',y5,x5,'*',y6,x6,'*')
                g2 = subplot(1,2,2);
                plot(goodtemp,geoheightvector,freezingyg,freezingxg,'r',gy1,gx1,'*',gy2,gx2,'*',gy3,gx3,'*',gy4,gx4,'*',gy5,gx5,'*',gy6,gx6,'*')
            otherwise
                %disp('Plotting disabled!')
        end
    elseif isempty(x)==1
        switch newfig
            %disp('No warmnose!')
            case 1
                f20303 = figure(e);
                g = subplot(1,2,1);
                plot(goodtemp,presheightvector,freezingy,freezingx,'r')
                g2 = subplot(1,2,2);
                plot(goodtemp,geoheightvector,freezingyg,freezingxg,'r')
            case 0
                f20303 = figure(20303);
                g = subplot(1,2,1);
                plot(goodtemp,presheightvector,freezingy,freezingx,'r')
                g2 = subplot(1,2,2);
                plot(goodtemp,geoheightvector,freezingyg,freezingxg,'r')
                xlim([-80 15])
            otherwise
                %disp('No warmnose!')
                %disp('Plotting disabled')
        end
    else
        %disp('Error!')
    end
    if newfig==1 || newfig == 0
        hold off
        datenum = num2str(soundstruct(e).valid_date_num);
        title(g,['Sounding for ' datenum])
        title(g2,['Sounding for ' datenum])
        % legend('Temp vs Pressure','Freezing line','Lower Bound #1','Upper Bound #1','Lower Bound #2','Upper Bound #2','Lower Bound #3','Upper Bound #3')
        xlabel(g,'Temperature in C')
        xlabel(g2,'Temperature in C')
        ylabel(g,'Pressure in mb')
        ylabel(g2,'Height in km')
        set(g,'YDir','reverse');
        ylim(g,[200 nanmax(presheightvector)]);
        ylim(g2,[0 13]);
        set(g2,'yaxislocation','right')
        hold off %otherwise skew-T will plot in the subplot
    else
        suppressant = 'shh';
    end
    switch skewT
        case 1
            [f9999] = FWOKXskew(soundstruct(e).rhum,soundstruct(e).temp,soundstruct(e).pressure,soundstruct(e).temp-soundstruct(e).dew_point_dep); %uncomment this line for skew-T plotting
        case 0
            [f9999] = FWOKXskew(soundstruct(e).rhum,soundstruct(e).temp,soundstruct(e).pressure,soundstruct(e).temp-soundstruct(e).dew_point_dep); %uncomment this line for skew-T plotting
        otherwise
            %disp('Skew-T plotting disabled!')
    end
    hold off
    
    soundstruct(e).warmnose.lclheight = (0.125.*(soundstruct(e).dew_point_dep(1))); %find the LCL in km
    soundstruct(e).warmnose.maxtemp = max(goodtemp); %find maximum temperature (corresponding to warm nose in pressure coordinates)
    soundstruct(e).warmnose.geotemp = max(goodtemp); %find maximum temperature (corresponding to warm nose in geopotential height coordinates)
  
    if isempty(x) %if x is empty, then there isn't a warm nose
        warmnose(e) = 0; %set index within warmnose to logical false
        %xintersect(e) = NaN; %xintersect does not exist
        soundstruct(e).warmnose.numwarmnose = 0; %and the warmnose entry within goodfinal is blank
    else %in ANY other circumstance, there is at least one warmnose
        warmnose(e) = 1;
        if length(x) == 1
            soundstruct(e).warmnose.x = x; %PRESSURE x value from polyxpoly
            soundstruct(e).warmnose.gx = gx; %HEIGHT x value from polyxpoly
            soundstruct(e).warmnose.numwarmnose = 1; %number of warm nose is one; since the T profile only crosses the freezing line once, it is implied that it is in contact with the ground
            soundstruct(e).warmnose.lowerbound1 = presheightvector(1); %PRESSURE lower bound (this is the lowest pressure reading)
            soundstruct(e).warmnose.lowerboundg1 = geoheightvector(1); %HEIGHT lower bound (this is the lowest height reading)
            soundstruct(e).warmnose.upperbound1 = x(1); %PRESSURE upper bound (this is the pressure level where the T profile crosses the freezing line)
            soundstruct(e).warmnose.upperboundg1 = gx(1); %HEIGHT upper bound (this is the height where the T profile crosses the freezing line)
            soundstruct(e).warmnose.lower(1) = presheightvector(1); %PRESSURE
            soundstruct(e).warmnose.lowerg(1) = geoheightvector(1); %HEIGHT
            soundstruct(e).warmnose.upper(1) = x(1); %PRESSURE
            soundstruct(e).warmnose.upperg(1) = gx(1); %HEIGHT (these second instances form a matrix of the lower/upper bounds, providing an easier way to see this information)
            soundstruct(e).warmnose.depth1 = soundstruct(e).warmnose.lowerbound1 - soundstruct(e).warmnose.upperbound1; %PRESSURE depth calculation; pressure decreases with height so this is lower minus upper
            soundstruct(e).warmnose.gdepth1 = soundstruct(e).warmnose.upperboundg1 - soundstruct(e).warmnose.lowerboundg1; %HEIGHT depth calculation; height increases with height so this is upper minus lower
        elseif length(x) == 2
            soundstruct(e).warmnose.x = x; %PRESSURE x value from polyxpoly
            soundstruct(e).warmnose.gx = gx; %HEIGHT x value from polyxpoly
            soundstruct(e).warmnose.numwarmnose = 1; %number of warm nose is one; since the T profile crosses the freezing line twice, it can be inferred that it is aloft
            soundstruct(e).warmnose.lowerbound1 = x(2); %PRESSURE lower bound
            soundstruct(e).warmnose.lowerboundg1 = gx(1); %HEIGHT lower bound; note that the indices are reversed because pressure decreases with height and height increases with height
            soundstruct(e).warmnose.upperbound1 = x(1); %PRESSURE upper bound
            soundstruct(e).warmnose.upperboundg1 = gx(2); %HEIGHT upper bound
            soundstruct(e).warmnose.lower(1) = x(2);
            soundstruct(e).warmnose.lowerg(1) = gx(1);
            soundstruct(e).warmnose.upper(1) = x(1);
            soundstruct(e).warmnose.upperg(1) = gx(2);
            soundstruct(e).warmnose.depth1 = soundstruct(e).warmnose.lowerbound1 - soundstruct(e).warmnose.upperbound1; %PRESSURE depth calculation; pressure decreases with height so this is lower minus upper
            soundstruct(e).warmnose.gdepth1 = soundstruct(e).warmnose.upperboundg1 - soundstruct(e).warmnose.lowerboundg1; %HEIGHT depth calculation; height increases with height so this is upper minus lower
        elseif length(x) == 3
            soundstruct(e).warmnose.x = x; %PRESSURE x value from polyxpoly
            soundstruct(e).warmnose.gx = gx; %HEIGHT x value from polyxpoly
            soundstruct(e).warmnose.numwarmnose = 2; %number of warm noses is two; since the T profile crosses the freezing line three times, it is clear that both a warmnose aloft and a warmnose in contact with the ground are present
            soundstruct(e).warmnose.lowerbound1 = presheightvector(1); %PRESSURE lower bound; this is the lowest pressure reading (since there is a warmnose at ground level)
            soundstruct(e).warmnose.lowerboundg1 = geoheightvector(1); %HEIGHT lower bound; this is the lowest height reading
            soundstruct(e).warmnose.upperbound1 = x(3); %PRESSURE upper bound of grounded warmnose
            soundstruct(e).warmnose.upperboundg1 = gx(1); %HEIGHT upper bound of grounded warmnose
            soundstruct(e).warmnose.upperbound2 = x(1); %PRESSURE upper bound of warmnose aloft
            soundstruct(e).warmnose.upperboundg2 = gx(3); %HEIGHT upper bound of warmnose aloft
            soundstruct(e).warmnose.lowerbound2 = x(2); %PRESSURE lower bound of warmnose aloft
            soundstruct(e).warmnose.lowerboundg2 = gx(2); %HEIGHT lower bound of warmnose aloft
            soundstruct(e).warmnose.lower(1) = presheightvector(1); 
            soundstruct(e).warmnose.lowerg(1) = geoheightvector(1);
            soundstruct(e).warmnose.upper(1) = x(3);
            soundstruct(e).warmnose.upperg(1) = gx(1);
            soundstruct(e).warmnose.lower(2) = x(2);
            soundstruct(e).warmnose.lowerg(2) = gx(2);
            soundstruct(e).warmnose.upper(2) = x(1);
            soundstruct(e).warmnose.upperg(2) = gx(3);
            soundstruct(e).warmnose.depth1 = soundstruct(e).warmnose.lowerbound1 - soundstruct(e).warmnose.upperbound1; %PRESSURE depth of grounded warmnose is lower minus upper
            soundstruct(e).warmnose.gdepth1 = soundstruct(e).warmnose.upperboundg1 - soundstruct(e).warmnose.lowerboundg1; %HEIGHT depth of grounded warmnose is upper minus lower
            soundstruct(e).warmnose.depth2 = soundstruct(e).warmnose.lowerbound2 - soundstruct(e).warmnose.upperbound2; %PRESSURE depth of warmnose aloft is lower minus upper
            soundstruct(e).warmnose.gdepth2 = soundstruct(e).warmnose.upperboundg2 - soundstruct(e).warmnose.lowerboundg2; %HEIGHT depth of warmnose aloft is upper minus lower
        elseif length(x) == 4
            soundstruct(e).warmnose.x = x; %PRESSURE x value from polyxpoly
            soundstruct(e).warmnose.gx = gx; %HEIGHT x value from polyxpoly
            soundstruct(e).warmnose.numwarmnose = 2; %number of warm noses is two; since the T profile croses the freezing line four times, it is clear that there are two warmnoses aloft
            soundstruct(e).warmnose.upperbound1 = x(3); %PRESSURE upper bound of lowest warmnose aloft
            soundstruct(e).warmnose.upperboundg1 = gx(2); %HEIGHT upper bound of lowest warmnose aloft
            soundstruct(e).warmnose.lowerbound1 = x(4); %PRESSURE lower bound of lowest warmnose aloft
            soundstruct(e).warmnose.lowerboundg1 = gx(1); %HEIGHT lower bound of lowest warmnose aloft
            soundstruct(e).warmnose.upperbound2 = x(1); %PRESSURE upper bound of highest warmnose aloft
            soundstruct(e).warmnose.upperboundg2 = gx(4); %HEIGHT upper bound of highest warmnose aloft
            soundstruct(e).warmnose.lowerbound2 = x(2); %PRESSURE lower bound of highest warmnose aloft
            soundstruct(e).warmnose.lowerboundg2 = gx(3); %HEIGHT lower bound of highest warmnose aloft
            soundstruct(e).warmnose.lower(1) = x(4);
            soundstruct(e).warmnose.lowerg(1) = gx(1);
            soundstruct(e).warmnose.upper(1) = x(3);
            soundstruct(e).warmnose.upperg(1) = gx(2);
            soundstruct(e).warmnose.lower(2) = x(2);
            soundstruct(e).warmnose.lowerg(2) = gx(3);
            soundstruct(e).warmnose.upper(2) = x(1);
            soundstruct(e).warmnose.upperg(2) = gx(4);
            soundstruct(e).warmnose.depth1 = soundstruct(e).warmnose.lowerbound1 - soundstruct(e).warmnose.upperbound1; %PRESSURE depth of lowest warmnose
            soundstruct(e).warmnose.gdepth1 = soundstruct(e).warmnose.upperboundg1 - soundstruct(e).warmnose.lowerboundg1; %HEIGHT depth of lowest warmnose
            soundstruct(e).warmnose.depth2 = soundstruct(e).warmnose.lowerbound2 - soundstruct(e).warmnose.upperbound2; %PRESSURE depth of highest warmnose
            soundstruct(e).warmnose.gdepth2 = soundstruct(e).warmnose.upperboundg2 - soundstruct(e).warmnose.lowerboundg2; %HEIGHT depth of highest warmnose
        elseif length(x) == 5
            soundstruct(e).warmnose.x = x; %PRESSURE x from polyxpoly
            soundstruct(e).warmnose.gx = gx; %HEIGHT x from polyxpoly
            soundstruct(e).warmnose.numwarmnose = 3; %number of warmnoses is three; since T profile crosses freezing line 5 times there are two warmnoses aloft and a grounded warmnose present
            soundstruct(e).warmnose.lowerbound1 = presheightvector(1); %PRESSURE lower bound of grounded warmnose
            soundstruct(e).warmnose.lowerboundg1 = geoheightvector(1); %HEIGHT lower bound of grounded warmnose
            soundstruct(e).warmnose.upperbound1 = x(5); %PRESSURE upper bound of grounded warmnose
            soundstruct(e).warmnose.upperboundg1 = gx(1); %HEIGHT upper bound of grounded warmnose
            soundstruct(e).warmnose.upperbound2 = x(3); %PRESSURE upper bound of lowest warmnose aloft
            soundstruct(e).warmnose.upperboundg2 = gx(3); %HEIGHT upper bound of lowest warmnose aloft
            soundstruct(e).warmnose.lowerbound2 = x(4); %PRESSURE lower bound of lowest warmnose aloft
            soundstruct(e).warmnose.lowerboundg2 = gx(2); %HEIGHT lower bound of lowest warmnose aloft
            soundstruct(e).warmnose.upperbound3 = x(1); %PRESSURE upper bound of highest warmnose aloft
            soundstruct(e).warmnose.upperboundg3 = gx(5); %HEIGHT upper bound of highest warmnose aloft
            soundstruct(e).warmnose.lowerbound3 = x(2); %PRESSURE lower bound of highest warmnose aloft
            soundstruct(e).warmnose.lowerboundg3 = gx(4); %HEIGHT lower bound of highest warmnose aloft
            soundstruct(e).warmnose.lower(1) = presheightvector(1); %disabled for now
            soundstruct(e).warmnose.lowerg(1) = geoheightvector(1); %hi
            soundstruct(e).warmnose.upper(1) = x(5);
            soundstruct(e).warmnose.upperg(1) = gx(1);
            soundstruct(e).warmnose.lower(2) = x(4);
            soundstruct(e).warmnose.lowerg(2) = gx(2);
            soundstruct(e).warmnose.upper(2) = x(3);
            soundstruct(e).warmnose.upperg(2) = gx(3);
            soundstruct(e).warmnose.lower(3) = x(2);
            soundstruct(e).warmnose.lowerg(3) = gx(4);
            soundstruct(e).warmnose.upper(3) = x(1);
            soundstruct(e).warmnose.upperg(3) = gx(5);
            soundstruct(e).warmnose.depth1 = soundstruct(e).warmnose.lowerbound1 - soundstruct(e).warmnose.upperbound1; %PRESSURE depth of grounded warmnose
            soundstruct(e).warmnose.gdepth1 = soundstruct(e).warmnose.upperboundg1 - soundstruct(e).warmnose.lowerboundg1; %HEIGHT depth of grounded warmnose
            soundstruct(e).warmnose.depth2 = soundstruct(e).warmnose.lowerbound2 - soundstruct(e).warmnose.upperbound2; %PRESSURE depth of lowest warmnose aloft
            soundstruct(e).warmnose.gdepth2 = soundstruct(e).warmnose.upperboundg2-soundstruct(e).warmnose.lowerboundg2; %HEIGHT depth of lowest warmnose aloft
            soundstruct(e).warmnose.depth3 = soundstruct(e).warmnose.lowerbound3 - soundstruct(e).warmnose.upperbound3; %PRESSURE depth of highest warmnose aloft
            soundstruct(e).warmnose.gdepth3 = soundstruct(e).warmnose.upperboundg3 - soundstruct(e).warmnose.lowerboundg3; %HEIGHT depth of highest warmnose aloft
        elseif length(x) == 6
            soundstruct(e).warmnose.x = x; %PRESSURE x from polyxpoly
            soundstruct(e).warmnose.gx = gx; %HEIGHT x from polyxpoly
            soundstruct(e).warmnose.numwarmnose = 3; %number of warmnoses is three; since T profile crosses the freezing line six times there are three warmnoses aloft
            soundstruct(e).warmnose.upperbound1 = x(5); %PRESSURE upper bound of lowest warmnose aloft
            soundstruct(e).warmnose.upperboundg1 = gx(2); %HEIGHT upper bound of lowest warmnose aloft
            soundstruct(e).warmnose.lowerbound1 = x(6); %PRESSURE lower bound of lowest warmnose aloft
            soundstruct(e).warmnose.lowerboundg1 = gx(1); %HEIGHT lower bound of lowest warmnose aloft
            soundstruct(e).warmnose.upperbound2 = x(3); %PRESSURE upper bound of middle warmnose aloft
            soundstruct(e).warmnose.upperboundg2 = gx(4); %HEIGHT upper bound of middle warmnose aloft
            soundstruct(e).warmnose.lowerbound2 = x(4); %PRESSURE lower bound of middle warmnose aloft
            soundstruct(e).warmnose.lowerboundg2 = gx(3); %HEIGHT lower bound of middle warmnose aloft
            soundstruct(e).warmnose.upperbound3 = x(1); %PRESSURE upper bound of highest warmnose aloft
            soundstruct(e).warmnose.upperboundg3 = gx(6); %HEIGHT upper bound of highest warmnose aloft
            soundstruct(e).warmnose.lowerbound3 = x(2); %PRESSURE lower bound of highest warmnose aloft
            soundstruct(e).warmnose.lowerboundg3 = gx(5); %HEIGHT lower bound of highest warmnose aloft
            soundstruct(e).warmnose.lower(1) = x(6);
            soundstruct(e).warmnose.lowerg(1) = gx(1);
            soundstruct(e).warmnose.upper(1) = x(5);
            soundstruct(e).warmnose.upperg(1) = gx(2);
            soundstruct(e).warmnose.lower(2) = x(4);
            soundstruct(e).warmnose.lowerg(2) = gx(3);
            soundstruct(e).warmnose.upper(2) = x(3);
            soundstruct(e).warmnose.upperg(2) = gx(4);
            soundstruct(e).warmnose.lower(3) = x(2);
            soundstruct(e).warmnose.lowerg(3) = gx(5);
            soundstruct(e).warmnose.upper(3) = x(1);
            soundstruct(e).warmnose.upperg(3) = gx(6);
            soundstruct(e).warmnose.depth1 = soundstruct(e).warmnose.lowerbound1 - soundstruct(e).warmnose.upperbound1; %PRESSURE depth of lowest warmnose
            soundstruct(e).warmnose.gdepth1 = soundstruct(e).warmnose.upperboundg1 - soundstruct(e).warmnose.lowerboundg1; %HEIGHT depth of lowest warmnose
            soundstruct(e).warmnose.depth2 = soundstruct(e).warmnose.lowerbound2 - soundstruct(e).warmnose.upperbound2; %PRESSURE depth of middle warmnose
            soundstruct(e).warmnose.gdepth2 = soundstruct(e).warmnose.upperboundg2 - soundstruct(e).warmnose.lowerboundg2; %HEIGHT depth of middle warmnose
            soundstruct(e).warmnose.depth3 = soundstruct(e).warmnose.lowerbound3 - soundstruct(e).warmnose.upperbound3; %PRESSURE depth of highest warmnose
            soundstruct(e).warmnose.gdepth3 = soundstruct(e).warmnose.upperboundg3 - soundstruct(e).warmnose.lowerboundg3; %HEIGHT depth of highest warmnose
        else
            soundstruct(e).warmnose.numwarmnose = NaN; %situations with any more than six warmnoses are discarded as instrument error
        end
    end
end

warmnoses = logical(warmnose); %find all of the indices where warmnoses actually exist
warmnosesfinal = soundstruct(warmnoses); %create a structure that contains only the warmnose soundings
       
nowarmnoses = ~logical(warmnose); %also create a structure that contains the quality-controlled soundings sans warmnoses
nowarmnosesfinal = soundstruct(nowarmnoses);
end