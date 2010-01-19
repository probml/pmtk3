function m = protectedMethods(className,localOnly)
    if nargin < 2, localOnly = true; end
    meths = cellfuncell(@(c)c.Name, meta.class.fromName(className).Methods);
    keep = false(numel(meths,1));
    for i=1:numel(meths)
       info = methodInfo(className,meths{i});
       keep(i) = info.isProtected && (~localOnly || info.isLocal);
    end
    m = meths(keep);
    
end