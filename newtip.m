    function [txt] = newtip(empt,event_obj)
    %%newtip
        % Customizes text of Data Cursor tooltips. This function should be nested
        % inside of another function; otherwise the only variables it can
        % access are empt and event_obj, which limits one's options to
        % basically zilch.
        %
        % This was written specifically to create a tooltip for warm nose plots
        % which contained a time, upper bound of bar, and lower bound of
        % bar. However, this method could be easily adapted for other purposes.
        % 
        % Best usage: dcm_obj = datacursormode(figure); set(dcm_obj,'UpdateFcn',@newtip)
        %
        %Outputs:
        %txt: the tooltip text
        %
        %Inputs:
        %empt: empty set []
        %event_obj: object created by datacursormode(figure)
        %
        %For example of practical usage, see wnaltplot
        %
        %Version Date: 9/1/17
        %Last major revision: 6/20/17
        %Written by: Daniel Hueholt
        %North Carolina State University
        %Undergraduate Research Assistant at Environment Analytics
        %
        %See also wnAllPlot
        %
        pos = get(event_obj,'Position'); %Position has two values: one is maximum y value, one is the x value
        [dex] = find(dateForBar == pos(1)); %Find the index corresponding to the datenumber; this is also the sounding's index in warmnosesfinal
        if pos(2)-sounding(dex).warmnose.upperg(1)<=0.0005 %The upper bound is either the first
            lowernum = pos(2)-sounding(dex).warmnose.gdepth1; %value of lower bound
        elseif pos(2)-sounding(dex).warmnose.upperg(2)<=0.0005 %second
            lowernum = pos(2)-sounding(dex).warmnose.gdepth2;
        elseif pos(2)-sounding(dex).warmnose.upperg(3)<=0.0005 %or third
            lowernum = pos(2)-sounding(dex).warmnose.gdepth3;
        else
            lowernum = 9999999; %Go crazy
        end
        lowerstr = num2str(lowernum); %Change to string
        txt = {['time: ',datestr(pos(1),'mm/dd/yy HH')],...
            ['Upper: ',num2str(pos(2))],['Lower: ',lowerstr]}; %This sets the tooltip format
    end