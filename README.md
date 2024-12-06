# Estimating prescription duration using single prescriptions when days of supply are not available by means of the non-parametric Waiting Time Distribution: the wtdR package
This project was developed to meet the requirements for the HMS 520 course, Fall 2024. 

## Overview
Modelling the duration of drug exposure is a paramount feature of pharmacoepidemiologic research studies. When the number of days of supply is not available or reliable, researchers often rely on arbitrary rules to define patients’ duration of exposure to medications based on filled prescriptions. The waiting time distribution (WTD) is a data-driven approach that uses the empiric distribution of times to the first prescription filled by individuals during a specific time window (e.g., a calendar year) relative to a given start date to estimate the drug exposure duration (typically, the first day of the calendar year). Typically, the 80th percentile of the WTD distribution is used to define the duration of exposure. 

Previous studies using Scandinavian databases have showed the accuracy of the WTD to estimate duration of drug exposure. In such studies, WTD appears more precise to estimate the duration of exposure for chronic treatments that require re-fills over relatively constant periods of time, for example, warfarin. However, the same studies show that WTD is less reliable to estimate the days of supply (and drug utilization) for non-steroidal anti-inflammatory drugs, which may present a less predictable pattern. 

WTD have been proposed to be useful to estimating the prevalence of drug exposure based on graphical methods. More recent research studies have used the reverse WTD (using as reference the last day of the calendar year, and measuring the time from the last prescription rather than the first) and random individual-patient level indexed dates to estimate duration of drug supply with enhanced results, especially in the presence of seasonality. Finally, the identification of prevalent users defined as those presenting prescriptions in the year preceding the WTD estimation has been suggested to increase the precision of the WTD estimation. 

Given that as of December 01, 2024, no R software package has been developed to implement such strategies, we, the authors (AF and FN), present the wtdR package to:

(i)	Estimate conventional WTD and reverse WTD, with customizable features, 
(ii)	Estimate WTD with random individual-patient level index dates,  with customizable features,
(iii)	Produce elegant eCDF plots and histograms based on (i) and (ii). 

Landmark studies available on WTD: 
1.	Hallas J, Gaist D, Bjerrum L. The Waiting Time Distribution as a Graphical Approach to Epidemiologic Measures of Drug Utilization. Epidemiology. 1997;8(6). 
2.	Pottegård A, Hallas J. Assigning exposure duration to single prescriptions by use of the waiting time distribution. Pharmacoepidemiol Drug Saf. 2013 Aug;22(8):803–9. 
3.	Støvring H, Pottegård A, Hallas J. Determining prescription durations based on the parametric waiting time distribution: Determining Prescription Durations. Pharmacoepidemiol Drug Saf. 2016 Dec;25(12):1451–9. 
4. Bødkergaard K, Selmer RM, Hallas J, Kjerpeseth LJ, Pottegård A, Skovlund E, et al. Using the waiting time distribution with random index dates to estimate prescription durations in the presence of seasonal stockpiling. Pharmacoepidemiol Drug Saf. 2020 Sep;29(9):1072–8.


