function Xrecon = rbmReconstruct(model, X)

up = rbmVtoH(model, X);
Xrecon = rbmHtoV(model, up);
end
