# EnvAn-WN
Basic description: MATLAB functions and scripts for warm nose sounding analysis.

Repository contains functions and scripts which are designed for use with soundings data with a focus on analysis of warm noses/melting layers. All software was coded in MATLAB 2014a. Files were created by Daniel Hueholt at North Carolina State University, unless otherwise specified.

For suggested bundles to download, see Toolboxes.txt.

Tags: ASOS, clouds, external, filter, IGRA tooolbox, import, in progress, Mesowest toolbox, original, poster, plotting toolbox, removed phase 2, renamed, sounding, surface observations, unused, utilities, warm nose toolbox

NOTE 9/3/17: This is the final push for this project, covering all of the work done over the summer of 2017. Further development will continue in the repository "EnvAn--WN Phase 2".
Poster link: http://www.environmentanalytics.com/pdfsposter/170731_Hueholt_SummerSymposiumPoster.pdf

File descriptions:

ASOSimport: Latest version (8/29/17) of function to create a structure of one-minute Automated Surface Observation System data given an input file.
Tags: surface observations, ASOS, import

atplot: Contains code for all remaining unused figures from Megan Amanatides’s original script. WILL BE REMOVED IN NEXT PUSH.
Tags: unused, original, removed phase 2

cloudbaseplot: Current version (8/29/17) of function to plot cloud base as estimated from sounding relative humidity observations.
Tags: sounding, plotting toolbox, clouds
Requires: dewrelh

convection: Current (5/31/17) version of MATLAB function to find relevant meteorological variables necessary to calculate basic properties relevant to convection and stability. Currently just a code skeleton from Megan Amanatides’s original script.
Tags: unused, original, in progress

datetickzoom: Function which expands on datetick so the ticks update at different zoom levels, originally written by Christophe Lauwerys. Link: https://www.mathworks.com/matlabcentral/fileexchange/15029-datetickzoom-automatically-update-dateticks
Tags: external, warm nose toolbox, utilities, external

dewrelh: Current version (9/1/17) of MATLAB function to calculate dew point and relative humidity from temperature and dew point depression.
Tags: plotting toolbox, IGRA toolbox

ESRLn: Current (5/31/17) version of MATLAB script to replace IGRA geopotential height data with ESRL geopotential height data. No longer necessary, as geopotential heights are now calculated using dewrelh; this is the same equation that ESRL uses to fill out their height data. WILL BE REMOVED IN NEXT PUSH.
Tags: unused, removed phase 2, sounding, import

findsnd: Current version (9/1/17) of MATLAB function to find the sounding number for a particular date and time within a soundings data structure.
Tags: sounding, plotting toolbox, IGRA toolbox, warm nose toolbox

fullIGRAimp: Current version (8/19/17) of MATLAB function to import IGRA v1 data and output ALL useful sounding structures. Renamed from “IGRAimpfil” in 9/3/17 push.
Tags: renamed, sounding, IGRA toolbox, import, filter
Requires: dewrelh, IGRAimpf, timefilter, levfilter, surfconfilter, nosedetect, prestogeo, precipfilter, simple_prestogeo, wnumport

FWOKXh6: Current (5/26/17) version of MATLAB script to process soundings and surface observations data, and produce a variety of data visualizations. Obsolete due to an overall move towards a functionalized workflow. WILL BE REMOVED IN NEXT PUSH.
Tags: removed phase 2

FWOKXh7: Current (6/30/17) and last version of the FWOKXh line of sounding process and analysis scripts. Obsolete due to an overall move towards a functionalized workflow. WILL BE REMOVED IN NEXT PUSH.

IGRAimpf: Current version (9/1/17) of MATLAB function to create a structure of soundings data from raw Integrated Global Radiosonde Archive v1 .dat data. (Based on a function originally written by Megan Amanatides.)
Tags: sounding, import, IGRA toolbox

levfilter: Current version (9/1/17) of MATLAB function to filter out given level types from IGRA v1 soundings data. Renamed from “levfilters” in 9/3/17 push.
Tags: filter, sounding, IGRA toolbox

mesowestDecoder: Current version (8/4/17) of MATLAB function to decode present weather codes from Mesowest data. Renamed from “ASOSdecoder” in 9/3/17 push.
Tags: Mesowest toolbox, surface observations

newtip: Current version (9/1/17) of MATLAB function to create a custom Data Cursor tooltip using variables from within a parent function. Must be nested within another function. This version of newtip is specifically designed to work with wnAllPlot and wnYearPlot, but the method could easily be adapted for any similar circumstance.
Tags: warm nose toolbox, utilities

nosedetect: Current version (8/24/17) of MATLAB function to separate a soundings data structure into warm nose and non warm nose structures, with the warm nose structure containing a nested structure with details about said noses.
Tags: sounding, IGRA toolbox
Requires: findsnd, prestogeo, simple_prestogeo

noseplotfind: Current version (8/17/17) of MATLAB function to detect and display warm noses. Current displays TvP, TvZ, and skew-T charts. See “to be added” section near end of function help for features in development.
Tags: in progress, sounding
Requires: prestogeo

numwarmnose: Current version (8/18/17) of MATLAB script to divide up soundings data by the number and type of warm noses present.
Tags: sounding, in progress, warm nose toolbox

precipfilter: Current version (8/19/17) of MATLAB function to filter warm nose soundings data by the presence of precipitation at the surface, as shown in Mesowest data adjacent in time to the soundings in the input structure.
Tags: surface observations, sounding, IGRA toolbox

prestogeo: Current version (9/1/17) of MATLAB function to calculate geopotential height given pressure and temperature. Includes a variety of bonus options which make it easier to use with other functions; for a bare-bones geopotential height calculator, see simple_prestogeo. Equation comes from Durre and Yin (2008) http://journals.ametsoc.org/doi/pdf/10.1175/2008BAMS2603.1
Tags: sounding, IGRA toolbox

rangebardemo: Demonstration of the “stacked” and “patch" methods to make ranged bar charts. Renamed from “rangebartest” in 9/3/17 push.
Tags: external, utilities, renamed

rhumplot: Current version (9/1/17) of MATLAB function to generate a figure with charts of relative humidity vs pressure and relative humidity vs height from input sounding number and sounding data structure. Additionally, makes a guess at cloud base height.
Tags: plotting toolbox, sounding, clouds

simple_prestogeo: Current version (9/1/17) of MATLAB function to calculate geopotential height given pressure and temperature. This is a no-frills calculator; see prestogeo for a calculator designed to interface with other functions.
Tags: utilities, IGRA toolbox

skewT: Current version (8/4/17) of MATLAB function to generate a skew-T chart given information from a soundings structure. Adapted from code originally found at MIT OpenCourseware. Renamed from “FWOKXskew” in 9/3/17 push.
Tags: plotting toolbox, sounding

skewT_noDew: Current version (8/4/17) of MATLAB function to generate a skew-T chart given humidity, temperature, and pressure vectors. Adapted from code originally found at MIT OpenCourseware. Renamed from “SkewT” in 9/3/17 push. WILL BE REMOVED IN NEXT PUSH.
Tags: removed phase 2

soundplots: Current version (9/3/17) of MATLAB function to generate a variety of figures based on soundings data for a specific time and date.
Tags: sounding, plotting toolbox
Requires: dewrelh, skewT, sounding

surfconfilter: Current version (9/3/17) of MATLAB function to filter soundings data structure based on surface conditions.
Tags: surface observations, IGRA toolbox, filter, sounding

surfconfind: Current version (9/3/17) of MATLAB function to find row index of Mesowest data table corresponding to an input time. Can also return the section of said table which contains the index and its surrounding entries, with the number of surrounding entries controllable by the user.
Tags: surface observations, Mesowest toolbox

timefilter: Current version (8/19/17) of MATLAB function to filter out years and months from a sounding structure.
Tags: sounding, IGRA toolbox

TvZ: Current version (8/19/17) of MATLAB function to plot a temperature-height figure from soundings data given an input time.
Tags: sounding, plotting toolbox

TvZprint: Current version (8/19/17) of MATLAB function to plot a temperature-height figure from soundings data given an input time, with figure settings tuned to be most useful for posters.
Tags: soundings, poster

wnAllPlot: Current version (8/24/17) of MATLAB function to display various kinds of warm nose plots based off a soundings structure containing warm nose data. Uses the stacked method for ranged bar graphs, which causes problems in representing some kinds of warm noses. Renamed from “wnaltplot” in 9/3/17 push.
Tags: sounding, warm nose toolbox, renamed
Requires: newtip, datetickzoom

wnlocplot: Current (6/12/17) version of MATLAB function to display physical locations of warmness within the atmosphere. DEFUNCT as of 6/12/17. Will be removed in following push.
Tags: removed phase 2

wnplot: Current version (8/24/17) of MATLAB function to create warm nose plots for individual soundings given an input time and soundings data. Uses the patch method for ranged bar graphs; accurately displays all warm noses that nosedetect properly represents. Renamed from “wnaltind” in 9/3/17 push.
Tags: sounding, warm nose toolbox
Requires: findsnd

wnplot_poster: Current version (8/24/17) of MATLAB function to create warm nose plots for individual soundings given an input time and soundings data. Uses the patch method for ranged bar graphs; accurately displays all warm noses that nosedetect properly represents. An improved version requiring MATLAB 2014b or later will be released soon. Renamed from “wnaltindposter” in 9/3/17 push.
Tags: sounding, warm nose toolbox, poster
Requires: findsnd

wnumport: Current version (8/28/17) of MATLAB function to create a structure of surface observations data given a raw Mesowest csv file.
Tags: surface observations, IGRA toolbox, Mesowest toolbox

wnYearPlot: Current version (9/3/17) of MATLAB function to create warm nose plots for an input year. Uses the stacked method for ranged bar graphs, which causes problems in representing some kinds of warm noses. Renamed from “wnaltyearplot” in 9/3/17 push.
Tags: sounding, warm nose toolbox
Requires: datetickzoom, newtip
