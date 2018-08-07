classdef hsmm < handle 
    properties
        ndim
        nstates
        in_model
        trans_model
        emis_model
        dur_model
    end
    methods
        function self = hsmm(ndim,nstates,emis_model2,in_model2,trans_model2,dur_model2)
            %Input
            % ndim: Data dimension
            % nstates: States Number (only if it is know)
            % emis_model: Observational model (it is different to default)
            %
            %
            %
            if exist('ndim','var'), self.ndim=ndim; else self.ndim=[]; end
            if exist('nstates','var'), self.nstates=nstates; else self.nstates=[]; end
            if exist('emis_model2','var')
                self.emis_model=emis_model2;
            else
                %e=vari_pdf.normal_normal_gamma(self.ndim,self.nstates);
                e=emis_model.normal_normal_wishart(self.ndim,self.nstates);
                self.emis_model=e;
                self.emis_model.priornoinf();
            end
            if exist('in_model2','var') 
                self.in_model=in_model2;
            else
                i=in_model.categ_dirichlet_in(self.nstates);
                self.in_model=i;
                if ~isempty(self.nstates),self.in_model.priornoinf();end
            end
            if exist('trans_model2','var')
                self.trans_model=trans_model2;
            else
                t=trans_model.categ_dirichlet_matrixdiag0(self.nstates);
                self.trans_model=t;
                if ~isempty(self.nstates),self.trans_model.priornoinf();end
            end
            if exist('dur_model2','var')
                self.dur_model=dur_model2;
            else
                %d=vari_pdf.normal_normal_gamma_disc(1,self.nstates);
                d=dur_model.lognormal_normal_gamma_disc(1,self.nstates);
                self.dur_model=d;
                self.dur_model.priornoinf();
            end       
        end
        function [data, stateseq, ndata,stateseq_norep, durations] = gen(self,ndata,varargin)
            opt.fixedndata='no';   
            for j=1:2:(nargin-2)
                opt=setfield(opt,varargin{j},varargin{j+1});
            end
            idx = 1;
            nextstate_distr = self.in_model.parsampl;
            stateseq = [];
            stateseq_norep = [];
            durations = [];
            while idx <= ndata
                state = util.sample_discrete(nextstate_distr);
                duration = self.dur_model.sample(1,state);
                stateseq_norep = [stateseq_norep, state];
                durations = [durations, duration];
                stateseq = [stateseq, state * ones(1,duration)];
                nextstate_distr = self.trans_model.parsampl(state,:)';
                idx = idx + duration;
            end
            data = [];
            for j = 1:length(durations)
                data=[data; self.emis_model.sample(durations(j),stateseq_norep(j))];
            end
            if strcmp(opt.fixedndata,'no')
                ndata=size(data,1);
            else
                data=data(1:ndata,:);
            end
        end
        function init(self,option)
            self.in_model.parsamplfun(option);
            self.emis_model.parsamplfun(option);
            self.trans_model.parsamplfun(option);
            self.dur_model.parsamplfun(option);
        end
        function [decodevar] = decode(self,X,varargin)  
            [decodevar] = inference.hsmmresidual_decodelog(self,X,varargin);
            %[decodevar] = inference.hsmmresidual_decode(self,X,varargin);
        end
        function [sq delta] = viterbi(self,data,varargin)
            [sq delta] = inference.hsmmresidual_logviterbi(self,data,varargin);
        end
        function [out, sim_array, hsmm2]=train(self,data,varargin)
            [out, sim_array, hsmm2]=inference.train(self,data,varargin);
        end
        function out=trainn(self,data,varargin)
            out=inference.trainn(self,data,varargin);
        end
        function cleanpos(self)
           self.emis_model.cleanpos();
           self.dur_model.cleanpos();
           self.in_model.cleanpos();
           self.trans_model.cleanpos();
        end
        function copy(self,hsmm1)
            self.ndim=hsmm1.ndim;
            self.nstates=hsmm1.nstates;
            self.emis_model.copy(hsmm1.emis_model);
            self.dur_model.copy(hsmm1.dur_model);
            self.in_model.copy(hsmm1.in_model);
            self.trans_model.copy(hsmm1.trans_model);
        end
        function hsmm2=copytrain(self,optcleanpos,nstates)
            if exist('nstates','var')
                newnstates=nstates;
            else
                newnstates=self.nstates;
            end
            pal=class(self.emis_model);
            e=eval([pal '(' num2str(self.ndim)  ')' ]);
            pal=class(self.in_model);
            i=eval([pal '(' num2str(newnstates)  ')' ]);
            pal=class(self.trans_model);
            t=eval([pal '(' num2str(newnstates)  ')' ]);
            pal=class(self.dur_model);
            d=eval([pal '(1)' ]);
            hsmm2=hsmm(self.ndim,newnstates,e,i,t,d);
            %hsmm2=hsmm(self.ndim,newnstates);
            hsmm2.copy(self);
            if optcleanpos==1
                hsmm2.cleanpos();
            end 
            hsmm2.nstates=newnstates;
            hsmm2.emis_model.nstates=newnstates;
            hsmm2.dur_model.nstates=newnstates;
            hsmm2.trans_model.ndim=newnstates;
            hsmm2.in_model.ndim=newnstates;
        end
        
        
        
        function output=elibrefun(self,decodevar)
            self.emis_model.divklfun();
            output.divklobs=self.emis_model.divkl;
            self.in_model.divklfun();
            output.divklin=self.in_model.divkl;
            self.dur_model.divklfun();            
            output.divkldur=self.dur_model.divkl;
            self.trans_model.divklfun();
            output.divkltrans=self.trans_model.divkl;
            output.loglik=decodevar.loglik;
            output.totaldivkl=-output.divkltrans-output.divklobs-output.divkldur- output.divklin;
            output.fe=output.loglik+output.totaldivkl;
        end 
    end
end

