function assertTrue(predicate, message, varargin)
% Test a predicate and throw an error, as the caller, if false
% Supports sprintf type inputs. 

% This file is from pmtk3.googlecode.com

if nargin < 2, message = 'assertion error'; end
if ~predicate, 
    throwAsCaller(MException('AssertTrue:Failure', sprintf(message, varargin{:}))); 
end

end
