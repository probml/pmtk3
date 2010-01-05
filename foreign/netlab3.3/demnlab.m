function demnlab(action);
%DEMNLAB A front-end Graphical User Interface to the demos
%
%	Description
%	This function will start a user interface allowing the user to select
%	different demonstration functions to view. The demos are divided into
%	4 groups, with the demo being executed by selecting the desired
%	option from a pop-up menu.
%
%	See also
%

%	Copyright (c) Ian T Nabney (1996-2001)

% If run without parameters, initialise gui.
if nargin<1,
	action='initialise';
end;

if strcmp(action,'initialise'),

  % Create figure
  fig = figure( ...
    'Name', 'Netlab Demos', ...
    'NumberTitle', 'off', ...
    'Color', [0.7529 0.7529 0.7529], ...
    'Visible', 'on');
  
  % Create GROUPS
  % Bottom of demo buttons
  group1_bot = 0.20;
  group1_top = 0.75;
  uicontrol(fig, ...
    'Style', 'frame', ...
    'Units', 'normalized', ...
    'Position', [0.03 group1_bot 0.94 group1_top - group1_bot], ...
    'BackgroundColor', [0.5 0.5 0.5]);

  % Bottom of help and close buttons
  group2_bot = 0.04;
  uicontrol(fig, ...
    'Style', 'frame', ...
    'Units', 'normalized', ...
    'Position', [0.03 group2_bot 0.94 0.12], ...
    'BackgroundColor', [0.5 0.5 0.5]);

  % Draw title
  hLogoAxis = axes( ...
    'Units', 'normalized', ...
    'Position', [0.05 0.82 0.90 0.14], ...
    'Box', 'off', ...
    'XColor', [0 0 0], ...
    'YColor', [0 0 0], ...
    'Visible', 'on');

  load netlogo;			% load image and colour map
  colormap(netcmap(1:3,:));	% change colour map: don't need many entries
  image(nlogo);			% draw logo
  axis('image');		% ensures pixels on axis are square
  axis off;			% turn axes off

  % Create static text
  uicontrol(fig, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'BackgroundColor', [0.5 0.5 0.5], ...
    'Position', [0.05 group1_top-0.1 0.90 0.08], ...
    'String', 'Select demo to run:');

  % First row text offset
  tRow1Offset = 0.14;
  % Offset between text and button
  TBoffset = 0.07;
  % First row button offset
  bRow1Offset = tRow1Offset+TBoffset;
  % ONE text
  uicontrol(fig, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'BackgroundColor', [0.5 0.5 0.5], ...
    'Position', [0.08 group1_top-tRow1Offset 0.36 0.05], ...
    'String', 'Regression');
  
  popup1str(1) = {'Select Option'};
  popup1str(2) = {'Multi-Layer Perceptron'};
  popup1str(3) = {'Radial Basis Function'};
  popup1str(4) = {'Mixture Density Network'};
  % ONE popup
  hPop1 = uicontrol(fig, ...
    'Style','popup', ...
    'Units','normalized', ...
    'String', popup1str, ...
    'Position', [0.08 group1_top-bRow1Offset 0.36 0.08], ...
    'BackgroundColor', [0.7 0.7 0.7], ...
    'Callback', 'demnlab popup1');

  % TWO text
  uicontrol(fig, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'BackgroundColor', [0.5 0.5 0.5], ...
    'Position', [0.56 group1_top-tRow1Offset 0.36 0.05], ...
    'String', 'Classification');
  
  popup2str(1) = popup1str(1);
  popup2str(2) = {'Generalised Linear Model (2 class)'};
  popup2str(3) = {'Generalised Linear Model (3 class)'};
  popup2str(4) = {'Multi-Layer Perceptron'};
  popup2str(5) = {'K nearest neighbour'};
  % TWO popup
  hPop2 = uicontrol(fig, ...
    'Style','popup', ...
    'Units','normalized', ...
    'String', popup2str, ...
    'Position', [0.56 group1_top-bRow1Offset 0.36 0.08], ...
    'BackgroundColor', [0.7 0.7 0.7], ...
    'Callback', 'demnlab popup2');
  
  tRow2Offset = 0.30;
  bRow2Offset = tRow2Offset+TBoffset;
  % THREE text
  uicontrol(fig, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'BackgroundColor', [0.5 0.5 0.5], ...
    'Position', [0.08 group1_top - tRow2Offset 0.36 0.05], ...
    'String', 'Density Modelling and Clustering'); 
  
  popup3str(1) = popup1str(1);
  popup3str(2) = {'Gaussian Mixture (EM training)'};
  popup3str(3) = {'Gaussian Mixture (spherical)'};
  popup3str(4) = {'Gaussian Mixture (diagonal)'};
  popup3str(5) = {'Gaussian Mixture (full)'};
  popup3str(6) = {'Neuroscale'};
  popup3str(7) = {'GTM (EM training)'};
  popup3str(8) = {'GTM (visualisation)'};
  popup3str(9) = {'K-means clustering'};
  popup3str(10) = {'Self-Organising Map'};
  % TWO popup
  % THREE popup
  hPop3 = uicontrol(fig, ...
    'Style','popup', ...
    'Units','normalized', ...
    'String', popup3str, ...
    'Position', [0.08 group1_top - bRow2Offset 0.36 0.08], ...
    'BackgroundColor', [0.7 0.7 0.7], ...
    'Callback', 'demnlab popup3');
  
  % FOUR text
  uicontrol(fig, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'BackgroundColor', [0.5 0.5 0.5], ...
    'Position', [0.56 group1_top - tRow2Offset 0.36 0.05], ...
    'String', 'Bayesian Methods');
  
  popup4str(1) = popup1str(1);
  popup4str(2) = {'Sampling the MLP Prior'};
  popup4str(3) = {'Evidence Approximation for MLP'};
  popup4str(4) = {'Evidence Approximation for RBF'};
  popup4str(5) = {'Evidence Approximation in Classification'};
  popup4str(6) = {'ARD for MLP'};
  popup4str(7) = {'Sampling the GP Prior'};
  popup4str(8) = {'GPs for Regression'};
  popup4str(9) = {'ARD for GP'};
  % FOUR popup
  hPop4 = uicontrol(fig, ...
    'Style','popup', ...
    'Units','normalized', ...
    'String', popup4str, ...
    'Position', [0.56 group1_top - bRow2Offset 0.36 0.08], ...
    'BackgroundColor', [0.7 0.7 0.7], ...
    'Callback', 'demnlab popup4');
  
  
  tRow3Offset = 0.45;
  bRow3Offset = tRow3Offset+TBoffset;
  % FIVE text
  uicontrol(fig, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'BackgroundColor', [0.5 0.5 0.5], ...
    'Position', [0.08 group1_top - tRow3Offset 0.36 0.05], ...
    'String', 'Optimisation and Visualisation'); 
  
  popup5str(1) = popup1str(1);
  popup5str(2) = {'Algorithm Comparison'};
  popup5str(3) = {'On-line Gradient Descent'};
  popup5str(4) = {'Hinton Diagrams'};
  % FIVE popup
  hPop5 = uicontrol(fig, ...
    'Style','popup', ...
    'Units','normalized', ...
    'String',popup5str, ...
    'Position', [0.08 group1_top - bRow3Offset 0.36 0.08], ...
    'BackgroundColor', [0.7 0.7 0.7], ...
    'Callback', 'demnlab popup5');
  
  % SIX text
  uicontrol(fig, ...
    'Style', 'text', ...
    'Units', 'normalized', ...
    'BackgroundColor', [0.5 0.5 0.5], ...
    'Position', [0.56 group1_top - tRow3Offset 0.36 0.05], ...
    'String', 'Sampling');
  
  popup6str(1) = popup1str(1);
  popup6str(2) = {'Sampling a Gaussian'};
  popup6str(3) = {'MCMC sampling (Metropolis)'};
  popup6str(4) = {'Hybrid MC (Gaussian mixture)'};
  popup6str(5) = {'Hybrid MC for MLP I'};
  popup6str(6) = {'Hybrid MC for MLP II'};
  % SIX popup
  hPop6 = uicontrol(fig, ...
    'Style','popup', ...
    'Units','normalized', ...
    'String', popup6str, ...
    'Position', [0.56 group1_top - bRow3Offset 0.36 0.08], ...
    'BackgroundColor', [0.7 0.7 0.7], ...
    'Callback', 'demnlab popup6');
  
  
  % Create HELP button
  uicontrol(fig, ...
    'Units', 'normalized', ...
    'Position' , [0.05 group2_bot+0.02 0.40 0.08], ...
    'String', 'Help', ...
    'Callback', 'demnlab help');
  
  % Create CLOSE button
  uicontrol(fig, ...
    'Units', 'normalized', ...
    'Position' , [0.55 group2_bot+0.02 0.40 0.08], ...
    'String', 'Close', ...
    'Callback', 'close(gcf)');
  
  hndlList=[fig hPop1 hPop2 hPop3 hPop4 hPop5 hPop6];
  set(fig, 'UserData', hndlList);
  set(fig, 'HandleVisibility', 'callback');
  
elseif strcmp(action, 'popup1'),
  
  hndlList=get(gcf,'UserData');
  hPop = hndlList(2);
  
  selected = get(hPop, 'Val');
  set(hPop, 'Val', [1]);
  
  switch selected
    case 2
      demmlp1;
    case 3
      demrbf1;
    case 4
      demmdn1;
  end;
  
elseif strcmp(action,'popup2'),
  
  hndlList=get(gcf,'UserData');
  hPop = hndlList(3);
  
  selected = get(hPop, 'Val');
  set(hPop, 'Val', [1]);
  
  switch selected
    case 2
      demglm1;
    case 3
      demglm2;
    case 4
      demmlp2;  
    case 5
      demknn1;
  end
    
elseif strcmp(action,'popup3'),
  
  hndlList=get(gcf,'UserData');
  hPop = hndlList(4);
  
  selected = get(hPop, 'Val');
  set(hPop, 'Val', [1]);
  
  switch selected
    case 2
      demgmm1;
    case 3
      demgmm2;
    case 4
      demgmm3;
    case 5
      demgmm4;
    case 6
      demns1;
    case 7
      demgtm1;
    case 8
      demgtm2;
    case 9
      demkmn1;
    case 10
      demsom1;
  end
  
elseif strcmp(action,'popup4'),
  
  hndlList=get(gcf,'UserData');
  hPop = hndlList(5);
  
  selected = get(hPop, 'Val');
  set(hPop, 'Val', [1]);
  
  switch selected
    case 2
      demprior;
    case 3
      demev1;
  case 4
      demev3;
  case 5
      demev2;
    case 6
      demard;
    case 7
      demprgp;
    case 8
      demgp;
    case 9
      demgpard;
  end

elseif strcmp(action,'popup5'),
  
  hndlList=get(gcf,'UserData');
  hPop = hndlList(6);
  
  selected = get(hPop, 'Val');
  set(hPop, 'Val', [1]);
  
  switch selected
    case 2
      demopt1;
    case 3
      demolgd1;
    case 4
      demhint;
  end

  
elseif strcmp(action,'popup6'),
  
  hndlList=get(gcf,'UserData');
  hPop = hndlList(7);
  
  selected = get(hPop, 'Val');
  set(hPop, 'Val', [1]);
  
  switch selected
    case 2
      demgauss;
    case 3
      demmet1;
    case 4
      demhmc1;
    case 5
      demhmc2;
    case 6
      demhmc3;
  end

elseif strcmp(action, 'help'),
  
  helpStr = {'To run a demo, press the appropriate button.'; ...
	'Instructions and information will appear in the Matlab';...
	'command window.'};
  
  hHelpDlg = helpdlg(helpStr, 'Netlab Demo Help');	

end;