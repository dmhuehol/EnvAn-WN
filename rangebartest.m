%%rangebartest -- script to demonstrate the process of creating a ranged
%bar graph without the use of boxplot.
%Written by: Matthew Miller
%Version Date: 6/12/17
%
%See also wnaltplot, wnaltyearplot
%

testThickTop = [1200 800 900 1000];
testThickBottom = [1000 700 888 500];
testThickDiff=testThickTop-testThickBottom;

figure;
barH=bar(linspace(datenum('20120101','yyyymmdd'),datenum('20120701','yyyymmdd'),4)',cat(2,testThickBottom',testThickDiff'),'stacked');
datetick
set(barH(1),'EdgeColor','none','FaceColor','w');