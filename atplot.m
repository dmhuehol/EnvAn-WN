
input_file = 'C:\Users\danielholt\Documents\MATLAB\Project 1 - Warm Noses\Soundings Data\Upton\72501.dat';
[sndng,filtered,soundsh,goodfinal,warmnosesfinal,nowarmnosesfinal] = IGRAimpfil(input_file);

% fh2 = figure(92);
% for f = 1:length(warmnosesfinal)
%     try
%     if length(warmnosesfinal(f).warmnose.gx) == 3
%         uppers(f) = (warmnosesfinal(f).warmnose.upperboundg2);
%         lowers(f) = (warmnosesfinal(f).warmnose.lowerboundg2);
%         title('Lower Bounds (Blue) and Upper Bounds (Red) of All Warm Noses Aloft - Z')
%         xlabel('Sounding Number')
%         ylabel('Height (in km) of Bottom of Warm Nose')
%         xlim([0 length(warmnosesfinal)]);
%         ylim([0 100])
%         hold on 
%     else
%         continue
%     end
%         catch ME;
%             continue
%     end
% end
%             


for f = 1:length(warmnosesfinal)
    try
    if length(warmnosesfinal(f).warmnose.gx) == 1
        plot(f,warmnosesfinal(f).warmnose.upperboundg1,'*r')
        plot(f,warmnosesfinal(f).warmnose.lowerboundg1,'*')
        title('Lower Bounds (Blue) and Upper Bounds (Red) of All Warm Noses Aloft - Z')
        xlabel('Sounding Number')
        ylabel('Height (in km) of Bottom of Warm Nose')
        xlim([0 length(warmnosesfinal)]);
        hold on  
    elseif length(warmnosesfinal(f).warmnose.gx) == 2
        plot(f,warmnosesfinal(f).warmnose.upperboundg1,'*r')
        plot(f,warmnosesfinal(f).warmnose.lowerboundg1,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 3
        plot(f,warmnosesfinal(f).warmnose.upperboundg1,'*r')
        plot(f,warmnosesfinal(f).warmnose.upperboundg2,'*r')
        plot(f,warmnosesfinal(f).warmnose.lowerboundg1,'*')
        plot(f,warmnosesfinal(f).warmnose.lowerboundg2,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 4
        plot(f,warmnosesfinal(f).warmnose.upperboundg1,'*r')
        plot(f,warmnosesfinal(f).warmnose.upperboundg2,'*r')
        plot(f,warmnosesfinal(f).warmnose.lowerboundg1,'*')
        plot(f,warmnosesfinal(f).warmnose.lowerboundg2,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 5
        plot(f,warmnosesfinal(f).warmnose.upperboundg1,'*r')
        plot(f,warmnosesfinal(f).warmnose.upperboundg2,'*r')
        plot(f,warmnosesfinal(f).warmnose.upperboundg3,'*r')
        plot(f,warmnosesfinal(f).warmnose.lowerboundg1,'*')
        plot(f,warmnosesfinal(f).warmnose.lowerboundg2,'*')
        plot(f,warmnosesfinal(f).warmnose.lowerboundg3,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 6
        plot(f,warmnosesfinal(f).warmnose.upperboundg1,'*r')
        plot(f,warmnosesfinal(f).warmnose.upperboundg2,'*r')
        plot(f,warmnosesfinal(f).warmnose.upperboundg3,'*r')
        plot(f,warmnosesfinal(f).warmnose.lowerboundg1,'*')
        plot(f,warmnosesfinal(f).warmnose.lowerboundg2,'*')
        plot(f,warmnosesfinal(f).warmnose.lowerboundg3,'*')
    end
    catch ME;
        continue
    end
end




fh6 = figure(96); %HEIGHT
for f = 1:length(warmnosesfinal)
    if length(warmnosesfinal(f).warmnose.gx) == 1
        plot(f,warmnosesfinal(f).warmnose.gdepth1,'*')
        title('Depth of All Warm Noses - Z')
        xlabel('Soundings with Warm Noses')
        ylabel('Depth (in km) of All Warm Noses')
        xlim([0 360]);
        hold on  
    elseif length(warmnosesfinal(f).warmnose.gx) == 2
        plot(f,warmnosesfinal(f).warmnose.gdepth1,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 3
        plot(f,warmnosesfinal(f).warmnose.gdepth1,'*')
        plot(f,warmnosesfinal(f).warmnose.gdepth2,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 4
        plot(f,warmnosesfinal(f).warmnose.gdepth1,'*')
        plot(f,warmnosesfinal(f).warmnose.gdepth2,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 5
        plot(f,warmnosesfinal(f).warmnose.gdepth1,'*')
        plot(f,warmnosesfinal(f).warmnose.gdepth2,'*')
        plot(f,warmnosesfinal(f).warmnose.gdepth3,'*')
    elseif length(warmnosesfinal(f).warmnose.gx) == 6
        plot(f,warmnosesfinal(f).warmnose.gdepth1,'*')
        plot(f,warmnosesfinal(f).warmnose.gdepth2,'*')
        plot(f,warmnosesfinal(f).warmnose.gdepth3,'*')
        %this plots the depth (km) of all warmnoses present
    end
end
hold off

for f = 1:length(warmnosesfinal)
    try
    upperbounds1(f) = warmnosesfinal(f).warmnose.upperbound1;
    upperboundsg1(f) = warmnosesfinal(f).warmnose.upperboundg1;
    if isfield(warmnosesfinal(f).warmnose,'upperbound2')
        upperbounds2(f) = warmnosesfinal(f).warmnose.upperbound2;
        upperboundsg2(f) = warmnosesfinal(f).warmnose.upperboundg2;
    end
    if isfield(warmnosesfinal(f).warmnose,'upperbound3')
        upperbounds3(f) = warmnosesfinal(f).warmnose.upperbound3;
        upperboundsg3(f) = warmnosesfinal(f).warmnose.upperboundg3;
    end
    catch ME;
        continue
    end
end


for f = 1:length(warmnosesfinal) %unfortunately nested structures require a loop to extract information
    %this loop grabs all of the warmnose depths out of the warmnosesfinal
    %structure, so that they can be concatenated into an array and used to
    %make depth plots
    try
    depths1(f) = warmnosesfinal(f).warmnose.depth1;
    gdepths1(f) = warmnosesfinal(f).warmnose.gdepth1;
    if isfield(warmnosesfinal(f).warmnose,'depth2')
        depths2(f) = warmnosesfinal(f).warmnose.depth2;
        gdepths2(f) = warmnosesfinal(f).warmnose.gdepth2;
    end
    if isfield(warmnosesfinal(f).warmnose,'depth3')
        depths3(f) = warmnosesfinal(f).warmnose.depth3;
        gdepths3(f) = warmnosesfinal(f).warmnose.gdepth3;
    else 
        depths2(f) = 0;
        gdepths2(f) = 0;
        depths3(f) = 0;
        gdepths3(f) = 0;
    end
    catch ME;
        continue
    end
end

% data:
bounds = horzcat(lowerboundsg2',upperboundsg2');
range = upperboundsg2-lowerboundsg2;
depth = [bounds(:,1)' range]

% solution 1, using bars
figure
boxplot(bounds')
title('Altitude vs Sounding Number: First Warm Nose Aloft Depth')
xlabel('Sounding number')
ylabel('Height (km)')
ylim([0 4.5])

% bh = bar(depth,'stacked');
% set(bh(1),'FaceColor','none','EdgeColor','none')
% set(gca,'ylim',[1 1100])
% set(gca,'xtick',[1 2 3],'xticklabel',{'A','B','C'})










