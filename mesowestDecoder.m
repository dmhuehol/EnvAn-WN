%%mesowestDecoder
    %This function is simply the decoding section of wnumport, split off
    %into its own function. It translates a given Mesowest code into
    %individual codes and descriptions, as described by the Mesowest
    %documentation at:
    %https://blog.synopticlabs.org/blog/2016/09/26/weather-condition-codes.html
    %
    %General form: [split,decoded] = mesowestDecoder(tcode)
    %
    %Outputs:
    %split: the combined code split into up to three individual condition codes
    %decoded: the English translations of the condition codes
    %
    %Input:
    %tcode: a single Mesowest weather condition code
    %
    %Version date: 8/4/17
    %Last major update: 8/4/17
    %Written by: Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %

function [split,decoded] = mesowestDecoder(tcode)
tcode1 = floor(tcode/6400); %this is the first condition
tcode2 = floor((tcode-tcode1*6400)/80); %this is the second condition
tcode3 = tcode-tcode1*6400-tcode2*80; %this is the third condition
tcodecat = [tcode1 tcode2 tcode3];
decoded = cell(1,3);
for g = 1:3
if isnan(tcodecat(g))==1
    decoded{g} = 'No reading';
elseif tcodecat(g)==Inf
    decoded{g} = 'No reading (added field)';
elseif tcodecat(g)==0
    decoded{g} = 'No reading';
elseif tcodecat(g)==1
    decoded{g} = 'Moderate rain';
elseif tcodecat(g)==2
    decoded{g} = 'Moderate drizzle';
elseif tcodecat(g)==3
    decoded{g} = 'Moderate snow';
elseif tcodecat(g)==4
    decoded{g} = 'Moderate hail';
elseif tcodecat(g)==5
    decoded{g} = 'Thunder';
elseif tcodecat(g)==6
    decoded{g} = 'Haze';
elseif tcodecat(g)==7
    decoded{g} = 'Smoke';
elseif tcodecat(g)==8
    decoded{g} = 'Dust';
elseif tcodecat(g)==9
    decoded{g} = 'Fog';
elseif tcodecat(g)==10
    decoded{g} = 'Squalls';
elseif tcodecat(g)==11
    decoded{g} = 'Volcanic ash';
elseif tcodecat(g)==12
    decoded{g} = 'No reading';
elseif tcodecat(g)==13
    decoded{g} = 'Light rain';
elseif tcodecat(g)==14
    decoded{g} = 'Heavy rain';
elseif tcodecat(g)==15
    decoded{g} = 'Moderate freezing rain';
elseif tcodecat(g)==16
    decoded{g} = 'Moderate rain shower';
elseif tcodecat(g)==17
    decoded{g} = 'Light drizzle';
elseif tcodecat(g)==18
    decoded{g} = 'Heavy drizzle';
elseif tcodecat(g)==19
    decoded{g} = 'Freezing drizzle';
elseif tcodecat(g)==20
    decoded{g} = 'Light snow';
elseif tcodecat(g)==21
    decoded{g} = 'Heavy snow';
elseif tcodecat(g)==22
    decoded{g} = 'Moderate snow shower';
elseif tcodecat(g)==23
    decoded{g} = 'Moderate ice pellets';
elseif tcodecat(g)==24
    decoded{g} = 'Moderate snow grains';
elseif tcodecat(g)==25
    decoded{g} = 'Moderate snow pellets';
elseif tcodecat(g)==26
    decoded{g} = 'Light hail';
elseif tcodecat(g)==27
    decoded{g} = 'Heavy hail';
elseif tcodecat(g)==28
    decoded{g} = 'Light thunder';
elseif tcodecat(g)==29
    decoded{g} = 'Heavy thunder';
elseif tcodecat(g)==30
    decoded{g} = 'Ice fog';
elseif tcodecat(g)==31
    decoded{g} = 'Ground fog';
elseif tcodecat(g)==32
    decoded{g} = 'Blowing snow';
elseif tcodecat(g)==33
    decoded{g} = 'Blowing dust';
elseif tcodecat(g)==34
    decoded{g} = 'Blowing spray';
elseif tcodecat(g)==35
    decoded{g} = 'Blowing sand';
elseif tcodecat(g)==36
    decoded{g} = 'Moderate ice crystals';
elseif tcodecat(g)==37
    decoded{g} = 'Ice needles';
elseif tcodecat(g)==38
    decoded{g} = 'Small hail';
elseif tcodecat(g)==39
    decoded{g} = 'Smoke, haze';
elseif tcodecat(g)==40
    decoded{g} = 'Dust whirls';
elseif tcodecat(g)==41
    decoded{g} = 'Unknown precipitation';
elseif tcodecat(g)==42
    decoded{g} = 'Unknown precipitation';
elseif tcodecat(g)==43
    decoded{g} = 'Unknown precipitation';
elseif tcodecat(g)==44
    decoded{g} = 'Unknown precipitation';
elseif tcodecat(g)==45
    decoded{g} = 'Unknown precipitation';
elseif tcodecat(g)==46
    decoded{g} = 'Unknown precipitation';
elseif tcodecat(g)==47
    decoded{g} = 'Unknown precipitation';
elseif tcodecat(g)==48
    decoded{g} = 'Unknown precipitation';
elseif tcodecat(g)==49
    decoded{g} = 'Light freezing rain';
elseif tcodecat(g)==50
    decoded{g} = 'Heavy freezing rain';
elseif tcodecat(g)==51
    decoded{g} = 'Light rain shower';
elseif tcodecat(g)==52
    decoded{g} = 'Heavy rain shower';
elseif tcodecat(g)==53
    decoded{g} = 'Light freezing drizzle';
elseif tcodecat(g)==54
    decoded{g} = 'Heavy freezing drizzle';
elseif tcodecat(g)==55
    decoded{g} = 'Light snow shower';
elseif tcodecat(g)==56
    decoded{g} = 'Heavy snow shower';
elseif tcodecat(g)==57
    decoded{g} = 'Light ice pellets';
elseif tcodecat(g)==58
    decoded{g} = 'Heavy ice pellets';
elseif tcodecat(g)==59
    decoded{g} = 'Light snow grains';
elseif tcodecat(g)==60
    decoded{g} = 'Heavy snow grains';
elseif tcodecat(g)==61
    decoded{g} = 'Light snow pellets';
elseif tcodecat(g)==62
    decoded{g} = 'Heavy snow pellets';
elseif tcodecat(g)==63
    decoded{g} = 'Moderate ice pellet shower';
elseif tcodecat(g)==64
    decoded{g} = 'Light ice crystals';
elseif tcodecat(g)==65
    decoded{g} = 'Heavy ice crystals';
elseif tcodecat(g)==66
    decoded{g} = 'Moderate thundershower';
elseif tcodecat(g)==67
    decoded{g} = 'Snow pellet shower';
elseif tcodecat(g)==68
    decoded{g} = 'Heavy blowing dust';
elseif tcodecat(g)==69
    decoded{g} = 'Heavy blowing sand';
elseif tcodecat(g)==70
    decoded{g} = 'Heavy blowing snow';
elseif tcodecat(g)==71
    decoded{g} = 'No reading';
elseif tcodecat(g)==72
    decoded{g} = 'No reading';
elseif tcodecat(g)==73
    decoded{g} = 'No reading';
elseif tcodecat(g)==74
    decoded{g} = 'No reading';
elseif tcodecat(g)==75
    decoded{g} = 'Light ice pellet shower';
elseif tcodecat(g)==76
    decoded{g} = 'Heavy ice pellet shower';
elseif tcodecat(g)==77
    decoded{g} = 'Light rain thundershower';
elseif tcodecat(g)==78
    decoded{g} = 'Heavy rain thundershower';
elseif tcodecat(g)==79
    decoded{g} = 'No reading';
else
    disp('Unknown code!') %This likely means something has gone wrong, as all 79 codes from the Mesowest documentation are implemented
    disp(dr,dc) %index of unknown code
end

split = [tcode1 tcode2 tcode3];
end