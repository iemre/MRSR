function D=define_decoding_weights(W,V,classDict,data,class)
numPatterns=length(class);
numClasses=max(class);
[n,m]=size(W);
GP=global_parameters;

switch GP.decode
  case 'binary'
    %number of output nodes is equal to number of classes
    %D=zeros(numClasses,numPatterns);
    D=zeros(numClasses,n);
    for c=1:numClasses
      %make all weights equal to 1 from basis vectors representing the same class
      D(c,:)=classDict==c; 
    end
  case 'linear'
    T=zeros(numClasses,numPatterns);
    Y=zeros(n,numPatterns);
    fprintf(1,'calculating decoding weights: ');
    for pattern=1:numPatterns
      if rem(pattern,100)==0, fprintf(1,'.%i/%i.',pattern,numPatterns); end
      x=data(:,pattern);      
      y=calc_sparse_representation(W,V,x,classDict,0);
      Y(:,pattern)=y; %define response matrix
      T(class(pattern),pattern)=1; %matrix of expected outputs
    end
    disp(' ');
    %calculate output weights as linear combination of the sparse responses
    if n==numPatterns 
      %if dictionary contains all training exemplars Y will be square, so use inv as
      %this is much faster than pinv
      D=T*inv(Y); 
    else
      D=T*pinv(Y); 
    end    
    disp('ELM-style linear decoding for "sum" results');
    
  case 'nnlinear'
    T=zeros(numClasses,numPatterns);
    Y=zeros(n,numPatterns);
    fprintf(1,'calculating decoding weights: ');
    for pattern=1:numPatterns
      if rem(pattern,100)==0, fprintf(1,'.%i/%i.',pattern,numPatterns); end
      x=data(:,pattern);      
      y=calc_sparse_representation(W,V,x,classDict,0);
      Y(:,pattern)=y; %define response matrix
      T(class(pattern),pattern)=1; %matrix of expected outputs
    end
    disp(' ');
    %calculate output weights as linear combination of the sparse responses
    D=T*Y';
    D=bsxfun(@rdivide,D,(1e-9+sum(D))); %normalise weights
    disp('Non-negative linear decoding for "sum" results');
    
  otherwise
    disp('ERROR: no method for creating weights to decode sparse response');
end
