PXKMASC ;ISL/JVS - Build and Pass to auto-check-out ;04/15/15  10:14
 ;;1.0;PCE PATIENT CARE ENCOUNTER;**22,41,73,164,210**;Aug 12, 1996
 ; Builds and passes data to MAS for Auto-checkout
 ;Variable List
 ;
EN1 ;Build the Temp global for MAS AND THE WORLD.
 ;S PXKGN=$P($T(GLOBAL^@PXKRTN),";;",2)_"("_PXKPIEN_","
 ;^TMP("PXKCO",$J,<VISIT IEN>,"PRV",<PROVIDER ien>,0,"AFTER")=DATA
 ;  ""                 ""                     ""    ,"BEFORE")=DATA
 N PXKGG,PXKSUB,PXKMOD,PXKSEQ,PXKOE,PXKVAL
 Q:PXKSOR=$O(^PX(839.7,"B","PIMS CHECK-OUT",0))
 S PXKGG=0
 S PXKSUB=""
 F  S PXKSUB=$O(PXKAFT(PXKSUB)) Q:PXKSUB=""  D
 . I PXKSUB'=1!(PXKCAT="IMM") D PXGO Q
 . S PXKSEQ=""
 . F  S PXKSEQ=$O(PXKAFT(PXKSUB,PXKSEQ)) Q:PXKSEQ=""  D
 .. S PXKMOD=PXKAFT(PXKSUB,PXKSEQ)
 .. D PXGO
 Q
PXGO ;
 S PXKGG=0
 S PXKGN=$P($T(GLOBAL^@PXKRTN),";;",2)_"("_PXKPIEN_","
 I PXKSUB'=1!(PXKCAT="IMM") D
 . I $D(^TMP("PXKCO",$J,PXKVST,PXKCAT,PXKPIEN,PXKSUB,"BEFORE")) S PXKGG=1
 . S PXKGN=PXKGN_PXKSUB_")"
 I PXKSUB=1 D
 . I PXKMOD]"",$D(^TMP("PXKCO",$J,PXKVST,PXKCAT,PXKPIEN,PXKSUB,"BEFORE",PXKMOD)) S PXKGG=1
 . S PXKGN=PXKGN_PXKSUB_","_PXKSEQ_","_0_")"
 D @$S(PXKGG=1:"DUP",1:"ORG")
 D DEL
 D PTR
 Q
 ;
DUP ;Overwrite if a duplicate just the After Node
 I PXKCAT="IMM",PXKSUB?1(1"2",1"3",1"11") D  Q
 . N PXKMIEN
 . S PXKMIEN=0
 . F  S PXKMIEN=$O(@PXKGN@(PXKMIEN)) Q:'PXKMIEN  D
 .. S ^TMP("PXKCO",$J,PXKVST,PXKCAT,PXKPIEN,PXKSUB,"AFTER",PXKMIEN)=$G(@PXKGN@(PXKMIEN,0))
 I PXKSUB'=1 D  Q
 . S ^TMP("PXKCO",$J,PXKVST,PXKCAT,PXKPIEN,PXKSUB,"AFTER")=$G(@PXKGN)
 I $G(@PXKGN)]"" D
 . S ^TMP("PXKCO",$J,PXKVST,PXKCAT,PXKPIEN,PXKSUB,"AFTER",$G(@PXKGN))=""
 Q
 ;
ORG ;If original copy both
 ;
 I PXKCAT="IMM",PXKSUB?1(1"2",1"3",1"11") D  Q
 . N PXKMIEN
 . ;
 . ; Set BEFORE Immunization Multiples
 . S PXKMIEN=0
 . F  S PXKMIEN=$O(PXKBEF(PXKSUB,PXKMIEN)) Q:'PXKMIEN  D
 . . S ^TMP("PXKCO",$J,PXKVST,PXKCAT,PXKPIEN,PXKSUB,"BEFORE",PXKMIEN)=PXKBEF(PXKSUB,PXKMIEN)
 . ; Set AFTER Immunization Multiples
 . S PXKMIEN=0
 . F  S PXKMIEN=$O(@PXKGN@(PXKMIEN)) Q:'PXKMIEN  D
 .. S ^TMP("PXKCO",$J,PXKVST,PXKCAT,PXKPIEN,PXKSUB,"AFTER",PXKMIEN)=$G(@PXKGN@(PXKMIEN,0))
 ;
 I PXKSUB'=1 D  Q
 . S ^TMP("PXKCO",$J,PXKVST,PXKCAT,PXKPIEN,PXKSUB,"AFTER")=$G(@PXKGN)
 . S ^TMP("PXKCO",$J,PXKVST,PXKCAT,PXKPIEN,PXKSUB,"BEFORE")=$G(PXKBEF(PXKSUB))
 I $G(@PXKGN)]"" D
 . S ^TMP("PXKCO",$J,PXKVST,PXKCAT,PXKPIEN,PXKSUB,"AFTER",$G(@PXKGN))=""
 I $G(PXKBEF(PXKSUB,PXKSEQ))]"" D
 . S ^TMP("PXKCO",$J,PXKVST,PXKCAT,PXKPIEN,PXKSUB,"BEFORE",PXKBEF(PXKSUB,PXKSEQ))=""
 Q
 ;
DEL ;DELETE IF BOTH ARE NULL
 I '$D(^TMP("PXKCO",$J,PXKVST,PXKCAT,PXKPIEN,0)) D
 .K ^TMP("PXKCO",$J,PXKVST,PXKCAT,PXKPIEN)
 I $G(^TMP("PXKCO",$J,PXKVST,PXKCAT,PXKPIEN,0,"AFTER"))']"" D
 .I $G(^TMP("PXKCO",$J,PXKVST,PXKCAT,PXKPIEN,0,"BEFORE"))']"" D
 ..K ^TMP("PXKCO",$J,PXKVST,PXKCAT,PXKPIEN)
 I $P($G(^TMP("PXKCO",$J,PXKVST,PXKCAT,PXKPIEN,0,"AFTER")),"^",1)="@" D
 .K ^TMP("PXKCO",$J,PXKVST,PXKCAT,PXKPIEN)
 Q
 ;
PTR ; Set the Provider Narrative equal to the pointer in the files etc.
 N PXJ,PXJJ,PXJJJ,PXKR
 I $D(PXKPTR) S PXJ="" F  S PXJ=$O(PXKPTR(PXJ)) Q:PXJ=""  D
 .S PXJJ=""  F  S PXJJ=$O(PXKPTR(PXJ,PXJJ)) Q:PXJJ=""  D
 ..S PXJJJ="" F  S PXJJJ=$O(PXKPTR(PXJ,PXJJ,PXJJJ)) Q:PXJJJ=""  D
 ...S PXKR=$P($T(GLOBAL^@PXKRTN),";;",2)_"("_PXJ_","_PXJJ_")"
 ...I $D(^TMP("PXKCO",$J,PXKVST,PXKCAT,PXJ,PXJJ,"AFTER")) D
 ....S $P(^TMP("PXKCO",$J,PXKVST,PXKCAT,PXJ,PXJJ,"AFTER"),"^",PXJJJ)=$P($G(@PXKR),"^",PXJJJ)
 Q
 ;
EVENT ; EVENT TO PRESENT THE DATA TO OTHER USERS
 Q:'$D(PXKCO("SOR"))
 I '$D(^TMP("PXKCO",$J)) Q
 S PXKVVST=+$O(^TMP("PXKCO",$J,0))
 S ^TMP("PXKCO",$J,PXKVVST,"VST",PXKVVST,0,"AFTER")=$G(^AUPNVSIT(PXKVVST,0))
 S ^TMP("PXKCO",$J,PXKVVST,"VST",PXKVVST,21,"AFTER")=$G(^AUPNVSIT(PXKVVST,21))
 S ^TMP("PXKCO",$J,PXKVVST,"VST",PXKVVST,800,"AFTER")=$G(^AUPNVSIT(PXKVVST,800))
 S ^TMP("PXKCO",$J,PXKVVST,"VST",PXKVVST,811,"AFTER")=$G(^AUPNVSIT(PXKVVST,811))
 S ^TMP("PXKCO",$J,PXKVVST,"VST",PXKVVST,150,"AFTER")=$G(^AUPNVSIT(PXKVVST,150))
 S ^TMP("PXKCO",$J,PXKVVST,"SOR",PXKCO("SOR"),0,"AFTER")=$G(^PX(839.7,PXKCO("SOR"),0))
 S ^TMP("PXKCO",$J,PXKVVST,"SOR",PXKCO("SOR"),0,"BEFORE")=$G(^PX(839.7,PXKCO("SOR"),0))
 S PXKOE=$O(^SCE("AVSIT",PXKVVST,"")) I PXKOE]"" S ^TMP("PXKCO",$J,PXKVVST,"OE",PXKOE,0,"BEFORE")=$G(^SCE(PXKOE,0))
 S X=+$O(^ORD(101,"B","PXK VISIT DATA EVENT",0))_";ORD(101,"
 ;D ENCEVENT^PXKENC(PXKVVST) ;makes the ^TMP("PXKENC",$J, array
 D COEVENT^PXKENC(PXKVVST) ;finishes the ^TMP("PXKCO",$J array
 D EN^XQOR
 D FINAL^SCDXHLDR(PXKVVST,$G(PXKVST))
UPD ;UP DATE VISIT FILE
 ;--REMOVE CHECK OUT DATE TIME
 N PXSWINFO S PXSWINFO=$$SWSTAT^IBBAPI()
 N VSIT
 I $D(PXKVVST),$D(^AUPNVSIT(PXKVVST)) S VSIT("IEN")=PXKVVST,VSIT("COD")="@" D CHKACCT D UPD^VSIT ;PX*1.0*164
 I +PXSWINFO D
 .I $P($G(^AUPNVSIT(PXKVVST,0)),"^",1)<$P(PXSWINFO,"^",2),$P($G(^TMP("PXKCO",$J,PXKVVST,"VST",PXKVVST,0,"BEFORE")),"^",1)<$P(PXSWINFO,"^",2) Q  ;Check visit for PFSS Activation date
 .S ^TMP("PXKCO",$J,PXKVVST,"VST",PXKVVST,0,"AFTER")=$G(^AUPNVSIT(PXKVVST,0))
 .S X=+$O(^ORD(101,"B","PX IBB CACHE FILING EVENT",0))_";ORD(101,"
 .D EN^XQOR
 K ^TMP("PXKCO",$J),PXKVVST,PXKCO,VSIT
 K ^TMP("PXKENC",$J)
 Q
CHKACCT ;
 N PXSWINFO S PXSWINFO=$$SWSTAT^IBBAPI()
 N OUTENC,PXPV1,PXPV2,SEQ,PXCPT0,PXPRV0,PXOERR,PXCPT,PXORREF,PXPROS
 Q:'+PXSWINFO
 Q:$P($G(^AUPNVSIT(PXKVVST,0)),"^",1)<$P(PXSWINFO,"^",2)  ;Check visit for PFSS Activation date
 Q:$P($G(^AUPNVSIT(PXKVVST,0)),"^",7)="E"  ;NO ACCOUNT # FOR HISTORIC ENCOUNTERS
 Q:$P($G(^AUPNVSIT(PXKVVST,0)),"^",7)="H"  ;NO ACCOUNT # FOR HOSPTIALIZATION ENCOUNTERS
 Q:$P($G(^AUPNVSIT(PXKVVST,812)),"^",2)=$$PKG2IEN^VSIT("RMPR")  ;NO ACCOUNT # FOR PROSTHETICS
 ;Check for existing ACT
 S VSIT("ACT")=$P($G(^AUPNVSIT(PXKVVST,0)),"^",26) Q:VSIT("ACT")
 ;Check Scheduling
 I $T(GETARN^SDPFSS2)'="" S VSIT("ACT")=$$GETARN^SDPFSS2($P(^AUPNVSIT(PXKVVST,0),"^",1),$P(^AUPNVSIT(PXKVVST,0),"^",5),$P(^AUPNVSIT(PXKVVST,0),"^",22)) Q:VSIT("ACT")]0  S VSIT("ACT")=""
 ;Check CPT codes for Lab 108, call ORWPFSS,
 I $E($T(ORACTREF^ORWPFSS),9)="(" S PXOERR=1 D  Q:PXOERR
 .I '$D(^TMP("PXKCO",$J,PXKVVST,"CPT")) S PXOERR=0 Q  ;No CPT codes, so Get Acct Ref
 .S SEQ="" F  S SEQ=$O(^TMP("PXKCO",$J,PXKVVST,"CPT",SEQ)) Q:SEQ=""  D  Q:'PXOERR
 ..S PXCPT0=$G(^TMP("PXKCO",$J,PXKVVST,"CPT",SEQ,0,"AFTER"))
 ..I $P(PXCPT0,"^",19)'=108 S PXOERR=0 Q  ;Not Lab, so Get Acct Ref
 ..I $P(PXCPT0,"^",17)="" S PXOERR=0 Q  ;Lab and no Order Reference, so Get Acct Ref
 ..I $P(PXCPT0,"^",17)'="" S PXCPT=$P(PXCPT0,"^",17) D ORACTREF^ORWPFSS(.PXORREF,.PXCPT) I PXORREF'>0 S PXOERR=0  ;Lab and no Acct Ref, so Get Acct Ref
 ;Call Get IBBACCT
 S PXPV1(2)=$P(^AUPNVSIT(PXKVVST,150),"^",2) S PXPV1(2)=$S(PXPV1(2)=1:"I",PXPV1(2)=0:"O",1:"") ;Inpatient, Outpatient
 S PXPV1(3)=$P(^AUPNVSIT(PXKVVST,0),"^",22) Q:PXPV1(3)=""  ;Hospital Location, Quit for Outside Locations
 S OUTENC=$O(^SCE("AVSIT",PXKVVST,0)) I OUTENC]"" S PXPV1(4)=$P(^SCE(OUTENC,0),"^",10) ;Appointment type
 ;Attending search
 S PXPV1(7)=""
 S SEQ="" F  S SEQ=$O(^TMP("PXKCO",$J,PXKVVST,"PRV",SEQ)) Q:SEQ=""  D  Q:PXPV1(7)]""
 .S PXPRV0=$G(^TMP("PXKCO",$J,PXKVVST,"PRV",SEQ,0,"AFTER"))
 .I $P(PXPRV0,"^",5)="A" S PXPV1(7)=$P(PXPRV0,"^",1)
 S PXPV1(18)=$P(^AUPNVSIT(PXKVVST,0),"^",8) ;DSS ID
 S PXPV1(44)=$P(^AUPNVSIT(PXKVVST,0),"^",1) ;Visit D/T
 S PXPV2(7)="" S:$P(^AUPNVSIT(PXKVVST,0),"^",21) PXPV2(7)=$P(^DIC(8,$P(^AUPNVSIT(PXKVVST,0),"^",21),0),"^",9) ;Eligibility
 S VSIT("PAT")=$P(^AUPNVSIT(PXKVVST,0),"^",5)
 S VSIT("ACT")=$$GETACCT^IBBAPI(VSIT("PAT"),"","A04","PXKMASC",.PXPV1,.PXPV2,,,,"","")
 K VSIT("PAT")
