function f = generalized_posteriors(thetas,K)
    global CHOICE_MATRIX RISK_MATRIX TIME_MATRIX EIS_MATRIX1 EIS_MATRIX2
        post=zeros(101,K);
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
    for ind=1:K
        post(:,ind)=p(ind)*calculate_L(betas(ind),alphas(ind),rhos(ind),CHOICE_MATRIX,RISK_MATRIX,TIME_MATRIX,EIS_MATRIX1,EIS_MATRIX2);
    end
    f=post./(sum(post,2)*ones(1,K));
end
