function [geoheight] = simple_prestogeo(p1,pz,t1,tz)
%%simple_prestogeo
    %Function to quickly calculate the geopotential
    %thickness given two pressures and two corresponding temperatures. Can be
    %easily used as a geopotential height calculator if the first pressure and
    %temperature input are the surface pressure and temperature. See prestogeo
    %for a more complicated, but more flexible, version of this function.
    %
    %General form: [geoheight] = simple_prestogeo(p1,pz,t1,tz)
    %
    %Output:
    %geoheight: geopotential height in kilometers
    %
    %Inputs: 
    %p1: pressure in hPa at lower altitude (higher pressure) - use surface pressure if
    %calculating geopotential height as opposed to level thickness
    %pz: pressure in hPa at altitude in question (lower pressure)
    %t1: temperature in deg C (conversion to K is built-in) at the t1 level
    %tz: temperature in deg C (conversion to K is built-in) at the tz level
    %
    %Version Date: 9/1/17
    %Last major revision: 5/31/17
    %Written by: Daniel Hueholt
    %North Carolina State University
    %Undergraduate Research Assistant at Environment Analytics
    %
    %See also prestogeo
    %

R = 287.75; %J/(K*kg) ideal gas constant
grav = 9.81; %m/s^2 acceleration of gravity
geoheight = (R/grav*(((t1+273.15)+(tz+273.15))/2).*log(p1./pz))/1000; %Equation comes from Durre and Yin (2008) http://journals.ametsoc.org/doi/pdf/10.1175/2008BAMS2603.1
end
