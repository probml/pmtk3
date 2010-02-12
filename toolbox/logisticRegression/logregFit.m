function model = logregFit(X, y, lambda, includeOffset)
  
    switch nargin
        case 2, args = {};
        case 3, args = {lambda};
        case 4, args = {lambda, includeOffset};
    end
    model = logregFitL2(X, y, args{:});
end