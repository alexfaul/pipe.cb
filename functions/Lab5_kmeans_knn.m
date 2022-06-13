%% Kmeans
load('data1.mat') % columns of X are variables and rows are the data points
figure;
plot(X(:,1),X(:,2),'.','markersize',10);

k = 2;
[idx,cs] = kmeans(X,k); % cluster X into 2 clusters using matlab's kmeans function

figure;
for i = 1:k
    plot(X(idx==i,1),X(idx==i,2),'.','markersize',10);  % plot the clusters
    hold all;
    plot(cs(i,1),cs(i,2),'x','markersize',10);  % plot the cluster centers
end

k = 3;
[idx,cs] = kmeans(X,k); % cluster X into 3 clusters using matlab's kmeans function

figure;
for i = 1:k
    plot(X(idx==i,1),X(idx==i,2),'.','markersize',10);
    hold all;
    plot(cs(i,1),cs(i,2),'x','markersize',10);
end

k = 4;
[idx,cs] = kmeans(X,k); % cluster X into 4 clusters using matlab's kmeans function

figure;
for i = 1:k
    plot(X(idx==i,1),X(idx==i,2),'.','markersize',10);
    hold all;
    plot(cs(i,1),cs(i,2),'x','markersize',10);
end

eva = evalclusters(X,'kmeans','DaviesBouldin','KList',[1:9])
figure;plot(eva)

close all
clear all
%% kmeans - Mahalanobis distance, computed using a positive definite covariance matrix.
load('data2.mat')
figure;
plot(X(:,1),X(:,2),'.','markersize',10);

k = 2;
[idx,cs] = kmeans(X,k); % cluster X into 2 clusters using matlab's kmeans function

for i = 1:k
    plot(X(idx==i,1),X(idx==i,2),'.','markersize',10);
    hold all;
    plot(cs(i,1),cs(i,2),'x','markersize',10);
end

k_means(X, k);  % cluster X into 2 clusters using our k_means function and euclidean distance

k_means(X, k, 'mahalanobis');   % cluster X into 2 clusters using our k_means function and mahalanobis distance

close all
clear all
%% kmeans - Gaussian kernel 
load('data3.mat')
figure;
plot(X(:,1),X(:,2),'.','markersize',10);

k = 2;
k_means(X, k);  % cluster X into 2 clusters using our k_means function and euclidean distance

k_means_kernel(X, k, 'gaussian', 3);    % cluster X into 2 clusters using our k_means_kernel function and Gaussian kernel

clear all
close all
%%%%%%%%%%%%%%%%%%%
load('data4.mat')
figure;
plot(X(:,1),X(:,2),'.','markersize',10);

k = 2;
k_means(X, k);  % cluster X into 2 clusters using our k_means function and euclidean distance

k_means(X, k, 'mahalanobis');   % cluster X into 2 clusters using our k_means function and mahalanobis distance

k_means_kernel(X, k, 'gaussian', 3);    % cluster X into 2 clusters using our k_means_kernel function and Gaussian kernel

close all
clear all
%% K Nearest Neighbor - KNN 
load('data8.mat')

x0 = X_ellipse(Y == 0,:);
x1 = X_ellipse(Y == 1,:);
figure;plot(x0(:,1),x0(:,2),'.','markersize',10)
hold on;plot(x1(:,1),x1(:,2),'.','markersize',10)

q = [-20 20; ...
      80 60; ...
      70 10];
  
line(q(:,1),q(:,2),'marker','x','color','k','markersize',10,'linewidth',2,'linestyle','none')

[nmh,dmh] = knnsearch(X_ellipse,q,'k',9,'distance','mahalanobis');
line(X_ellipse(nmh,1),X_ellipse(nmh,2),'color','g','marker','o','linestyle','none','markersize',10)

% generate model instead
Mdl = fitcknn(X_ellipse,Y,'Distance','mahalanobis','NumNeighbors',9)
label = predict(Mdl, q)
