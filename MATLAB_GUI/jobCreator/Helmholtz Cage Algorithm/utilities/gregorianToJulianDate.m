function julianDate = gregorianToJulianDate(...
    year,month,day,hour,minute,second)
%GREGORIANTOJULIANDATE returns the Julian date equivalent of a Gregorian
%calendar date.
%
% Inputs:
% - year:       Four-digit calendar year (1900-2100)
% - month:      Month of the year (1-12)
% - day:        Day of the month (1-31)
% - hour:       Hour of the day (0-11)
% - minute:     Minute of the hour (0-59)
% - second:     Seconds and fractional seconds
%
% Output:
% - julianDate: The interval of time measured in days from the epoch
%               January 1, 4713 B.C.E. 12:00
%
% Reference:
% - Vallado, Fundamentals of Astrodynamics and Applications, 2001,
%   3.5.1 Solar Time and Universal Time, Algorithm 14.
%
% Notes:
% - Valid for the period from March 1, 1900 to February 28, 2100. Its use
%   is restricted because the Julian date is continuous whereas the
%   calendar contains periodic steps through the addition of leap years and
%   seconds.
% - Valid for any time system, for example:
%       - UT1: Universal time 1
%       - TDT: Terrestrial dynamical time
%       - TDB: Barycentric dynamical time (temps dynamic barycentric)
%
%#codegen

julianDate = 367*year ...
    - floor( ( 7*(year + floor( (month+9)/12 ) ) ) / 4 ) ...
    + floor(275*month/9) ...
    + day ...
    + 1721013.5 ...
    + ( (second/60 + minute)/60 + hour)/24;

end
