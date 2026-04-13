log using "C:\Users\abrown\Dropbox\Hagen-Alex\R2\data\STATA_log.log", replace
clear all
import excel using "C:\Users\abrown\Dropbox\Hagen-Alex\R2\data\STATA_data.xlsx", firstrow
label var rswitch1 "switch point, risk-preference task"
label var tswitch1 "switch point, time-preference task"
label var eswitch1 "switch point, intertemporal-substitutability-preference task"
label var rswitch2 "switch point, risk-preference task, second set"
label var tswitch2 "switch point, time-preference task, second set"
label var eswitch2 "switch point, intertemporal-substitutability-preference task, second set"
label var type1_post "posterior probability of type 1, finite mixture model (C=4)"
label var type2_post "posterior probability of type 2, finite mixture model (C=4)"
label var type3_post "posterior probability of type 3, finite mixture model (C=4)"
label var type4_post "posterior probability of type 4, finite mixture model (C=4)"
label var alpha "{&alpha}"
label var beta "{&beta}"
label var rho "{&rho}"
label var choice "uncertainty resolution preference"

//Generates figures 5a-5b
twoway histogram rswitch1, xlabel(1(2)11) ylabel(0(10)30) discrete frequency
graph export "C:\Users\abrown\Documents\Epstein-Zin\revision\results\stata graphs\risk_switch1.pdf", as(pdf) replace

twoway histogram rswitch2, xlabel(1(2)11) ylabel(0(10)30) discrete frequency
graph export "C:\Users\abrown\Documents\Epstein-Zin\revision\results\stata graphs\risk_switch2.pdf", as(pdf) replace

//Generates figures 6a-6b
twoway histogram tswitch1, xlabel(1(2)11) ylabel(0(10)60) discrete frequency
graph export "C:\Users\abrown\Documents\Epstein-Zin\revision\results\stata graphs\time_switch1.pdf", as(pdf) replace

twoway histogram tswitch2, xlabel(1(2)11) ylabel(0(10)60) discrete frequency
graph export "C:\Users\abrown\Documents\Epstein-Zin\revision\results\stata graphs\time_switch2.pdf", as(pdf) replace

//Generates figures 7a-7b
twoway histogram eswitch1, xlabel(1(2)11) ylabel(0(10)65) discrete frequency
graph export "C:\Users\abrown\Documents\Epstein-Zin\revision\results\stata graphs\eis_switch1.pdf", as(pdf) replace

twoway histogram eswitch2, xlabel(1(2)11) ylabel(0(10)65) discrete frequency
graph export "C:\Users\abrown\Documents\Epstein-Zin\revision\results\stata graphs\eis_switch2.pdf", as(pdf) replace

//Generates figures 8a-c
label var alpha "{&alpha} (determined by second switch point)"
twoway histogram alpha, ylabel(0(20)80) frequency
graph export "C:\Users\abrown\Documents\Epstein-Zin\revision\results\stata graphs\hist_alpha.pdf", as(pdf) replace

label var alpha "{&alpha}"

twoway histogram beta, ylabel(0(20)80) frequency
graph export "C:\Users\abrown\Documents\Epstein-Zin\revision\results\stata graphs\hist_beta.pdf", as(pdf) replace

twoway histogram rho, ylabel(0(20)80) frequency
graph export "C:\Users\abrown\Documents\Epstein-Zin\revision\results\stata graphs\hist_rho.pdf", as(pdf) replace

//Generates figures 9a-c
twoway scatter alpha beta if choice==1, jitter(10) msymbol(O) || scatter alpha beta if choice==2, jitter(15) msymbol(Oh) || scatter alpha beta if choice==3, jitter(10) msymbol(X) legend(label(1 "early resolution chosen") label(2 "late resolution chosen") label(3 "neither chosen (indifferent)") label (4 "trend line")) || lfit alpha beta , xtitle("{&beta} (determined by second switch points)") ytitle("{&alpha} (determined by second switch point)")
graph export "C:\Users\abrown\Documents\Epstein-Zin\revision\results\stata graphs\alpha_v_beta.pdf", as(pdf) replace

twoway scatter beta rho if choice==1, jitter(10) msymbol(O) || scatter beta rho if choice==2, jitter(15) msymbol(Oh) || scatter beta rho if choice==3, jitter(10) msymbol(X) legend(label(1 "early resolution chosen") label(2 "late resolution chosen") label(3 "neither chosen (indifferent)") label (4 "trend line")) || lfit beta rho, ytitle("{&beta}")
graph export "C:\Users\abrown\Documents\Epstein-Zin\revision\results\stata graphs\beta_v_rho.pdf", as(pdf) replace

twoway scatter alpha rho if choice==1, jitter(10) msymbol(O) || scatter alpha rho if choice==2, jitter(15) msymbol(Oh) || scatter alpha rho if choice==3, jitter(10) msymbol(X) legend(label(1 "early resolution chosen") label(2 "late resolution chosen") label(3 "neither chosen (indifferent)") label (4 "trend line")) || lfit alpha rho, ytitle("{&alpha}")
graph export "C:\Users\abrown\Documents\Epstein-Zin\revision\results\stata graphs\alpha_v_rho.pdf", as(pdf) replace

//Generates figure 10
twoway scatter alpha rho if choice==1, jitter(10) msymbol(O) || scatter alpha rho if choice==2, jitter(15) msymbol(Oh) || scatter alpha rho if choice==3, jitter(10) msymbol(X) legend(label(1 "early resolution chosen") label(2 "late resolution chosen") label(3 "neither chosen (indifferent)") label (4 "trend line")) || line alpha alpha, xtitle("{&rho}") ytitle("{&alpha}")
graph export "C:\Users\abrown\Documents\Epstein-Zin\revision\results\stata graphs\alpha_v_rho_pred.pdf", as(pdf) replace

//Generates figures A.1(a-c)
twoway scatter rswitch1 tswitch1 if choice==1, jitter(10) msymbol(O) || scatter rswitch1 tswitch1 if choice==2, jitter(15) msymbol(Oh) || scatter rswitch1 tswitch1 if choice==3, jitter(10) msymbol(X) legend(label(1 "early resolution chosen") label(2 "late resolution chosen") label(3 "neither chosen (indifferent)") label (4 "trend line")) || lfit rswitch1 tswitch1, ytitle("switch point, risk-preference task")
graph export "C:\Users\abrown\Documents\Epstein-Zin\revision\results\stata graphs\srisk_v_stime.pdf", as(pdf) replace

twoway scatter rswitch1 eswitch1 if choice==1, jitter(10) msymbol(O) || scatter rswitch1 eswitch1 if choice==2, jitter(15) msymbol(Oh) || scatter rswitch1 eswitch1 if choice==3, jitter(10) msymbol(X) legend(label(1 "early resolution chosen") label(2 "late resolution chosen") label(3 "neither chosen (indifferent)") label (4 "trend line")) || lfit rswitch1 eswitch1, ytitle("switch point, risk-preference task")
graph export "C:\Users\abrown\Documents\Epstein-Zin\revision\results\stata graphs\srisk_v_seis.pdf", as(pdf) replace

twoway scatter tswitch1 eswitch1 if choice==1, jitter(10) msymbol(O) || scatter tswitch1 eswitch1 if choice==2, jitter(15) msymbol(Oh) || scatter tswitch1 eswitch1 if choice==3, jitter(10) msymbol(X) legend(label(1 "early resolution chosen") label(2 "late resolution chosen") label(3 "neither chosen (indifferent)") label (4 "trend line")) || lfit tswitch1 eswitch1, ytitle("switch point, time-preference task")
graph export "C:\Users\abrown\Documents\Epstein-Zin\revision\results\stata graphs\stime_v_seis.pdf", as(pdf) replace

//Generates figures A.2(a-d)
twoway histogram type1_post, frequency
graph export "C:\Users\abrown\Documents\Epstein-Zin\revision\results\stata graphs\type1_hist.pdf", as(pdf) replace
twoway histogram type2_post, frequency
graph export "C:\Users\abrown\Documents\Epstein-Zin\revision\results\stata graphs\type2_hist.pdf", as(pdf) replace
twoway histogram type3_post, frequency
graph export "C:\Users\abrown\Documents\Epstein-Zin\revision\results\stata graphs\type3_hist.pdf", as(pdf) replace
twoway histogram type4_post, frequency
graph export "C:\Users\abrown\Documents\Epstein-Zin\revision\results\stata graphs\type4_hist.pdf", as(pdf) replace

//Generates data for table 1
tabulate rswitch1

//Generates data for table 2
tabulate tswitch1

//Generates data for table 3
tabulate eswitch1

//Generates table 5
regress early early_post
EWreg early early_post 


//Generates table A.1
tobit rswitch1 male age white hh econ height texan barratt ztotal, ll(0) ul(11)
tobit tswitch1 male age white hh econ height texan barratt ztotal, ll(0) ul(11)
tobit eswitch1 male age white hh econ height texan barratt ztotal, ll(0) ul(11)
logit early male age white hh econ height texan barratt ztotal
log close
