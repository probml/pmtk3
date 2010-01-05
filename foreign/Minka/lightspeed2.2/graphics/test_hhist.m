% demonstrate use of hhist

figure;
x = sample([0.1 0.2 0.3 0.4], 1000);
hhist(x);

figure;
% verify density for product of indep normals
x = prod(randn(2,100000));
ts = linspace(-1,1,1000);
z = hhist(x, ts);
h = plot(ts, z, ts, besselk(0,abs(ts))*1/pi);
%set(h(2),'LineWidth',2)    
axis_pct
