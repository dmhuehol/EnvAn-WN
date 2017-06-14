# EnvAn-WN
Basic description: MATLAB programs for warm nose sounding analysis

Repository contains functions and scripts in MATLAB used to analyze atmospheric soundings data containing melting layers, or "warm noses." Files were created by Daniel Hueholt at North Carolina State University, and contain any additional authorship information as needed.

Short descriptions of files:

Working:

FWOKXh6: current (5/26/17) version of MATLAB script to process soundings and surface observations data, and produce a variety of data visualizations. Refers to several of the functions in this repository. (Based on a script originally written by Megan Amanatides at NC State)

FWOKXh7: current (6/8/17) version of the FWOKXh line of sounding processing and analysis scripts. This is the first one to head towards the eventual goal of offloading most of the functionality into the auxiliary functions, which are called within this script. Updated 6/8/17 with small changes, mostly just fiddly test things to make wnlocplot work.

dewrelh: current (6/13/17) version of MATLAB function to calculate dewpoint and relative humidity from temperature and dewpoint depression. Updated 6/13/17 to standardize the function help format.

findsnd: current (6/14/17) version of MATLAB function to find the sounding number of a sounding on a particular date from within a sounding structure. Updated 6/14/17 to standardize function help format.

prestogeo: current (6/14/17) version of MATLAB function to calculate geopotential height given pressure and temperature. Includes a variety of bonus options that work with the FWOKXh line, which I wrote with this project in mind. simple_prestogeo was designed to be a bare-bones geopotential height calculator. Equation comes from Durre and Yin (2008) http://journals.ametsoc.org/doi/pdf/10.1175/2008BAMS2603.1 Updated 6/14/17 to standardize help format and make small editing changes to the rest of the function.

simple_prestogeo: current (6/14/17) version of MATLAB function to calculate geopotential height given pressure and temperature. This is a simple calculator with no frills. Equation commes from Durre and Yin (2008) http://journals.ametsoc.org/doi/pdf/10.1175/2008BAMS2603.1 Updated 6/14/17 to standardize function help format.

surfconfilter: current (6/14/17) version of MATLAB function to filter soundings data structure based on surface conditions, specifically temperature and relative humidity. Uses a filter settings structure similar to yearfilterfs, which can be designated as surfcon.temp = value and surfcon.relative_humidity = value. Updated 6/14/17 to standardize function help format and clarify some comments.

FWOKXskew: current (6/14/17) version of MATLAB function to create a skew-T chart given information from a soundings structure. (Adapted from code originally found at MIT OpenCourseware). Updated 6/14/17 to standardize the formatting of the function help.

IGRAimpf: current (6/14/17) version of MATLAB function to create a structure of soundings data from raw Integrated Global Radiosonde Archive v1 .dat data. (Based on a function originally written by Megan Amanatides at NC State.) Updated 6/14/17 to standardize the function help format.

IGRAimpfil: current (6/14/17) version of MATLAB function to import IGRA v1 data and output ALL useful sounding structures (filtered, goodfinal, and warmnosesfinal being the most important). Updated 6/14/17 to add help, make input_file a usable input, and remove tic/toc.

nosedetect: current (6/14/17) version of MATLAB function to separate a soundings data structure into warmnose and nonwarmnose structures, with the warmnose structure also containing a structure with details about the warmnose(s). A little clumsy right now, but noseplotfind is usually preferable anyways. Updated 6/14/17 to standardize help format and make small editing changes within the function.

rhumplot: current (6/14/17) version of MATLAB function to generate a figure with charts of relative humidity (%) vs pressure and relative humidity vs height from input sounding number and sounding data structure. Additionally, takes a guess at the cloud base height and returns this 1x2 array (pressure level, height) as output. rhumplot is called within soundplots--this function only needs to be used if the user does not want other plots. Updated 6/14/17 to fix freezing temperature and standardize the help format.

SkewT: current (6/14/17) version of MATLAB function to generate a skew-T chart given generic humidity, temperature, and pressure vectors. (Adapted from code originally found at MIT OpenCourseware.) Updated 6/14/17 to standardize the help format.

surfconfind: current (6/14/17) version of MATLAB function to find row index of Mesowest data table corresponding to a date/time input. Also possesses the ability to return a section of said data table containing the index and its surrounding entries, with the number of surrounding entries controllable by the user. Basically a Mesowest version of findsnd. Updated 6/14/17 to standardize function help format.

levfilters: current (6/13/17) version of MATLAB function to filter out given level types from IGRA v1 soundings data. Updated 6/13/17 to standardize help format and reflect changes in other functions.

soundplots: current (6/14/17) version of MATLAB function to chart soundings given a specific time and date. Updated 6/14/17 to fix freezing temperature, edit comments, and standardize the function help format.

wnumport: current (6/14/17) version of MATLAB function to create a structure of surface observations data given a raw Mesowest csv file. Updated 6/14/17 to standardize function help and make minor editing changes to the function.

yearfilterfs: current (6/14/17) version of MATLAB function to filter out years from a sounding structure. Updated 6/14/17 to standardize function help format.


In progress:

atplot: currently (6/8/17) just a grab bag of plotting loops, originally from FWOKXh7. May be removed eventually, but currently serves as a testing ground for improvements and functionalizations of the remaining plotting sections of FWOKXh7.

convection: current (5/31/17) version of MATLAB function to find relevant meteorological variables necessary to calculate basic properties relevant to convection and stability. Currently just a skeleton of code from Megan Amanatides's original script.

noseplotfind: current (6/14/17) version of MATLAB function to detect and display warmnoses. Currently displays TvP, Tvz, and skew-T charts. See "to be added" section near end of help for features which will be added in the near future. Updated 6/14/17 to reflect the complete splitting of warmnose analysis duties to nosedetect, standardize funciton format, and fix freezing temperature.

WarmNoseMain: current (6/14/17) version of MATLAB script where issues with the altitude plots are being worked out. Will be removed once all issues are worked out, and functionality will be folded into wnaltplot.

wnaltplot: current (6/14/17) version of MATLAB function to display the altitudes of the physical locations of the warmnoses within the atmosphere. Basically, creates a ranged bar graph against time to represent the warmnoses, given a sounding structure containing only warmnose data. Future updates will make aesthetic changes to figures, add ability to plot by year, add commenting and help, filtration by month and surface conditions, and plotting of cloud base.

Nonfunctional:

ESRLn: current (5/31/17) version of MATLAB function to replace IGRA geopotential height data with ESRL geopotential height data. ESRLn is not currently under development, as the geopotential height calculation in FWOKXh6, FWOKXh7, prestogeo, and simple_prestogeo is accurate enough that this does not need to be pursued as a high priority.

wnlocplot: current (6/12/17) version of MATLAB function to display the physical locations (vertically) of warmnoses within the atmosphere. Displays bars representing the upper bound/lower bound/thickness of warmnoses, given a sounding structure containing only warmnose data. DEFUNCT as of 6/12/17, and has been replaced by wnaltplot. No further development of wnlocplot will occur.

External:

datetickzoom: function found online which expands on datetick to update the ticks at different zoom levels. Originally written by Christophe Lauwerys. Link: https://www.mathworks.com/matlabcentral/fileexchange/15029-datetickzoom-automatically-update-dateticks

Images folder:

Now includes relevant images; currently (6/2/17) includes some plots generated by soundplots for the 1/24/2015 event.
