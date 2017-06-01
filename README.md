# EnvAn-WN
Basic description: MATLAB programs for warm nose sounding analysis

Repository contains functions and scripts in MATLAB used to analyze atmospheric soundings data containing melting layers, or "warm noses." Files were created by Daniel Hueholt at North Carolina State University, and contain any additional authorship information as needed.

Short descriptions of files:

Working:

FWOKXh6: current (5/26/17) version of MATLAB script to process soundings and surface observations data, and produce a variety of data visualizations. Refers to several of the functions in this repository. (Based on a script originally written by Megan Amanatides at NC State)

FWOKXh7: current (5/31/17) version of the FWOKXh line of sounding processing and analysis scripts. This is the first one to head towards the eventual goal of offloading most of the functionality into the auxiliary functions, which are called within this script.

dewrelh: current (5/31/17) version of MATLAB function to calculate dewpoint and relative humidity from temperature and dewpoint depression.

findsnd: current (5/31/17) version of MATLAB function to find the sounding number of a sounding on a particular date from within a sounding structure.

prestogeo: current (5/31/17) version of MATLAB function to calculate geopotential height given pressure and temperature. Includes a variety of bonus options that work with the FWOKXh line, which I wrote with this project in mine. simple_prestogeo was designed to be a bare-bones geopotential height calculator. Equation comes from Durre and Yin (2008) http://journals.ametsoc.org/doi/pdf/10.1175/2008BAMS2603.1

simple_prestogeo: current (5/31/17) version of MATLAB function to calculate geopotential height given pressure and temperature. This is a simple calculator with no frills. Equation commes from Durre and Yin (2008) http://journals.ametsoc.org/doi/pdf/10.1175/2008BAMS2603.1

surfconfilter: current (5/31/17) version of MATLAB function to filter soundings data structure based on surface conditions, specifically temperature and relative humidity. Uses a filter settings structure similar to yearfilterfs, which can be designated as surfcon.temp = value and surfcon.relative_humidity = value.

FWOKXskew: current (5/24/17) version of MATLAB function to create a skew-T chart given information from a soundings structure. (Adapted from code originally found at MIT OpenCourseware)

IGRAimpf: current (5/19/17) version of MATLAB function to create a structure of soundings data from raw Integrated Global Radiosonde Archive v1 .dat data. (Based on a function originally written by Megan Amanatides at NC State)

SkewT: current (5/24/17) version of MATLAB function to generate a skew-T chart given generic humidity, temperature, and pressure vectors. (Adapted from code originally found at MIT OpenCourseware)

levfilters: current (5/19/17) version of MATLAB function to filter out given level types from IGRA v1 soundings data.

soundplots: current (5/26/17) version of MATLAB function to chart soundings given a specific time and date.

wnumport: current (5/31/17) version of MATLAB function to create a structure of surface observations data given a raw Mesowest csv file. Now contains a date number within the output structure.

yearfilterfs: current (5/19/17) version of MATLAB function to filter out years from a sounding structure.


In progress:

noseplot: current (5/31/17) version of MATLAB function to generate TvP, Tvz, and skew-T figures from a sounding structure. Currently also contains a great deal of other figures which will be offloaded to another function. "To be added" section within the comments at the beginning of the file details planned additions in the near future (within the next couple of weeks).

convection: current (5/31/17) version of MATLAB function to find relevant meteorological variables necessary to calculate basic properties relevant to convection and stability. Currently just a skeleton of code from Megan Amanatides's original script.


Nonfunctional:

ESRLn: current (5/31/17) version of MATLAB function to replace IGRA geopotential height data with ESRL geopotential height data. ESRLn is not currently under development, as the geopotential height calculation in FWOKXh6, FWOKXh7, prestogeo, and simple_prestogeo is accurate enough that this does not need to be pursued as a high priority.
