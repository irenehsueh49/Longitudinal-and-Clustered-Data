/******************** Homework 1 - Longitudinal and Clustered Data ********************/
libname datasets "C:/Irene Hsueh's Documents/MS Applied Biostatistics/BS 857 - Analysis of Correlated Data/Datasets";
proc format;
	value trt_format 1="High-Dose" 2="Placebo";
run;

title "Converting Wide to Long Format";
data chol;
	set datasets.cholesterol;
		chol=y0; 	time=0;		output;
		chol=y6; 	time=6;		output;
		chol=y12; 	time=12;	output;
		chol=y20; 	time=20;	output;
		chol=y24; 	time=24;	output;
		drop y0 y6 y12 y20 y24;
		format trt trt_format.;
run;
title;

title "Adding Categorical Time Variable";
data chol;
	set chol;
		t = time;
run;
title;

title "National Cooperative Gallstone Study Dataset";
proc print data=chol (obs=20) label;
run;
title;



title "Overall Descriptive Statistics";
proc means data=chol mean std var;
	class time;
	var chol;
run;
title;

title "Descriptive Statistics by Treatment";
proc means data=chol mean std var;
	class time trt;
	var chol;
run;
title;


ODS graphics on;
Proc Glimmix data=chol;
	class time trt;
	model chol = time trt time*trt;
	lsmeans time*trt / plots=(meanplot(join sliceby=trt)); 
run;
ODS graphics off;
ods rtf close;




ODS HTML close;
ODS HTML;




title "Correlation Matrix Between Measurements";
proc corr data=datasets.cholesterol cov;
	var y0 y6 y12 y20 y24;
run;
title;



title "GLS with Known Variance-Covariance Parameters";
proc mixed data=chol;
	class id trt(ref="Placebo") t;
	model chol = trt time / s chisq covb;
	repeated t / subject=id type=un r rcorr;
	parms (2188.94)(1548.99)(1882.99)(1425.72)(1436.20)(1730.27)(1483.76)(1529.31)
			(1277.42)(1796.00)(1469.55)(1590.92)(1500.93)(1372.77)(2436.50) / noiter;
run;
title;

title "GLS with Unknown Variance-Covariance Parameters";
proc mixed data=chol method=mivque0;
	class id trt(ref="Placebo") t;
	model chol = trt time / s chisq covb;
	repeated t / subject=id type=un r rcorr;
run;
title;



title "Maximum Likelihood Estimators";
proc mixed data=chol method=ML covtest;
	class id trt(ref="Placebo") t;
	model chol = trt time / s chisq covb;
	repeated t / subject=id type=un r rcorr;
run;
title;

title "Restricted Maximum Likelihood Estimators";
proc mixed data=chol method=REML;
	class id trt(ref="Placebo") t;
	model chol = trt time / s chisq covb;
	repeated t / subject=id type=un r rcorr;
run;
title;
