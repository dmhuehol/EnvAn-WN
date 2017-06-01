# EnvAn-WN
Basic description: MATLAB programs for warm nose sounding analysis

Repository contains functions and scripts in MATLAB used to analyze atmospheric soundings data containing melting layers, or "warm noses." Files were created by Daniel Hueholt at North Carolina State University, and contain any additional authorship information as needed.

Short descriptions of files:

Working:

FWOKXh6: current (5/26/17) version of MATLAB script to process soundings and surface observations data, and produce a variety of data visualizations. Refers to several of the functions in this repository. (Based on a script originally written by Megan Amanatides at NC State)

FWOKXh7: current (6/1/17) version of the FWOKXh line of sounding processing and analysis scripts. This is the first one to head towards the eventual goal of offloading most of the functionality into the auxiliary functions, which are called within this script. Updated 6/1/17 to further move towards this goal.

dewrelh: current (5/31/17) version of MATLAB function to calculate dewpoint and relative humidity from temperature and dewpoint depression.

findsnd: current (6/1/17) version of MATLAB function to find the sounding number of a sounding on a particular date from within a sounding structure. Updated 6/1/17 to use switch/case instead of exist functions; also, code is now commented.

prestogeo: current (5/31/17) version of MATLAB function to calculate geopotential height given pressure and temperature. Includes a variety of bonus options that work with the FWOKXh line, which I wrote with this project in mine. simple_prestogeo was designed to be a bare-bones geopotential height calculator. Equation comes from Durre and Yin (2008) http://journals.ametsoc.org/doi/pdf/10.1175/2008BAMS2603.1 Updated 6/1/17 with better control over display at command window.

simple_prestogeo: current (5/31/17) version of MATLAB function to calculate geopotential height given pressure and temperature. This is a simple calculator with no frills. Equation commes from Durre and Yin (2008) http://journals.ametsoc.org/doi/pdf/10.1175/2008BAMS2603.1

surfconfilter: current (5/31/17) version of MATLAB function to filter soundings data structure based on surface conditions, specifically temperature and relative humidity. Uses a filter settings structure similar to yearfilterfs, which can be designated as surfcon.temp = value and surfcon.relative_humidity = value.

FWOKXskew: current (5/24/17) version of MATLAB function to create a skew-T chart given information from a soundings structure. (Adapted from code originally found at MIT OpenCourseware)

IGRAimpf: current (5/19/17) version of MATLAB function to create a structure of soundings data from raw Integrated Global Radiosonde Archive v1 .dat data. (Based on a function originally written by Megan Amanatides at NC State)

nosedetect: current (6/1/17) version of MATLAB function to separate a soundings data structure into warmnose and nonwarmnose structures, with the warmnose structure also containing a structure with details about the warmnose(s). A little clumsy right now, but noseplotfind is usually preferable anyways.

rhumplot: current (6/1/17) version of MATLAB function to generate a figure with charts of relative humidity (%) vs pressure and relative humidity vs height from input sounding number and sounding data structure. Additionally, takes a guess at the cloud base height and returns this 1x2 array (pressure level, height) as output. rhumplot is called within soundplots--this function only needs to be used if the user does not want other plots.

SkewT: current (5/24/17) version of MATLAB function to generate a skew-T chart given generic humidity, temperature, and pressure vectors. (Adapted from code originally found at MIT OpenCourseware)

surfconfind: current (6/1/17) version of MATLAB function to find row index of Mesowest data table corresponding to a date/time input. Also possesses the ability to return a section of said data table containing the index and its surrounding entries, with the number of surrounding entries controllable by the user. Basically a Mesowest version of findsnd.

levfilters: current (5/19/17) version of MATLAB function to filter out given level types from IGRA v1 soundings data.

soundplots: current (6/1/17) version of MATLAB function to chart soundings given a specific time and date. Updated 6/1/17 to call dewrelh instead of running humidity calculation within function, corrected check for presence of relative humidity in input soundings data structure, and added rhum-P and rhum-z plots.

wnumport: current (5/31/17) version of MATLAB function to create a structure of surface observations data given a raw Mesowest csv file. Now contains a date number within the output structure.

yearfilterfs: current (5/19/17) version of MATLAB function to filter out years from a sounding structure.


In progress:

noseplot: SEE NOSEPLOTFIND

noseplotfind: current (6/1/17) version of MATLAB function to detect and display warmnoses. Currently displays TvP, Tvz, and skew-T charts, and splits the sounding data structure into warmnose and nonwarmnose versions. See "to be added" section near end of help for features which will be added in the near future.

convection: current (5/31/17) version of MATLAB function to find relevant meteorological variables necessary to calculate basic properties relevant to convection and stability. Currently just a skeleton of code from Megan Amanatides's original script.


Nonfunctional:

ESRLn: current (5/31/17) version of MATLAB function to replace IGRA geopotential height data with ESRL geopotential height data. ESRLn is not currently under development, as the geopotential height calculation in FWOKXh6, FWOKXh7, prestogeo, and simple_prestogeo is accurate enough that this does not need to be pursued as a high priority.
