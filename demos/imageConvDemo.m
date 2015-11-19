%http://graphics.cs.cmu.edu/courses/15-463/2005_fall/www/Lectures/convolution.pdf

foo=load('clown');
clown = foo.X;

g = fspecial('gaussian',15,2);
%figure;imagesc(g)
figure; surfl(g); title('kernel');


gclown = conv2(clown,g,'same');
figure; imagesc(clown); axis off; title('clown');
printPmtkFigure('clown')

figure;imagesc(conv2(clown,[-1 1],'same')); 
axis off; title('Derivative');
printPmtkFigure('clownDeriv')

figure;imagesc(conv2(gclown,[-1 1],'same'));
axis off; title('[-1,1]*g*I'); 

dx = conv2(g,[-1 1],'same');
figure; imagesc(conv2(clown,dx,'same'));
axis off; title('Vertical edges'); 
printPmtkFigure('clownDOGX')

dy = conv2(g,[-1;1],'same');
figure; imagesc(conv2(clown,dy,'same'));
axis off; title('Horizontal edges'); 
printPmtkFigure('clownDOGY')


lg = fspecial('log',15,2);
lclown = conv2(clown,lg,'same');
figure; imagesc(lclown); title('Laplacian of Gaussian');
axis off; 
printPmtkFigure('clownLOG')

