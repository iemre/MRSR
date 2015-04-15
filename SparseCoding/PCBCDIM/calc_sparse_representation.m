function [y,e,s,nmse,totalTime,sTrace]=calc_sparse_representation(W,V,x,classDict,totalTime)
[n,m]=size(V);
numClasses=max(classDict);
GP=global_parameters;

switch GP.network
  case 'subnets'
    %calculate response of each sub-dictionary separately
    y=zeros(n,1);
    e=zeros(m,numClasses);
    nmse=zeros(1,numClasses);
    for c=1:numClasses
      ind=logical(classDict==c);
      [y(ind),e(:,c),nmse(c),sTrace(c,:),totalTime]=sparse_solve(W(ind,:),V(ind,:),x,totalTime);
    end
  case 'single'
    %calculate response of dictionary as a whole
    [y,e,nmse,sTrace,totalTime]=sparse_solve(W,V,x,totalTime);
end

%calculate the sparsity of the response (using Hoyer's sparsity measure)
sqrtn=sqrt(n);
s=(sqrtn-(norm(y,1)/norm(y,2)))/(sqrtn-1);
if size(sTrace,2)==1, sTrace=s; end





function [y,e,nmse,sTrace,totalTime]=sparse_solve(W,V,x,totalTime)
%calculate a sparse representation over the dictionary using one of several alternative sparce solvers
[n,m]=size(V);
GP=global_parameters;
sTrace=0;

switch GP.alg
  %solvers from smallBox: http://small-project.eu/software-data/smallbox/
  case 'MP'
    tic;y=full(SMALL_MP(V',x,n,n/1000,1e-5));
  case 'OMP'
    tic;y=full(SMALL_chol(V',x,n,n/1000,1e-5));
  case 'PCGP'
    tic;y=full(SMALL_pcgp(V',x,n,n/10,1e-5));

  %solvers from SparseLab: http://sparselab.stanford.edu/
  case 'PDBBP'
    tic;y=SolveBP(double(V'),double(x),n);
  case 'LARS'
    tic;y=SolveLasso(V',x,n,'nnlars');
  case 'LARSlasso'
    tic;y=SolveLasso(V',x,n,'nnlasso');
  case 'PFP'
    tic;y=SolvePFP(V',x,n,'nnpfp');
  case 'IRWLS'
    tic;y=SolveIRWLS(V',x,n); %very poor performance - poor parameter choice/bug?
  case 'MPsparseLab'
    tic;y=SolveMP(V',x,n); %same alg as in smallBox - this version very slow!

  %solvers for the L1Benchmark: http://www.eecs.berkeley.edu/~yang/software/l1benchmark/
  case 'PDIPA'
    tic;y=SolvePDIPA(V',x,'isNonnegative',true);
  case 'L1LS'
    tic;y=SolveL1LS(V',x);
  case 'Homotopy'
    tic;y=SolveHomotopy(V',x,'isNonnegative',true,'tolerance',1e-14);
  case 'SpaRSA'
    tic;y=SolveSpaRSA(V',x,'isNonnegative',true);
  case 'FISTA'
    tic;y=SolveFISTA(V',x,'isNonnegative',true);
  case 'DALM'
    tic;y=SolveDALM(V',x);
  case 'PALM'
    tic;y=SolvePALM(double(V'),double(x)); %very, very slow!

  %Algebraic Pursuit algorithm: Volkan Cevher
  case 'AlgebraicPursuit'
    tic;y=AlgebraicPursuit(x, V', fix(n/100));

  %Focuss: http://hebb.mit.edu/people/jfmurray/software.htm
  case 'Focuss'
    tic;y=focuss(x,V',-1,1,15,0.5,2e-3);

    
  %proposed solver: PC/BC-DIM
  case 'PCBCconv'
    m=prod(GP.imDims);
    %convert dictionary weights to cell arrays defining convolution masks
    for j=1:n
      w{j,1}=pad_to_make_odd(reshape(W(j,1:m),GP.imDims));
      v{j,1}=pad_to_make_odd(reshape(V(j,1:m),GP.imDims));
      if GP.onoff
        w{j,2}=pad_to_make_odd(reshape(W(j,1+m:2*m),GP.imDims));
        v{j,2}=pad_to_make_odd(reshape(V(j,1+m:2*m),GP.imDims));
      end
    end
    %convert input to a cell array
    X{1}=reshape(x(1:m),GP.imDims);
    if GP.onoff
      X{2}=reshape(x(1+m:2*m),GP.imDims);
    end
    tic;[Y,E,sTrace]=dim_activation_conv(w,v,X);
    %convert output of each convolution to a single response vector 
    y=zeros(n,1,'single');
    for j=1:n
      y(j)=sum(sum(Y{j}));
    end
    e=E{1}(:);
    if GP.onoff
      e=[e;E{2}(:)];
    end
   
  case 'PCBC' 
    tic;[y,e,sTrace]=dim_activation(W,V,x);
    

  %dense representations
  case 'euclid'
    tic;
    for j=1:n
      y(j,1)=sqrt(sum((V(j,:)'-x).^2));
    end
    y=-y; %classification based on similarity not distance!
  case 'CC' %equals NCC if using l2-norm
    tic;y=V*x;

    
  otherwise
    disp('ERROR: unknown solver');
end
totalTime=totalTime+toc;

if ~exist('e','var'), e=x./(V'*y); end

%calculate the NMSE between the input and the reconstruction of the input
nmse=sum((x-(V'*y)).^2)./sum(x.^2);
