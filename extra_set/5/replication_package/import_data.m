clear
global CHOICE_MATRIX RISK_MATRIX TIME_MATRIX EIS_MATRIX1 EIS_MATRIX2 NUMBER_OF_SUBJECTS
NUMBER_OF_SUBJECTS=101;
risk1=xlsread('inputs.xls','risk1'); %all data 101x10
risk2=xlsread('inputs.xls','risk2'); %last column contains switchpoint 101x11
time1=xlsread('inputs.xls','time1'); %all data 101x10
time2=xlsread('inputs.xls','time2'); %last column contains switchpoint 101x11
eis1=xlsread('inputs.xls','eis1'); %11th column contains total money divided, last column contains total of choices (useless?)
eis2=xlsread('inputs.xls','eis2'); %last column contains switchpoint 101x11
CHOICE_MATRIX=[risk1 risk2(:,1:10) time1 time2(:,1:10) eis1(:,1:10) eis2(:,1:10)];
%CHOICE_MATRIX=-1*((-1).^CHOICE_MATRIX);
CHOICE_MATRIX=((-1).^CHOICE_MATRIX);
rswitch=risk2(:,11)/10;
RISK_MATRIX=[ones(NUMBER_OF_SUBJECTS,1)*(0.1:0.1:1) rswitch*ones(1,10)+ones(NUMBER_OF_SUBJECTS,1)*(0.01:0.01:0.1)];
tswitch=time2(:,11)+6;
TIME_MATRIX=[ones(NUMBER_OF_SUBJECTS,1)*(8:1:17) tswitch*ones(1,10)+ones(NUMBER_OF_SUBJECTS,1)*(0.1:0.1:1)]; 
evalue=eis1(:,11);
eswitch=min(0.05*(eis2(:,11)-1),0.45);
EIS_MATRIX1=round(100*diag(evalue)*[ones(NUMBER_OF_SUBJECTS,1)*(0.05:0.05:0.5) eswitch*ones(1,10)+ones(NUMBER_OF_SUBJECTS,1)*(0.005:0.005:0.05)])/100; 
EIS_MATRIX2=evalue*ones(1,20)-EIS_MATRIX1;

