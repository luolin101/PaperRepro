rswitch1=zeros(NUMBER_OF_SUBJECTS,1);
rswitch2=zeros(NUMBER_OF_SUBJECTS,1);
tswitch1=zeros(NUMBER_OF_SUBJECTS,1);
tswitch2=zeros(NUMBER_OF_SUBJECTS,1);
eswitch1=zeros(NUMBER_OF_SUBJECTS,1);
eswitch2=zeros(NUMBER_OF_SUBJECTS,1);
for icounter = 1:NUMBER_OF_SUBJECTS
   if isempty(find(CHOICE_MATRIX(icounter,1:10)==1,1))
       rswitch1(icounter,1)=11;
   else
       rswitch1(icounter,1)=find(CHOICE_MATRIX(icounter,1:10)==1,1);
   end
   if isempty(find(CHOICE_MATRIX(icounter,11:20)==1,1))
       rswitch2(icounter,1)=11;
   else
       rswitch2(icounter,1)=find(CHOICE_MATRIX(icounter,11:20)==1,1);
   end
   if isempty(find(CHOICE_MATRIX(icounter,21:30)==1,1))
       tswitch1(icounter,1)=11;
   else
       tswitch1(icounter,1)=find(CHOICE_MATRIX(icounter,21:30)==1,1);
   end
   if isempty(find(CHOICE_MATRIX(icounter,31:40)==1,1))
       tswitch2(icounter,1)=11;
   else
       tswitch2(icounter,1)=find(CHOICE_MATRIX(icounter,31:40)==1,1);
   end
   if isempty(find(CHOICE_MATRIX(icounter,41:50)==1,1))
       eswitch1(icounter,1)=11;
   else
       eswitch1(icounter,1)=find(CHOICE_MATRIX(icounter,41:50)==1,1);
   end
   if isempty(find(CHOICE_MATRIX(icounter,51:60)==1,1))
       eswitch2(icounter,1)=11;
   else
       eswitch2(icounter,1)=find(CHOICE_MATRIX(icounter,51:60)==1,1);
   end   
end