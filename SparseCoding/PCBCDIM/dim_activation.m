function [y,e,sTrace,yTrace]=dim_activation(W,V,x)
[n,m]=size(W);
sqrtn=sqrt(n);
epsilon1=1e-9;
epsilon2=1e-3;
GP=global_parameters;
if nargout>2, sTrace=zeros(1,GP.iterations); end
if nargout>3, yTrace=zeros(n,GP.iterations); end

%set initial prediction node activations
y=zeros(n,1,'single'); 
%iterate to find steady-state response to input 
for t=1:GP.iterations
  e=x./(epsilon2+(V'*y));
  %e=x./max(epsilon2,(V'*y));
  %e=(epsilon2+x)./(epsilon2+(V'*y));

  y=(epsilon1+y).*(W*e);
  %y=(epsilon1+y).*(1+0.2.*((W*e)-1));
  %y=(epsilon1+y).*(W*(1+tanh(log(e.^2))));
  %y=max(epsilon1,y).*(W*e);
  
  if nargout>2, sTrace(t)=(sqrtn-(sum(y)/sqrt(sum(y.^2))))/(sqrtn-1); end
  if nargout>3, yTrace(:,t)=y; end
end
