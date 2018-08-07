opt.train='VB';
opt.maxcyc=100;%100;
opt.tol=0.001;
opt.dmax=200;
%Kmeans
opt.nrep=10;
opt.maxiter=300;
opt.initoption='kmeans';
%%%%%%%%%%%%%%%%%%
opt.maxitersim=1;
opt.minstates=2;
opt.maxstates=12;
opt.seq='maxgamma';
opt.verbose='yes';
opt.prepro='nothing';
opt.decalpha=0;
opt.decbeta=0;
opt.deceta=0;
opt.prioremis='default';
opt.shareemis = 1;
opt.sharetrans = 0;
opt.sharecond = 0;
opt.sharedur = 0;

