function interpret(thetas,K)
    %vector shoud contain 4K-2 elements where K is number of groups for
    %K>3, for K=2 7 elements, for K=1 3 elements
    if K>=3
        %three types, one with alpha>rho, one with rho>alpha, and one with
        %alpha=rho the remainder are free from restrictions
        p=[thetas(1:K-1) 1-sum(thetas(1:K-1))];
        betas=thetas(K:2*K-1);
        alphas=thetas(2*K:3*K-1);
        rhos=[thetas(2*K) thetas(3*K:4*K-2)];        
    elseif K==2
        % one free alpha and rho and another that must be alpha>rho
        p=[thetas(1) 1-thetas(1)];
        betas=thetas(2:3);
        alphas=thetas(4:5);
        rhos=thetas(6:7);
    else
        % one type with free alpha and rho
        p=1;
        betas=thetas(1);
        alphas=thetas(2);
        rhos=thetas(3);
    end
    disp(['NUMBER OF TYPES:  ', num2str(K)]);
    if K>=3
        str{1}='a=r';
        str{2}='a>r';
        str{3}='a<r';
        str{4}='free';
        disp('type     proportion     beta     alpha     rho');
        for ind=1:K
            disp([str{min(ind,4)},'     ',num2str(p(ind)),'     ',num2str(betas(ind)),'     ',num2str(alphas(ind)),'     ',num2str(rhos(ind))]);
        end
    elseif K==2
        disp('type     proportion     beta     alpha     rho');
        disp(['a<r','     ',num2str(p(1)),'     ',num2str(betas(1)),'     ',num2str(alphas(1)),'     ',num2str(rhos(1))]);
        disp(['free','     ',num2str(p(2)),'     ',num2str(betas(2)),'     ',num2str(alphas(2)),'     ',num2str(rhos(2))]);
    else
        disp('type     proportion     beta     alpha     rho');
        disp(['free','     ',num2str(p(1)),'     ',num2str(betas(1)),'     ',num2str(alphas(1)),'     ',num2str(rhos(1))]);
    end
        disp(['log likelihood:  ', num2str(generalized_likelihood(thetas,K))]);
end
