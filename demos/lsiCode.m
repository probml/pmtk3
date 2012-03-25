% lsiCode
clear all

X = load('lsiMatrix.txt')';

%fid = fopen('lsiWords.txt');
%tmp = textscan(fid,'%s');
%fclose(fid);
%words = tmp{1};
words = textread('lsiWords.txt', '%s');

	
[U,S,V] = svd(X);
K = 2;
UK = U(:,1:K);
SK = S(1:K, 1:K);
VK = V(:,1:K);

[nwords ndoc] = size(X);
% plot documents in latent space
Xhat = VK';
figure(1);clf
for j=1:ndoc
  plot(Xhat(1,j), Xhat(2,j),  'o', 'linewidth', 2);
  hold on
  eps = 0.005;
  h=text(Xhat(1,j)+eps, Xhat(2,j)+eps,  sprintf('%d', j),'fontsize',18);
end

% find closest documents to query
ndx = strmatch('abducted',words);
q = zeros(nwords,1);
q(ndx) = 1;
qhat = inv(SK)*UK'*q;
for j=1:ndoc
  tmp = (qhat'*Xhat(:,j))/(norm(qhat)*norm(Xhat(:,j)));
  angle(j) = acos(tmp)*(180/pi);
end
[ndx, angles] = sort(angle)
top3 = ndx(1:3)


%Xhat = UK; % 460x2
%figure(1);clf
%for i=1:nwords
%  %plot(Xhat(i,1), Xhat(i,2),  'o');
%  h=text(Xhat(i,1), Xhat(i,2),  sprintf('%d', i),'fontsize',10);
%  hold on
%end
