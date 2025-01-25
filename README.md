# Waiting Time Distribution (WTD) Package Project

## Overall Goal
Estimate prescription duration using single prescriptions when days of supply are not available by means
of the non-parametric Waiting Time Distribution: the wtdR package. 

### Introduction
Modeling the duration of drug exposure is a paramount feature of pharmacoepidemiologic research studies. 
When the number of days of supply is not available or reliable, researchers often rely on arbitrary rules 
to define patients’ duration of exposure to medications based on filled prescriptions. The waiting time 
distribution (WTD) is a data-driven approach that uses the empiric distribution of times to the first 
prescription filled by individuals during a specific time window (e.g., a calendar year) relative to a 
given start date to estimate the drug exposure duration (typically, the first day of the calendar year). 
Usually, the 80th percentile of the WTD distribution is used to define the duration of exposure. 

### Background
Previous studies using Scandinavian databases have shown the accuracy of the WTD in estimating the duration of
drug exposure. In such studies, WTD appears more precise in estimating exposure duration for chronic treatments 
requiring refills over relatively constant periods, such as warfarin. However, the same studies show that WTD
is less reliable in estimating the days of supply (and drug utilization) for non-steroidal anti-inflammatory drugs,
which may present a less predictable pattern.

WTD has been proposed to be useful for estimating drug exposure prevalence based on graphical methods.
More recent research studies have used the reverse WTD (using as reference the last day of the calendar year,
and measuring the time from the last prescription rather than the first) and random individual-patient level
indexed dates to estimate the duration of drug supply with enhanced results, especially in the presence of seasonality.
Finally, the identification of prevalent users defined as those presenting prescriptions in the year preceding 
the WTD estimation has been suggested to increase the precision of the WTD estimation.

### Project Scope
Given that as of December 01, 2024, no R software package has been developed to implement such strategies, we, 
the authors (AF and FN), present the wtdR package to:
(i) Estimate conventional WTD and reverse WTD, with customizable features
(ii) Estimate WTD with random individual-patient level index dates, with customizable features
(iii) Produce elegant eCDF plots and histograms based on (i) and (ii)

### Landmark WTD Studies for Reference
1. Hallas J, Gaist D, Bjerrum L. The Waiting Time Distribution as a Graphical Approach to Epidemiologic Measures of Drug Utilization. Epidemiology. 1997;8(6). 
2. Pottegård A, Hallas J. Assigning exposure duration to single prescriptions by use of the waiting time distribution. Pharmacoepidemiol Drug Saf. 2013 Aug;22(8):803–9. 
3. Støvring H, Pottegård A, Hallas J. Determining prescription durations based on the parametric waiting time distribution: Determining Prescription Durations. Pharmacoepidemiol Drug Saf. 2016 Dec;25(12):1451–9. 
4. Bødkergaard K, Selmer RM, Hallas J, Kjerpeseth LJ, Pottegård A, Skovlund E, et al. Using the waiting time distribution with random index dates to estimate prescription durations in the presence of seasonal stockpiling. Pharmacoepidemiol Drug Saf. 2020 Sep;29(9):1072–8.


## License
This work is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 4.0 International License.

!CC BY-NC-ND 4.0
Creative Commons Attribution-NonCommercial-NoDerivs 4.0 International Public License

By exercising the Licensed Rights (defined below), You accept and agree to be bound by the terms and conditions of this Creative Commons Attribution-NonCommercial-NoDerivs 4.0 International Public License ("Public License"). To the extent this Public License may be interpreted as a contract, You are granted the Licensed Rights in consideration of Your acceptance of these terms and conditions, and the Licensor grants You such rights in consideration of benefits the Licensor receives from making the Licensed Material available under these terms and conditions.

Section 1 – Definitions.

a. Adapted Material means material subject to Copyright and Similar Rights that is derived from or based upon the Licensed Material and in which the Licensed Material is translated, altered, arranged, transformed, or otherwise modified in a manner requiring permission under the Copyright and Similar Rights held by the Licensor. For purposes of this Public License, where the Licensed Material is a musical work, performance, or sound recording, Adapted Material is always produced where the Licensed Material is synched in timed relation with a moving image.

b. Adapter's License means the license You apply to Your Copyright and Similar Rights in Your contributions to Adapted Material in accordance with the terms and conditions of this Public License.

c. BY-NC-ND Compatible License means a license listed at https://creativecommons.org/compatiblelicenses, approved by Creative Commons as essentially the equivalent of this Public License.

d. Copyright and Similar Rights means copyright and/or similar rights closely related to copyright including, without limitation, performance, broadcast, sound recording, and Sui Generis Database Rights, without regard to how the rights are labeled or categorized. For purposes of this Public License, the rights specified in Section 2(b)(1)-(2) are not Copyright and Similar Rights.

e. Effective Technological Measures means those measures that, in the absence of proper authority, may not be circumvented under laws fulfilling obligations under Article 11 of the WIPO Copyright Treaty adopted on December 20, 1996, and/or similar international agreements.

f. Exceptions and Limitations means fair use, fair dealing, and/or any other exception or limitation to Copyright and Similar Rights that applies to Your use of the Licensed Material.

g. Licensed Material means the artistic or literary work, database, or other material to which the Licensor applied this Public License.

h. Licensed Rights means the rights granted to You subject to the terms and conditions of this Public License, which are limited to all Copyright and Similar Rights that apply to Your use of the Licensed Material and that the Licensor has authority to license.

i. Licensor means the individual(s) or entity(ies) granting rights under this Public License.

j. NonCommercial means not primarily intended for or directed towards commercial advantage or monetary compensation. For purposes of this Public License, the exchange of the Licensed Material for other material subject to Copyright and Similar Rights by digital file-sharing or similar means is NonCommercial provided there is no payment of monetary compensation in connection with the exchange.

k. Share means to provide material to the public by any means or process that requires permission under the Licensed Rights, such as reproduction, public display, public performance, distribution, dissemination, communication, or importation, and to make material available to the public including in ways that members of the public may access the material from a place and at a time individually chosen by them.

l. Sui Generis Database Rights means rights other than copyright resulting from Directive 96/9/EC of the European Parliament and of the Council of 11 March 1996 on the legal protection of databases, as amended and/or succeeded, as well as other essentially equivalent rights anywhere in the world.

m. You means the individual or entity exercising the Licensed Rights under this Public License. Your has a corresponding meaning.

Section 2 – Scope.

a. License grant.

1. Subject to the terms and conditions of this Public License, the Licensor hereby grants You a worldwide, royalty-free, non-sublicensable, non-exclusive, irrevocable license to exercise the Licensed Rights in the Licensed Material to:

A. reproduce and Share the Licensed Material, in whole or in part, for NonCommercial purposes only; and

B. produce and reproduce, but not Share, Adapted Material for NonCommercial purposes only.

2. Exceptions and Limitations. For the avoidance of doubt, where Exceptions and Limitations apply to Your use, this Public License does not apply and You do not need to comply with its terms and conditions.

3. Term. The term of this Public License is specified in Section 6(a).

4. Media and formats; technical modifications allowed. The Licensor authorizes You to exercise the Licensed Rights in all media and formats whether now known or hereafter created, and to make technical modifications necessary to do so. The Licensor waives and/or agrees not to assert any right or authority to forbid You from making technical modifications necessary to exercise the Licensed Rights, including technical modifications necessary to circumvent Effective Technological Measures. For purposes of this Public License, simply making modifications authorized by this Section 2(a)(4) never produces Adapted Material.

5. Downstream recipients.

A. Offer from the Licensor – Licensed Material. Every recipient of the Licensed Material automatically receives an offer from the Licensor to exercise the Licensed Rights under the terms and conditions of this Public License.

B. No downstream restrictions. You may not offer or impose any additional or different terms or conditions on, or apply any Effective Technological Measures to, the Licensed Material if doing so restricts exercise of the Licensed Rights by any recipient of the Licensed Material.

6. No endorsement. Nothing in this Public License constitutes or may be construed as permission to assert or imply that You are, or that Your use of the Licensed Material is, connected with, or sponsored, endorsed, or granted official status by, the Licensor or others designated to receive attribution as provided in Section 3(a)(1)(A)(i).

b. Other rights.

1. Moral rights, such as the right of integrity, are not licensed under this Public License, nor are publicity, privacy, and/or other similar personality rights; however, to the extent possible, the Licensor waives and/or agrees not to assert any such rights held by the Licensor to the limited extent necessary to allow You to exercise the Licensed Rights, but not otherwise.

2. Patent and trademark rights are not licensed under this Public License.

3. To the extent possible, the Licensor waives any right to collect royalties from You for the exercise of the Licensed Rights, whether directly or through a collecting society under any voluntary or waivable statutory or compulsory licensing scheme. In all other cases the Licensor expressly reserves any right to collect such royalties, including when the Licensed Material is used other than for NonCommercial purposes.

Section 3 – License Conditions.

Your exercise of the Licensed Rights is expressly made subject to the following conditions.

a. Attribution.

1. If You Share the Licensed Material (including in modified form), You must:

A. retain the following if it is supplied by the Licensor with the Licensed Material:

i. identification of the creator(s) of the Licensed Material and any others designated to receive attribution, in any reasonable manner requested by the Licensor (including by pseudonym if designated);

ii. a copyright notice;

iii. a notice that refers to this Public License;

iv. a notice that refers to the disclaimer of warranties;

v. a URI or hyperlink to the Licensed Material to the extent reasonably practicable;

B. indicate if You modified the Licensed Material and retain an indication of any previous modifications; and

C. indicate the Licensed Material is licensed under this Public License, and include the text of, or the URI or hyperlink to, this Public License.

2. You may satisfy the conditions in Section 3(a)(1) in any reasonable manner based on the medium, means, and context in which You Share the Licensed Material. For example, it may be reasonable to satisfy the conditions by providing a URI or hyperlink to a resource that includes the required information.

3. If requested by the Licensor, You must remove any of the information required by Section 3(a)(1)(A) to the extent reasonably practicable.

b. ShareAlike.

1. In addition to the conditions in Section 3(a), if You Share Adapted Material You produce, the following conditions also apply.

A. The Adapter's License You apply must be a Creative Commons license with the same License Elements, this version or later, or a BY-NC-ND Compatible License.

B. You must include the text of, or the URI or hyperlink to, the Adapter's License You apply. You may satisfy this condition in any reasonable manner based on the medium, means, and context in which You Share Adapted Material.

C. You may not offer or impose any additional or different terms or conditions on, or apply any Effective Technological Measures to, Adapted Material that restrict exercise of the rights granted under the Adapter's License You apply.

Section 4 – Sui Generis Database Rights.

Where the Licensed Rights include Sui Generis Database Rights that apply to Your use of the Licensed Material:

a. for the avoidance of doubt, Section 2
