function simulatedAnnealingDemo2d()

[XX, YY]=meshgrid(1:49,1:49);
f = exp(-energySurface); % 49x49 grid 

% find maximum peak by exhaustive search
M = max(f(:)); % 8.0752
[row,col] = find(f==M); % max  row 38, col 25
fprintf('Search: max height = %5.3f at (%d, %d)\n', M, row, col);

% simulated annealing
setSeed(2);
xinit = [35,25];
    
Sigma_prop = 2^2 * eye(2); %2^2 = variance
Nsamples  = 1000;
opts = struct(...
    'proposal', @(x) (x+(gaussSample(zeros(2,1), Sigma_prop, 1))), ...
    'maxIter', Nsamples, ...
    'minIter', Nsamples, ...
    'temp', @(T,iter) (0.995*T), ...
    'verbose', 0);

% find minimum energy (-ve peaks) 
[xopt, fval, samples, energies, acceptRate, temp] =  ...
    simAnneal(@energy, xinit, opts);

fprintf('SA: max value = %5.3f at (%5.3f, %5.3f)\n', -fval, xopt(1), xopt(2));

figure; plot(temp); title('temperature vs iteration');
printPmtkFigure('sim_anneal_temp_vs_time');

figure; plot(energies); title('energy vs iteration')
printPmtkFigure('sim_anneal_energy_vs_time');


% plot the histogram of samples at K time points during evolution
N_bins = 20; % otherwise the image file gets too large
Nsamples = size(samples, 1);
K = 3;
Ns = round(linspace(100, Nsamples, K));
Ns = [100, 300, 600];
for i=1:length(Ns)
    T = Ns(i); % iteration
    temperature = temp(T);
    figure;
    %hist3(samples(1:T,:), [N_bins N_bins], 'FaceAlpha', 0.65);
    counts = hist3(samples(1:T,:), {1:50, 1:50}, 'FaceAlpha', 0.65);
    bar3(counts);
    xlabel('x'); ylabel('y')
    %view(-37,34);
    title(sprintf('iteration %d, temperature %5.3f', T, temperature));
    set(get(gca, 'child'), 'FaceColor', 'interp', 'CDataMode', 'auto');
    printPmtkFigure(sprintf('sim_anneal_samples%d', i));  

    ft = exp(-energySurface/temperature);
    figure;
    surf(ft); 
    %surf(XX,YY,ft); 
    %surf(YY,XX,ft);
    title(sprintf('iteration %d, temperature %5.3f', T, temperature));
    xlabel('x'); ylabel('y')
    printPmtkFigure(sprintf('sim_annealing_surface%d', i));
end

keyboard


    function z = energySurface()
        % scaled version of peaks function
    dx = 1/8;
    [x,y] = meshgrid(-3:dx:3);
    z =  3*(1-x).^2.*exp(-(x.^2) - (y+1).^2) ...
       - 10*(x/5 - x.^3 - y.^5).*exp(-x.^2-y.^2) ...
       - 1/3*exp(-(x+1).^2 - y.^2);
     z = z/10;
    end

   function  p = energy(x)
    Z = energySurface;
    r = round(x(1)); c = round(x(2));
    if r >= 1 && r <= size(Z,1) && c >= 1 && c <= size(Z,2)
        p = Z(r,c);
    else
        p = inf; % invalid
    end
    end

end

