BIHS ;IHS/CMI/MWR - DISPLAY HEALTH SUMMARY; MAY 10, 2010
 ;;8.5;IMMUNIZATION;;SEP 01,2011
 ;;* MICHAEL REMILLARD, DDS * CIMARRON MEDICAL INFORMATICS, FOR IHS *
 ;;  CALLS APCH SOFTWARE TO DISPLAY HEALTH SUMMARY.
 ;;  CALLED BY PROTOCOL: BI HEALTH SUMMARY.
 ;
 ;
 ;----------
HS ;EP
 ; ZEXCEPT: BIDFN
 ;---> Called from Protocol to display Health Summary.
 ;
 Q:'$G(BIDFN)
 N DFN,X,Y
 D FULL^VALM1
 ;
 I '$$RPMS^BIUTL9() D VISTA QUIT
 ;
 ;---> Set Health Summary Type default.
 D
 .;---> Look for user's last choice.
 .N Y S Y=$G(^DISV($G(DUZ),"^APCHSCTL("))
 .S X=$P($G(^APCHSCTL(+Y,0)),U,1)
 .Q:X]""
 .;
 .;---> Get default from PCC MASTER CONTROL File.
 .I $D(^APCCCTRL($G(DUZ(2)),0))#2 S X=$P(^(0),U,3) Q
 .;
 .S X="ADULT REGULAR"
 ;
 ;---> Select Health Summary Type.
 D DIC^BIFMAN(9001015,"QEMA",.Y,,$G(X))
 Q:Y<0
 ;
 N APCHSPAT,APCHSTYP,APCHSTAT,APCHSMTY,AMCHDAYS,AMCHDOB,APCDHDR
 S APCHSTYP=+Y,(APCHSPAT,DFN)=BIDFN
 S APCDHDR="PCC Health Summary for "_$P(^DPT(DFN,0),U)
 D
 .;---> Preserve BIDFN.
 .N BIDFN
 .;---> Call Viewer.
 .D VIEWR^XBLM("EN^APCHS",APCDHDR)
 .;---> Use next line the instead of the previous if there are problems
 .;---> with Listmanager display of Health Summary.  ;MWRZZZ
 .;D HSOUT^APCHS,DIRZ^BIUTL3()
 ;
 Q
 ; 
VISTA ; EP Print VISTA Health Summary
 ; ZEXCEPT: BIDFN
 ; Use IA 242
 N DIC,X,Y,DLAYGO,DINUM,DTOUT,DUOUT 
 S DIC=142,DIC(0)="AEMQ" D ^DIC  ; Select Health Summary type
 I $G(DTOUT)!$G(DUOUT) QUIT
 N TYP S TYP=+Y
 ;
 N %ZIS S %ZIS="Q"  ; queueing allowed
 D ^%ZIS
 Q:$G(POP)
 ;
 I $D(IO("Q")) D  ; queueing requested
 . N ZTRTN,ZTDESC,ZTDTH,ZTIO,ZTUCI,ZTCPU,ZTPRI,ZTSAVE,ZTKIL,ZTSYNC,ZTSK
 . S ZTRTN="ENX^GMTSDVR(BIDFN,TYP)",ZTDTH=$H,ZTDESC="Health Summary from Immunizations Package"
 . S ZTSAVE("BIDFN")="",ZTSAVE("TYP")=""
 . D ^%ZTLOAD
 . I $G(ZTSK) W "Printing off as task number "_ZTSK_" ."
 . E  W "Couldn't task this. Please call support."
 . N DIR,X,Y,DA,DTOUT,DUOUT,DIRUT,DIROUT
 . S DIR(0)="E" D ^DIR
 ;
 E  D  ; no queueing. Print in process.
 . U IO
 . D ENX^GMTSDVR(BIDFN,TYP)
 ;
 D ^%ZISC  ; close device in either case
 QUIT
