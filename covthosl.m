function varargout=covthosl(th,k,scl)
% [covF,F]=COVTHOSL(th,k,scl)
%
% Calculates the entries of the theoretical unblurred covariance matrix of
% the estimate, indeed the inverse Fisher matrix, hopefully close to the
% expectation of the Hessian of the actual simulations. As seen in Olhede &
% Simons (2013) for the SINGLE-FIELD Matern model.
%
% INPUT:
%
% th       The three-parameter vector (true or estimated) [scaled]:
%          th(1)=s2   The first Matern parameter, aka sigma^2
%          th(2)=nu   The second Matern parameter
%          th(3)=rho  The third Matern parameter
% k        Wavenumber(s) at which the Fisher matrix is evaluated [1/m]
% scl      The vector with any scalings applied to the parameter vector
%
% OUTPUT:
%
% covF     The theoretical covariance matrix between the parameters
% F        The scaled full-form Fisher matrix
%
% EXAMPLE:
%
% [~,th0,p,k]=simulosl([],[],1);
% covF=covthosl(th0,k,1);
% round(sqrt(covF(1,1)))
%
% Last modified by fjsimons-at-alum.mit.edu, 09/29/2016

% Default scaling is none
defval('scl',ones(size(th)))

% Explicitly remove the zero wavenumber from consideration
if ~isempty(k(~k))
  warning(sprintf('%s zero wavenumber',upper(mfilename))); 
end

% First, the Fisher matrix at each wavenumber, unwrapped, unscaled
mcF=Fisherkosl(k,th.*scl);

% Take the expectation and put the elements in the right place
for ind=1:length(mcF)
   % Note below that only half of the full-plane wavenumbers are independent
   mcF{ind}=nanmean(mcF{ind});
end

% The full Fisher matrix
% These will become the variances
F(1,1)=mcF{1};
F(2,2)=mcF{2};
F(3,3)=mcF{3};

% These will be the covariances of D with others
F(1,2)=mcF{4};
F(1,3)=mcF{5};

% These will be the covariances of f2 with others
F(2,3)=mcF{6};

% Returns the unscaled covariance matrix and the scaled Fisher matrix
% Note that only half of the full-plane wavenumbers are independent
[covF,F]=fish2cov(F,scl,length(k(~~k))/2);

% Output
varns={covF,F};
varargout=varns(1:nargout);
