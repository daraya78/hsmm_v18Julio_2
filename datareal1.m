j2=5;
archivo{1}='prior0_001_2.mat';
archivo{2}='prior0_0015.mat';
archivo{3}='prior0_002.mat';
archivo{4}='prior0_0025.mat';
archivo{5}='prior0_003.mat';
pal{1}='0.001';
pal{2}='0.0015';
pal{3}='0.002';
pal{4}='0.0025';
pal{5}='0.003';

    
    load(archivo{j2})
    n=size(sim_arrayhsmm,2);
    difloglik=[];
    diftotaldivkl=[];
    for k=2:n-1
        loglik(k)=sim_arrayhsmm(k).loglik;
        totaldivkl(k)=sim_arrayhsmm(k).totaldivkl;
        difloglik(k)=sim_arrayhsmm(k+1).loglik-sim_arrayhsmm(k).loglik;
        diftotaldivkl(k)=sim_arrayhsmm(k+1).totaldivkl-sim_arrayhsmm(k).totaldivkl;
    end
    loglik(n)=sim_arrayhsmm(n).loglik;
    totaldivkl(n)=sim_arrayhsmm(n).totaldivkl;
    
    
    figure
    plot(2:n,difloglik,2:n,-diftotaldivkl,2:n,difloglik,2:n,-diftotaldivkl,'x')
    title(num2str(n-1))
    xlabel('Numero de Estados')
    ylabel('Dif')
    title(['Diferencia Loglik y Divergencia prec=' pal{j2}])
    grid
    
    figure
    plot(2:n,loglik(2:n),2:n,loglik(2:n),2:n,loglik(2:n),2:n,loglik(2:n),'x')
    xlabel('Numero de Estados')
    ylabel('Loglik')
    title(['Loglik prec=' pal{j2}])
    grid
    
    
    figure
    plot(2:n,totaldivkl(2:n),2:n,totaldivkl(2:n),2:n,totaldivkl(2:n),2:n,totaldivkl(2:n),'x')
    xlabel('Numero de Estados')
    ylabel('Divergencia')
    title(['Divergencia prec=' pal{j2}])
    grid
    
    
    figure
    elibre=loglik+totaldivkl;
    plot(2:n,elibre(2:n),2:n,elibre(2:n),2:n,elibre(2:n),2:n,elibre(2:n),'x')
    xlabel('Numero de Estados')
    ylabel('Elibre')
    title(['Energia Libre prec=' pal{j2}])
    grid
     drawnow
 
     
%end
    
    
    


    
    
    
    
