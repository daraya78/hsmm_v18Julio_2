        function [decodevar] = hsmmresidual_decodelog(self,X,opt_varargin)
            
            n=0;            
            if isempty(opt_varargin)
                program_option;
                n=size(opt_varargin,2);
            elseif isstruct(opt_varargin{1})
                opt=opt_varargin{1};
            else
                program_option;
                n=size(opt_varargin,2);
            end
            ma=[];
            for j=1:2:n
                opt=setfield(opt,opt_varargin{j},opt_varargin{j+1});
            end
        
            dmax=opt.dmax;
            [B2 B]  = self.emis_model.prob(opt.train,X);
            [A2 A]  = self.trans_model.expect(opt.train);
            [in2 in] = self.in_model.expect(opt.train);
            [P2 P]  = self.dur_model.prob(opt.train,(1:1:dmax)');
            T=size(B,1);
            B=B';
            P=P';
            %%%%%%%%%%5
            B2=B2';
            P2=P2';
            
            %%%%%%%%%%%%5
            
            
            m=self.nstates;
            %ALPHA=[in', zeros(m, dmax-1)];
            ALPHA=repmat(in',1,dmax);
            ALPHA2=repmat(in2',1,dmax);  %borrar
            
            
            
            for t=1:T
                %x=repmat(((A'*ALPHA(:,1)).*B(:,t)),1,dmax).*P;
                x=repmat((util.logmultmat(A',ALPHA(:,1))+B(:,t)),1,dmax)+P;
                x2=repmat(((A2'*ALPHA2(:,1)).*B2(:,t)),1,dmax).*P2;   %borrar
                
                %w=ALPHA(:,2:dmax).*repmat(B(:,t),1,dmax-1);
                w=ALPHA(:,2:dmax)+repmat(B(:,t),1,dmax-1);
                w2=ALPHA2(:,2:dmax).*repmat(B2(:,t),1,dmax-1);  %borrar
                
                
                
                %ALPHA=[w,zeros(m,1)]+x;
                ALPHA=util.logsumexpmat([w,-inf(m,1)],x);
                ALPHA2=[w2,zeros(m,1)]+x2;    %borrar
                

                %c(t)=1/sum(ALPHA(:));
                c(t)=-util.logsumexp(ALPHA(:));
                c2(t)=1/sum(ALPHA2(:));  %borrar
                
                
                
                %ALPHA=ALPHA.*c(t); 
                ALPHA=ALPHA+c(t);
                ALPHA2=ALPHA2.*c2(t); %borrar
                
                
                ALPHAx(:,t)=ALPHA(:,1);
                ALPHATOTAL(:,:,t)=ALPHA;
                
                ALPHAx2(:,t)=ALPHA2(:,1); %borrar
                ALPHATOTAL2(:,:,t)=ALPHA2; %borrar
                
                
            end
            %BETA=[ones(m,1),zeros(m,dmax-1)];  %otra opcion
            %BETA=repmat(ones(m,1),1,dmax); 
            BETA=repmat(zeros(m,1),1,dmax);  %borrar 
            BETA2=repmat(ones(m,1),1,dmax); 
            
            
            %BETATOTAL(:,:,T)=BETA;
            BETATOTAL(:,:,T)=BETA;
            BETATOTAL2(:,:,T)=BETA2;   %borrar
            
            
            %GAMMA=sum(ALPHA,2);
            GAMMA=util.logsumexp(ALPHA,2);     %borrar
            GAMMA2=sum(ALPHA2,2);
            
            
            [u,S_est(T)]=max(GAMMA);
            for t=(T-1):-1:1
                %y=B(:,t+1).*c(t+1);
                y=B(:,t+1)+c(t+1);
                y2=B2(:,t+1).*c2(t+1);  %borrar
                
                
                
                %z=y.*(sum((P.*BETA),2));
                z=y+(util.logsumexp((P+BETA),2));
                z2=y2.*(sum((P2.*BETA2),2));
                
                
                %zdur=repmat(y,1,dmax).*P.*BETA;
                %BETA(:,2:dmax)=repmat(y,1,dmax-1).*BETA(:,1:dmax-1);
                %BETA(:,1)=A*z;
                %BETATOTAL(:,:,t)=BETA;
                
                zdur=repmat(y,1,dmax)+P+BETA;
                BETA(:,2:dmax)=repmat(y,1,dmax-1)+BETA(:,1:dmax-1);
                BETA(:,1)=util.logmultmat(A,z);
                BETATOTAL(:,:,t)=BETA;
                
                zdur2=repmat(y2,1,dmax).*P2.*BETA2;
                BETA2(:,2:dmax)=repmat(y2,1,dmax-1).*BETA2(:,1:dmax-1);
                BETA2(:,1)=A2*z2;
                BETATOTAL2(:,:,t)=BETA2;
                
                
                
                
                
                
                %for d=1:dmax
                %    XIdur(:,:,d,t)=(ALPHAx(:,t)*zdur(:,d)'.*A);
                %end
                %XI=(ALPHAx(:,t)*z').*A;
                %XITOTAL(:,:,t)=XI;
                %GAMMA=GAMMA+sum(XI,2)-sum(XI',2);
                %GAMMATOTAL(t,:)=GAMMA;
                %[u,S_est(t)]=max(GAMMA);
                
                
                for d=1:dmax
                    XIdur(:,:,d,t)=(util.logmultmat(ALPHAx(:,t),zdur(:,d)')+A);
                end
                XI=(util.logmultmat(ALPHAx(:,t),z'))+A;
                XITOTAL(:,:,t)=XI;
                XIaux1=util.logsumexpmat(GAMMA,util.logsumexp(XI,2));
                XIaux2=util.logsumexp(XI',2);
                GAMMA=util.logsubexpmat(XIaux1,XIaux2);
                GAMMATOTAL(t,:)=GAMMA;
                [u,S_est(t)]=max(GAMMA);
                
                %%%%%%%%%%%BORRAR%%%%%%%%%
                for d=1:dmax
                    XIdur2(:,:,d,t)=(ALPHAx2(:,t)*zdur2(:,d)'.*A2);
                end
                XI2=(ALPHAx2(:,t)*z2').*A2;
                XITOTAL2(:,:,t)=XI2;
                aux1=GAMMA2+sum(XI2,2);
                aux2=sum(XI2',2);
                GAMMA2=aux1-aux2;
                GAMMATOTAL2(t,:)=GAMMA2;
                [u,S2_est2(t)]=max(GAMMA2);
                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%
                
            end
            
            
            %aux=ALPHATOTAL.*BETATOTAL;
            %aux2=sum(aux,2);
            %for t=1:T
            %    gamma(t,:)=aux2(:,1,t)';
            %end    
            %nor=sum(gamma(10,:));
            %gamma=gamma/nor;
            %XITOTAL=XITOTAL/nor;
            %clear aux
            %aux3=sum(XIdur,1);
            %for t=1:T-1
            %    aux(:,:)=aux3(1,:,:,t);
            %    eta(:,:,t)=aux';
            %end
            %xi=XITOTAL;
            %eta=eta/nor;
            %clear aux;
            %clear aux2;
            %aux=sum(sum(XIdur,1),4);
            %durcount(:,:)=aux(1,:,:)/nor;
            %loglik=sum(log(1./c));
            
            
            aux=ALPHATOTAL+BETATOTAL;
            gamma=squeeze(util.logsumexp(aux,2))';
            nor=util.logsumexp(gamma(10,:),2);
            gamma=gamma-nor;
            XITOTAL=XITOTAL-nor;
            aux3=squeeze(util.logsumexp(XIdur,1)); 
            eta=permute(aux3,[2 1 3])-nor;
            xi=XITOTAL;
            aux=util.logsumexp(util.logsumexp(XIdur,1),4);
            durcount = squeeze(aux(1,:,:))-nor;
            loglik=sum(-c);
            
            
            
            
            
            %%%BORRAR
            aux2=ALPHATOTAL2.*BETATOTAL2;
            gamma2 = squeeze(sum(aux2,2))';   
            
            
            nor2=sum(gamma2(10,:));
            gamma2=gamma2/nor2;
            XITOTAL2=XITOTAL2/nor2;
            clear aux
            aux3=sum(XIdur2,1);
            for t=1:T-1
                aux5(:,:)=aux3(1,:,:,t);
                eta2(:,:,t)=aux5';
            end
            eta5 = permute(squeeze(sum(XIdur2,1)),[2 1 3]);
            
            
            xi2=XITOTAL2;
            eta2=eta2/nor2;
            clear aux;
            clear aux2;
            aux2=sum(sum(XIdur2,1),4);
            durcount2(:,:)=aux2(1,:,:)/nor2;
            loglik2=sum(log(1./c2));
            %%%%%%%%%%%%%%%%%
            
            
            
            
            
            
            
            
            if isnan(loglik)
                'loglik indefinida'
            end
            
            
           % decodevar.alpha2=ALPHA2;
            decodevar.Emi=B; 
            decodevar.alpha=ALPHATOTAL;
            decodevar.beta=BETATOTAL;
            decodevar.scale=c;
            decodevar.gamma=gamma;
            decodevar.eta=eta;
            decodevar.xi=xi;
            decodevar.loglik=loglik;
            
        end
        

