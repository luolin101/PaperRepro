clear
global CHOICE_MATRIX RISK_MATRIX TIME_MATRIX EIS_MATRIX1 EIS_MATRIX2 NUMBER_OF_SUBJECTS NUMBER_OF_BOOTS MAX_K BOOTCOUNTER
NUMBER_OF_SUBJECTS=101;
NUMBER_OF_BOOTS=1000;
MAX_K=4;
format compact;
format shortG;
theta_1s=zeros(NUMBER_OF_BOOTS,3);
theta_2s=zeros(NUMBER_OF_BOOTS,7);
theta_3s=zeros(NUMBER_OF_BOOTS,10);
theta_4s=zeros(NUMBER_OF_BOOTS,14);
LL_matrix=zeros(NUMBER_OF_BOOTS,MAX_K);
AIC_matrix=zeros(NUMBER_OF_BOOTS,MAX_K);
BIC_matrix=zeros(NUMBER_OF_BOOTS,MAX_K);
NEC_matrix=zeros(NUMBER_OF_BOOTS,MAX_K);
ICL_matrix=zeros(NUMBER_OF_BOOTS,MAX_K);
for BOOTCOUNTER=1:NUMBER_OF_BOOTS
    %display(BOOTCOUNTER);
    import_data_forboots
    tic    
    C=cell(MAX_K,1);
    T=cell(MAX_K,1);
    Z=cell(MAX_K,1);
    CL=cell(MAX_K,1);
    AIC=zeros(MAX_K,1);
    BIC=zeros(MAX_K,1);
    NEC=zeros(MAX_K,1);
    ICL=zeros(MAX_K,1);
    for K=1:MAX_K
        if K==1
            startpoint=[0.5 0.5 0.5];
        elseif K==2
            %startpoint=[0.5 0.5 C{1}(1) 1 C{1}(2) 0.5 C{1}(1)];
            starter=fminsearch(@(pthetas) -generalized_likelihood([pthetas(1) pthetas(2) C{1}(1) pthetas(3) C{1}(2) pthetas(4) C{1}(3)],K), [0.5 0.5 1 0.5],optimset('MaxFunEvals',100000*4,'MaxIter',100000*4));
            startpoint=[starter(1) starter(2) C{1}(1) starter(3) C{1}(2) starter(4) C{1}(1)];
        elseif K==3
            %startpoint=[1/3 1/3 0.5 C{2}(2) C{2}(3) 1 C{2}(4) C{2}(5) C{2}(6) C{2}(7)];
            starter=fminsearch(@(pthetas) -generalized_likelihood([pthetas(1) (1-pthetas(1))*C{2}(1) pthetas(2) C{2}(2) C{2}(3) pthetas(3) C{2}(4) C{2}(5) C{2}(6) C{2}(7)],K), [1/3 0.5 1],optimset('MaxFunEvals',100000*3,'MaxIter',100000*3));
            startpoint=[starter(1) (1-starter(1))*C{2}(1) starter(2) C{2}(2) C{2}(3) starter(3) C{2}(4) C{2}(5) C{2}(6) C{2}(7)];
        else %K>3 adds a free parameter
            %startpoint=[1/K*ones(1,K-1) C{K-1}(K-1:2*K-3) 0.5 C{K-1}(2*K-2:3*K-4) 0.5 C{K-1}(3*K-3:4*K-6) 0.5];
            starter=fminsearch(@(pthetas) -generalized_likelihood([(1-pthetas(1))*C{K-1}(1:K-2) (1-pthetas(1))*(1-sum(C{K-1}(1:K-2))) C{K-1}(K-1:2*K-3) pthetas(2) C{K-1}(2*K-2:3*K-4) pthetas(3) C{K-1}(3*K-3:4*K-6) pthetas(4)],K), [1/K 0.5 0.5 0.5],optimset('MaxFunEvals',100000*4,'MaxIter',100000*4));
            startpoint=[(1-starter(1))*C{K-1}(1:K-2) (1-starter(1))*(1-sum(C{K-1}(1:K-2))) C{K-1}(K-1:2*K-3) starter(2) C{K-1}(2*K-2:3*K-4) starter(3) C{K-1}(3*K-3:4*K-6) starter(4)];
        end
        %display(startpoint);
        %display(length(startpoint));
        pi_hats=startpoint(1:K-1);
        theta_hats=startpoint(K:length(startpoint));
        old_maximum_likelihood=-Inf('double');
        maximum_likelihood=generalized_likelihood(startpoint,K);
        while abs(maximum_likelihood-old_maximum_likelihood)>0.01
            old_maximum_likelihood=maximum_likelihood;
            old_pi_hats=pi_hats;
            old_theta_hats=theta_hats;
            mean_matrix=mean(generalized_posteriors([pi_hats theta_hats],K));
            pi_hats=mean_matrix(1:K-1);
            theta_hats=fminsearch(@(thetas)-generalized_likelihood([old_pi_hats, thetas],K),old_theta_hats,optimset('MaxFunEvals',100000*length(old_theta_hats),'MaxIter',100000*length(old_theta_hats)));
            maximum_likelihood=generalized_likelihood([pi_hats theta_hats],K);
            if old_maximum_likelihood>maximum_likelihood 
                theta_hats=old_theta_hats;
            end
        end
        C{K}=[pi_hats theta_hats];
        toc;
        %display([num2str(K) ' PARAMETERIZATION FINALIZED']);
        interpret(C{K},K);
        AIC(K)=-2*generalized_likelihood(C{K},K)+2*length(C{K});
        %%display(AIC(K));
        BIC(K)=-2*generalized_likelihood(C{K},K)+length(C{K})*log(numel(CHOICE_MATRIX));
        %display(BIC(K));
        T{K}=generalized_posteriors(C{K},K);
        NEC(K)=-sum(sum(T{K}.*log(T{K})))/(generalized_likelihood(C{K},K)-generalized_likelihood(C{1},1));
        %display(NEC(K));
        Z{K}=(T{K}==(max(T{K},[],2)*ones(1,size(T{K},2))));
        CL{K}=zeros(NUMBER_OF_SUBJECTS,K);
        thetas=C{K};
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
        for ind=1:K
            CL{K}(:,ind)=calculate_L(betas(ind),alphas(ind),rhos(ind),CHOICE_MATRIX,RISK_MATRIX,TIME_MATRIX,EIS_MATRIX1,EIS_MATRIX2);
        end
        ICL(K)=-2*sum(log(sum(Z{K}.*CL{K},2)))-length(C{K})*log(numel(CHOICE_MATRIX));
        %display(ICL(K));
    end
    theta_1s(BOOTCOUNTER,:)=C{1};
    theta_2s(BOOTCOUNTER,:)=C{2};
    theta_3s(BOOTCOUNTER,:)=C{3};
    theta_4s(BOOTCOUNTER,:)=C{4};
    LL_matrix(BOOTCOUNTER,:)=[generalized_likelihood(C{1},1) generalized_likelihood(C{2},2) generalized_likelihood(C{3},3) generalized_likelihood(C{4},4)];
    AIC_matrix(BOOTCOUNTER,:)=AIC;
    BIC_matrix(BOOTCOUNTER,:)=BIC;
    NEC_matrix(BOOTCOUNTER,:)=NEC;
    ICL_matrix(BOOTCOUNTER,:)=ICL;
end
k=clock;
str=['new_boot_data_' num2str(k(2)) num2str(k(3)) num2str(k(4)) num2str(k(5)) 'EM.mat'];
save(str);
xlswrite('boot_output.xls',theta_1s,'theta_1s');
xlswrite('boot_output.xls',theta_2s,'theta_2s');
xlswrite('boot_output.xls',theta_3s,'theta_3s');
xlswrite('boot_output.xls',theta_4s,'theta_4s');
xlswrite('boot_output.xls',LL_matrix,'LL_matrix');
xlswrite('boot_output.xls',AIC_matrix,'AIC_matrix');
xlswrite('boot_output.xls',BIC_matrix,'BIC_matrix');
xlswrite('boot_output.xls',NEC_matrix,'NEC_matrix');
xlswrite('boot_output.xls',ICL_matrix,'ICL_matrix');