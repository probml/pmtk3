function maximizeFigure
    scrsz = get(0,'ScreenSize');
    %Borders

% This file is from pmtk3.googlecode.com

    left =  10;   right = 10;
    lower = 50;   upper = 125;
    set(gcf,'Position',[left,lower,scrsz(3)-left-right, scrsz(4)-lower-upper]);
end
