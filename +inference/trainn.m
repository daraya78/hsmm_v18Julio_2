function [out] = trainn(self,X,opt_varargin)
    n=0;
    if isempty(opt_varargin)
        program_option;
    elseif isstruct(opt_varargin{1})
        opt=opt_varargin{1};
       
    else
        aux_func.defaultopt;
        n=size(opt_varargin,2);
    end
    for j=1:2:n
        opt=setfield(opt,opt_varargin{j},opt_varargin{j+1});
    end
    
    if strcmp(opt.prepro,'meanvarnor')
        ndata=size(X,1);
        X=(X-repmat(mean(X),ndata,1))./repmat(sqrt(var(X)),ndata,1); 
    end
    
    
    %INITIAL CONDITION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%INIT E-STEP RANDOM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if self.emis_model.posteriorfull();
        decodevar=self.decode(X,opt);
    else 
        decodevar = util.initvb(self,X,opt);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dif=inf;
    cycle=0;
    while dif>opt.tol && cycle<opt.maxcyc
        cycle=cycle+1;     
        %save anterior
        %%%%%%%%%%%%%%%%%%%%%%M-STEP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Upgrade of Observation Model
      
        
        self.emis_model.update(opt.train,X,decodevar.gamma);
        if strcmp(class(self),'hsmm')
            %durcount=sum(decodevar.eta,3);
            %self.dur_model.update(2,(1:opt.dmax)',durcount);
            self.dur_model.update(opt.train,(1:opt.dmax)',decodevar.durcount);
        end
        self.trans_model.update(opt.train,decodevar.xi); %Upgrade of Transition Model 
        self.in_model.update(opt.train,decodevar.gamma(1,:)); %Upgrade of initial Model
        %%%%%%%%%%%%%%%%%%%%%%%E-STEP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        decodevar=self.decode(X,opt);
        %%%%%%%%%%%%%%%%%%FREE ENERGY ESTIMATION %%%%%%%%%%%%%%%%%%%%%%%%%%
        freearray(cycle)=self.elibrefun(decodevar);
        %%%%%%%%%%%%%%%%%%VERBOSE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if strcmp(opt.verbose,'yes')
            if cycle==1
                fprintf('\nIteration Start \n');
            end
            fprintf('It:%3i \tFree Energy:%3.5f \n',cycle,freearray(cycle).fe);
        end
        %%%%%%%%%%%%%%%%%%%FREE ENERGY CONDITION CHECK %%%%%%%%%%%%%%%%%%%%
        if cycle>1
            dif=(freearray(cycle).fe-freearray(cycle-1).fe)/abs(freearray(cycle-1).fe)*100;
            if dif< 0 %-1e-5
                %disp('ERROR')ce
                %save posterior
                %dif
                dif=1;
                %keyboard
            end
        end
    end
    out.fe=freearray(end).fe;
    out.loglik=freearray(end).loglik;
    out.totaldivkl=freearray(end).totaldivkl;
    out.fedetail=freearray;
    out.decodevar=decodevar;
    out.niter=cycle;
    
    
   
end
    
    
    
    
    
    
    
    
    
    
    
    