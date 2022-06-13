function idx = k_means_kernel(X, k, kernel, kernel_par)

    rng(50);

    n = size(X,1);  % number of data points

    idx = ceil(k*rand(n,1));    % randomly assign points to clusters

    old_idx = zeros(size(idx));
    
    K = Gram(X, kernel, kernel_par);    % compute the Gram matrix
    
    figure;    
    while(any(idx~=old_idx))    % continue until the cluster centers are stabilize
        old_idx = idx;
        
        u = zeros(n,k);
        for i = 1:k     % form matrix u which indicates what cluster each data point belongs to
            u(idx==i,i) = 1;
        end                
        
        D = zeros(n,k);
        for j = 1:k
            nj = sum(u(:,j));   % find the number of points in cluster j
            D(:,j) = diag(K)' - 2*(1/nj)*u(:,j)'*K + (1/(nj^2))*u(:,j)'*K*u(:,j);   % compute the distance between data points and cluster centers
        end
        
        [~,idx] = min(D,[],2);  % assign data points to clusters
                
        hold off;
        for i = 1:k
            plot(X(idx==i,1),X(idx==i,2),'.','markersize',10);  % plot the clusters
            hold all;
        end
        %pause(1);
    end
end

function K = Gram(X, kernel, kernel_par)
    if(strcmpi(kernel,'linear'))
        K = X*X';
    elseif(strcmpi(kernel,'polynomial'))
        K = (X*X'+1).^kernel_par;
    elseif(strcmpi(kernel,'gaussian'))
        K = exp(-(1/(2*kernel_par^2))*squareform(pdist(X)).^2);
    end  
end