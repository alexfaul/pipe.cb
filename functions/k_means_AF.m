function [idx,cs,opt_rep] = k_means_AF(X, k, dist,replications, plotclusters)
% I:
%       X      = data (). Columns of X are variables(features) and rows are observations
%       k      = number of clusters, determine w elbow/knee method (davies-bouldin,
%                silhouette, etc) USE evalclusters prior to setting
%      dist    = distance metric, passed as a string, e.g. 'euclidean'
% replications = number of times to run the clustering (since it chooses 
%                a random initialization point, you should run it at least 3-5 times, more
%                like 10 if you have a large dataset.
% plotclusters = whether to generate graph to plot the stabilized clusters.
%                T/F, true/false, or 1/0 input expected. Default is true

% O:
% idx = index with cluster assignment of data (e.g 1st data point is cluster 3, etc) of best replication (min sumd)
% cs = Cs (center) values associated with lowest sumd (optimized centers)
% opt_rep - replication number used for optimal clustering. Good for debugging/checking but not much else

% Kernel K-means or Spectral clustering can handle non-convex shapes in
% data so use kMeansKernel if not getting good clustering from these
% distance metrics
% Alexa Faulkner, 2019
%% Assumptions
    if(nargin<3)                % if dist is not provided, use euclidean distance
        dist = 'euclidean';     % mahalanobis is typically better than euclidean if data can be represented in a meaningful spatial way
    end                         % the allowed distance metrics are elaborated at end of function
    if (nargin<4)
        replications=1
    end 
    if nargin<5
        plotclusters=true
    end
    rep_num=replications;

%% Selecting random center points for clustering data around
%%Then clustering based on those points until stable
%cs_start is randomly selected center clusters
%cs_end is the centerpoint of clusters after stabilized

%clear replications field cs_start cs rp ii i n old_cs rp2 m cs_test cs_new2 cs_new cs2 variable ii

n = size(X,1);                   % number data points
   
    for ii=1:rep_num   
        rp(:,ii) = randperm(n);  %randomly generates list that includes 1:500 to be used as index to grab
                                 %for inital center points of cluster, each column is different replication
                                 %picks the center point randomly so 1st iteration might not have best
                                 %clustering
                                 
        field = strcat('Replication',num2str(ii));      %making struct to store all replications
        cs_start.(field)=X(rp(1:k,ii),:);               %each replication starting points stored in structure
    end
    clear ii 

    old_cs = zeros(k,size(X,2));                        %pre-allocate
    cs_index=fieldnames(cs_start);                      %fieldnames of struct with cs replications 
    
   for ii=1:rep_num   
        cs_temp=cs_start.(cs_index{ii});                %temp array to loop through each replication's cs
    while(any(cs_temp~=old_cs))                          % continue until the cluster centers stabilize
        old_cs = cs_temp;                                % parameters to stabilize to
        D = distance(X,cs_temp,dist);                    % find the distances of each point to the center of k clusters                               
        [min_distance,idx] = min(D,[],2);                %based on distances found above, 
                                                         %creates index that assigns data points in X to closest clusters
        min_dist.(cs_index{ii})=min_distance;            %storing outputs to compare for best performance
        c_idx.(cs_index{ii})=idx;                        %cluster index, which cluster data points belong to          
        cs_temp = [];
        
        for i = 1:k
            cs_temp(i,:) = mean(X(idx==i,:)); % find the new cluster centers
            cs_end.(cs_index{ii})=cs_temp;    % save to rep structure                
        end
                    
    end 
   end
   
   %% find replication with minimum sum of distances between center of cluster and cluster data 
clear ii old_cs i idx
   for ii=1:rep_num;
       sumd{ii}=sum(min_dist.(cs_index{ii})); %it might be one off here bc 10 is at top?
   end   
sumd=cell2mat(sumd);                          %changing classes
[~,I]=min(sumd);                              %to find index of 1st replication resulting in minimum distance
cs=cs_end.(cs_index{I});                      %make final cs output the cs values associated with lowest sumd w updated centers
idx=c_idx.(cs_index{I});
opt_rep=cs_index{I};
 %% Plotting
 if plotclusters==1
    figure;
    distanceUpdate='Data Clustering (Best Replication -  %s distance)'
    clusterUpdate='Cluster number, k = %d'
    for i = 1:k;
        plot(X(idx==i,1),X(idx==i,2),'.','markersize',10); % plot the points, by closest cluster
        hold all;
    end
    set(gca,'ColorOrderIndex',1); %reset color loop in plotting
    for i = 1:k
        plot(cs(i,1),cs(i,2),'x','markersize',12); % plot the cluster centers
    end
    title(sprintf(distanceUpdate,dist))
    xlabel(sprintf(clusterUpdate,k))
 end 
end    

%% distance metric function

function D = distance(X,Y,dist)
    D = squareform(pdist([X ; Y],dist));    % find all the distances according to the distance metric
    D = D(1:size(X,1),end-size(Y,1)+1:end); % only keep the distances between points in X and Y
end

%ALTERNATE Kmeans distance metrics:
% 'euclidean'        - Euclidean distance (default)
% 'squaredeuclidean' - Squared Euclidean distance 
% 'seuclidean'       - Standardized Euclidean distance. Each
%                            coordinate difference between rows in X is
%                            scaled by dividing by the corresponding
%                            element of the standard deviation S=NANSTD(X).
%                            To specify another value for S, use
%                            D=PDIST(X,'seuclidean',S).
% 'cityblock'        - City Block distance
% 'minkowski'        - Minkowski distance. The default exponent is 2.
%                            To specify a different exponent, use
%                            D = PDIST(X,'minkowski',P), where the exponent
%                            P is a scalar positive value.
% 'chebychev'        - Chebychev distance (maximum coordinate
%                            difference)
% 'mahalanobis'      - Mahalanobis distance, using the sample
%                            covariance of X as computed by NANCOV. To
%                            compute the distance with a different
%                            covariance, use
%                            D =  PDIST(X,'mahalanobis',C), where the
%                            matrix C is symmetric and positive definite.
% 'cosine'           - One minus the cosine of the included angle
%                            between observations (treated as vectors)
% 'correlation'      - One minus the sample linear correlation
%                            between observations (treated as sequences of
%                            values).
% 'spearman'         - One minus the sample Spearman's rank 
%                            correlation between observations (treated as
%                            sequences of values).
% 'hamming'          - Hamming distance, percentage of coordinates
%                            that differ
% 'jaccard'          - One minus the Jaccard coefficient, the
%                            percentage of nonzero coordinates that differ
% function           - A custom distance function specified using @, for
%                            example @DISTFUN.