clear
import_data
syms alf betf rhof
make_switchpoints
alpha_ests=zeros(NUMBER_OF_SUBJECTS,1);
beta_ests=zeros(NUMBER_OF_SUBJECTS,1);
rho_ests=zeros(NUMBER_OF_SUBJECTS,1);
for icounter= 1:NUMBER_OF_SUBJECTS
    % set bounds on risk questions (probabilities)
    if rswitch1(icounter)==1 && rswitch2(icounter)==1 %the 1,1 case
        p1=RISK_MATRIX(icounter,rswitch1(icounter));
        p2=RISK_MATRIX(icounter,rswitch1(icounter));
        %p2=RISK_MATRIX(icounter,rswitch1(icounter)+1);
    elseif rswitch1(icounter)==11 && rswitch2(icounter)==11 %the 11,11 case
        %p1=RISK_MATRIX(icounter,rswitch1(icounter)-2);
        p1=RISK_MATRIX(icounter,rswitch1(icounter)-1);
        p2=RISK_MATRIX(icounter,rswitch1(icounter)-1);
    elseif rswitch2(icounter)==1 %the x>1,1 case
        p1=RISK_MATRIX(icounter,rswitch1(icounter)-1);
        p2=RISK_MATRIX(icounter,10+rswitch2(icounter));
    elseif rswitch2(icounter)==11 %the x<11,11 case
        p1=RISK_MATRIX(icounter,rswitch1(icounter));
        p2=RISK_MATRIX(icounter,rswitch1(icounter));
    else %the regular case      
        p1=RISK_MATRIX(icounter,10+rswitch2(icounter)-1);
        p2=RISK_MATRIX(icounter,10+rswitch2(icounter));
    end
    % solve for risk parameters (alphas)
    a1=double(solve((p1*8^alf+(1-p1)*6.4^alf)^(1/alf)==(p1*15.4^alf+(1-p1)*0.4^alf)^(1/alf)));
    a2=double(solve((p2*8^alf+(1-p2)*6.4^alf)^(1/alf)==(p2*15.4^alf+(1-p2)*0.4^alf)^(1/alf)));
    %if ~(rswitch1(icounter)==1 && rswitch2(icounter)==1) && ~(rswitch1(icounter)==11&&rswitch2(icounter)==11)
        alpha_ests(icounter)=(a1+a2)/2;
    %elseif (rswitch1(icounter)==1 && rswitch2(icounter)==1) %the 1,1 case
        %alpha_ests(icounter)=a1-(a2-a1)/2;
    %else %the 11,11 case
        %alpha_ests(icounter)=a2+(a2-a1)/2;
    %end
    % set bounds on time questions (amounts)
    if tswitch1(icounter)==1 && tswitch2(icounter)==1 %the 1,1 case
        b1=TIME_MATRIX(icounter,tswitch1(icounter));
        b2=TIME_MATRIX(icounter,tswitch1(icounter));
        %b2=TIME_MATRIX(icounter,tswitch1(icounter)+1);
    elseif tswitch1(icounter)==11 && tswitch2(icounter)==11 %the 11,11 case
        %b1=TIME_MATRIX(icounter,tswitch1(icounter)-2);
        b1=TIME_MATRIX(icounter,tswitch1(icounter)-1);
        b2=TIME_MATRIX(icounter,tswitch1(icounter)-1);
    elseif tswitch2(icounter)==1 %the x>1,1 case
        b1=TIME_MATRIX(icounter,tswitch1(icounter)-1);
        b2=TIME_MATRIX(icounter,10+tswitch2(icounter));
    elseif tswitch2(icounter)==11 %the x<11,11 case
        b1=TIME_MATRIX(icounter,tswitch1(icounter));
        b2=TIME_MATRIX(icounter,tswitch1(icounter));
    else %the regular case      
        b1=TIME_MATRIX(icounter,10+tswitch2(icounter)-1);
        b2=TIME_MATRIX(icounter,10+tswitch2(icounter));
    end
    % set bounds on time questions (amounts)
    if eswitch1(icounter)==1 && eswitch2(icounter)==1 %the 1,1 case
        s11=EIS_MATRIX1(icounter,eswitch1(icounter));
        s12=EIS_MATRIX1(icounter,eswitch1(icounter));
        %s12=EIS_MATRIX1(icounter,eswitch1(icounter)+1);
        s21=EIS_MATRIX2(icounter,eswitch1(icounter));
        s22=EIS_MATRIX2(icounter,eswitch1(icounter));
        %s22=EIS_MATRIX2(icounter,eswitch1(icounter)+1);
    elseif eswitch1(icounter)==11 && eswitch2(icounter)==11 %the 11,11 case
        %s11=EIS_MATRIX1(icounter,eswitch1(icounter)-2);
        s11=EIS_MATRIX1(icounter,eswitch1(icounter)-1);
        s12=EIS_MATRIX1(icounter,eswitch1(icounter)-1);
        %s21=EIS_MATRIX2(icounter,eswitch1(icounter)-2);
        s21=EIS_MATRIX2(icounter,eswitch1(icounter)-1);
        s22=EIS_MATRIX2(icounter,eswitch1(icounter)-1);
    elseif eswitch2(icounter)==1 %the x>1,1 case
        s11=EIS_MATRIX1(icounter,eswitch1(icounter)-1);
        s12=EIS_MATRIX1(icounter,10+eswitch2(icounter));
        s21=EIS_MATRIX2(icounter,eswitch1(icounter)-1);
        s22=EIS_MATRIX2(icounter,10+eswitch2(icounter));
    elseif eswitch2(icounter)==11 %the x<11,11 case
        s11=EIS_MATRIX1(icounter,eswitch1(icounter));
        s12=EIS_MATRIX1(icounter,eswitch1(icounter));
        s21=EIS_MATRIX2(icounter,eswitch1(icounter));
        s22=EIS_MATRIX2(icounter,eswitch1(icounter));
    else %the regular case      
        s11=EIS_MATRIX1(icounter,10+eswitch2(icounter)-1);
        s12=EIS_MATRIX1(icounter,10+eswitch2(icounter));
        s21=EIS_MATRIX2(icounter,10+eswitch2(icounter)-1);
        s22=EIS_MATRIX2(icounter,10+eswitch2(icounter));
    end
    % solve for time, eis parameters (betas, rhos)
    r11=double(solve((s11^rhof+(8/(b1))^rhof*s21^rhof)^(1/rhof)==8,rhof));
    b11=(8/(b1))^r11;
    r12=double(solve((s12^rhof+(8/(b1))^rhof*s22^rhof)^(1/rhof)==8,rhof));
    b12=(8/(b1))^r12;
    r21=double(solve((s11^rhof+(8/(b2))^rhof*s21^rhof)^(1/rhof)==8,rhof));
    b21=(8/(b2))^r21;
    r22=double(solve((s12^rhof+(8/(b2))^rhof*s22^rhof)^(1/rhof)==8,rhof));
    b22=(8/(b2))^r22;
    maxb=max([b11,b12,b21,b22]);
    minb=min([b11,b12,b21,b22]);
    maxr=max([r11,r12,r21,r22]);
    minr=min([r11,r12,r21,r22]);
    %if ~(tswitch1(icounter)==1 && tswitch2(icounter)==1) && ~(tswitch1(icounter)==11&&tswitch2(icounter)==11)
        beta_ests(icounter)=(minb+maxb)/2;
    %elseif (rswitch1(icounter)==1 && rswitch2(icounter)==1) %the 1,1 case
        %beta_ests(icounter)=minb-(maxb-minb)/2;
    %else %the 11,11 case
        %beta_ests(icounter)=maxb+(maxb-minb)/2;
    %end
    %if ~(eswitch1(icounter)==1 && eswitch2(icounter)==1) && ~(eswitch1(icounter)==11&&eswitch2(icounter)==11)
        rho_ests(icounter)=(minr+maxr)/2;
    %elseif (eswitch1(icounter)==1 && eswitch2(icounter)==1) %the 1,1 case
        %rho_ests(icounter)=minr-(maxr-minr)/2;
    %else %the 11,11 case
        %rho_ests(icounter)=maxr+(minr-maxr)/2;
    %end
end