function (clustCrit,idx)=kMeansWrapper(data)
%% load and plot data

cd ''                                               % path to data between ''
load('data1.mat')                                   % columns of X are variables and rows are the data points
X(:,1)=sampEnt.t04Sut3191117
X(:,2)=AUC.t04Sut3191117
figure;
hist(X);
maxLim=max(X)                                              % used for finding best xlim and ylim
minLim=min(X)

figure;
plot(X(:,1),X(:,2),'.','markersize',8);
xlim([minLim(1),maxLim(1)])
ylim([minLim(2),maxLim(2)])
title('Data1 Distribution')
close all
%% testing optimal number of clusters
replications = 10;
clusterNum=2:10;
evalParam='DaviesBouldin'
myfunc = @(X,k)(k_means_AF(X, k, 'mahalanobis', replications ));
clustCrit=evalclusters(X,myfunc,evalParam,'klist',(clusterNum)); %testing 2:10 clusters

figure
bar(clustCrit.CriterionValues)
xticks(1:length(clusterNum))
xticklabels({clusterNum})
xlabel('Number of Clusters')
[~,I]=min(clustCrit.CriterionValues)            % Depending on the clustering criteria, this might have to flip to max (silhouette uses max)
k=clusterNum(I)                                 % Optimal number of clusters

% more straightforward way:
k=clustCrit.OptimalK
%% Optimal clustering w Mahalanobis
[idx,cs]=k_means_AF(X, k, 'mahalanobis',10);     % cluster X into 5 clusters using our k_means function and mahalanobis distance
                                                 % 10 replications
                                                 % [idx, cs, opt_rep]
                                                 % idx-cluster assignment index
                                                 % cs - centers
                                                 % opt_rep - replication used. Good for debugging/checking but not much else 
%% Alternative clustering methods (using kernels instead of distance)
% Use kMeansKernel if not getting good clustering from distance metrics
clear ans cs idx 
[idx] =k_means_kernel(X, k, 'gaussian', 10);     % testing gaussian clustering
figure;
for i = 1:k
    plot(X(idx==i,1),X(idx==i,2),'.','markersize',10);
    hold all
    xlim([minLim(1),maxLim(1)]);
    ylim([minLim(2),maxLim(2)]);
end

clear ans cs idx 
[idx] =k_means_kernel(X, k, 'linear', 10);       % testing linear clustering
figure;
for i = 1:k
    plot(X(idx==i,1),X(idx==i,2),'.','markersize',10);
    hold all
    xlim([minLim(1),maxLim(1)]);
    ylim([minLim(2),maxLim(2)]);
end

clear ans cs idx 
[idx] =k_means_kernel(X, k, 'polynomial', 2);   % testing polynomial clustering
figure;
for i = 1:k
    plot(X(idx==i,1),X(idx==i,2),'.','markersize',10);
    hold all
    xlim([minLim(1),maxLim(1)]);
    ylim([minLim(2),maxLim(2)]);
end
close all
%% FINAL NOTE

% If you have ground truth, you should conduct external validation (F, Rand,
%etc)

% IF you conduct external validity, you will have to partition your data and
% cluster on subset before doing final clustering on entire set
% (basically becomes test/train issue at that point)

end 