function phd_figure_style(figHandle)
% set exportable image size
%figHandle = gcf ;
%xSize = 640 ;
%ySize = 480 ;

xSize = 540 ;
ySize = 400 ;

position = get(figHandle,'Position') ;
set(gcf,'Position', ...
    [position(1)+position(3)-xSize, position(2)+position(4)-ySize, ...
    xSize, ySize]) ;
figAxes = get(figHandle,'CurrentAxes') ;
set(figAxes(1),'LineWidth',2) ;
set(figAxes(1),'XGrid','on') ;
set(figAxes(1),'YGrid','on') ;
set(figAxes(1),'FontSize',14) ;

colorTbl = [.75 0.33 0.33 ; .33 0.33 0.75 ; .4 0.7 0.55; 0.4 0.9 0.9; 0.9 .2 0.3 ] ;

figLines = findobj(figAxes(1),'Type','line') ;
for n=1:length(figLines)
    handl = figLines(n) ;
    set(handl,'Color',colorTbl(n,:)) ;
    set(handl,'LineWidth',2) ;
end

obj_list = findall(gca) ;
for n=1:length(obj_list)
    type = get(obj_list(n),'Type') ;
    if strcmpi(type,'text')
        set(obj_list(n),'FontSize',14) ;
    end
end

