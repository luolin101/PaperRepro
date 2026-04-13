function f = generalized_likelihood(thetas,K)
    %vector shoud contain 4K-2 elements where K is number of groups for
    %K>3, for K=2 7 elements, for K=1 3 elements
    global CHOICE_MATRIX RISK_MATRIX TIME_MATRIX EIS_MATRIX1 EIS_MATRIX2 %COUNTER
    if K>=3
        %three types, one with alpha>rho, one with rho>alpha, and one with
        %alpha=rho the remainder are free from restrictions
        p=[thetas(1:K-1) 1-sum(thetas(1:K-1))];
        betas=thetas(K:2*K-1);
        alphas=thetas(2*K:3*K-1);
        rhos=[thetas(2*K) thetas(3*K:4*K-2)];
        if rhos(2)>=alphas(2) || rhos(3)<=alphas(3)
            f=-Inf('double');
            return;
        end
    elseif K==2
        % one free alpha and rho and another that must be alpha>rho
        p=[thetas(1) 1-thetas(1)];
        betas=thetas(2:3);
        alphas=thetas(4:5);
        rhos=thetas(6:7);
        if rhos(1)>=alphas(1)
            f=-Inf('double');
            return;
        end
    else
        % one type with free alpha and rho
        p=1;
        betas=thetas(1);
        alphas=thetas(2);
        rhos=thetas(3);
    end
    if (sum(rhos<=0)+(sum(p)>1)+sum(betas<=0)+sum(betas>=1)+sum(p<0)+sum(p>1))>=1
    %if rho_1<=0 || rho_2<=0 || rho_3<=0 || alpha_4<=0 || p_1+p_2+p_3>1 || delta_1<=0 || delta_1>1 || delta_2<=0 || delta_2>1 || delta_3<=0 || delta_3>1 || delta_4<=0 || delta_4>1 || alpha_1<=rho_1 || alpha_2>=rho_2 || p_1<0 || p_1>1 || p_2<0 || p_2>1 || p_3<0 || p_3>1
        %display('booted');
        f=-Inf('double'); 
        %return
    else
        f=0;
        for ind=1:K
            f=f+p(ind)*calculate_L(betas(ind),alphas(ind),rhos(ind),CHOICE_MATRIX,RISK_MATRIX,TIME_MATRIX,EIS_MATRIX1,EIS_MATRIX2);
        end
        f=sum(log(f));
        %COUNTER=COUNTER+1;
        %if mod(COUNTER,1000)==0
            %toc;
            %display(COUNTER);
            %display(thetas);
            %display(f);
            %interpret(thetas,K);
        %end        
    end
end
