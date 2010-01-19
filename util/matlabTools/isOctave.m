function b = isOctave()
% Return true if this function is run on Octave, otherwise false.     
     v = ver();
     b = isequal(v(1).Name,'Octave');
end