function [model]=generate_model(training_features,labels)
%% Initialize
% clearvars -except features labels
X2=training_features;
y2=labels;
model = fitcnb(X2, y2);
 
%% Scratch

% if y2(:)~=2                             %if the classes are 1 and 0, matlab errors bc must have "positive class"
%     y2(y2==1)=2;
%     y2(y2==0)=1;
% end


% %% Holdout test set for end test set
% % Everything is 10 fold cross validation with training and tune up set
% % Final validation is with test set separated before cross validation
% 
% cvp = cvpartition(y2, 'Holdout', 0.25);                           %partitions the data into 20% for testing and 80% for training
% training = cvp.training;                                        %returns vector of training indices
% test = cvp.test;                                                %returns vector of test indices                                                                    %GLOBAL
% X = X2(training,:);                                        % form the training data
% y = y2(training);                                          % from cvpartition train index                                                                  %GLOBAL
% test_X2 = X2(test,:);                                             % form the testing data
% test_y2 = y2(test);                                               % from cvpartition test index
% % %% for hyperparameter tuning - SVM performance ultimately less optimal when randomizing data
% % %distribution of this data is normalized so drawbacks of naive bayes are
% % %minimized
% % kernel_scales = [ 0.1 0.5 1 5 10 50 100 500 1000 1500];
% % Cs = [ 0.1 0.5 1 5 10 50 100 500 1000 1500];
% % rng('default'); 
% % [kernel_scale_best, C_best] = svm_hyperparameter_tuning(X2,y2,'rbf',kernel_scales,Cs);
% % 
% % %% Fold validation
% % clear Cs kernel_scales training
% % cvp = cvpartition(y,'KFold',10);
% % for i = 1:cvp.NumTestSets
% %     disp(['Fold ',num2str(i)])
% %     training = cvp.training(i);
% %     test = cvp.test(i);
% %     
% %     train_X = X(training,:); % form the training data
% %     train_y = y(training); 
% %     test_X = X(test,:); % form the testing data
% %     test_y = y(test);    
% % 
% %     model = fitcsvm(train_X, train_y, 'KernelFunction', 'rbf', 'KernelScale', ...
% %         kernel_scale_best, 'BoxConstraint', C_best);
% %      [~, score] = predict(model, test_X);
% %      train_pred_y = predict(model, train_X); 
% %      train_acc(i) = sum(train_y == train_pred_y)/length(train_y); 
% %      test_pred_y = predict(model, test_X); 
% %      test_acc(i) = sum(test_y == test_pred_y)/length(test_y);
% %      precision(i) = sum(test_y==1 & test_pred_y==1) / sum(test_pred_y==1);
% %      recall(i) = sum(test_y==1 & test_pred_y==1) / sum(test_y==1);
% %      F1(i) = (2*precision(i)*recall(i))/(precision(i)+recall(i));
% % end
% % F1_all(:,1)=F1;
% % %% Final validation
% %  clear train_pred_y score train_acc test_acc model precision recall  
% %  model = fitcsvm(X, y, 'KernelFunction', 'rbf', 'KernelScale', kernel_scale_best,...
% %     'BoxConstraint', C_best);
% %      [~, score] = predict(model, test_X2);    
% %      train_pred_y = predict(model, X); 
% %      train_acc = sum(y == train_pred_y)/length(y); 
% %      test_pred_y = predict(model, test_X2);      
% %      test_acc = sum(test_y2 == test_pred_y)/length(test_y2);
% %      precision = sum(test_y2==1 & test_pred_y==1) / sum(test_pred_y==1);
% %      recall = sum(test_y2==1 & test_pred_y==1) / sum(test_y2==1);
% %      F1 = (2*precision*recall)/(precision+recall);
% %% NAIVE BAYES
%  clear train_pred_y score train_acc test_acc model precision recall F1 test_pred_y test_y test_X cvp
% cvp = cvpartition(y,'KFold',10);
% for i = 1:cvp.NumTestSets
%     disp(['Fold ',num2str(i)])
%     training = cvp.training(i);
%     test = cvp.test(i);
%     
%     train_X = X(training,:); 
%     train_y = y(training); 
%     test_X = X(test,:); 
%     test_y = y(test);    
% 
%     model = fitcnb(train_X, train_y);
%      [~, score] = predict(model, test_X);    
%      train_pred_y = predict(model, train_X); 
%      train_acc(i) = sum(train_y == train_pred_y)/length(train_y); 
%      test_pred_y = predict(model, test_X);      
%      test_acc(i) = sum(test_y == test_pred_y)/length(test_y);
%      precision(i) = sum(test_y==1 & test_pred_y==1) / sum(test_pred_y==1);
%      recall(i) = sum(test_y==1 & test_pred_y==1) / sum(test_y==1);
%      F1(i) = (2*precision(i)*recall(i))/(precision(i)+recall(i));
% end
% F1_all(:,2)=F1;

%% Naive bayes final validation
%  clear train_pred_y score train_acc test_acc model precision recall F1 test_pred_y test_y test_X cvp
% 
%     model = fitcnb(X, y);
% 
%      [~, score] = predict(model, test_X2);    
%     train_pred_y = predict(model, X); 
%      train_acc = sum(y == train_pred_y)/length(y); 
%      test_pred_y = predict(model, test_X2);      
%      test_acc = sum(test_y2 == test_pred_y)/length(test_y2);
%      precision = sum(test_y2==1 & test_pred_y==1) / sum(test_pred_y==1);
%      recall = sum(test_y2==1 & test_pred_y==1) / sum(test_y2==1);
%      F1_cb = (2*precision*recall)/(precision+recall);
% boxplot(F1_all)
end 