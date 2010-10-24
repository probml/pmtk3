function [stream, cleanString] = text2stream(string)
% Converts a charachter array to an array of integers
% corresponding to the letters and spaces in the string.

% This file is from pmtk3.googlecode.com


string = lower(string);
letters = double('a':'z');
space  = double(' ');
v = double(lower(string));
alphaMask = (v >= min(letters) & v <= max(letters));
spaceMask = (v == space);
valid =  alphaMask | spaceMask;
v(~valid) = space;
spaceMask = (v == space);
v(alphaMask) = v(alphaMask) - min(letters) + 1;
v(spaceMask) = 27;

stream = v;
alphabet = ['a':'z' ' '];
cleanString = alphabet(stream);
