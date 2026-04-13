clear
global NUMBER_OF_SUBJECTS NUMBER_OF_BOOTS
NUMBER_OF_SUBJECTS=101;
NUMBER_OF_BOOTS=1000;
risk1=xlsread('inputs.xls','risk1'); %all data 101x10
risk2=xlsread('inputs.xls','risk2'); %last column contains switchpoint 101x11
time1=xlsread('inputs.xls','time1'); %all data 101x10
time2=xlsread('inputs.xls','time2'); %last column contains switchpoint 101x11
eis1=xlsread('inputs.xls','eis1'); %11th column contains total money divided, last column contains total of choices (useless?)
eis2=xlsread('inputs.xls','eis2'); %last column contains switchpoint 101x11
for bootcounter=1:NUMBER_OF_BOOTS
    display(bootcounter);
    boots_used=random('unid',NUMBER_OF_SUBJECTS,NUMBER_OF_SUBJECTS,1);
    risk1_export=risk1(boots_used,:);
    risk2_export=risk2(boots_used,:);
    time1_export=time1(boots_used,:);
    time2_export=time2(boots_used,:);
    eis1_export=eis1(boots_used,:);
    eis2_export=eis2(boots_used,:);
    fname=['boot inputs\inputb' num2str(bootcounter) '.xls'];
    xlswrite(fname,risk1_export,'risk1');
    xlswrite(fname,risk2_export,'risk2');
    xlswrite(fname,time1_export,'time1');
    xlswrite(fname,time2_export,'time2');
    xlswrite(fname,eis1_export,'eis1');
    xlswrite(fname,eis2_export,'eis2');
end