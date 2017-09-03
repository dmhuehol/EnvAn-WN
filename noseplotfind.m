function [] = noseplotfind(soundstruct,first,last,newfig,skewT,freezeT,top)
%%noseplotfind
    %function to plot TvP, Tvz, and skew-T charts of soundings
    %data. noseplotfind allows for a great deal of control over its figures
    %and calculations; see the discussion of inputs for a full understanding.
    %
    %General form: noseplotfind(soundstruct,first,last,newfig,skewT,freezeT,top)
    %
    %Outputs:
    %none
    %
    %Inputs:
    %soundstruct: soundings data structure
    %first: first soundings number wanted
    %last: last soundings number wanted
    %newfig: controls whether plots are opened on individual figures or overwrite
    %   the previous figure. 0 for overwrite option, 1 for individual figures, all
    %   other options suppress plotting entirely.
    %skewT: controls whether skewT chart is loaded. 1 will load skewT, all
    %   other options will suppress it.
    %freezeT: value of freezing line; when temperature profile crosses this line it
    %   is considered a warmnose. Default value is 0.
    %top: highest pressure level/height considered, default value is 200mb (which 
    %   corresponds to a geopotential height of roughly 15km.)
    %
    %
    %noseplotfind is most appropriate for viewing a large number of
    %soundings at once; basically, it's the best tool for getting the general
    %feel of a soundings dataset. For individual soundings, it's much
    %easier to use soundplots, TvZ, or wnplot.
    %
    %For analysis of warm noses, see nosedetect.
    %
    %Version Date: 8/17/17
    %Last major revision: 6/14/17
    %Written by: Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %To be added: rhumvP, rhumvz, skew-T new figure plotting, switch to control
    %presence of P subplot
    %Note that the above features will likely be added in the relatively
    %distant future--since this function is mostly useful in the early
    %stages of dataset analysis, improving it is currently a low priority.
    %
    %See also: IGRAimpf, nosedetect, soundplots
    %

% For creation of a freezing line in the plots (see within the loop)
if ~exist('freezeT','var')
    freezeT = 0; %Set default value of freezing temperature to 0 deg C
end

% To make running without entering all the inputs easier
if ~exist('newfig','var')
    newfig = 0;
end
if ~exist('skewT','var')
    skewT = -1;
end

% Define the freezing line
freezingx = [0 1200]; %Two points to define a line
freezingxg = [0 16]; %Two points to define a line
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
            %Do nothing
        otherwise
            %disp('Skew-T plotting disabled!')
    end
    hold off
    
    soundstruct(e).warmnose.lclheight = (0.125.*(soundstruct(e).dew_point_dep(1))); %find the LCL in km
    soundstruct(e).warmnose.maxtemp = max(goodtemp); %find maximum temperature (corresponding to warm nose in pressure coordinates)
    soundstruct(e).warmnose.geotemp = max(goodtemp); %find maximum temperature (corresponding to warm nose in geopotential height coordinates)
  
end
end