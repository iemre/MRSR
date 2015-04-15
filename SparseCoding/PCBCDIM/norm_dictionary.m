function V=norm_dictionary(V,order)
GP=global_parameters;
if nargin<2 || isempty(order), order=GP.dict_norm; end

[n,m]=size(V);
if order==1
  %normalise so that sum equals one (unit norm)
  if n==1 || m==1
    V=V./sum(abs(V));   
  else
    V=bsxfun(@rdivide,V,(1e-9+sum(abs(V),2))); %for matrices normalise rows
  end
    
elseif order==2
  %normalise so that sqrt of the sum of squares equals one (unit l2 norm)
  if n==1 || m==1
    V=V./norm(V,2); 
  else
    V=bsxfun(@rdivide,V,(1e-9+sqrt(sum(V.^2,2)))); %for matrices normalise rows
  end
  
elseif isinf(order)
  %normalise so that the maximum value equals one (unit l-inf norm)
  if n==1 || m==1
    V=V./max(abs(V)); 
  else
    V=bsxfun(@rdivide,V,(1e-9+max(abs(V),[],2))); %for matrices normalise rows
  end
  
end