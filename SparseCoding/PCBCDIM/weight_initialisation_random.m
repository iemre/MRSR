function [W,V,U]=weight_initialisation_random(n,m,wMean,wStd)
if nargin<3, wMean=0.5; end
if nargin<4, wStd=0.05; end

W=gaussian_weights(n,m,wMean,wStd);
V=gaussian_weights(n,m,wMean,wStd);
U=gaussian_weights(n,m,wMean,wStd);

function W=gaussian_weights(n,m,wMean,wStd)
W=wMean+wStd.*randn(n,m,'single');  %Gaussian distributed weights with given
W(W<0)=0;                           %mean and standard deviation				   


