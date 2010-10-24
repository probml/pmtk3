function javaTable(data,columnNames,tableName)
% Display a cell array of strings in a java JTable
% PMTKneedsMatlab 
%%

% This file is from pmtk3.googlecode.com

if(isempty(data))
    fprintf('\ndata cannot be empty\n');
    return;
end
if(nargin < 2)
    columnNames = cell(1,size(data,2));
    columnNames(:) = {''};
end
if(nargin < 3)
    tableName = '';
end

import javax.swing.* java.awt.*;

jdata = cell2java2D(data);
jcolumnNames = cell2java1D(columnNames);
table = JTable(jdata,jcolumnNames);
scrollPane = JScrollPane(table);

frame = JFrame(tableName);
frame.getContentPane().add(scrollPane);

table.setFont(Font('Times New Roman', Font.PLAIN, 15));
table.setAutoResizeMode( JTable.AUTO_RESIZE_OFF );
p = get(0,'ScreenSize');
width = 0.95*p(3); height = 0.6*p(4);
table.setPreferredScrollableViewportSize(Dimension(width,height));
for i=0:numel(columnNames)-1
    table.getColumnModel().getColumn(i).setPreferredWidth(floor(width)/numel(columnNames));
end


frame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
frame.pack();
frame.setVisible(true);

    function jobj = cell2java1D(data)
        %Convert a 1d cell array into a java String array, i.e. String[]
        jobj = javaArray('java.lang.String',numel(data));
        for i=1:numel(data)
            jobj(i) = java.lang.String(data{i});
        end
        
    end


    function jobj = cell2java2D(data)
        %Convert a 2d cell array into a 2d java String array, i.e. String[][]
        [nrows,ncols] = size(data);
        jobj = javaArray('java.lang.String',nrows,ncols);
        for r=1:nrows
            for c=1:ncols
                jobj(r,c) = java.lang.String(data{r,c});
            end
        end
    end

end
