function [] = wnaltind(y,m,d,h,sounding)

[numdex] = findsnd(y,m,d,h,sounding); %find the index of the sounding for the input time

if ~exist('numdex','var') %if the index doesn't exist
    return %end the function; findsnd will take care of the warning message
end

numwarmnose = sounding(numdex).warmnose.numwarmnose; %find how many noses there are
lb1 = sounding(numdex).warmnose.lowerboundg1; %there will always be a first warmnose
d1 = sounding(numdex).warmnose.gdepth1; %first depth
if numwarmnose == 2
    lb2 = sounding(numdex).warmnose.lowerboundg2; %second
    d2 = sounding(numdex).warmnose.upperboundg2-lb2; %second depth
elseif numwarmnose == 3
    lb2 = sounding(numdex).warmnose.lowerboundg2; %second
    d2 = sounding(numdex).warmnose.upperboundg2-lb2; %second depth
    lb3 = sounding(numdex).warmnose.lowerboundg3; %third
    d3 = sounding(numdex).warmnose.upperboundg3-lb3; %third depth
end

dateForBar = sounding(numdex).valid_date_num; %date entry is just date from sounding

[LCL] = cloudbaseplot(sounding,numdex,0,0); %locate cloud base
try
    if isnan(LCL(2))~=1 %if the cloudbase exists
        cloudbase = LCL(2); %this is the cloud base in km
    elseif isnan(LCL(2))==1
        %do nothing
    else %in case there's something weird
        disp('Cloud base calculation failed!')
    end
catch ME; %in case there's something REALLY weird
    disp('Cloud base calculation failed!')
end

%bounds for plotting cloud base as horizontal bar
lhb = dateForBar-0.6; %left 
rhb = dateForBar+0.6; %right

date = [y m d h]; %for figures

%% Plotting
%%NOTE THIS DOESN'T WORK 
figure(1); %altitude of warmnoses aloft vs observation time for input year
bd1 = cat(2,lb1,d1);
barWN = bar(sum(bd1))
set(barWN,'EdgeColor','g','FaceColor','g')
hold on
barASFD = bar(bd1(1))
set(barASFD,'EdgeColor','none','FaceColor','w')
hold on
bd2 = cat(2,lb2,d2)
barWN2 = bar(sum(bd2))
set(barWN2,'EdgeColor','b','FaceColor','b')
hold on
barQWR = bar(bd2(1))
set(barQWR,'EdgeColor','none','FaceColor','w')

%%YOU'VE BEEN WORKING BETWEEN THE LAST DOUBLE PERCENT AND HERE
set(barWN(1),'EdgeColor','none','FaceColor','w'); %change the color of the bar from 0 to min altitude to be invisible
set(barWN(2),'EdgeColor','k','FaceColor','k');
hold on
if exist('lb2','var')
    barWN2 = bar([cat(2,lb2,d2);NaN(1,2)],'stacked');
    set(barWN2(1),'EdgeColor','none','FaceColor','w');
    set(barWN2(2),'EdgeColor','b','FaceColor','b');
    hold on
end
if exist('lb3','var')
    barWN3 = bar([cat(2,lb3,d3);NaN(1,2)],'stacked');
    set(barWN3(1),'EdgeColor','none','FaceColor','w');
    set(barWN3(2),'EdgeColor','b','FaceColor','b');
    hold on
end
if exist('cloudbase','var')
    plot([cloudbase,cloudbase],'r','LineWidth',1.5) %plot cloudbase as a horizontal line
end
ylim([0 5])
line1 = ('Altitude of Warmnoses Aloft vs Sounding Date');
dateString = num2str(date);
line2 = (['KOKX Soundings Data ' dateString]);
lines = {line1,line2};
title(lines)
xlabel('Observation Time')
ylabel('Height (km)')
set(gca,'XMinorTick','on','YMinorTick','on')
% datetickzoom('x',2,'keeplimits') %EXTERNAL FUNCTION - otherwise tick number is very inflexible
% dcm_obj = datacursormode(figure(1));
%     function [txt] = newtip(empt,event_obj)
%         %%newtip
%         % Customizes text of Data Cursor tooltips. This function should be nested
%         % inside of another function; otherwise the only variables it can
%         % access are empt and event_obj, which limits one's options to
%         % basically zilch.
%         %
%         pos = get(event_obj,'Position'); %position has two values: one is maximum y value, one is the x value
%         [dex] = find(dateForBar == pos(1)); %find the index corresponding to the datenumber; this is also the sounding's index in warmnosesfinal
%         if pos(2)-soundings(dex).warmnose.upperg(1)<=0.0005 %the upper bound is either the first
%             lowernum = pos(2)-soundings(dex).warmnose.gdepth1; %value of lower bound
%         elseif pos(2)-soundings(dex).warmnose.upperg(2)<=0.0005 %second
%             lowernum = pos(2)-soundings(dex).warmnose.gdepth2;
%         elseif pos(2)-soundings(dex).warmnose.upperg(3)<=0.0005 %or third
%             lowernum = pos(2)-soundings(dex).warmnose.gdepth3;
%         else
%             lowernum = 9999999; %go crazy
%         end
%         lowerstr = num2str(lowernum); %change to string
%         txt = {['time: ',datestr(pos(1),'mm/dd/yy HH')],...
%             ['Upper: ',num2str(pos(2))],['Lower: ',lowerstr]}; %this sets the tooltip format
%     end
% set(dcm_obj,'UpdateFcn',@newtip) %set the tooltips to use the newtip format
% hold off
% 
% 
% switch grounded %switch/case instead of if/elseif/else so adding new functionality later is easier
%     case 1 %only show grounded plots if grounded = 1
%         figure(2); %altitude of warmnoses grounded and aloft against observation time for input year
%         barGN = bar(dateForBarY,cat(2,groundedyear',groundedDepthyear'),'stacked');
%         set(barGN(1),'EdgeColor','none','FaceColor','w');
%         set(barGN(2),'EdgeColor','g','FaceColor','g');
%         hold on
%         barGN2 = bar(dateForBarY,cat(2,groundedyear2',grounded2Depthyear'),'stacked');
%         set(barGN2(1),'EdgeColor','none','FaceColor','w');
%         set(barGN2(2),'EdgeColor','g','FaceColor','g');
%         hold on
%         barWN = bar(dateForBarY,cat(2,lbyear',boundsdepthyear'),'stacked'); %bar the dates vs the amalgamation of the lowerbounds and depth
%         set(barWN(1),'EdgeColor','none','FaceColor','w'); %change the color of the bar from 0 to min altitude to be invisible
%         set(barWN(2),'EdgeColor','b','FaceColor','b');
%         hold on
%         barWN2 = bar(dateForBarY,cat(2,lbyear2',boundsdepthyear2'),'stacked');
%         set(barWN2(1),'EdgeColor','none','FaceColor','w');
%         set(barWN2(2),'EdgeColor','b','FaceColor','b');
%         hold on
%         barWN3 = bar(dateForBarY,cat(2,lbyear3',boundsdepthyear3'),'stacked');
%         set(barWN3(1),'EdgeColor','none','FaceColor','w');
%         set(barWN3(2),'EdgeColor','b','FaceColor','b');
%         ylim([0 5])
%         line1 = ('Altitude of Warmnoses Aloft vs Sounding Date');
%         yearstr = num2str(year);
%         line2 = (['KOKX Soundings Data ' yearstr]);
%         lines = {line1,line2};
%         title(lines)
%         xlabel('Observation Time (D/M/Y/H)')
%         ylabel('Height (km)')
%         set(gca,'XMinorTick','on','YMinorTick','on')
%         set(gca,'XTick',dateForBarY) %set where XTicks are; make sure they're in the same place as the date information
%         hold on
%         for gg = 1:length(dateForBarY)
%             plot([lhb(gg),rhb(gg)],[cloudbase(gg),cloudbase(gg)],'r','LineWidth',1.5) %plot cloudbase as a horizontal line
%             hold on
%         end
%         for gg = 1:length(dateForBarY)
%             plot([lhb(gg),rhb(gg)],[cloudbasealoft(gg),cloudbasealoft(gg)],'r','LineWidth',1.5) %plot cloudbase as a horizontal line
%             hold on
%         end
%         datetickzoom('x',2) %EXTERNAL FUNCTION - otherwise tick number is very inflexible
%         dcm_obj = datacursormode(figure(2));
%         set(dcm_obj,'UpdateFcn',@newtip) %set the tooltips to use the newtip format
%         
%         figure(3); %altitude of grounded warmnoses vs observation time for input year
%         barGN = bar(dateForBarY,cat(2,groundedyear',groundedDepthyear'),'stacked');
%         set(barGN(1),'EdgeColor','none','FaceColor','w');
%         set(barGN(2),'EdgeColor','g','FaceColor','g');
%         hold on
%         barGN2 = bar(dateForBarY,cat(2,groundedyear2',grounded2Depthyear'),'stacked');
%         set(barGN2(1),'EdgeColor','none','FaceColor','w');
%         set(barGN2(2),'EdgeColor','g','FaceColor','g');
%         hold on
%         for gg = 1:length(dateForBarY)
%             plot([lhb(gg),rhb(gg)],[cloudbase(gg),cloudbase(gg)],'-r','LineWidth',1.5) %plot cloudbase as a horizontal line
%             hold on
%         end
%         ylim([0 5])
%         line1 = ('Altitude of Grounded Warmnoses vs Sounding Date');
%         yearstr = num2str(year);
%         line2 = (['KOKX Soundings Data ' yearstr]);
%         lines = {line1,line2};
%         title(lines)
%         xlabel('Obsevation Time (D/M/Y/H)')
%         ylabel('Height (km)')
%         set(gca,'XMinorTick','on','YMinorTick','on')
%         set(gca,'XTick',dateForBarY) %set where XTicks are; make sure they're in the same place as the date information
%         datetickzoom('x',2) %EXTERNAL FUNCTION - otherwise tick number is very inflexible
%         dcm_obj = datacursormode(figure(3));
%         set(dcm_obj,'UpdateFcn',@newtip) %set the tooltips to use the newtip format
%     otherwise
%         disp('Grounded warmnoses were not plotted')
%         return
% end

end