%% numwarmnose
    %Script to divide up a warm nose sounding dataset by the number of warm
    %noses present in the sounding. (Due to some minor flaws in how nosedetect
    %treats warm noses, this is very good but imperfect; fixing these
    %unusual cases is a high priority goal.)
    %numwarmnose has been left as a script because many of the variables are 
    %useful for analysis, and an inconvenient number of outputs would need 
    %to be designated to make this work as a function.
    %
    %The most useful variables, in my experience, are:
    %onenose: contains numwarmnose=1
    %twonose: contains numwarmnose=2
    %threenose: contains numwarmnose=3
    %nannose: contains numwarmnose=NaN
    %
    %To create an appropriate soundings data structure, see fullIGRAimp.
    %
    %Version Date: 8/18/17
    %Last major revision: 8/17/17
    %Written by: Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %
    %See also: fullIGRAimp, wnplot
    %
    
sy = 0;
if sy == 1 %Sometimes useful for troubleshooting
    wnoutput = 0; %THIS IS THE INPUT SOUNDINGS STRUCTURE--change this name to whatever variable name applies to the desired input structure
end

% Define matrices of the size of the input
onenose = zeros(1,length(wnoutput)); %One warm nose
twonose = zeros(1,length(wnoutput)); %Two warm nose
threenose = zeros(1,length(wnoutput)); %Three warm nose
nannose = zeros(1,length(wnoutput)); %Greater than three warm nose

fiveg = zeros(1,length(wnoutput)); %Temperature vs geopotential height crosses freezing line five times

%% Classify soundings by numwarmnose
for c = 1:length(wnoutput);
    if length(wnoutput(c).warmnose.gx)==5 %Temperature profile crosses the freezing line five times
        fiveg(c) = 1; %Indices that meet the if condition are ones; others are zeros
    end
    if wnoutput(c).warmnose.numwarmnose==1 %One warm nose
        onenose(c) = 1;
    elseif wnoutput(c).warmnose.numwarmnose==2 %Two warm nose
        twonose(c) = 1;
    elseif wnoutput(c).warmnose.numwarmnose==3 %Three warm nose
        threenose(c) = 1;
    else
        nannose(c) = 1; %These have numwarmnose values higher than 3 and were filtered out in nosedetect.
        %Future versions will treat these in more detail.
    end
end

% Indices for various numbers of noses
[indOne] = find(onenose~=0);
[indTwo] = find(twonose~=0);
[indThree] = find(threenose~=0);
[indNaN] = find(nannose~=0);

[indFiveg] = find(fiveg~=0);

count1 = 1;
count2 = 1;
onenoseFinal = wnoutput(indOne); %Soundings that correspond to the one nose indices

for g = 1:length(onenoseFinal) %Split the one nose soundings into grounded layers and noses aloft
    if onenoseFinal(g).temp(1)>0
        grounded(count1) = onenoseFinal(g); %Grounded noses
        count1 = count1+1;
    else
        aloft(count2) = onenoseFinal(g); %Noses aloft
        count2 = count2+1;
    end
end

% Reset the counters
count1 = 1;
count2 = 1;

twonoseFinal = wnoutput(indTwo); %Soundings that correspond to the two nose indices

for g = 1:length(twonoseFinal) %Split the two nose soundings into cold and warm ground
    if twonoseFinal(g).temp(1)>0
        groundedTwoNose(count1) = twonoseFinal(g); %One grounded, one aloft
        count1 = count1+1;
    elseif twonoseFinal(g).temp(1)<0 %&& twonosefinal(g).temp(2)<0 %Restrict as seen in commented half of line to get more impressive aloft soundings
        aloftTwoNose(count2) = twonoseFinal(g); %Two aloft
        count2 = count2+1;
    end
end

threenoseFinal = wnoutput(indThree); %Soundings that correspond to the three nose indices
%One could potentially split up the three noses into those with cold and
%warm ground scenarios. In practice, this rarely comes up because of how
%few three noses there are--it's almost easier to sort through them by
%hand.

nannoseFinal = wnoutput(indNaN); %Soundings that correspond to the NaN nose indices

fivegFinal = wnoutput(indFiveg); %Soundings that correspond to the five freezing line cross cases
