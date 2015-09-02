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
 ;---> Make sure we have a hospital location to use for Standalone Immunizations
 ;TODO: MAKE SURE THAT WHEN WE USE CPRS, WE HAVE AN ACTUAL HOSPITAL LOCATION
 ;
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
 ;---> Institution (BILOC is really IHS Location, which is DINUMMED to file 4).
 S VSIT("INS")=$G(BILOC)
 ;
 ;---> Hospital Location
 ;XXX TODO XXX: This is hardcoded.
 I BICAT'="E" S VSIT("LOC")=2
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
 ; *** VEN/SMH - THIS IS A FIRST DRAFT OF HOW THIS THING SHOULD WORK ***
 ; Some major differences between this and RPMS code in BIVISIT
 ; 1. There is not auto-contraindications filing. This happens when we document
 ;    the reaction to an immunization or to a PPD. I can't find where in the
 ;    software you enter a reaction at the same time as a an immunization; so
 ;    I am taking that out for auto-contraindications for Immunizations.
 ;    Adding a CI for a positive PPD is done in such an extremely sloppy way
 ;    in RPMS that I won't port this over. PPD is represented as an Immunization
 ;    not a skin test!
 ; 2. There is no representation currently of VFC eligibility for VISTA. This is
 ;    important and I would like to port that over. Thankfully, the field has
 ;    been brought over from RPMS in PX*1.0*201.
 ; 3. VISTA wants to store Lot, Manufacturer and Expiration Date; RPMS wants
 ;    to store Lot and NDC. Both are illogical since you really only need Lot.
 ;    Lot has information on the rest of the data.
 ; 4. The PXAPI code in VISTA wants you to file the data all at once via itself.
 ;    You are not given a handle back to the IEN of the V IMM or V SK to add
 ;    extra fields to the entry, which is what is done in BIVISIT.
 ; 5. RPMS does not require that you have a hospital location for an encounter.
 ;    VISTA seems to require it. I need to do some more research.
 ; 6. There are many todos for missing fields that I need to gradually bring
 ;    over:
 ;
 ; TODOs:
 ; - Three skin test fields are missing from VISTA. These need to be brought
 ;   over: 
 ;   -> .08: Skin Test Reader
 ;   -> .09: Skin Test Site
 ;   -> .11: Volume
 ; - The VIS fields for VISTA don't have a way to file them right now. I may
 ;   have to change the PXA* routines to do that. And there are two different
 ;   VIS fields: Which VIS is it (Imm and Date) and when it was given to the
 ;   patient
 ; - Dose Overide field? I don't know whether I need that. I think it has to do
 ;   with overriding the forecaster, but I haven't seen where that is used.
 ; - Injection Site and Volume are stored in different places in VISTA. The
 ;   Form needs to be changed to point them. The VISTA stuff is brand new files.
 ; - RPMS has a field to say "this CPT created me". It something to look into,
 ;   but I don't think I will actually get to supporting it.
 ; - RPMS has a field in V IMM to say whether an Immunization was imported. I
 ;   think a useful thing to have.
 ; - Some random extra fields for RPMS:
 ;   -> Admin Note
 ;   -> Admin Date (seperate from Visit Date. Reason: In RPMS, they have V
 ;       INPATIENT, and an Inpatinent Visit can span many days; so a workaround
 ;       to say when something really took place is a seperate field for Admin
 ;       Date)
 ;
 ; - Edits for Immunizations doesn't work b/c of missing VFC field
 ; - Edits for Skin tests happened to delete my previous entry. Need to track down.
 ;
 I BIDATA="" D ERRCD^BIUTL2(437,.BIERR) S BIERR="1^"_BIERR Q
 ;
 N BIVTYPE,BIDFN,BIPTR,BIDOSE,BILOT,BIDATE,BILOC,BIOLOC,BICAT
 N BIOIEN,BIRES,BIREA,BIDTR,BIREC,BIVISD,BIPROV,BIOVRD,BIINJS,BIVOL
 N BIREDR,BISITE,BICCPT,BIMPRT,BIANOT
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
 ; | #.08 DOSE OVERRIDE  |  Not used                                   |
 ; | #.09 INJECTION SITE |  #1302 ROUTE OF ADMINISTRATION  &           |
 ; |                     |  #1303 SITE OF ADMINISTRATION               |
 ; | #.11 VOLUME         |  #1312 DOSAGE                               |
 ; | #.12 DATE OF VIS    |  #2 (Multiple) VIS OFFERED/GIVEN TO PATIENT |
 ; | #.13 CREATED BY V CPT ENTRY | Not used                            |
 ; | #.14 VAC ELIGIBILITY|  Not used                                   |
 ; | #.15 IMPORT FROM... |  Not used                                   |
 ; | #.16 NDC            |  Not used                                   |
 ; | #1 ADMIN NOTES      |  Not used                                   |
 ; | #1201 EVENT DT/TM   |  Not used (says exact time of V Imm)        |
 ; | #.17 DATE VIS PRES  |  #2 (see above)                             |
 ; + ------------------- | ------------------------------------------- |
 ;
 I BIVTYPE="I" D
 . S PXVIMM("IMMUNIZATION",1,"IMMUN")=BIPTR              ; Immunization/vaccine name.
 . S PXVIMM("IMMUNIZATION",1,"LOT NUM")=$G(BILOT)        ; Lot Number
 . S PXVIMM("IMMUNIZATION",1,"REACTION")=$G(BIREC)       ; Reaction XXX INVESTIGATE XXX
 . S PXVIMM("IMMUNIZATION",1,"ENC PROVIDER")=BIPROV      ; Shot provider
 . S PXVIMM("IMMUNIZATION",1,"DOSAGE")=BIVOL             ; Dosage (e.g. 0.5 mL) XXX Check Data
 . S PXVIMM("IMMUNIZATION",1,"ADMIN ROUTE")=$P(BIINJS,"-")       ; Injection Site Route
 . S PXVIMM("IMMUNIZATION",1,"ANATOMIC LOC")=$P(BIINJS,"-",2) ; Injection Site Site
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
 ;---> Save IEN of V IMMUNIZATION just created.
 ;XXX find how to get that for VISTA
 ;
 ;
 ;---> ADD OTHER V IMMUNIZATION FIELDS:
 ;---> Quit if this is not an Immunization.
 Q:BIVTYPE'="I"
 ;
 ; XXX VIS DATA MUST BE ENTERED INTO VISTA VIA FILEMAN! .12 and .17
 ;
 ;---> Now trigger New Immunization Trigger Event.
 D TRIGADD^BIVISIT2
 QUIT
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
