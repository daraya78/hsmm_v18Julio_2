function [out,sim_array, model] = train(self,data,opt_varargin)
    %Inputs
    % data:         Emission Data
    % opt_varargin: options change of default
    %Output
    % out:          Result Struct
    % ma:
    % sim_array:
    % model:
    
    n=size(opt_varargin,2);
    ent=0;
    for j=1:2:n
        if strcmp(opt_varargin{j},'opt')
            opt=opt_varargin{j+1};
            ent=1;
        end
    end
    if ent==0
    program_option; %Charge Default options
    end
    
    
    ma=[];
    for j=1:2:n
        opt=setfield(opt,opt_varargin{j},opt_varargin{j+1});
    end
    
    
    
    
    
    if ~isempty(self.nstates)
        for j=1:opt.maxitersim
            model(j)=self.copytrain(0);
            sim_array(j)=model(j).trainn(data,opt);
        end
        [a pos2]=max(cell2mat({sim_array.fe}));
        self.copy(model(pos2));
        out=sim_array(pos2);
    else
        ma=-inf(1,opt.maxstates);
        for kstate=opt.minstates:opt.maxstates
            for j=1:opt.maxitersim
                model(j,kstate)=self.copytrain(1,kstate);
                model(j,kstate).in_model.priornoinf();
                model(j,kstate).trans_model.priornoinf();
                sim_array(j,kstate)=model(j,kstate).trainn(data,opt);
            end
            array_ite(:,kstate)=cell2mat({sim_array(:,kstate).fe})';
            [ma(kstate) pos3(kstate)]=max(array_ite(:,kstate));
            if ma(kstate)<ma(kstate-1)
                break
            end
        end
        if ~(ma(kstate)<ma(kstate-1))
            self.copy(model(pos3(kstate),kstate));
            out=sim_array(pos3(kstate),kstate);
        else
            self.copy(model(pos3(kstate-1),kstate-1));
            out=sim_array(pos3(kstate-1),kstate-1);
        end
    end
    
    if strcmp(opt.seq,'maxgamma')
        [a pos2]=max(out.decodevar.gamma');
        out.stateseq=pos2;
    elseif strcmp(opt.seq,'viterbi')
        %HOLD
    end
    out.nstates=length(unique(out.stateseq));
end      
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    
    
    