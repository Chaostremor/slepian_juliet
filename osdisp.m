function varargout=osdisp(th0,thhats,nl,avhs,Fisher,covF)
% OSDISP(th0,thhats,nl,avhs,Fisher,covF)
% OSDISP(th0,params)
% [str0,str1,str2,str3]=OSDISP(...)
%
% Displays some messages to the command screen for MLEOS, MLEROS, MLEROS0
% and also SIMULOS, SIMULROS, SIMULROS0
%
% INPUT:
%
% th0        True parameter vector
% thhats     Estimated parameter vector, OR
% params     A structure with the fixed parameter settings
% nl         Number of experiments over which the average Hessian is reported
% avhs       Average Hessian matrix at the estimates
% Fisher     Fisher matrix at the truth
% covF       The covariance based on the Fisher matrix at the truth
%
% OUTPUT:
%
% The strings used 
%
% Last modified by fjsimons-at-alum.mit.edu, 11/15/2016

% The necessary strings for formatting
str0='%18s';
str1='%13.5g ';
str2='%13i ';
str3='%13s ';

% Replicate to the size of the parameter vector
str1s=repmat(str1,size(th0));
str2s=repmat(str2,size(th0));
%str1s='%13.0f %13.2f %13.0f';

% Don't use STRUC2ARRAY since we want them in our own order
% But see the reordering solution in OSWZEROB
if isstruct(thhats) && nargin==2
  params=thhats;
  if length(th0)>3
    disp(sprintf(sprintf('\n%s   %s ',str0,repmat(str3,1,10)),...
		 ' ','D1','D2','g','z2','dy','dx','Ny','Nx','blurs','quart'))
    disp(sprintf(sprintf('%s : %s ',str0,repmat(str1,1,10)),...
                 'Parameters',params.DEL,params.g,params.z2,...
                 params.dydx,params.NyNx,params.blurs,params.quart))
  else
    disp(sprintf(sprintf('\n%s   %s ',str0,repmat(str3,1,6)),...
		 ' ','dy','dx','Ny','Nx','blurs','quart'))
    disp(sprintf(sprintf('%s : %s ',str0,repmat(str1,1,6)),...
                 'Parameters',params.dydx,params.NyNx,params.blurs,params.quart))
  end
else
  % Estimated values
  disp(sprintf(sprintf('%s : %s \n',str0,str1s),...
	       'Average estimated theta',mean(thhats,1)))
  % Average numerical Hessian and Fisher matrix at the truth
   disp(sprintf(['Over %i simulations, the average numerical Hessian and' ...
		 ' the Fisher matrix at the truth are'],nl))
   disp(sprintf(...
       '|%4.2f|%s apart on average (the relevant diagn file had the full information)',...
       1/100*round(100*mean(abs([avhs-Fisher]'./Fisher'*100))),'%'))

  % Covariance, relative, empirical, and theoretical
  disp(sprintf(sprintf('%s : %s',str0,str1s),...
	       'Observed standard deviation',std(thhats)))
  disp(sprintf(sprintf('%s : %s',str0,str1s),...
	       'Theortcl standard deviation',sqrt(diag(covF))))
  disp(sprintf(sprintf('%s : %s',str0,str2s),...
	       'Perct of obs to pred stnddv',...
	       round(100*std(thhats)./sqrt(diag(covF)'))))
  disp(sprintf(sprintf('%s : %s\n',str0,str2s),...
	       'Observed percent stand devn',...
	       round(100*std(thhats)./th0)))
end

if length(th0)==6
  disp(sprintf(sprintf('\n%s   %s ',str0,repmat(str3,size(th0))),...
	       ' ','D','f2','r','s2','nu','rho'))
  disp(sprintf(sprintf('%s : %s ',str0,str1s),'True theta',th0))
elseif length(th0)==5
  disp(sprintf(sprintf('\n%s   %s ',str0,repmat(str3,size(th0))),...
	       ' ','D','f2','s2','nu','rho'))
  disp(sprintf(sprintf('%s : %s ',str0,str1s),'True theta',th0))
elseif length(th0)==3
  disp(sprintf(sprintf('\n%s   %s ',str0,repmat(str3,size(th0))),...
	       ' ','s2','nu','rho'))
  disp(sprintf(sprintf('%s : %s ',str0,str1s),'True theta',th0))
end

% Optional output
varns={str0,str1,str2,str3};
varargout=varns(1:nargout);
