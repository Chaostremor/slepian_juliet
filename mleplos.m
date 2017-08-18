function varargout=mleplos(thhats,th0,covF0,covHav,covHpix,E,v,params,name,thpix)
% MLEPLOS(thhats,th0,covF0,covHav,covHpix,E,v,params,name,thpix)
%
% Graphical statistical evaluation of the maximum-likelihood inversion
% results from the suite MLEOS, MLEROS, MLEROS0, MLEOSL. 
%
% INPUT:
%
% thhats     The estimated model parameter vector
% th0        The true model parameter vector
%            th0(1)=D    Isotropic flexural rigidity 
%            th0(2)=f2   The sub-surface to surface initial loading ratio 
%            th0(3)=r    The sub-surface to surface initial correlation coefficient
%            th0(3/4)=s2   The first Matern parameter, aka sigma^2 
%            th0(4/5)=nu   The second Matern parameter 
%            th0(5/6)=rho  The third Matern parameter 
% covF0      The covariance matrix based on the Fisher matrix at the truth
% covHav     The covariance matrix based on the average numerical Hessian
%            matrix at the individual estimates
% covHpix   The covariance matrix based on the numerical Hessian at a random estimate
% E          Young's modulus (not used for single fields)
% v          Poisson's ratio (not used for single fields)
% params     The structure with the fixed parameters from the experiment
% name       A name string for the title
% thpix      The example estimate, randomly picked up
%
% OUTPUT:
%
% ah,ha,yl,xl,tl  Various axis handles of the plots made
%
% EXAMPLE:
%
% This only gets used in MLEOS/MLEROS/MLEROS0/MLEOSL thus far
%
% Last modified by fjsimons-at-alum.mit.edu, 08/17/2017

defval('xver',0)

% Number of times the standard deviation for scale truncation
nstats=[-3:3]; fax=3;
sclth0=10.^round(log10(abs(th0)));
movit=0.01;
labs={'D','f^2','\sigma^2','\nu','\rho',};
labs0={'D_0','f^2_0','\sigma^2_0','\nu_0','\rho_0'};
unts={'Nm' [] [] [] []};
yls=[-0.0 0.75];
% Determines the rounding on the y axis 
rondo=1e2;
% Sets the format for the estimated/true plot labels

% The number of parameters
np=size(thhats,2);
if np==6
  labs={'D','f^2','r','\sigma^2','\nu','\rho'};
  labs0={'D_0','f^2_0','r_0','\sigma^2_0','\nu_0','\rho_0',};
  unts={'Nm' [] [] [] [] []};
elseif np==5
  labs={'D','f^2','\sigma^2','\nu','\rho',};
  labs0={'D_0','f^2_0','\sigma^2_0','\nu_0','\rho_0'};
  unts={'Nm' [] [] [] []};
elseif np==3
  labs={'\sigma^2','\nu','\rho',};
  labs0={'\sigma^2_0','\nu_0','\rho_0'};
  unts={[] [] []};
end

clf
[ah,ha]=krijetem(subnum(2,np));

disp(sprintf('\n'))

% For each of the parameters
for ind=1:np
  % The empirical means and standard deviations of the estimates
  mobs=mean(thhats(:,ind));
  sobs=std(thhats(:,ind));
  % Collect them all
  mobss(ind)=mean(thhats(:,ind));
  sobss(ind)=std(thhats(:,ind));

  % The theoretical means and standard deviations for any one estimate
  th0i=th0(ind);
  if ~isempty(covF0)
    % Error estimate based on the Fisher matrix 
    stdF=real(sqrt(covF0(ind,ind)));
  else
    stdF=NaN;
  end
  % Collect them all
  stdFs(ind)=stdF;

  if ~isempty(covHav)
    % Error estimate based on the median Hessian matrix
    stdH=real(sqrt(covHav(ind,ind)));
  else
    stdH=NaN;
  end
  if ~isempty(covHpix)
    % Error estimate based on one particular randomly picked Hessian
    stdHts=real(sqrt(covHpix(ind,ind)));
  else
    stdHts=NaN;
  end

  % HISTOGRAMS
  axes(ah(ind))
  % The "kernel density estimate"
  % Second input was a different default which we lowered
  [a,bdens,c]=kde(thhats(:,ind),2^8);
  if isinf(a) || any(bdens<-1e-10) || size(thhats,1)<50
    % If it's funky use the good old histogram
    [bdens,c]=hist(thhats(:,ind),min(size(thhats,1)/3,25));
    bdens=bdens/indeks(diff(c),1)/size(thhats(:,ind),1);
  end
  % This number is close to one... it's a proper density!
  if xver==1
    disp(sprintf('%s pdf normalization check by summation %g',...
                 upper(mfilename),sum(bdens)*indeks(diff(c),1)))
  end
  
  % Now plot it using a scale factor to remove the units from the y axis
  thhis(ind)=bar(c,sobs*bdens,1);
  set(ah(ind),'ylim',yls)
  stats=mobs+nstats*sobs;
  % What is the percentage captured within the range?
  nrx=20; nry=15;
  set(ah(ind),'xlim',stats([1 end]),'xtick',stats,'xtickl',nstats)

  % Truth and range based on the Fisher matrix at the truth... 
  hold on
  p0(ind)=plot([th0i th0i],ylim,'k-');
  halfup=indeks(ylim,1)+range(ylim)/2;
  ps(ind)=plot(th0i+[-1 1]*stdF,...
	       [halfup halfup],'k-'); 
  % Didn't like this range bar in the end
  delete(ps(ind))
  
  % Estimate x-axis from observed means and variances
  xnorm=linspace(nstats(1),nstats(end),100)*sobs+mobs;
  % Normal distribution based on the Fisher matrix at the truth
  psF(ind)=plot(xnorm,sobs*normpdf(xnorm,th0i,stdF));
  % Based on the average/median Hessian matrix
  psH(ind)=plot(xnorm,sobs*normpdf(xnorm,th0i,stdH));
  % Based on one of them picked at random, numerical Hessian at estimate
  psh(ind)=plot(xnorm,sobs*normpdf(xnorm,th0i,stdHts));
  % Based on the actually observed covariance of these data
  pth(ind)=plot(xnorm,sobs*normpdf(xnorm,th0i,sobs));

  % Some annotations
  % Experiment size, he giveth, then taketh away
  tu(ind)=text(stats(end)-range(stats)/nrx,indeks(ylim,2)-range(ylim)/nry,...
	      sprintf('N = %i',size(thhats,1))); set(tu(ind),'horizon','r')
  fbb=fillbox(ext2lrtb(tu(ind),[],0.8),'w'); delete(tu(ind)); set(fbb,'EdgeC','w')
  tu(ind)=text(stats(end)-range(stats)/nrx,indeks(ylim,2)-range(ylim)/nry,...
	      sprintf('N = %i',size(thhats,1))); set(tu(ind),'horizon','r')

  % The percentage covered in the histogram that is being shown
  tt(ind)=text(stats(1)+range(stats)/nrx,indeks(ylim,2)-2*range(ylim)/nry,...
	      sprintf('s/%s = %5.2f','\sigma',sobs/stdH)); 
  fb=fillbox(ext2lrtb(tt(ind),[],0.8),'w'); delete(tt(ind)); set(fb,'EdgeC','w')
  tt(ind)=text(stats(1)+range(stats)/nrx,indeks(ylim,2)-2*range(ylim)/nry,...
	      sprintf('s/%s = %5.2f','\sigma',sobs/stdH));

  % The ratio of the observed to the theoretical standard deviation
  t(ind)=text(stats(1)+range(stats)/nrx,indeks(ylim,2)-range(ylim)/nry,...
	      sprintf('%4.2f%s',...
		      sum(bdens([c>=stats(1)&c<=stats(end)])/sum(bdens)*100),...
		      '%'));
  hold off
  xl(ind)=xlabel(labs{ind});

  % QUANTILE-QUANTILE PLOTS  
  axes(ah(ind+np))
  h=qqplot(thhats(:,ind)); delete(h(2))
  set(h(1),'MarkerE','k')  
  set(h(3),'LineS','-','Color',grey)
  top(h(3),ah(ind+np))
  set(ah(ind+np),'xlim',nstats([1 end]),...
		'box','on','xtick',nstats,'xtickl',nstats)
  delete(get(ah(ind+np),'ylabel'));
  delete(get(ah(ind+np),'title'));
  delete(get(ah(ind+np),'xlabel'));
  set(ah(ind+np),'ylim',stats([1 end]),'ytick',stats,...		       
		'ytickl',round(rondo*stats/sclth0(ind))/rondo);
  hold on
  e(ind)=plot(xlim,[mobs mobs],'k:');
  f(ind)=plot([0 0],ylim,'k:');
  bottom(e(ind),ah(ind+np))
  bottom(f(ind),ah(ind+np))
  set(ah(ind+np),'plotbox',[1 1 1])
  if sclth0(ind)~=1
    tl(ind)=title(sprintf('%s = %5.3f %s %4.0e %s',labs{ind},...
			  mobs/sclth0(ind),'x',...
			  sclth0(ind),unts{ind}));
    xl0(ind)=xlabel(sprintf('%s = %5.3f %s %4.0e %s',labs0{ind},...
			    th0(ind)/sclth0(ind),'x',...
			    sclth0(ind),unts{ind}));
  else
    tl(ind)=title(sprintf('%s = %5.3f %s',labs{ind},...
			  mobs/sclth0(ind),...
			  unts{ind}));
    xl0(ind)=xlabel(sprintf('%s = %5.3f %s',labs0{ind},...
			    th0(ind)/sclth0(ind),...
			    unts{ind}));
  end
  movev(xl0(ind),-range(ylim)/15)
  drawnow
end     

% Cosmetics
set(thhis(1:np),'FaceC',grey,'EdgeC',grey)
if np==6
  mv=0.125; mh=0.01; aps1=[0.8 1]; aps2=[1 1];
  set(thhis(4:6),'FaceC',grey(9),'EdgeC',grey(9))
elseif np==5
  mv=0.125; mh=0.01; aps1=[0.8 1]; aps2=[1 1];
  set(thhis(3:5),'FaceC',grey(9),'EdgeC',grey(9))
elseif np==3
  mv=0.1; mh=-0.075; aps1=[1.3 1]; aps2=[1.4 1.4];
end
for ind=1:np-1
  moveh(ha([1:2]+2*(ind-1)),(ind-np)*mh)
end
shrink(ah(1:np),aps1(1),aps1(2))
shrink(ah(np+1:end),aps2(1),aps2(2))

movev(ah(length(ah)/2+1:end),mv)
axes(ah(1))
yl=ylabel('posterior probability density');
longticks(ah)
% Normal distribution based on the Fisher matrix at the truth
set(psF,'linew',0.5,'color','k','LineS','--')
% Based on the average/median Hessian matrix
set(psH,'linew',1.5,'color','k')
% Based on the randomly picked Hessian matrix
set(psh,'linew',0.5,'color','k')
% Based on the actually observed covariance of these data
set(pth,'linew',1.5,'color',grey(3.5))

% Do this so the reduction looks slightly better
set(yl,'FontS',12)
nolabels(ah(2:np),2)
%disp(sprintf('\n'))
fig2print(gcf,'landscape')

% Stick the params here somewhere so we can continue to judge
movev(ah,-.1)
% If params isn't a structure, we're not in the right mindset
if isstruct(params)
  t=ostitle(ah,params,name); movev(t,.4)
end

% Here is the TRUTH and the FISHER-BASED standard deviation
[answ,answs]=osansw(th0,covF0,E,v);
disp(sprintf('%s',...
             'Truth and Fisher-covariance standard deviation at the truth'))
disp(sprintf(answs,answ{:}))
% Here is the mean estimate and its covariance-based standard deviation
[answ,answs]=osansw(mean(thhats),cov(thhats),E,v);
disp(sprintf('\n%s',...
             'Mean estimate and ensemble-covariance standard deviation'))
disp(sprintf(answs,answ{:}))
tt=supertit(ah(np+1:2*np),sprintf(answs,answ{:}));
% Here is the random estimate and its numerical-Hessian based standard deviation
[answ,answs]=osansw(thpix,covHpix,E,v);
disp(sprintf('\n%s',...
             'Example estimate and numerical-Hessian covariance standard deviation'))
disp(sprintf(answs,answ{:}))

if np>3; movev(tt,-4); else; movev(tt,-3.5); end

% Make basic x-y plots of the parameters
if xver==1
  figure
  clf
  pstats=[-2 2]; pcomb=nchoosek(1:np,2);
  [ah,ha]=krijetem(subnum(1,3));
  for ind=1:np
    axes(ah(ind))
    plot(thhats(:,pcomb(ind,1)),thhats(:,pcomb(ind,2)),'o'); hold on
    m(ind)=plot(mobss(pcomb(ind,1)),mobss(pcomb(ind,2)),'o','MarkerFaceC','b');
    % Observed means and observed standard deviations
    o(ind)=plot(mobss(pcomb(ind,1))+pstats*sobss(pcomb(ind,1)),...
		[mobss(pcomb(ind,2)) mobss(pcomb(ind,2))],'LineW',2);
    % Observed means and theoretical standard deviations
    ot(ind)=plot(mobss(pcomb(ind,1))+pstats*stdFs(pcomb(ind,1)),...
		 [mobss(pcomb(ind,2)) mobss(pcomb(ind,2))],'g--');
    % Observed means and observed standard deviations
    t(ind)=plot([mobss(pcomb(ind,1)) mobss(pcomb(ind,1))],...
		mobss(pcomb(ind,2))+pstats*sobss(pcomb(ind,2)),'LineW',2);
    % Observed means and theoretical standard deviations
    tt(ind)=plot([mobss(pcomb(ind,1)) mobss(pcomb(ind,1))],...
		 mobss(pcomb(ind,2))+pstats*stdFs(pcomb(ind,2)),'g--');
    hold off
    % Truths
    set(ah(ind),'xtick',th0(pcomb(ind,1)),'ytick',th0(pcomb(ind,2))); grid on
  end
  seemax([ah(1) ah(2)],1)
  seemax([ah(2) ah(3)],2)
end

% Output
varns={ah,ha,yl,xl,tl};
varargout=varns(1:nargout);

% Subfunction to compute standard deviations
