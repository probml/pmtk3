function name = getUsername()
% Return name of current user
% Currently this function is hardcoded to recognize
% a small select group of people :)
dirname = pwd;
if regexp(dirname, 'kpmurphy')
  name = 'kpmurphy'; return;
end
if regexp(dirname, 'emtiyaz')
  name = 'emtiyaz'; return;
end
name = '';
%error(sprintf('could not figure out username from %s', dirname))
end
