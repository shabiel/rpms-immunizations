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
 S VSIT(0)="EN"  ; Controller of how a visit is added on VISTA. 
 ;                 N means okay to add a visit.
 ;                 E means use patient 1ry eligibility
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
 ; ZEXCEPT: PXVNOM Used internally for testing forcing interactiveness
 I $G(PXVNOM),VSIT(0)'["I" S VSIT(0)=VSIT(0)_"I"
 ;
 ;---> Institution
 S VSIT("INS")=DUZ(2)
 ;
 ;---> Hospital Location
 I BICAT'="E" S VSIT("LOC")=BILOC
 ;
 ;---> Other Location (Text if Location="OTHER").
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
 QUIT
 ;
 ;
VFILE(BIVSIT,BIDATA,BIERR) ; [Private] File V data for VISTA. Called from VFILE^BIVISIT.
 ;---> Add (create) V IMMUNIZATION or V SKIN TEST entry for this Visit.
 ;---> Parameters:
 ;     1 - BIVSIT (req) IEN of Parent Visit.
 ;     2 - BIDATA (req) String of data for the Visit to be added.
 ;                      See BIDATA definition at linelabel PARSE.
 ;     3 - BIERR  (ret) Text of Error Code if any, otherwise null.
 ;
 ; TODOs:
 ; - Three skin test fields are missing from VISTA. These need to be brought
 ;   over: 
 ;   -> .08: Skin Test Reader
 ;   -> .09: Skin Test Site
 ;   -> .11: Volume
 ; - RPMS has a field to say "this CPT created me". It something to look into,
 ;   but I don't think I will actually get to supporting it.
 ; - RPMS has a field in V IMM to say whether an Immunization was imported. I
 ;   think a useful thing to have.
 ; - Some random extra fields for RPMS:
 ;   -> Admin Note
 ;
 ; - Edits for Skin tests happened to delete my previous entry. Need to track down.
 ;
 ; NB:
 ;    Adding a CI for a positive PPD is done in such an extremely sloppy way
 ;    in RPMS that I won't port this over. PPD is represented as an Immunization
 ;    not a skin test!
 ;
 I BIDATA="" D ERRCD^BIUTL2(437,.BIERR) S BIERR="1^"_BIERR Q
 ;
 N BIVTYPE,BIDFN,BIPTR,BIDOSE,BILOT,BIDATE,BILOC,BIOLOC,BICAT
 N BIOIEN,BIRES,BIREA,BIDTR,BIREC,BIVISD,BIPROV,BIOVRD,BIINJS,BIVOL
 N BIREDR,BISITE,BICCPT,BIMPRT,BIANOT,BIADMIN,BIVPRES,BIVFC
 ;
 ;---> See BIDATA definition at linelabel PARSE (above).
 D PARSE^BIVISIT(BIDATA,1)
 ;
 ;---> Check that a Parent VISIT exists.
 I '$D(^AUPNVSIT(+$G(BIVSIT),0)) D  Q
 .D ERRCD^BIUTL2(432,.BIERR) S BIERR="1^"_BIERR
 ;
 ;
 N PXVIMM
 ;
 S PXVIMM("PROVIDER",1,"NAME")=DUZ
 S PXVIMM("PROVIDER",1,"PRIMARY")=1
 ;
 ; Notes regarding port.
 ; Dose # in RPMS is disabled. Rm here.
 ; Last modified user in not an explicit field to be set here like in RPMS
 ;
 ; VISTA DEPRECATED/MISSING FIELDS
 ; +-------------------------------------------------------------------+
 ; | RPMS                |  VISTA                                      |
 ; | ------------------- | ------------------------------------------- |
 ; | #.08 DOSE OVERRIDE  |  Available for RPMS; but not used           |
 ; | #.09 INJECTION SITE |  #1302 ROUTE OF ADMINISTRATION  &           |
 ; |                     |  #1303 SITE OF ADMINISTRATION               |
 ; | #.11 VOLUME         |  #1312 DOSAGE                               |
 ; | #.12 DATE OF VIS    |  #2 (Multiple) VIS OFFERED/GIVEN TO PATIENT |
 ; | #.13 CREATED BY V CPT ENTRY | Not used                            |
 ; | #.14 VAC ELIGIBILITY|  Not used                                   |
 ; | #.15 IMPORT FROM... |  Not used                                   |
 ; | #.16 NDC            |  Not used                                   |
 ; | #1 ADMIN NOTES      |  Not used                                   |
 ; | #.17 DATE VIS PRES  |  #2 (see above)                             |
 ; + ------------------- | ------------------------------------------- |
 ;
 I BIVTYPE="I" D
 . S PXVIMM("IMMUNIZATION",1,"IMMUN")=BIPTR              ; Immunization/vaccine name.
 . S PXVIMM("IMMUNIZATION",1,"LOT NUM")=BILOT            ; Lot Number
 . S PXVIMM("IMMUNIZATION",1,"REACTION")=BIREC           ; Reaction
 . S PXVIMM("IMMUNIZATION",1,"ENC PROVIDER")=BIPROV      ; Shot provider
 . S PXVIMM("IMMUNIZATION",1,"DOSE")=BIVOL               ; Dosage (e.g. 0.5 mL)
 . S PXVIMM("IMMUNIZATION",1,"DOSE UNITS")=$$FIND1^DIC(757.5,,"QX","mL","C")          ; Dose Units (New in *210)
 . S PXVIMM("IMMUNIZATION",1,"ADMIN ROUTE")=$P(BIINJS,"-")       ; Injection Site Route
 . S PXVIMM("IMMUNIZATION",1,"ANATOMIC LOC")=$P(BIINJS,"-",2) ; Injection Site Site
 . S PXVIMM("IMMUNIZATION",1,"EVENT D/T")=BIADMIN        ; Administration Date (not time yet)
 . S PXVIMM("IMMUNIZATION",1,"VIS",1,0)=$S(BIVISD="":"@",1:BIVISD_U_BIVPRES) ; Vaccine Info Statement (#920) ^ Presentation Date
 ;
 ; NB: RPMS has these extra fields, which are not in VISTA:
 ; .08: Skin Test Reader
 ; .09: Skin Test Site
 ; .11: Volume
 I BIVTYPE="S" D
 . S PXVIMM("SKIN TEST",1,"TEST")=BIPTR                  ; Skin Test
 . S PXVIMM("SKIN TEST",1,"RESULT")=BIRES                ; Result
 . S PXVIMM("SKIN TEST",1,"READING")=BIREA               ; Reading
 . S PXVIMM("SKIN TEST",1,"D/T READ")=BIDTR              ; Date Read
 . S PXVIMM("SKIN TEST",1,"ENC PROVIDER")=BIPROV         ; Skin test provider
 ;
 ; $$DATA2PCE^PXAPI(INPUTROOT,PKG,SOURCE,.VISIT,USER,ERRDISP,.ERRARRAY,PPEDIT,.ERRPROB, .ACCOUNT)
 N % S %=$$DATA2PCE^PXAPI($NAME(PXVIMM),"BIV","IMMUNIZATION PACKAGE",.BIVSIT,BIPROV,1)
 ;
 I %'=1 D  QUIT
 .I BIVTYPE="I" D ERRCD^BIUTL2(402,.BIERR) S BIERR="1^"_BIERR Q
 .I BIVTYPE="S" D ERRCD^BIUTL2(413,.BIERR) S BIERR="1^"_BIERR Q
 ;
 ;---> Save IEN of V IMMUNIZATION/V SKIN TEST just created.
 N BIADFN S BIADFN=$$GTV(BIVTYPE,BIDFN,BIPTR,BIVSIT)
 ;
 I 'BIADFN S $EC=",U-ASSERT,"
 ;
 ;---> ADD OTHER V IMMUNIZATION FIELDS:
 ;---> Quit if this is not an Immunization.
 Q:BIVTYPE'="I"
 ;
 ; VFC Eligibility
 N BIFLD S BIFLD(.14)=BIVFC
 N BIERR
 D FDIE^BIFMAN(9000010.11,BIADFN,.BIFLD,.BIERR)
 I BIERR=1 D ERRCD^BIUTL2(421,.BIERR) S BIERR="1^"_BIERR QUIT
 ;
 ;---> If there was an anaphylactic reaction to this vaccine,
 ;---> add it as a contraindication for this patient.
 D:BIREC=9
 .Q:'$G(BIDFN)  Q:'$G(BIPTR)  Q:'$G(BIDATE)
 .N BIREAS S BIREAS=$$FIND1^DIC(920.4,,"QX","VXC20","C") ; SEVERE REACTION PREVIOUS DOSE
 .Q:'BIREAS
 .;
 .N BIADD,N,V S N=0,BIADD=1,V="|"
 .;---> Loop through patient's existing contraindications.
 .F  S N=$O(^BIPC("B",BIDFN,N)) Q:'N  Q:'BIADD  D
 ..N X S X=$G(^BIPC(N,0))
 ..Q:'X
 ..;---> Quit (BIADD=0) if this contra/reason/date already exists.
 ..I $P(X,U,2)=BIPTR&($P(X,U,3)=BIREAS)&($P(X,U,4)=BIDATE) S BIADD=0
 .Q:'BIADD
 .;
 .D ADDCONT^BIRPC4(.BIERR,BIDFN_V_BIPTR_V_BIREAS_V_BIDATE)
 .I $G(BIERR)]"" S BIERR="1^"_BIERR
 ;
 Q:$G(BIERR)
 ;
 ;---> Handle Dose Override
 D ASSERT(BIOIEN=BIADFN,"old and new IENS should be the same in VISTA")
 I BIOIEN D  ; If we are editing a visit (this is the old IEN; but same as new in VISTA)
 . S:BIOVRD="" BIOVRD="@"  ; If empty, delete
 . N BIFLD S BIFLD(.08)=BIOVRD
 . N BIERR
 . D FDIE^BIFMAN(9000010.11,BIOIEN,.BIFLD,.BIERR)
 . I BIERR=1 D ERRCD^BIUTL2(421,.BIERR) S BIERR="1^"_BIERR
 ;
 Q:$G(BIERR)
 ;
 ;---> Now trigger New Immunization Trigger Event.
 D TRIGADD^BIVISIT2
 QUIT
 ;
 ;
 ; The following two entry points are used by BI TABLE DATA ELEMENTS for VISTA.
 ; Entries # 51 and 90. See BIRPC1 for documentation.
VISENTRY(VIEN) ; [Public $$] First VIS Entry given IEN
 N IEN S IEN=$O(^AUPNVIMM(VIEN,2,0))
 I 'IEN Q ""
 N VIS S VIS=$P(^AUPNVIMM(VIEN,2,IEN,0),U)
 Q VIS
 ;
VISPDATE(VIEN) ; [Public $$] Presentation date of VIS given to patient
 N IEN S IEN=$O(^AUPNVIMM(VIEN,2,0))
 I 'IEN Q ""
 N VISDATE S VISDATE=$P(^AUPNVIMM(VIEN,2,IEN,0),U,2)
 Q VISDATE
 ;
GTV(BIVTYPE,DFN,BIPTR,BIVSIT) ; [Public $$] Get V IMM/V SK IEN that was just created
 N INVDATE S INVDATE=9999999-$P(+^AUPNVSIT(BIVSIT,0),".")
 QUIT:BIVTYPE="I" $O(^AUPNVIMM("AA",DFN,BIPTR,INVDATE,""))
 QUIT:BIVTYPE="S" $O(^AUPNVSK("AA",DFN,BIPTR,INVDATE,""))
 S $EC=",U-INVALID-CODE-PATH,"
 ;
 ;----------
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
 ;N BILOC S BILOC=$P($$SITE^VASITE(),U,3)
 N BIOLOC S BIOLOC="TEST OTHER LOCATION"
 N BICAT S BICAT="E"
 N BIVST,BIERR
 ; S PXVNOM=1
 D CREATE(.BIVST,.BIERR)
 D ASSERT(BIVST>0,"Visit should be created.")
 D ASSERT('$D(BIERR),"No error expected")
 D ASSERT($P(^AUPNVSIT(BIVST,0),U,7)="E","An event is expected.")
 D ASSERT(^AUPNVSIT(BIVST,21)=BIOLOC,"Outside location didn't get recorded")
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
 ; ZEXCEPT: %ut
 I $D(%ut) D CHKTF^%ut(X,$G(MSG)) QUIT
 I 'X S $EC=",U-ASSERTION-FAILED,"
 QUIT
