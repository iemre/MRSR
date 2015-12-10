
lambdas = [0.01,0.02,0.04,0.08,0.16,0.32,0.64,1.28,2.56,5.12,10.24,20.48,40.96,81.92];

R = L_train;
Y = Rating_train;
lambdas = 10;
error_rate = zeros(length(lambdas),1);
for i=1:length(lambdas)
    lambda = lambdas(i);
    
    % cross validation    

    [item_num,user_num] = size(R);
    %lambda = 0.02;
    feat_num = 10;

    P = mf_resys_func( Y,R,feat_num,lambda);
    
    error_rate(i) = sum(sum((test_R.*P - test_Y).^2))/sum(sum(test_Y.^2));
    
    fprintf('lambda %f | error: %f\n',lambda, error_rate(i));
end
plot(lambdas,error_rate,'-o');
ylabel('error rate');
xlabel('\lambda');
set(gca,'xscale','log');
set(gcf, 'Color', 'w');

%export_fig lambda_select.eps

