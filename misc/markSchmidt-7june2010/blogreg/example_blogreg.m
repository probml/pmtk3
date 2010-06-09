[X,y] = twos_threes;
ns = 250;
s = logist2Sample(X,y,eye(256)*1,ns);

pos = [119 144 152 162 184 196];
neg = [30 75 106 109 123 124];
neu = [79 167 182 213 222 255];
figure(1);
j=1;
for i = 1:6
    subplot(6,3,j);
    j=j+1;
    hist(s(pos(i),:));
    title('Positive Variables');
    subplot(6,3,j);
    j=j+1;
    hist(s(neg(i),:));
    title('Negative Variables');
    subplot(6,3,j);
    j=j+1;
    hist(s(neu(i),:));
    title('Neutral Variables');
end

    

s2 = logist2Sample2(X,y,eye(256)*1,ns);
figure(2);
j=1;
for i = 1:6
    subplot(6,3,j);
    j=j+1;
    hist(s2(pos(i),:));
    title('Positive Variables');
    subplot(6,3,j);
    j=j+1;
    hist(s2(neg(i),:));
    title('Negative Variables');
    subplot(6,3,j);
    j=j+1;
    hist(s2(neu(i),:));
    title('Neutral Variables');
end

s3= logist2_FS_Sample(X,y,eye(256)*1,ns);
figure(3);
j=1;
for i = 1:6
    subplot(6,3,j);
    j=j+1;
    hist(s3(pos(i),:));
    title('Positive Variables');
    subplot(6,3,j);
    j=j+1;
    hist(s3(neg(i),:));
    title('Negative Variables');
    subplot(6,3,j);
    j=j+1;
    hist(s3(neu(i),:));
    title('Neutral Variables');
end