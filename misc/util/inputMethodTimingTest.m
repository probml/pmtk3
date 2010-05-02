function inputMethodTimingTest()

n = 10000; 

tic
for i=1:n
    controlCase(1, 2, 3, 4, 5, 6, 7, 8); 
    controlCase(1, [], [], 4, 5);
    controlCase();
end
tControl = toc/n

tic
for i=1:n
    process_options_test...
        ( 'a', 1, 'b', 2, 'c', 3, 'd', 4, 'e', 5, 'f', 6, 'g', 7, 'h', 8); 
    
    process_options_test('a', 1, 'd', 4, 'e', 5); 
    process_options_test();
end
t_po = toc/n

tic
for i=1:n
    setDefault_test(1, 2, 3, 4, 5, 6, 7, 8);
    setDefault_test(1, [], [], 4, 5); 
    setDefault_test();
end
t_sd = toc/n



end

function process_options_test(varargin)

    [a, b, c, d, e, f, g, h] = process_options(varargin, ...
        'a', 1, 'b', 2, 'c', 3, 'd', 4, 'e', 5, 'f', 6, 'g', 7, 'h', 8); 


end

function setDefault_test(a,b,c,d,e,f,g,h)

SetDefaultValue(1, 'a', 1);
SetDefaultValue(2, 'b', 2);
SetDefaultValue(3, 'c', 3);
SetDefaultValue(4, 'd', 4);
SetDefaultValue(5, 'e', 5);
SetDefaultValue(6, 'f', 6);
SetDefaultValue(7, 'g', 7);
SetDefaultValue(8, 'h', 8);

end


function controlCase(a, b, c, d, e, f, g, h)

nin = nargin();
if nin < 1 || isempty(a)
    a = 1;
end

if nin < 2 || isempty(b)
    b = 2;
end

if nin < 3 || isempty(c)
    c = 2;
end

if nin < 4 || isempty(d)
    d = 2;
end

if nin < 5 || isempty(e)
    e = 2;
end

if nin < 6 || isempty(f)
    f = 2;
end

if nin < 7 || isempty(g)
    g = 2;
end

if nin < 8 || isempty(h)
    h = 2;
end
    



end