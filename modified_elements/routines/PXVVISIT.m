PXVVISIT ;VEN/SMH - Main VISTA Immunizations Visit Filer;7/2/2015
 ;;0.0;IMMUNIZATIONS VISTA PORT;
 ;
 ; This file contains the main code for interacting with the VISTA
 ; V files from the Ported RPMS Immunizations package
 ;
 ; The callers are BIVISIT and BIVISIT1
 ;
 ; The code here mirrors the RPMS code
 ;
CREATE(BIVSIT,BIERR,BINOM) ; [Private]. Mirror copy of CREATE^BIVISIT1. Called from there.
 ;---> Create a new Visit OR match on an existing Visit in VISIT File.
 ;---> Parameters:
 ;     1 - BIVSIT (ret) IEN of newly created Parent Visit.
 ;     2 - BIERR  (ret) 1^Text of Error Code if any, otherwise null.
 ;     3 - BINOM  (opt) 0=Allow display of Visit Selection Menu if site
 ;                      parameter is set. 1=No display (for export).
 ;
 ;
 D ASSERT(BISITE,"BISITE must be definined by the time you get here")
 ;
 ;---> Visit creating package namespace
 N VSITPKG S VSITPKG="BIV" ; "IMMUNIZATIONS VISTA PORT"
 ;
 ;---> Patient.
 ; ZEXCEPT: DFN
 S DFN=BIDFN
 ;
 ;---> PCC Date/Time; If no time, 12 noon will be attached.
 N VSIT 
 S VSIT=BIDATE
 S VSIT(0)=""  ; Controller of how a visit is added on VISTA.
 ;
 ;---> If Visit Selection Menu is Disabled, create/link automatically:
 ;---> Linking/Adding PCC Visits:
 ;--->    1) If no Visit exists on this date, create one silently.
 ;--->    2) If a Visit exists with exact time match, append to it.
 ;--->    3) If a Visit exists for this date but a different time,
 ;--->          add a new Visit.
 ;
 ;---> If site param says do NOT display Visit Selection Menu, then
 ;---> link or create automatically.
 ;---> Ditto for BINOM
 D
 . I '$$VISMNU^BIUTL2(BISITE) QUIT  ; No
 . I $G(BINOM) QUIT  ; No
 . S VSIT(0)=VSIT(0)_"I" ; interactive
 ;
 ; Institution (BILOC is really IHS Location, which is DINUMMED to file 4).
 ; TODO(VEN/SMH): BILOC may be an empty string. Is VISTA picky about this???
 S VSIT("INS")=BILOC
 ;
 ;---> Other Location (Text if Location="OTHER").
 ; TODO(VEN/SMH): Ditto
 S VSIT("OUT")=$G(BIOLOC)
 ;
 ;---> Set Type of Visit from VISIT TRACK PARAMETERS file (VISTA copy of RPMS
 ;     PCC MASTER CONTROL FILE).
 S VSIT("TYP")=$$GET1^DIQ(150.9,1,.03,"I")
 I VSIT("TYP")="" S VSIT("TYP")="V"
 ;
 ; !!!SAM STOPPED HERE!!!
 ;
 ;---> Category.  A=Ambulatory, I=Inpatient, E=Event/Historical.
 ;---> If User said this was an Ambulatory Visit, and if the Inpatient Visit
 ;---> Check Site Parameter is enabled, check to see if patient was an
 ;---> Inpatient on BIDATE; if so, change Category to "I",Inpatient.
 ;
 I BICAT="A",$$INPTCHK^BIUTL2(BISITE),$$INPT^BIUTL11(BIDFN,BIDATE) S BICAT="I"
 S APCDALVR("APCDCAT")=BICAT
 ;
 ;---> Call to add (create) Visit.
 ;---> NOTE: $G(BICAT)="E" (Historical) will override Active/Inactive
 ;---> selection screen on .01 Field of Immunization File #9999999.14.
 ;
 ;---> If PIMS is loaded, call new API.
 ;---> *** Use this below to test version of BSDAPI4?:
 ;---> I $P($T(BSDAPI4+1^BSDAPI4),"**",2)>1002
 D
 .;---> Check for PIMS (following lines from bottom of APCDAPI4).
 .;I $L($T(^APCDAPI4)),$L($T(VISIT^BSDV)),$L($T(GETVISIT^BSDAPI4)) D NEWCALL Q
 .D OLDCALL
 ;
 Q:$G(BIERR)
 ;
 ;S BITEST=1
 D:$G(BITEST) DISPLAY1^BIPCC
 ;
 ;---> Quit if Visit was not created.
 I '$G(APCDALVR("APCDVSIT"))!($D(APCDALVR("APCDAFLG"))) D  Q
 .D ERRCD^BIUTL2(401,.BIERR) S BIERR="1^"_BIERR
 ;
 ;Returns:  APCDVSIT - Pointer to Visit just selected or created.
 ;          APCDVSIT("NEW") - If ^APCDALVR created a new Visit.
 ;          APCDAFLG - =2 If FAILED to select or create a Visit.
 ;
 ;---> Save IEN of Visit just created.
 S BIVSIT=APCDALVR("APCDVSIT")
 Q
 ;
 ;
ASSERT(X,MSG) ; Primitive assertion engine.
 I 'X S $EC=",U-ASSERTION-FAILED,"
 QUIT
