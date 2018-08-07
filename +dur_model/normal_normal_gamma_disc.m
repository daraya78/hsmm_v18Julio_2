classdef normal_normal_gamma_disc < handle
   
    properties
        prior = struct('mean_normal',[], 'prec_gamma',[]); %Sampling of Parameters
        posterior = struct('mean_normal',[], 'prec_gamma',[]); %Sampling of Parameters
        parsampl = struct('mean',[], 'prec',[]); %Sampling of Parameters
        eelog       %Expectation
        divkl       %Divergence
        ndim        %Dimension
        nstates     %States Numbers
    end
    
    methods
        function self=normal_normal_gamma_disc(ndim,nstates)
            if exist('ndim','var'), self.ndim=ndim; else self.ndim=[]; end
            if exist('nstates','var'), self.nstates=nstates; else self.nstates=[]; end
            self.priornoinf();
            self.posterior.mean_normal{1}.mean=[];
            self.posterior.mean_normal{1}.prec=[];
            self.posterior.prec_gamma{1}.shape=[];
            self.posterior.prec_gamma{1}.scale=[];
            self.eelog=[];
            self.divkl=[];
        end
        
        function self=parsamplfun(self,option)
            for j=1:self.nstates
                if option==1
                    self.parsampl.prec{j}=diag(gamrnd(self.posterior.prec_gamma{j}.shape,self.posterior.prec_gamma{j}.scale));
                    self.parsampl.mean{j}=mvnrnd(self.posterior.mean_normal{j}.mean,(self.posterior.mean_normal{j}.prec)^-1);
                elseif option==2
                    if size(self.prior.mean_normal,2)>1
                        self.parsampl.prec{j}=diag(gamrnd(self.prior.prec_gamma{j}.shape,self.prior.prec_gamma{j}.scale));
                        self.parsampl.mean{j}=mvnrnd(self.prior.mean_normal{j}.mean,(self.prior.mean_normal{j}.prec)^-1);
                    else
                        self.parsampl.prec{j}=diag(gamrnd(self.prior.prec_gamma{1}.shape,self.prior.prec_gamma{1}.scale));
                        self.parsampl.mean{j}=mvnrnd(self.prior.mean_normal{1}.mean,(self.prior.mean_normal{1}.prec)^-1);
                    end
                elseif option==3
                    self.parsampl.prec{j}=diag(self.posterior.prec_gamma{j}.shape.*self.posterior.prec_gamma{j}.scale);
                    self.parsampl.mean{j}=self.posterior.mean_normal{j}.mean;   
                elseif option==4
                    flag=size(self.prior.mean_normal,2)>1;
                    k=flag*j+1*(1-flag);
                    self.parsampl.prec{j}=diag(self.prior.prec_gamma{k}.shape.*self.prior.prec_gamma{k}.scale);
                    self.parsampl.mean{j}=self.prior.mean_normal{k}.mean; 
                end
                
                
                
                
            end
        end
        
        function re = sample(self,num,state)
            re = ceil(mvnrnd(self.parsampl.mean{state},inv(self.parsampl.prec{state}),num));
            re = max(1,re);
        end
        
        function [p,plog]=prob(self,opttrain,X,state)
            if ~exist('state','var')
                k1=1;
                k2=self.nstates;
            else
                k1=state;
                k2=k1;
            end
            if strcmp(opttrain,'EM')       % Conventional (pdf)
                conta=1;
                for state=k1:k2
                    p(:,conta)=mvnpdf(X,self.parsampl.mean{state},inv(self.parsampl.prec{state}));
                    conta=conta+1;
                end
            elseif strcmp(opttrain,'VB')  % Variational Bayes
                conta=1;
                for state=k1:k2
                    aux=sum(psi(self.posterior.prec_gamma{state}.shape)+log(self.posterior.prec_gamma{state}.scale));
                    XC = bsxfun(@minus, X, self.posterior.mean_normal{state}.mean);
                    E = trace( diag(self.posterior.prec_gamma{state}.shape.*self.posterior.prec_gamma{state}.scale)*(self.posterior.mean_normal{state}.prec)^-1)+...
                    sum((XC*diag(self.posterior.prec_gamma{state}.shape.*self.posterior.prec_gamma{state}.scale)).*XC,2);
                    plog(:,conta)=repmat(0.5*aux, size(X,1),1)- self.ndim*log(2*pi)- 0.5*E;
                    plog(:,conta)=plog(:,conta)-util.logsumexp(plog(:,conta));
                    p(:,conta)=exp(plog(:,conta));
                    conta=conta+1;
                end
            end
        end
        
        function update (self,opttrain,X,gammain,statereq)
            if ~exist('statereq','var')
                k1=1;
                k2=self.nstates;
            else
                k1=statereq;
                k2=k1;
            end
            if strcmp(opttrain,'EM')    % Used for E.M
                for state=k1:k2
                    if ~exist('statereq','var')
                        gamma=gammain;
                    else
                        gamma=gammain(:,state);
                    end
                    scale=sum(gamma);
                    self.parsampl.mean{state}=sum(X.*repmat(gamma,[1 self.ndim]))/scale;
                    d=(X-ones(length(X),1)*self.parsampl.mean{state});
                    Sigma=(repmat(gamma,[1 self.ndim]).*d)'*d;  %Revisar
                    Sigma=Sigma/scale;
                    self.parsampl.prec{state}=inv(Sigma);
                end
            elseif strcmp(opttrain,'VB') %Used for Variational Bayes
                for state=k1:k2
                    if ~exist('statereq','var')
                        gamma=gammain(:,state);
                    else
                        gamma=gammain;
                    end
                    ndata=size(X,1);
                    Nk = sum(gamma,1);
                    Nk = Nk + 1e-10;
                    xbar = sum(bsxfun(@times, X, gamma)) / Nk;
                    if size(self.prior.mean_normal,2)>1
                        nprior=state;
                    else
                        nprior=1;
                    end
                    R0=self.prior.mean_normal{nprior}.prec;
                    m0=self.prior.mean_normal{nprior}.mean;
                    k0=self.prior.prec_gamma{nprior}.shape;
                    teta0=self.prior.prec_gamma{nprior}.scale;

                    if length(self.posterior.mean_normal)==self.nstates  
                        mk=self.posterior.mean_normal{state}.mean;
                        Rk=self.posterior.mean_normal{state}.prec;        
                    else
                        mk=sum(X.*repmat(gamma,1,self.ndim))./sum(gamma);%Borrar, solo provisorio
                        self.posterior.mean_normal{state}.mean=mk;
                        XC = bsxfun(@minus,X,xbar);
                        Sk = bsxfun(@times, XC, gamma)'*XC / Nk; %
                        %Rk = Nk*inv(Sk);
                        Rk = inv(Sk);
                        self.posterior.mean_normal{state}.prec=Rk;
                    end
                    if Nk < 0.001 % extinguished
                            self.posterior.mean_normal{state}.prec = self.prior.mean_normal{nprior}.prec; 
                            self.posterior.mean_normal{state}.mean = self.prior.mean_normal{nprior}.mean;
                            self.posterior.prec_gamma{state}.shape = self.prior.prec_gamma{nprior}.shape; 
                            self.posterior.prec_gamma{state}.scale = self.prior.prec_gamma{nprior}.scale; 
                    else
                        self.posterior.prec_gamma{state}.shape=Nk/2+k0;
                        aux=sum(repmat(gamma,1,self.ndim).*( (X-repmat(mk,ndata,1)).^2+repmat(1./diag(Rk)',ndata,1) ));
                        self.posterior.prec_gamma{state}.scale = 1./( 1/2*aux+1./teta0 );
                        kk=self.posterior.prec_gamma{state}.shape;
                        tetak=self.posterior.prec_gamma{state}.scale;
                        self.posterior.mean_normal{state}.prec=R0+Nk*diag(kk.*tetak);
                        self.posterior.mean_normal{state}.mean=(m0*R0+xbar*Nk*diag(kk.*tetak))*(self.posterior.mean_normal{state}.prec)^-1;
                    end
                end
            end
        end
        function priornoinf(self,X,varargin)
            opt.prior='default';   
            for j=1:2:(nargin-2)
                opt=setfield(opt,varargin{j},varargin{j+1});
            end
            n=self.ndim;
            if strcmp(opt.prior,'default')
                self.prior.mean_normal{1}.mean=100;
                self.prior.mean_normal{1}.prec=1/(100^2) ;
                self.prior.prec_gamma{1}.shape=0.001;
                self.prior.prec_gamma{1}.scale=1000;
            elseif strcmp(opt.prior,'databased')
                %It must to check this option.
                %It will used for other data
                mean2=mean(X);
                std2=5*std(X);
                self.prior.mean_normal{1}.mean=mean2;
                self.prior.mean_normal{1}.prec=diag(1/((std2)^2));
                self.prior.prec_gamma{1}.shape=1/(std2);
                self.prior.prec_gamma{1}.scale=10/(std2);
            end
        end
       function cleanpos(self)
            self.posterior.mean=[];
            self.posterior.prec=[];
            self.eelog=[];
       end
       function copy(self,o1)
            self.prior = o1.prior;
            self.posterior = o1.posterior;
            self.parsampl = o1.parsampl;
            self.eelog = o1.eelog;
            self.divkl = o1.divkl;
            self.ndim = o1.ndim;
            self.nstates = o1.nstates;
       end 
       
        function []=divklfun(self)
            D=0;
            for state=1:self.nstates
                 if size(self.prior.mean_normal,2)>1
                    R0=self.prior.mean_normal{state}.prec;
                    m0=self.prior.mean_normal{state}.mean;
                    k0=self.prior.prec_gamma{state}.shape;
                    teta0=self.prior.prec_gamma{state}.scale;
                else
                    R0=self.prior.mean_normal{1}.prec;
                    m0=self.prior.mean_normal{1}.mean;
                    k0=self.prior.prec_gamma{1}.shape;
                    teta0=self.prior.prec_gamma{1}.scale;
                end
                Rk=self.posterior.mean_normal{state}.prec;
                mk=self.posterior.mean_normal{state}.mean;
                kk=self.posterior.prec_gamma{state}.shape;
                tetak=self.posterior.prec_gamma{state}.scale; 
                for j=1:self.ndim         
                    D=D+util.Gamma.klgamma(kk(j),1/tetak(j),k0(j),1/teta0(j));   
                end                               
                D=D+util.Normal.spm_kl_normal(mk,inv(Rk),m0,inv(R0));  %Se debe revisar
            end
            self.divkl=D;
        end
    end
end

