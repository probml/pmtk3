function assertTrue(predicate,message,varargin)
    
    if nargin < 2, message = 'assertion error'; end
    if ~predicate, throwAsCaller(MException('AssertTrue:Failure',sprintf(message,varargin{:}))); end
    
end