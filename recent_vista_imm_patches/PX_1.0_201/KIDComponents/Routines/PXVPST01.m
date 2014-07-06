PXVPST01 ;BIR/CML3 - V IMMUNIZATION FILE CONVERSION;20 Jun 2014  7:49 PM
 ;;1.0;PCE PATIENT CARE ENCOUNTER;**201**;Aug 12, 1996;Build 5
 ;
MVDIAGS ;
 ; moves the data in the previous DIAGNOSIS fields to the new fields:
 ; the PRIMARY DIAGNOSIS (#1304) and the OTHER DIAGNOSIS (#3) multiple
 ; this is a one-time task
 ; ^AUPNVIMM( is the V IMMUNIZATION file (#9000010.11)
 ; PXVV is the IENs of that file
 ; PXVD are pieces 8-15 of the zero node, where the data for the
 ; previous diagnosis fields (#s .08 thru .15) is stored
 N DA,DIC,DIE,DR,Q,X,Y,PXVD,PXVV
 S PXVV=0
 F  S PXVV=$O(^AUPNVIMM(PXVV)) Q:'PXVV  S PXVD=$P($G(^(PXVV,0)),"^",8,15) I PXVD'="",PXVD'?1.7"^" D  ;
 . ; DIAGNOSIS becomes PRIMARY DIAGNOSIS
 . S X=$P(PXVD,"^")
 . I X'="" K DA S DIE="^AUPNVIMM(",DA=PXVV,DR="1304///"_X D ^DIE S $P(^AUPNVIMM(PXVV,0),"^",8)=""
 . ; DIAGNOSES 2-8 become entries in the OTHER DIAGNOSIS multiple
 . F Q=2:1:8 S X=$P(PXVD,"^",Q) I X'="" D  ;
 .. K DA,DIC S DIC="^AUPNVIMM("_PXVV_",3,",DIC(0)="",DA(1)=PXVV
 .. D FILE^DICN S $P(^AUPNVIMM(PXVV,0),"^",Q+7)=""
 Q
