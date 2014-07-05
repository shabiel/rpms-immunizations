BIPATUP1 ;IHS/CMI/MWR - UPDATE PATIENT DATA; DEC 15, 2011
 ;;8.5;IMMUNIZATION;**8**;MAR 15,2014;Build 2
 ;;* MICHAEL REMILLARD, DDS * CIMARRON MEDICAL INFORMATICS, FOR IHS *
 ;;  UPDATE PATIENT DATA, IMM FORECAST IN ^BIPDUE(.
 ;:  PATCH 1: Include FLU-DERMAL CVX=144.  IHSPREL+55
 ;;  PATCH 4, v8.5: Use newer Related Contraindications call to determine
 ;;                 contraindicaton.  IHSPNEU+16
 ;;  PATCH 8: Extensive changes to accommodate new TCH Forecaster   LDFORC+0
 ;
 ;----------
LDFORC(BIDFN,BIFORC,BIHX,BIFDT,BIDUZ2,BINF,BIPDSS) ;EP
 ;---> Load Immserve Data (Immunizations Due) into ^BIPDUE(.
 ;---> Parameters:
 ;     1 - BIDFN  (req) Patient IEN.
 ;     2 - BIFORC (req) String containing Patient's Imms Due.
 ;     3 - BIHX   (req) String containing Patient's Imm History.
 ;     4 - BIFDT  (opt) Forecast Date (date used for forecast).
 ;     5 - BIDUZ2 (opt) User's DUZ(2) indicating site parameters.
 ;     6 - BINF   (opt) Array of Vaccine Grp IEN'S that should not be forecast.
 ;     7 - BIPDSS (ret) Returned string of Visit IEN's that are
 ;                      Problem Doses, according to ImmServe.
 ;
 Q:'$G(BIDFN)  Q:$G(BIFORC)=""  Q:$G(BIHX)=""
 ;---> If no Forecast Date passed, set it equal to today.
 S:'$G(BIFDT) BIFDT=DT S:'$D(BINF) BINF=""
 ;
 ;---> Set Patient Age in months for this Forecast Date.
 N BIAGE S BIAGE=$$AGE^BIUTL1(BIDFN,2,BIFDT)
 ;
 ;---> First clear out any previously set Immunizations Due and
 ;---> any Forecasting Errors for this patient.
 D KILLDUE^BIPATUP2(BIDFN)
 ;
 ;---> If no BIDUZ2, try DUZ(2); otherwise, defaults will be used.
 S:'$G(BIDUZ2) BIDUZ2=$G(DUZ(2))
 ;
 ;********** PATCH 8, v8.5, MAR 15,2014, IHS/CMI/MWR
 ;---> Check for any input doses that TCH identified as problems.
 ;---> Build and return a string of "V IMM IEN_%_CVX" problem doses,
 ;---> as identified in the TCH Input Doses segment.
 ;D DPROBS^BIPATUP2(BIFORC,.BIPDSS,.BIID)
 D DPROBS^BIPATUP2(BIFORC,.BIPDSS)
 ;**********
 ;
 ;---> Parse Doses Due from Forecaster string (BIFORC), perform any
 ;---> necessary translations, and set as due in patient global ^BIPDUE(.
 ;---> If Immserve set Flu due, set BIIMMFL=1.  Same for H1N1.
 N BIIMMFL,BIIMMH1 S BIIMMFL=0,BIIMMH1=0
 ;
 ;********** PATCH 8, v8.5, MAR 15,2014, IHS/CMI/MWR
 ;---> Check if TCH has already forecast Pneumo, pass in BITCHPN.
 ;---> If TCH set Pneumo due, set BITCHPN=1.
 N BITCHPN S BITCHPN=0
 ;D DDUE(BIFORC,BIAGE,BIHX,.BINF,.BIIMMFL,.BIIMMH1,BIDUZ2)
 D DDUE(BIFORC,BIAGE,BIHX,.BINF,.BIIMMFL,.BIIMMH1,BIDUZ2,.BITCHPN,BIFDT)
 ;
 ;---> Collect any Error Codes for any individual Vaccine Groups in
 ;---> the Immserve Forecast and set them in ^BIPERR(
 ;D IMMSERR^BIPATUP2(BIFORC)
 ;
 N BIFLU,BIFFLU,BILIVE,BIRISKI,BIRISKP
 S BIFLU="",(BIFFLU,BILIVE,BIRISKI,BIRISKP)=0
 ;
 ;---> Pre-IHS Forecast Preload.
 D IHSPREL(BIDFN,BIHX,BIFDT,.BIFLU,.BIFFLU,.BIRISKI,.BIRISKP,.BILIVE,BIDUZ2)
 ;
 ;********** PATCH 8, v8.5, MAR 15,2014, IHS/CMI/MWR
 ;---> No longer called, since TCH forecasts Flu for all ages.
 ;---> Forecast Influenza.
 ;D IHSFLU^BIPATUP2(BIDFN,.BIFLU,BIFFLU,BIRISKI,.BINF,BIFDT,BIAGE,BIIMMFL,BIDUZ2)
 ;
 ;---> Forecast Pneumo.
 ;********** PATCH 8, v8.5, MAR 15,2014, IHS/CMI/MWR
 ;---> Only check to forecast Pneumo if TCH has not already done so.
 ;D IHSPNEU(BIDFN,.BIFLU,BIFFLU,BIRISKP,.BINF,BIFDT,BIAGE,BIDUZ2)
 I '$G(BITCHPN) D IHSPNEU(BIDFN,.BIFLU,BIFFLU,BIRISKP,.BINF,BIFDT,BIAGE,BIDUZ2)
 ;
 ;---> Forecast Zostervax.
 ;********** PATCH 8, v8.5, MAR 15,2014, IHS/CMI/MWR
 ;---> No longer forecast Zoster, since TCH does.
 ;D IHSZOS^BIPATUP3(BIDFN,.BIFLU,BIFFLU,BIRISKP,.BINF,BIFDT,BIAGE,BIDUZ2)
 ;**********
 ;
 ;---> Forecast H1N1. v8.33
 ;---> Disable for v8.4.
 ;D IHSH1N1^BIPATUP2(BIDFN,.BIFLU,BIFFLU,BIRISKI,.BINF,BIFDT,BIAGE,BIIMMH1,BILIVE)
 ;
 Q
 ;
 ;
 ;********** PATCH 8, v8.5, MAR 15,2014, IHS/CMI/MWR
 ;---> Add BITCHPN parameter to pass TCH already forecast Pneumo.
 ;----------
DDUE(BIFORC,BIAGE,BIHX,BINF,BIIMMFL,BIIMMH1,BIDUZ2,BITCHPN,BIFDT) ;EP
 ;---> Parse Doses Due from Immserve string (BIFORC), perform any
 ;---> necessary translations, and set as due in patient global ^BIPDUE.
 ;---> Parameters:
 ;     1 - BIFORC  (req) Forecast string coming back from TCH.
 ;     2 - BIAGE   (req) Patient Age in months for this Forecast Date.
 ;     3 - BIHX    (req) String containing Patient's Imm History.
 ;     4 - BINF    (opt) Array of Vaccine Grp IEN'S that should not be forecast.
 ;     5 - BIIMMFL (opt) BIIMMFL=1 means Immserve already forecast Flu.
 ;     6 - BIIMMH1 (opt) BIIMMH1=1 means Immserve already forecast H1N1.
 ;     7 - BIDUZ2  (opt) User's DUZ(2) indicating site parameters.
 ;     8 - BITCHPN (opt) BITCHPN=1 means TCH already forecast Pneumo.
 ;     9 - BIFDT   (opt) Forecast Date (date used for forecast).
 ;
 ;
 ;********** PATCH 8, v8.5, MAR 15,2014, IHS/CMI/MWR
 ;---> Changes to accommodate new TCH Forecaster parsing.
 N BIFORC1,BIDOSE,N
 S BIFORC1=$P(BIFORC,"~~~",3)
 ;
 F N=1:1 S BIDOSE=$P(BIFORC1,"|||",N) Q:(BIDOSE="")  D
 .D DDUE2(BIDOSE,BIAGE,BIHX,.BINF,.BIPC,.BIIMMFL,.BIIMMH1,BIDUZ2,.BITCHPN,BIFDT)
 Q
 ;
 ;
 ;----------
DDUE2(BIDOSE,BIAGE,BIHX,BINF,BIPC,BIIMMFL,BIIMMH1,BIDUZ2,BITCHPN,BIFDT) ;EP
 ;---> Parse Doses Due (see linelabel DDUE above).
 ;---> Parameters: See DDUE immediately above!
 ;
 ;********** PATCH 6, v8.5, MAR 15,2014, IHS/CMI/MWR
 ;---> Many changes below to accommodate new TCH Forecaster.
 ;
 ;---> Uncomment next line to see raw ImmServe Doses Due:
 ;W !!!,BIDOSE R ZZZ
 ;
 N A,BI,D,X S X=BIDOSE
 ;---> A=CVX Code
 S A=$P(X,U,1)
 ;
 ;---> "PAST"=Past Due Indicator
 S BI("PAST")=$P(X,U,3)
 ;
 ;---> Get Fileman formats of due dates.
 ;---> "MIN"=Minimum Date Due
 S BI("MIN")=$$TCHFMDT^BIUTL5($P(X,U,4)) S:('BI("MIN")) BI("MIN")=""
 ;
 ;---> "REC"=Recommended Date Due
 S BI("REC")=$$TCHFMDT^BIUTL5($P(X,U,5)) S:('BI("REC")) BI("REC")=""
 ;
 ;---> "EXC"=Exceeds Date Due
 S BI("EXC")=$$TCHFMDT^BIUTL5($P(X,U,6)) S:('BI("EXC")) BI("EXC")=""
 ;
 ;---> Determine whether to set Recommended Age or Minimum Accepted Age
 ;---> based on Site Parameter.
 S BI("DUE")=BI("REC")
 I $$MINAGE^BIUTL2($G(BIDUZ2))="A" S BI("DUE")=BI("MIN")
 ;
 ;---> If this dose is past due (B=1), D(2) will stuff DATE PAST DUE;
 ;---> Otherwise, D(1) will stuff RECOMMENDED DATE DUE.
 ;S (D(1),D(2))="" D
 ;.I B S D(2)=D Q
 ;.S D(1)=D
 S (D(1),D(2))="" D
 .I BI("PAST") S D(2)=BI("EXC") Q
 .S D(1)=BI("DUE")
 ;
 ;---> *** TRANSLATIONS OF INCOMING IMMSERVE VACCINES:
 ;--->     -------------------------------------------
 ;
 ;---> * * * PNEUMO * * *
 ;---> If incoming Dose is Pneumo (HL7 33 or 109) and the patient is
 ;---> 5 yrs or older, then ignore it; we forecast pneumo below.
 ;---> 100 is for kids; do not intercept.
 ;I BIAGE>59 Q:A=33  Q:A=109
 ;
 ;
 ;********** PATCH 8, v8.5, MAR 15,2014, IHS/CMI/MWR
 ;---> Suppress forecasting of Flu from April 1 to August 1.
 ;---> Turns out TCH can handle this.  Reserve code in case that changes.
 ;I ((A=15)!(A=16)!(A=88)!(A=111)!(A=123)!(A=140)!(A=141)) D
 ;.N BIMDAY S BIMDAY=+$E(BIFDT,4,7)
 ;.S:((BIMDAY>331)&(BIMDAY<801)) A=""
 ;
 Q:A=""
 ;
 ;---> Check to see if Site specified do not forecast this Vaccine Group.
 Q:$D(BINF($$HL7TX^BIUTL2(A,1)))
 ;
 ;---> Add this Immunization Due.
 D SETDUE^BIPATUP2(BIDFN_U_$$HL7TX^BIUTL2(A)_U_U_D(1)_U_D(2))
 ;
 ;********** PATCH 8, v8.5, MAR 15,2014, IHS/CMI/MWR
 ;---> If TCH set Pneumo due, set BITCHPN=1.
 S:(A=33) BITCHPN=1
 ;**********
 ;
 ;---> If Immserve set Flu due, set BIIMMFL=1.
 ;********** PATCH 2, v8.4, OCT 15,2010, IHS/CMI/MWR
 ;---> Include CVX 140 & 141 when checking for Immserve.
 ;S:((A=15)!(A=16)!(A=88)!(A=111)!(A=123)!(A=140)!(A=141)) BIIMMFL=1
 ;
 ;---> If Immserve set H1N1 due, set BIIMMH1=1.
 ;S:((A=125)!(A=126)!(A=127)!(A=128)) BIIMMH1=1
 ;
 Q
 ;
 ;
 ;----------
IHSPREL(BIDFN,BIHX,BIFDT,BIFLU,BIFFLU,BIRISKI,BIRISKP,BILIVE,BIDUZ2) ;EP
 ;---> IHS Forecast Preload.
 ;---> Parameters:
 ;     1 - BIDFN   (req) Patient IEN.
 ;     2 - BIHX    (req) String containing Patient's Imm History.
 ;     3 - BIFDT   (req) Forecast Date (date used for forecast).
 ;     4 - BIFLU   (ret) Influ, Pneumo, & H1N1 History array: BIFLU(CVX,INVDATE).
 ;     5 - BIFFLU  (ret) Value (0-4) for force Flu/Pneumo regardless of age.
 ;     6 - BIRISKI (ret) 1=Patient has Risk of Influenza; otherwise 0.
 ;     7 - BIRISKP (ret) 1=Patient has Risk of Pneumo; otherwise 0.
 ;     8 - BILIVE  (ret) 1-Patient received a LIVE vaccine <28 days before
 ;                       the forecast date.
 ;     9 - BIDUZ2  (req) User's DUZ(2) indicating Immserve Forc Rules.
 ;
 ;---> Loop through History string, gathering previous Influenzas and Pneumos.
 ;
 N BIDOSE,BIHX1,I,X,Y
 S BIHX1=$P(BIHX,"~~~",2)
 ;
 ;---> Loop through RPMS Input String History, collecting for prior Pneumo.
 ;---> Store in BIFLU by HL7 Code, inverse date.
 ;F I=1:1:Y D
 F I=1:1  S BIDOSE=$P(BIHX1,"|||",I) Q:BIDOSE=""  D
 .;
 .;---> For this Immunization, set A=CVX Code, D=Date.
 .N A,D S A=$P(BIDOSE,U,2),D=$P(BIDOSE,U,3)
 .;---> Quit if Dose Override (ImmServe Input Field 51)=Invalid Dose=2.
 .;I $P(BIDOSE,U,5),$P(BIDOSE,U,5)<9 Q
 .;
 .;---> If patient received Flu-nasal CVX 111 on the Forecast Date,
 .;---> then set BILIVE=1 (cannot receive 111 and 125 on the same day).
 .;I ((A=111)&(BIFDT=$$IMMSDT^BIPATUP2(D))) S BILIVE=1
 .;I ((A=111)&(BIFDT=$$TCHFMDT^BIUTL5(D))) S BILIVE=1
 .;
 .;---> If this was a live vaccine given less than 28 days prior to the
 .;---> forecast data, then set BILIVE=1.
 .;I ((A=3)!(A=4)!(A=7)!(A=21)!(A=94)!(A=111)!(A=121)!(A=125)) D
 ..;---> Calculate #days between Forecast date and date of this live vaccine.
 ..;N X,X1,X2 S X1=BIFDT,X2=$$TCHFMDT^BIUTL5(D)
 ..;D ^%DTC
 ..;
 ..;---> Set BILIVE=1 if patient received this LIVE vaccine <28 days prior
 ..;---> to the Forecast date.
 ..;S:((X>0)&(X<28)) BILIVE=1
 .;
 .;---> If this is a Pneumo (33,100,109) or Influ (15,16,88,111; but not 123)
 .;---> store it in local array BIFLU(CVX,Inverse Fileman date).
 .;
 .;********** PATCH 8, v8.5, MAR 15,2014, IHS/CMI/MWR
 .;---> Update Pneumo CVX's.
 .;S:((A=100)!(A=109)) A=33
 .S:((A=100)!(A=109)!(A=133)!(A=152)) A=33
 .;
 .;********** PATCH 3, v8.5, SEP 15,2012, IHS/CMI/MWR
 .;---> Include FLU-TIV's CVX=140 & 141.
 .;S:((A=15)!(A=16)!(A=111)!(A=135)!(A=144)) A=88
 .;S:((A=15)!(A=16)!(A=111)!(A=135)!(A=140)!(A=141)!(A=144)) A=88
 .;**********
 .;S:((A=126)!(A=127)!(A=128)) A=125
 .;---> Add Zoster.  Imm v8.5
 .;S:(A=33!(A=88)!(A=125)) BIFLU(A,9999999-$$IMMSDT^BIPATUP2(D))=""
 .;
 .;********** PATCH 8, v8.5, MAR 15,2014, IHS/CMI/MWR
 .;---> Only concerned with Pneumos.
 .;S:(A=33!(A=88)!(A=125)!(A=121)) BIFLU(A,9999999-$$TCHFMDT^BIUTL5(D))=""
 .S:(A=33) BIFLU(A,9999999-$$TCHFMDT^BIUTL5(D))=""
 .;**********
 .;S X=X+7 OLD IMMSERVE COUNTER.
 ;
 ;
 ;---> Get value for forced Influenza regardless of age.
 ;---> 0=Normal, 1=Influenza, 2=Pneumococcal, 3=Both, 4=Disregard Risk Factors.
 ;S BIFFLU=$$INFL^BIUTL11(BIDFN)
 ;---> Quit (don't check Risk Factors) if BIFFLU=4, Disregard Risk Factors.
 Q:BIFFLU=4
 ;
 ;---> Quit if Site Param says NOT to include Risk Factors.
 Q:'$$RISKP^BIUTL2(BIDUZ2)
 ;
 ;********** PATCH 8, v8.5, MAR 15,2014, IHS/CMI/MWR
 ;---> Only Pneumo will be checked (Flu now forecast for everyone), by
 ;---> passing 2 in the third parameter.
 ;
 ;---> Check for Influenza and Pneumo Risk Factors.
 ;---> If BIRISKI, BIRISKP =0, then either site param is turned off
 ;---> or patient is NOT High Risk.  Both cases exclude it from forecast.
 ;D RISK^BIDX(BIDFN,BIFDT,0,.BIRISKI,.BIRISKP)
 D RISK^BIDX(BIDFN,BIFDT,2,.BIRISKI,.BIRISKP)
 ;**********
 Q
 ;
 ;
 ;----------
IHSPNEU(BIDFN,BIFLU,BIFFLU,BIRISKP,BINF,BIFDT,BIAGE,BIDUZ2) ;EP
 ;---> IHS Pneumo Forecast.
 ;---> Parameters:
 ;     1 - BIDFN   (req) Patient IEN.
 ;     2 - BIFLU   (req) Influ and Pneumo History array: BIFLU(CVX,INVDATE).
 ;     3 - BIFFLU  (req) Value (0-4) for force Flu/Pneumo regardless of age.
 ;     4 - BIRISKP (req) 1=Patient has Risk of Pneumo; otherwise 0.
 ;     5 - BINF    (opt) Array of Vaccine Grp IEN'S that should not be forecast.
 ;     6 - BIFDT   (req) Forecast Date (date used for forecast).
 ;     7 - BIAGE   (req) Patient Age in months for this Forecast Date.
 ;     8 - BIDUZ2  (req) User's DUZ(2) indicating Immserve Forc Rules.
 ;
 ;---> Quit if Forecasting turned off for Pneumo.
 Q:$D(BINF(11))
 ;
 ;---> Quit if this patient has a contraindication to Pneumo.
 ;********** PATCH 4, v8.5, DEC 01,2012, IHS/CMI/MWR
 ;---> Use newer Related Contraindications call to determine contraindicaton.
 ;Q:$$CONTR^BIUTL11(BIDFN,119)
 N BICT D CONTRA^BIUTL11(BIDFN,.BICT)
 Q:$D(BICT(33))
 ;**********
 ;
 ;---> Quit if this Pt Age <60 months (5yrs), regardless of risk.
 Q:BIAGE<60
 ;
 N BIPNAGE,BIMRECNT,BIALLAGE
 ;---> BIPNAGE=Site Parameter Age to forecast Pneumo ("Pneumo Age") in months.
 S BIPNAGE=($P($$PNMAGE^BIPATUP2(BIDUZ2),U)*12)
 ;---> BIMRECNT=Fileman Date of most recent Pneumo.
 S BIMRECNT=(9999999-$O(BIFLU(33,0))) S:BIMRECNT=9999999 BIMRECNT=0
 S BIALLAGE=0
 ;
 ;---> Quit if patient is less than Age Appropriate for Pneumo in years
 ;---> and has already had one Pneumo.
 Q:((BIAGE<BIPNAGE)&(BIMRECNT))
 ;
 ;---> If High Risk Pneumo or Forecast Regardless of Age, set BIALLAGE=1.
 I BIRISKP!(23[BIFFLU) S BIALLAGE=1
 ;
 ;---> Quit if Pt Age < Pneumo Age (on Forecast date) and not forecast for
 ;---> all ages.
 Q:((BIAGE<BIPNAGE)&('BIALLAGE))
 ;
 ;---> If patient has reached site Pneumo Age or has Forced Pneumo AND
 ;---> has NO previous pneumo, then forecast Pneumo and quit.
 I ((BIAGE'<BIPNAGE)!BIALLAGE),'BIMRECNT D  Q
 .D SETDUE^BIPATUP2(BIDFN_U_$$HL7TX^BIUTL2(33)_U_U_BIFDT)
 ;
 ;********** PATCH 8, v8.5, MAR 15,2014, IHS/CMI/MWR
 ;---> TCH will forecast routine Pneumo after age 65.
 Q
 ;---> Quit if patient is <65yrs. (Only patients >65 can get 2nd pneumo.)
 Q:(BIAGE<780)
 ;
 ;---> If patient received most recent Pneumo <65yrs age, and if he received
 ;---> it 5 years before the forecast date, then forecast Pneumo.
 N BIDOB S BIDOB=$$DOB^BIUTL1(BIDFN)
 I BIMRECNT<(BIDOB+650000),((BIMRECNT+50000)'>BIFDT) D  Q
 .D SETDUE^BIPATUP2(BIDFN_U_$$HL7TX^BIUTL2(33)_U_U_BIFDT)
 ;
 ;---> Patient is >65 yrs but had a Pneumo <5 yrs before forecast date,
 ;---> so do not forecast Pneumo yet.
 ;---> OR, patient had most recent Pneumo after age 65 and therefore no
 ;---> longer needs one.  Whew!
 Q
 ;---> If they request to bring back q6y pneumo forecasting, see Q6Y^BIPATUP2.
 Q
