function [txt] = myupdatefcn(empt,event_obj)
   % Customizes text of data tips
   pos = get(event_obj,'Position'); %position has two values: one is maximum y value, one is the x value (time)
   %[index] = find(dateForBar == pos(1))
%    if isequal(pos(2),sounding(dex).warmnose.upperg(1))==1
%        lowernum = pos(2)-sounding(dex).warmnose.gdepth1;
%    elseif isequal(pos(2),sounding(dex).warmnose.upperg(2))==1
%        lowernum = pos(2)-sounding(dex).warmnose.gdepth2;
%    elseif isequal(pos(2),sounding(dex).warmnose.upperg(3))==1
%        lowernum = pos(2)-sounding(dex).warmnose.gdepth3;
%    else
%        lowernum = 345678;
%    end
%    lowerstr = num2str(lowernum);
lowernum = pos(1);
lowerstr = num2str(lowernum);
   txt = {['time: ',datestr(pos(1),'mm/dd/yy HH')],...
['Upper: ',num2str(pos(2))],['Lower: ',lowerstr]}; %this sets the tooltip format
end