%preallocation
onenose = zeros(1,length(warmnosesfinal));
twonose = zeros(1,length(warmnosesfinal));
threenose = zeros(1,length(warmnosesfinal));
nannose = zeros(1,length(warmnosesfinal));

fiveg = zeros(1,length(warmnosesfinal));

%classify by number
for c = 1:2026
    if length(warmnosesfinal(c).warmnose.gx)==5
        fiveg(c) = 1;
    end
    if warmnosesfinal(c).warmnose.numwarmnose==1
        onenose(c) = 1;
    elseif warmnosesfinal(c).warmnose.numwarmnose==2
        twonose(c) = 1;
    elseif warmnosesfinal(c).warmnose.numwarmnose==3
        threenose(c) = 1;
    else
        nannose(c) = 1; %these have numwarmnose values higher than 3 and were filtered out in nosedetect.
        %Future versions will treat these in more detail.
    end
end

%indices for various numbers of noses
[indOne] = find(onenose~=0);
[indTwo] = find(twonose~=0);
[indThree] = find(threenose~=0);
[indNaN] = find(nannose~=0);

[indFiveg] = find(fiveg~=0);

onenosefinal = warmnosesfinal(indOne);
twonosefinal = warmnosesfinal(indTwo);
threenosefinal = warmnosesfinal(indThree);
nannosefinal = warmnosesfinal(indNaN);

fivegfinal = warmnosesfinal(indFiveg);
