# Weighted Time Distribution (WTD) Package Project
This project was developed to meet the final project requirements for the HMS 520 course, Fall 2024. 

## Team Members
1. Augusto Ferraris
2. Floria Nyandaya

## Overall Goal
Estimating prescription duration using single prescriptions when days of supply are not available by means
of the non-parametric Waiting Time Distribution: the wtdR package. 

## Introduction
Modeling the duration of drug exposure is a paramount feature of pharmacoepidemiologic research studies. 
When the number of days of supply is not available or reliable, researchers often rely on arbitrary rules 
to define patients’ duration of exposure to medications based on filled prescriptions. The waiting time 
distribution (WTD) is a data-driven approach that uses the empiric distribution of times to the first 
prescription filled by individuals during a specific time window (e.g., a calendar year) relative to a 
given start date to estimate the drug exposure duration (typically, the first day of the calendar year). 
Typically, the 80th percentile of the WTD distribution is used to define the duration of exposure. 

## Background
Previous studies using Scandinavian databases have shown the accuracy of the WTD in estimating the duration of
drug exposure. In such studies, WTD appears more precise to estimate the duration of exposure for chronic
treatments that require re-fills over relatively constant periods of time, for example, warfarin. However,
the same studies show that WTD is less reliable in estimating the days of supply (and drug utilization) for
non-steroidal anti-inflammatory drugs, which may present a less predictable pattern.

WTD has been proposed to be useful to estimating the prevalence of drug exposure based on graphical methods.
More recent research studies have used the reverse WTD (using as reference the last day of the calendar year,
and measuring the time from the last prescription rather than the first) and random individual-patient level
indexed dates to estimate the duration of drug supply with enhanced results, especially in the presence of seasonality.
Finally, the identification of prevalent users defined as those presenting prescriptions in the year preceding 
the WTD estimation has been suggested to increase the precision of the WTD estimation.

## Project Scope
Given that as of December 01, 2024, no R software package has been developed to implement such strategies, we, 
the authors (AF and FN), present the wtdR package to:
(i) Estimate conventional WTD and reverse WTD, with customizable features
(ii) Estimate WTD with random individual-patient level index dates, with customizable features
(iii) Produce elegant eCDF plots and histograms based on (i) and (ii)

## Timeline
1. **Nov 25–29:** Define project scope and objectives 
2. **Nov 28-Dec 8):** Develop WTD Functions 
3. **Dec 6–8):** Perform comprehensive testing of both functions with datasets, ensuring accuracy and performance.  
5. **Dec 9–10:** Complete documentation and presentation preparation, including usage examples
6. **Dec 16–Jan:** Finalize the package and prepare a user manual based on peer reviews and feedback, and plan for deployment 
