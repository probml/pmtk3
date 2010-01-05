function [im_hatch,colorlist] = applyhatch_pluscolor(h,patterns,CvBW,Hinvert,colorlist, ...
                                                dpi,hatchsc,lw)
%APPLYHATCH_PLUSCOLOR Apply hatched patterns to a figure in BW or Color
%  APPLYHATCH_PLUSCOLOR(H,PATTERNS) creates a new figure from the figure H by
%  replacing distinct colors in H with the black and white
%  patterns in PATTERNS. The format for PATTERNS can be
%    a string of the characters:
%    '/', '\', '|', '-', '+', 'x', '.', 'c', 'w', 'k'
%    (see makehatch_plus.m for more details) or
%    a cell array of matrices of zeros (white) and ones (black)
%
%  In addition, H can alternatively be a uint8 NxMx3 matrix of the type
%  produced by imread.  In this case, colors in this image will be
%  replaced with patterns as if it was a figure.  A final figure window
%  will be generated that displays the result.  The DPI argument
%  discussed below will be ignored if H is an image matrix.
%
%  APPLYHATCH_PLUSCOLOR(H,PATTERNS,CVBW) binary value for choice of Color or Black
%  and White plots. If color is chosen the color will match that of the 
%  current fill. 1 -> Color, anything else -> BW
%
%  APPLYHATCH_PLUSCOLOR(H,PATTERNS,CVBW,HINVERT) binary value to invert the hatch.
%  i.e., if it is black lines with a white background, that becomes white
%  lines with a black background. This can either be a scalar value or a 
%  1xN array equal to the length of PATTERNS. When used as an array each
%  PATTERNS(i) will be inverted according to Hinvert(i). 1 -> Invert,
%  anything else -> Non Inverted
%
%  APPLYHATCH_PLUSCOLOR(H,PATTERNS,CVBW,HINVERT,COLORS) maps the colors in the n by 3
%  matrix COLORS to PATTERNS. Each row of COLORS specifies an RGB
%  color value.
%
%  Note this function makes a bitmap image of H and so is limited
%  to bitmap output.
%
%  Additional arguments:
%
%  [im_hatch,colorlist] = applyhatch_plus(h,patterns,CvBW,Hinvert,colorlist,dpi,hatchsc,linewidth)
%
%   input   DPI         allows specification of bitmap resolution, making plot resolution
%                       better for printing.  Ignored if H is an image matrix.
%           HATCHSC     multiplier for hatch scale to increase size of pattern for better operation
%                       at higher resolutions
%                       default [] uses screen resolution as in
%                       APPLYHATCH
%           LINEWIDTH   A scaling factor to apply to line and dot sizes
%                       in hatching.  Defaults to 1.
%   output  IM_HATCH    RGB bitmap matrix of new figure
%                       use IMWRITE to output in desired format
%           COLORLIST   List of colors actually replaced.  Useful info if
%                       no colorlist initially given to function.
%                       Colorlist will be uint8, not 0-1 scale as
%                       originally specified.
%
%  Example 1:
%    bar(rand(3,4));
%    [im_hatch,colorlist] = applyhatch_pluscolor(gcf,'\-x.',0,0,[],150);
%    imwrite(im_hatch,'im_hatch.png','png')
%
%  Example 2:
%    bar(rand(3,4));
%    [im_hatch,colorlist] = applyhatch_pluscolor(gcf,'\-x.',1,[],[],150);
%    imwrite(im_hatch,'im_hatch.png','png')
%
%  Example 3:
%    colormap(cool(6));
%    pie(rand(6,1));
%    legend('Jan','Feb','Mar','Apr','May','Jun');
%    im_hatch = applyhatch_pluscolor(gcf,'|-.+\/',1,[1 1 0 1 0 0],cool(6),200,3,2);
%    imwrite(im_hatch,'im_hatch.png','png')
%
%  Example 4: Produces roughly the same thing as example 1
%    bar(rand(3,4));
%    print -dtiff -r150 im.tiff
%    im = imread( 'im.tiff', 'tiff' );
%    [im_hatch,colorlist] = applyhatch_pluscolor(im,'\-x.');
%    imwrite(im_hatch,'im_hatch.tiff','tiff')
%    
%
% Modification of APPLYHATCH to allow higher resolution output
% Modified Brian FG Katz    8-aout-03
% Modified David M Kaplan   19-fevrier-08
%
% Modification of APPLYHATCH_PLUS to allow for color and inverted hatch
% Modified Brandon Levey  May 6, 2009
%
%  See also: APPLYHATCH, APPLYHATCH_PLUS, MAKEHATCH, MAKEHATCH_PLUS

%  By Ben Hinkle, bhinkle@mathworks.com
%  This code is in the public domain. 


if ~exist('CvBW','var'); CvBW = 0      ; end  % defaults to black and white
if isempty(CvBW); CvBW = 0     ; end  % defaults to black and white
if (CvBW ~= 0 && CvBW ~= 1); CvBW = 0     ; end  % defaults to black and white

if ~exist('Hinvert','var'); Hinvert = 0      ; end  % defaults to not inverted
if isempty(Hinvert); Hinvert = 0     ; end  % defaults to not inverted
if length(Hinvert) == length(patterns) || length(Hinvert) == 1
    for i = 1:length(Hinvert)
        if Hinvert(i) ~= 0 && Hinvert(i) ~= 1; Hinvert(i) = 0     ; end
    end
else
    error(['The length of Hinvert must be 1 or equal to the length of PATTERNS']);
end

if ~exist('hatchsc','var'); hatchsc = 1      ; end
if ~exist('dpi','var'); dpi = 0          ; end     % defaults to screen resolution
if ~exist('colorlist','var'); colorlist = []   ; end
if ~exist('lw','var'); lw=1; end

if numel(h) == 1 % Assume it is a figure window
  oldppmode = get(h,'paperpositionmode');
  oldunits = get(h,'units');
  oldcolor = get(h,'color');
  oldpos = get(h,'position');
  set(h,'paperpositionmode','auto');
  set(h,'units','pixels');
  set(h,'color',[1 1 1]);
  figsize = get(h,'position');

  bits = hardcopy(h,'-dzbuffer',['-r' num2str(dpi)]);

  % % Try a different approach using a temporary file - use this if having probs
  % tn = [ tempname '.tif' ];
  % print( '-dtiff', [ '-r' num2str(dpi) ], tn )
  % bits = uint8( imread( tn, 'TIFF' ) );
  % delete(tn)
  
  set(h,'paperpositionmode',oldppmode);
  set(h,'color',oldcolor);
elseif size(h,3) == 3 % Assume it is an image matrix
  bits = h;
  oldunits='pixels';
  oldpos = [ 0, 0, size(bits,2), size(bits,1) ];
  figsize = oldpos;
else 
  error( 'Bad first argument.' );
end

bwidth = size(bits,2);
bheight = size(bits,1);
bsize = bwidth * bheight;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The next bit basically modernizes the original
% version of this function using things like unique
% and for loops
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make bitmap one long matrix with 3 columns
bits = reshape(bits,[bsize,3]);

% Convert original color scale to 255 scale
if ~isempty(colorlist)
  % NOTE: Added "floor" below because this seems to better pick out
  % correct colors produced by "hardcopy above better than uint8 by itself
  
  %colorlist = uint8(255*colorlist);
  colorlist = uint8(floor(255*colorlist));
else
  % Find unique colors in image - this takes a long time at high resolution
  [B,I,J] = unique( bits, 'rows' );

  switch CvBW
      case 0 % BW plot
        % Find just "colored" colors
        C = find( B(:,1)~=B(:,2) | B(:,1)~=B(:,3) );
      case 1 % color plot
        % Find all non black and white
        B = sortrows(B);
        C = 1:size(B,1);
        C = C(2:end-1)';
  end
  
  colorlist = B( C , : );
end

% Loop over list of colors and find matches
for k = 1:size(colorlist,1)

  % Find points that match color
  if exist('B','var') % Use unique colors if around
    I = C(k) == J;
  else % Otherwise test each point
    cc = colorlist(k,:);
    I = bits(:,1)==cc(1) & bits(:,2)==cc(2) & bits(:,3)==cc(3);
    if ~any(I(:)), continue, end
  end

  % What pattern to use
  pati = mod( k-1, numel(patterns) ) + 1;
  if iscell(patterns)
    pattern = patterns{pati};
  elseif isa(patterns,'char')
    pattern = makehatch_plus(patterns(pati),6*hatchsc,lw);
  else
    pattern = patterns;
  end
  pattern = uint8(1-pattern);
  
  if length(Hinvert) == 1
    invertHatch = logical(Hinvert);
  else
    invertHatch = logical(Hinvert(pati));
  end

  % Make a big pattern matching size of bits
  pheight = size(pattern,2);
  pwidth = size(pattern,1);
  ratioh = ceil(bheight/pheight);
  ratiow = ceil(bwidth/pwidth);
  bigpattern = repmat(pattern,[ratioh ratiow]);
  if ratioh*pheight > bheight
    bigpattern(bheight+1:end,:) = [];
  end
  if ratiow*pwidth > bwidth
    bigpattern(:,bwidth+1:end) = [];
  end
  
  % Put that pattern into bits and logical values based on CvBW and Hinvert
  switch CvBW
      case 0 % BW
          if invertHatch
              bits(find(I),:) = repmat(~bigpattern(I)*255,[1,3]);
          else
              bits(find(I),:) = repmat(bigpattern(I)*255,[1,3]);
          end
      case 1 % Color
          if invertHatch
              bits(find(I),:) = [ ...
                (uint8(bigpattern(I)) * colorlist(k,1)) + uint8((~bigpattern(I)) * 255), ...
                (uint8(bigpattern(I)) * colorlist(k,2)) + uint8((~bigpattern(I)) * 255), ...
                (uint8(bigpattern(I)) * colorlist(k,3)) + uint8((~bigpattern(I)) * 255)];
          else
              bits(find(I),:) = [ ...
                (uint8(~bigpattern(I)) * colorlist(k,1)) + uint8((bigpattern(I)) * 255), ...
                (uint8(~bigpattern(I)) * colorlist(k,2)) + uint8((bigpattern(I)) * 255), ...
                (uint8(~bigpattern(I)) * colorlist(k,3)) + uint8((bigpattern(I)) * 255)];
          end
  end
  
end

% Put bits back into its normal shape
bits = reshape( bits, [bheight,bwidth,3] );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Replot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
newfig = figure('units',oldunits,'visible','off');
imaxes = axes('parent',newfig,'units','pixels');
im = image(bits,'parent',imaxes);
%fpos = get(newfig,'position');
%set(newfig,'position',[fpos(1:2) figsize(3) figsize(4)+1]);
set(newfig,'position',oldpos)
set(newfig,'units','pixels')
set(imaxes,'position',[0 0 figsize(3) figsize(4)+1],'visible','off');
set(newfig,'visible','on');

set(newfig,'units','normalized');
set(imaxes,'units','normalized');
set(imaxes,'DataAspectRatio',[1 1 1],'DataAspectRatioMode','manual');


if nargout > 0, im_hatch = bits; end
if nargout < 2, clear colorlist; end
