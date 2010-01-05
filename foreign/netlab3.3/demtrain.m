function demtrain(action);
%DEMTRAIN Demonstrate training of MLP network.
%
%	Description
%	DEMTRAIN brings up a simple GUI to show the training of an MLP
%	network on classification and regression problems.  The user should
%	load in a dataset (which should be in Netlab format: see  DATREAD),
%	select the output activation function, the  number of cycles and
%	hidden units and then train the network. The scaled conjugate
%	gradient algorithm is used. A graph shows the evolution of the error:
%	the value is shown  MAX(CEIL(ITERATIONS / 50), 5) cycles.
%
%	Once the network is trained, it is saved to the file MLPTRAIN.NET.
%	The results can then be viewed as a confusion matrix (for
%	classification problems) or a plot of output versus target (for
%	regression problems).
%
%	See also
%	CONFMAT, DATREAD, MLP, NETOPT, SCG
%

%	Copyright (c) Ian T Nabney (1996-2001)

% If run without parameters, initialise gui.
if nargin<1,
  action='initialise';
end;

% Global variable to reference GUI figure
global DEMTRAIN_FIG
% Global array to reference sub-figures for results plots
global DEMTRAIN_RES_FIGS
global NUM_DEMTRAIN_RES_FIGS

if strcmp(action,'initialise'),

  file = '';
  path = '.';
  
  % Create FIGURE
  fig = figure( ...
	'Name', 'Netlab Demo', ...
	'NumberTitle', 'off', ...
	'Menubar', 'none', ...
	'Color', [0.7529 0.7529 0.7529], ...
	'Visible', 'on');
  % Initialise the globals
  DEMTRAIN_FIG = fig;
  DEMTRAIN_RES_FIGS = 0;
  NUM_DEMTRAIN_RES_FIGS = 0;

  % Create GROUP for buttons
  uicontrol(fig, ...
	'Style', 'frame', ...
	'Units', 'normalized', ...
	'Position', [0.03 0.08 0.94 0.22], ...
	'BackgroundColor', [0.5 0.5 0.5]);

  % Create MAIN axis
  hMain = axes( ...
	'Units', 'normalized', ...
	'Position', [0.10 0.5 0.80 0.40], ...
	'XColor', [0 0 0], ...
	'YColor', [0 0 0], ...
	'Visible', 'on');

  % Create static text for FILENAME and PATH
  hFilename = uicontrol(fig, ...
	'Style', 'text', ...
	'Units', 'normalized', ...
	'BackgroundColor', [0.7529 0.7529 0.7529], ...
	'Position', [0.05 0.32 0.90 0.05], ...
	'HorizontalAlignment', 'center', ...
	'String', 'Please load data file.', ...
	'Visible', 'on');
  hPath = uicontrol(fig, ...
	'Style', 'text', ...
	'Units', 'normalized', ...
	'BackgroundColor', [0.7529 0.7529 0.7529], ...
	'Position', [0.05 0.37 0.90 0.05], ...
	'HorizontalAlignment', 'center', ...
	'String', '', ...
	'Visible', 'on');

  % Create NO OF HIDDEN UNITS slider and text
  hSliderText = uicontrol(fig, ...
	'Style', 'text', ...
	'BackgroundColor', [0.5 0.5 0.5], ...
	'Units', 'normalized', ...
	'Position', [0.27 0.12 0.17 0.04], ...
	'HorizontalAlignment', 'right', ...
	'String', 'Hidden Units: 5');
  hSlider = uicontrol(fig, ...
	'Style', 'slider', ...
	'Units', 'normalized', ...
	'Position', [0.45 0.12 0.26 0.04], ...
	'String', 'Slider', ...
	'Min', 1, 'Max', 25, ...
	'Value', 5, ...
	'Callback', 'demtrain slider_moved');

  % Create ITERATIONS slider and text
  hIterationsText = uicontrol(fig, ...
	'Style', 'text', ...
	'BackgroundColor', [0.5 0.5 0.5], ...
	'Units', 'normalized', ...
	'Position', [0.27 0.21 0.17 0.04], ...
	'HorizontalAlignment', 'right', ...
	'String', 'Iterations: 50');
  hIterations = uicontrol(fig, ...
	'Style', 'slider', ...
	'Units', 'normalized', ...
	'Position', [0.45 0.21 0.26 0.04], ...
	'String', 'Slider', ...
	'Min', 10, 'Max', 500, ...
	'Value', 50, ...
	'Callback', 'demtrain iterations_moved');

  % Create ACTIVATION FUNCTION popup and text
  uicontrol(fig, ...
	'Style', 'text', ...
	'BackgroundColor', [0.5 0.5 0.5], ...
	'Units', 'normalized', ...
	'Position', [0.05 0.20 0.20 0.04], ...
	'HorizontalAlignment', 'center', ...
	'String', 'Activation Function:');
  hPopup = uicontrol(fig, ...
	'Style', 'popup', ...
	'Units', 'normalized', ...
	'Position' , [0.05 0.10 0.20 0.08], ...
	'String', 'Linear|Logistic|Softmax', ...
	'Callback', '');

  % Create MENU
  hMenu1 = uimenu('Label', 'Load Data file...', 'Callback', '');
  uimenu(hMenu1, 'Label', 'Select training data file', ...
	'Callback', 'demtrain get_ip_file');
  hMenu2 = uimenu('Label', 'Show Results...', 'Callback', '');
  uimenu(hMenu2, 'Label', 'Show classification results', ...
	'Callback', 'demtrain classify');
  uimenu(hMenu2, 'Label', 'Show regression results', ...
	'Callback', 'demtrain predict');
  
  % Create START button
  hStart = uicontrol(fig, ...
	'Units', 'normalized', ...
	'Position' , [0.75 0.2 0.20 0.08], ...
	'String', 'Start Training', ...
	'Enable', 'off',...
	'Callback', 'demtrain start');

  % Create CLOSE button
  uicontrol(fig, ...
	'Units', 'normalized', ...
	'Position' , [0.75 0.1 0.20 0.08], ...
	'String', 'Close', ...
	'Callback', 'demtrain close');

  % Save handles of important UI objects
  hndlList = [hSlider hSliderText hFilename hPath hPopup ...
      hIterations hIterationsText hStart];
  set(fig, 'UserData', hndlList);
  % Hide window from command line
  set(fig, 'HandleVisibility', 'callback');

  
elseif strcmp(action, 'slider_moved'),

  % Slider has been moved. 
  
  hndlList = get(gcf, 'UserData');
  hSlider = hndlList(1);
  hSliderText = hndlList(2);

  val = get(hSlider, 'Value');
  if rem(val, 1) < 0.5,  % Force up and down arrows to work!
	val = ceil(val);
  else
	val = floor(val);
  end;
  set(hSlider, 'Value', val);
  set(hSliderText, 'String', ['Hidden Units: ' int2str(val)]);

  
elseif strcmp(action, 'iterations_moved'),

  % Slider has been moved. 
  
  hndlList = get(gcf, 'UserData');
  hSlider = hndlList(6);
  hSliderText = hndlList(7);

  val = get(hSlider, 'Value');
  set(hSliderText, 'String', ['Iterations: ' int2str(val)]);

elseif strcmp(action, 'get_ip_file'),

  % Get data file button pressed.
  
  hndlList = get(gcf, 'UserData');

  [file, path] = uigetfile('*.dat', 'Get Data File', 50, 50);

  if strcmp(file, '') | file == 0,
    set(hndlList(3), 'String', 'No data file loaded.');
    set(hndlList(4), 'String', '');
  else
    set(hndlList(3), 'String', file);
    set(hndlList(4), 'String', path);
  end;
  
  % Enable training button
  set(hndlList(8), 'Enable', 'on');

  set(gcf, 'UserData', hndlList);
  
elseif strcmp(action, 'start'),

  % Start training
  
  % Get handles of and values from UI objects
  hndlList = get(gcf, 'UserData');
  hSlider = hndlList(1); % 				No of hidden units
  hIterations = hndlList(6); 
  iterations = get(hIterations, 'Value');
  
  hFilename = hndlList(3);	% 			Data file name
  filename = get(hFilename, 'String');

  hPath = hndlList(4);	% 				Data file path
  path = get(hPath, 'String');

  hPopup = hndlList(5);		% 			Activation function
  if get(hPopup, 'Value') == 1,
	act_fn = 'linear';
  elseif get(hPopup, 'Value') == 2,
	act_fn = 'logistic';
  else
	act_fn = 'softmax';
  end;
  nhidden = get(hSlider, 'Value');

  % Check data file exists
  if fopen([path '/' filename]) == -1,
	errordlg('Training data file has not been selected.', 'Error');
  else
	% Load data file
	[x,t,nin,nout,ndata] = datread([path filename]);
	
	% Call MLPTRAIN function repeatedly, while drawing training graph.
	figure(DEMTRAIN_FIG);
	hold on;
	
	title('Training - please wait.');
	
	% Create net and find initial error
	net = mlp(size(x, 2), nhidden, size(t, 2), act_fn);
	% Initialise network with inverse variance of 10
	net = mlpinit(net, 10);
	error = mlperr(net, x, t);
	% Work out reporting step: should be sufficiently big to let training
	% algorithm have a chance
	step = max(ceil(iterations / 50), 5);

	% Refresh and rescale axis.
	cla;
	max = error;
	min = max/10;
	set(gca, 'YScale', 'log');
	ylabel('log Error');
	xlabel('No. iterations');
	axis([0 iterations min max+1]);
	iold = 0;
	errold = error;
	% Plot circle to show error of last iteration
	% Setting erase mode to none prevents screen flashing during 
	% training
	plot(0, error, 'ro', 'EraseMode', 'none');
	hold on
	drawnow; % Force redraw
	for i = step-1:step:iterations,
	  [net, error] = mlptrain(net, x, t, step);
	  % Plot line from last point to new point.
	  line([iold i], [errold error], 'Color', 'r', 'EraseMode', 'none');
	  iold = i;
	  errold = error;
	  
	  % If new point off scale, redraw axes.
	  if error > max,
	    max = error;
	    axis([0 iterations min max+1]);
	  end;
	  if error < min
	    min = error/10;
	    axis([0 iterations min max+1]);
	  end
	  % Plot circle to show error of last iteration
	  plot(i, error, 'ro', 'EraseMode', 'none');
	  drawnow; % Force redraw
	end;
	save mlptrain.net net
	zoom on;

	title(['Training complete. Final error=', num2str(error)]);
	
  end;

elseif strcmp(action, 'close'),
  
  % Close all the figures we have created
  close(DEMTRAIN_FIG);
  for n = 1:NUM_DEMTRAIN_RES_FIGS
    if ishandle(DEMTRAIN_RES_FIGS(n))
      close(DEMTRAIN_RES_FIGS(n));
    end
  end

elseif strcmp(action, 'classify'),
  
  if fopen('mlptrain.net') == -1,
	errordlg('You have not yet trained the network.', 'Error');
  else
  
	hndlList = get(gcf, 'UserData');
	filename = get(hndlList(3), 'String');
	path = get(hndlList(4), 'String');
	[x,t,nin,nout,ndata] = datread([path filename]);
	load mlptrain.net net -mat
	y = mlpfwd(net, x);
	
	% Save results figure so that it can be closed later
	NUM_DEMTRAIN_RES_FIGS = NUM_DEMTRAIN_RES_FIGS + 1;
	DEMTRAIN_RES_FIGS(NUM_DEMTRAIN_RES_FIGS)=conffig(y,t);
	
  end;

elseif strcmp(action, 'predict'),
  
  if fopen('mlptrain.net') == -1,
	errordlg('You have not yet trained the network.', 'Error');
  else
  
	hndlList = get(gcf, 'UserData');
	filename = get(hndlList(3), 'String');
	path = get(hndlList(4), 'String');
	[x,t,nin,nout,ndata] = datread([path filename]);
	load mlptrain.net net -mat
	y = mlpfwd(net, x);
	
	for i = 1:size(y,2),
	  % Save results figure so that it can be closed later
	  NUM_DEMTRAIN_RES_FIGS = NUM_DEMTRAIN_RES_FIGS + 1;
	  DEMTRAIN_RES_FIGS(NUM_DEMTRAIN_RES_FIGS) = figure;
	  hold on;
	  title(['Output no ' num2str(i)]);
	  plot([0 1], [0 1], 'r:');
	  plot(y(:,i),t(:,i), 'o');
	  hold off;
	end;
  end;
	
end;