function cpd = muxCpdCreate(num_inputs, num_states)
% Make a tabular CPD representing a multiplexer. We assume the first
% input parent is the switch variable.

% This file is from pmtk3.googlecode.com

 
function out = mux(parents)
    switch_val = parents(1);
    inputs = parents(2:end);
    out = inputs(switch_val);
end

% switching variable is first parent.
parent_sizes = [num_inputs, num_states * ones(1, num_inputs)];
cpd = deterministicCpdCreate(@mux, 1, parent_sizes, num_states);

end

 