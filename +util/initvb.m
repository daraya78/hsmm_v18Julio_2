function [decodevar] = initvb(self,X,opt)
    ndataefec=self.emis_model.ndatafun(X);
    if strcmp(opt.initoption,'kmeans')
        ncluster=self.nstates;
        stateseq=kmeans(X,ncluster,'replicates',opt.nrep,'MaxIter',opt.maxiter);
        %load stateseq
        [durationseq stateseqnorep]=util.durseq(stateseq');     
    elseif strcmp(opt.initoption,'random')
        %%%%%%%%%%%%%RANDOM SAMPLE PARAMETER%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        self.init(2);    
        %%%%%%%%%%GENERATE DATA AND DELETE PAR%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [datatmp stateseq ndata stateseqnorep durationseq] = self.gen(ndataefec,'fixedndata','yes');
    elseif strcmp(opt.initoption,'seqprior')
        seqs=opt.seqs;
        nseqs=size(seqs,1);
        if nseqs==1
            if size(size(seqs),2)==3
                stateseq(:,:)=squeeze(seqs(1,:,self.nstates))';
            else
                stateseq=seqs';
            end
        else
            for j=1:nseqs
                opt2=opt;
                model(j)=self.copytrain(0);
                opt2.maxcyc=3;
                opt2.initoption='seqprior';
                opt2.seqs=seqs(j,:,self.nstates);
                %opt2.verbose='no';
                outdata(j)=model(j).trainn(X,opt2);
            end
            [a b]=max([outdata.fe]);
            stateseq=seqs(b,:,self.nstates)';
        end
    end
    %%%%%%%%GENERATE GAMMA, XI AND ETA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    decodevar=util.decodevarinit(stateseq',class(self),opt.dmax,opt);
end