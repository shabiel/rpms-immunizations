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
 ; ZEXCEPT: BICAT,BIDATE,BIDFN,BILOC,BIOLOC,BISITE
 ; All defined by the Imm package
 ;
 ;---> Visit creating package namespace
 N VSITPKG S VSITPKG="BIV" ; "IMMUNIZATIONS VISTA PORT"
 ;
 ;---> Make sure that the Imm package is allowed to create visits
 I $$PKGON^VSIT("BIV")=-1 N % S %=$$PKG^VSIT("BIV",1)
 ;
 ;---> Patient.
 ; ZEXCEPT: DFN
 S DFN=BIDFN
 ;
 ;---> PCC Date/Time; If no time, 12 noon will be attached.
 N VSIT 
 S VSIT=BIDATE
 S VSIT(0)="N"  ; Controller of how a visit is added on VISTA. N means okay to add a visit.
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
 ; test
 ; ZEXCEPT: PXVNOM Used internally for testing forcing interactiveness
 I $G(PXVNOM),VSIT(0)'["I" S VSIT(0)=VSIT(0)_"I"
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
 ;---> Category.  A=Ambulatory, I=Inpatient, E=Event/Historical.
 ;---> If User said this was an Ambulatory Visit, and if the Inpatient Visit
 ;---> Check Site Parameter is enabled, check to see if patient was an
 ;---> Inpatient on BIDATE; if so, change Category to "I",Inpatient.
 ;
 I BICAT="A",$$INPTCHK^BIUTL2(BISITE),$$INPT^BIUTL11(BIDFN,BIDATE) S BICAT="I"
 S VSIT("SVC")=BICAT
 ;
 ;*** DON'T THINK THIS APPLIES TO VISTA
 ;---> Call to add (create) Visit.
 ;---> NOTE: $G(BICAT)="E" (Historical) will override Active/Inactive
 ;---> selection screen on .01 Field of Immunization File #9999999.14.
 ;*** DON'T THINK THIS APPLIES TO VISTA
 ;
 D ^VSIT
 ;
 ; VSIT("IEN") = -1 -> can't make visit
 ; VSIT("IEN") = -2 -> package is inactive
 I +VSIT("IEN")<0 D ERRCD^BIUTL2(401,.BIERR) S BIERR="1^"_BIERR QUIT
 ;
 Q:$G(BIERR)
 ;
 S BIVSIT=+VSIT("IEN")
 ;
 ;S BITEST=1
 D:$G(BITEST) DISPLAY1^BIPCC
 ;
 Q
 ;
 ;
 ;
TEST D EN^%ut($T(+0),1,1) QUIT
 ;
TCRREG ; @TEST Test Create Regular
 ; BICAT,BIDATE,BIDFN,BILOC,BIOLOC,BISITE
 N BISITE S BISITE=$O(^BISITE(0))
 N BIDFN S BIDFN=1
 N BIDATE S BIDATE=$$FMADD^XLFDT(DT,-$R(9999))
 N BILOC S BILOC=$P($$SITE^VASITE(),U,3)
 N BICAT S BICAT="E"
 N BIVST,BIERR
 ; S PXVNOM=1
 D CREATE(.BIVST,.BIERR)
 D ASSERT(BIVST>0,"Visit should be created.")
 D ASSERT('$D(BIERR),"No error expected")
 QUIT
 ;
TCRHX ; @TEST Test Create Historical
 ; BICAT,BIDATE,BIDFN,BILOC,BIOLOC,BISITE
 N BISITE S BISITE=$O(^BISITE(0))
 N BIDFN S BIDFN=1
 N BIDATE S BIDATE=$$FMADD^XLFDT(DT,-$R(9999))
 N BILOC S BILOC=$P($$SITE^VASITE(),U,3)
 N BICAT S BICAT="E"
 N BIVST,BIERR
 ; S PXVNOM=1
 D CREATE(.BIVST,.BIERR)
 D ASSERT(BIVST>0,"Visit should be created.")
 D ASSERT('$D(BIERR),"No error expected")
 D ASSERT($P(^AUPNVSIT(BIVST,0),U,7)="E","An event is expected.")
 QUIT
 ;
TCRDUP ; @TEST Make sure we don't duplicate a visit
 ; BICAT,BIDATE,BIDFN,BILOC,BIOLOC,BISITE
 N BISITE S BISITE=$O(^BISITE(0))
 N BIDFN S BIDFN=1
 N BIDATE S BIDATE=$$FMADD^XLFDT(DT,-$R(9999))
 N BILOC S BILOC=$P($$SITE^VASITE(),U,3)
 N BICAT S BICAT="A"
 N BIVST,BIERR
 ; S PXVNOM=1
 D CREATE(.BIVST,.BIERR)
 D ASSERT('$D(BIERR),"No error expected")
 D ASSERT(BIVST>0,"Visit should be created.")
 N OLDVISIT S OLDVISIT=BIVST
 K BIVST
 ; S PXVNOM=1
 D CREATE(.BIVST,.BIERR)
 D ASSERT(BIVST=OLDVISIT,"A visit shouldn't be duplicated")
 QUIT
 ;
ASSERT(X,MSG) ; Primitive assertion engine.
 I $D(%ut) D CHKTF^%ut(X,$G(MSG)) QUIT
 I 'X S $EC=",U-ASSERTION-FAILED,"
 QUIT
