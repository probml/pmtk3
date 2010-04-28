function answer = isOctave()
% Return true if this function is run on Octave, otherwise false.     
    answer = ~isSubstring('MATLAB', matlabroot, true); 
end