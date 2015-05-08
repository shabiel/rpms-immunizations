XUMF654 ;OIFO-BP/BATRAN - MFS parameters file ;03/25/2015
 ;;8.0;KERNEL;**654**;Jul 10, 1995
 ;Per VHA Directive 10-92-142, this routine should not be modified
 Q
 ;-------------------------------------------------
ADD(IEN,DATA) ; ADD ZERO NODE
 N FDA,FDAIEN,XFIELD,XVALUE,XCOUNT,XDATA,XI,XDATA1
 S XDATA=$$STRIP^XLFSTR(DATA,"]")
 S XCOUNT=$L(DATA)-$L(XDATA)+1
 S FDAIEN(1)=IEN
 S FDA(4.001,"?+1,",.01)=IEN
 F XI=1:1:XCOUNT D
 . S XDATA1=$P(DATA,"]",XI),XFIELD=+$P(XDATA1,";",1),XVALUE=$P(XDATA1,";",2)
 . I XFIELD'>0 Q
 . S FDA(4.001,"?+1,",XFIELD)=XVALUE
 .Q
 D UPDATE^DIE("","FDA","FDAIEN","ERR")
 I $D(ERR) D
 .D EM("UPDATE PARAMETR error on file #"_IEN,.ERR)
 .K ERR
 Q
 ;----------------------------------------------
ADDMD5(XUNAME) ; ADD ZERO NODE
 N IENS1
 K FDA
 S FDA(4.005,"+1,",.01)=XUNAME
 ;S FDA(4.005,"+1,",6)=0
 D UPDATE^DIE("E","FDA",,"ERR")
 I $D(ERR) D
 .D EM("UPDATE MD5 error on file "_XUNAME,.ERR)
 .K ERR
 Q
 ;---------------------------------------------------
SCMD5(XUNAME,FILEN) ; ADD SECOND LEVEL
 N XUIEN,IENS,XC
 K FDA
 S XUIEN=$O(^DIC(4.005,"B",XUNAME,0))
 I XUIEN'>0 Q
 K FDA
 S IENS="?+1,"_XUIEN_","
 S FDA(4.0051,IENS,.01)=FILEN
 D UPDATE^DIE("E","FDA",,"ERR")
 I $D(ERR) D
 .D EM("UPDATE MD5 error on file "_XUNAME,.ERR)
 .K ERR
 Q
 ;--------------------------------------------------
SUBMD5(XUNAME,XDATA,FILEN,XIEN) ; ADD THIRD LEVEL
 N XUIEN,IENS,XC
 K FDA
 S XUIEN=$O(^DIC(4.005,"B",XUNAME,0))
 I XUIEN'>0 Q
 ;
 S XC=","
 S IENS="+1"_XC_FILEN_XC_XUIEN_XC
 S FDAIEN(1)=XIEN
 S FDA(4.00511,IENS,.01)=$P(XDATA,"^",1)
 S FDA(4.00511,IENS,1)=$P(XDATA,"^",2)
 S FDA(4.00511,IENS,2)=$P(XDATA,"^",3)
 S FDA(4.00511,IENS,3)=$P(XDATA,"^",4)
 S FDA(4.00511,IENS,4)=$P(XDATA,"^",5)
 S FDA(4.00511,IENS,5)=$P(XDATA,"^",6,7)
 D UPDATE^DIE("","FDA","FDAIEN","ERR")
 ;D UPDATE^DIE("E","FDA",,"ERR")
 I $D(ERR) D
 .D EM("UPDATE MD5 error on file "_XUNAME,.ERR)
 .K ERR
 Q
 ;---------------------------------------------
DEL(IEN) ; Delete entries
 N DIK,DA
 S DIK="^DIC(4.001,",DA=IEN D ^DIK
 Q
 ;
DELMD5(XUNAME) ; Delete entries
 N DIK,DA
 I $G(XUNAME)="" Q
 S DA=$O(^DIC(4.005,"B",XUNAME,0))
 I DA'>0 Q
 S DIK="^DIC(4.005," D ^DIK
 Q
 ;
 ;-----------------------------------------------
NODES(IEN,XDATA,XCOUNT) ; -- ADD SEQUENCES
 ;
 N DATA,I
 F I=1:1:XCOUNT D
 . S DATA=$T(@XDATA+I)
 . D ADD1(DATA,IEN)
 . Q
 Q
 ;----------------------------------------------
ADD1(DATA,IEN) ;add sub level - ADD SINGLE SEQUENCE
 N NODE,IENS
 K FDA
 S DATA=$P(DATA,";",2)
 S NODE=$P(DATA,"^",1)
 S DATA=$P(DATA,"^",2,99)
 S IENS="+"_NODE_","_IEN_","
 S FDA(4.011,IENS,.01)=$P(DATA,"^",1)
 S FDA(4.011,IENS,.02)=$P(DATA,"^",2)
 S FDA(4.011,IENS,.03)=$P(DATA,"^",3)
 S FDA(4.011,IENS,.04)=$P(DATA,"^",4)
 S FDA(4.011,IENS,.05)=$P(DATA,"^",5)
 S FDA(4.011,IENS,.06)=$P(DATA,"^",6)
 S FDA(4.011,IENS,.07)=$P(DATA,"^",7)
 S FDA(4.011,IENS,.08)=$P(DATA,"^",8)
 S FDA(4.011,IENS,.09)=$P(DATA,"^",9)
 S FDA(4.011,IENS,.11)=$P(DATA,"^",11)
 S FDA(4.011,IENS,.12)=$P(DATA,"^",12)
 S FDA(4.011,IENS,.13)=$P(DATA,"^",13)
 S FDA(4.011,IENS,.14)=$P(DATA,"^",14)
 S FDA(4.011,IENS,.15)=$P(DATA,"^",15)
 S FDA(4.011,IENS,.16)=$P(DATA,"^",16)
 D UPDATE^DIE("E","FDA",,"ERR")
 I $D(ERR) D
 .D EM("UPDATE PARAMETER error on file #"_IEN,.ERR)
 .K ERR
 Q
 ;------------------------------------------------
ADD2(XIEN1,XNAME,XCOUNT,XDATA) ; add sub-sub level
 N XC,IENS,ERR,XIEN2
 K FDA
 S XIEN2=+$O(^DIC(4.001,XIEN1,1,"B",XNAME,0))
 I XIEN2'>0 Q
 S XC=","
 S IENS="+"_XCOUNT_XC_XIEN2_XC_XIEN1_XC
 S FDA(4.111,IENS,.01)=$P(XDATA,"^",1) ; SUBFILE SEQUENCE
 S FDA(4.111,IENS,.02)=$P(XDATA,"^",2) ; SUBFILE COLUMN NAME
 S FDA(4.111,IENS,.03)=$P(XDATA,"^",3) ; SUBFILE FIELD NUMBER
 S FDA(4.111,IENS,.04)=$P(XDATA,"^",4) ; SUBFILE FIELD VUID
 S FDA(4.111,IENS,.05)=$P(XDATA,"^",5) ; SUBFILE FIELD TYPE
 D UPDATE^DIE("","FDA","FDAIEN","ERR")
 I $D(ERR) D
 .D EM("UPDATE PARAMETER error on file "_XNAME,.ERR)
 .K ERR
 Q
 ;------------------------------------------------
EM(ERROR,ERR,XMSUB) ; -- error message
 N X,XMTEXT,XMDUZ
 D MSG^DIALOG("AM",.X,80,,"ERR")
 S X(.1)="HL7 message ID: "_$G(HL("MID"))
 S X(.2)="",X(.3)=$G(ERROR),X(.4)=""
 S:$G(XMSUB)="" XMSUB="MFS ERROR"
 S:'$D(XMY("user12345@FORUM.DOMAIN")) XMY("G.XUMF ERROR@FORUM.DOMAIN")=""
 S XMDUZ=.5
 S XMTEXT="X("
 D ^XMD
 Q
 ;----------------------------------------------
DATA9904 ;9999999.04
 ;1^Term^.01^^^^^^^75^^^^^^1^
 ;2^VistA_MVX_Code^.02^^^^^^^3^^^^^^2^
 ;3^VistA_MVX_Notes^201^^^^^^^99^^^^^^3^
 ;4^vista_replaced_by^99.97^^^^^^^^^^^VUID^^4^
 ;5^Status^.02^^9999999.0499^^^^^^^^^^^5^
 ;6^VistA_Inactive_Flag^.03^^^^^^^1^^^^^^6^
 ;-------------------------------------------------
DATA ;9999999.14
 ;1^Term^.01^^^^^^^99^^^^^^1^
 ;2^VistA_Acronym^8802^^^^^^^20^^^^^^2^
 ;3^VistA_CDC_Full_Vaccine_Name^2^^^^^^^^^^^^^3^1
 ;4^VistA_CDC_Product_Name^.01^ST^9999999.145^^VistA_CDC_Product_Name^^^30^^^0^^^4^
 ;5^VistA_Combination_Immunization^.2^^^^^^^1^^^^^^5^
 ;6^VistA_Class^100^^^^^^^^^^^^^6^
 ;7^VistA_CVX_Mapping^.01^^9999999.143^^VistA_CVX_Mapping^^^^^^^^^7^
 ;8^VistA_CVX_Code^.03^^^^^^^3^^^^^^8^
 ;9^VistA_Inactive_Flag^.07^^^^^^^1^^^^^^9^
 ;10^VistA_Max_No_In_Series^.05^^^^^^^^^^^^^10^
 ;11^VistA_Mnemonic^8801^^^^^^^3^^^^^^11^
 ;12^VistA_Reading_Required^.51^^^^^^^1^^^^^^12^
 ;13^VistA_Selectable_For_Historic^8803^^^^^^^^^^^^^13^
 ;14^VistA_Synonym^.01^ST^9999999.141^^VistA_Synonym^^^30^^^0^^^14^
 ;15^vista_has_vis^.01^ST^9999999.144^^vista_has_vis^^^15^^^0^VUID^^15^
 ;16^vista_replaced_by^99.97^^^^^^^^^^^VUID^^16^
 ;17^Status^.02^^9999999.1499^^^^^^^^^^^17^
 ;------------------------------------------------
DATA9928 ;9999999.28
 ;1^Term^.01^^^^^^^30^^^^^^1^
 ;2^VistA_Class^100^^^^^^^^^^^^^2^
 ;3^VistA_Inactive_Flag^.03^^^^^^^1^^^^^^4^
 ;4^VistA_Mnemonic^8801^^^^^^^3^^^^^^5^
 ;5^VistA_Print_Name^1201^^^^^^^15^^^^^^6^
 ;6^VistA_Skin_Test_Code^.02^^^^^^^2^^^^^^7^
 ;7^VistA_Skin_Test_Mapping^.01^ST^9999999.283^^VistA_Skin_Test_Mapping^^^30^^^^^^8^
 ;8^vista_replaced_by^99.97^^^^^^^^^^^VUID^^9^
 ;9^Status^.02^^9999999.2899^^^^^^^^^^^10^
 ;-------------------------------------------------
DATA920 ;920
 ;1^Term^.01^^^^^^^50^^^^^^1^
 ;2^VistA_VIS_Bar_Code^100^^^^^^^24^^^^^^2^
 ;3^VistA_VIS_Edition_Date^.02^^^^^^^^^^^^^3^
 ;4^VistA_VIS_Edition_Status^.03^^^^^^^^^^^^^4^
 ;5^VistA_VIS_Language^.04^^^^^^^^^^^^^5^
 ;6^VistA_VIS_URL^101^^^^^^^99^^^^^^6^
 ;7^vista_replaced_by^99.97^^^^^^^^^^^VUID^^7^
 ;8^Status^.02^^920.99^^^^^^^^^^^8^
 ;-------------------------------------------------
DATA9201 ;920.1
 ;1^Term^.01^^^^^^^60^^^^^^1^
 ;2^VistA_HL7_Code^.02^^^^^^^2^^^^^^2^
 ;3^vista_replaced_by^99.97^^^^^^^^^^^VUID^^3^
 ;4^Status^.02^^920.199^^^^^^^^^^^4^
 ;5^VistA_Inactive_Flag^.03^^^^^^^1^^^^^^5^
 ;-------------------------------------------------
DATA9202 ;920.2
 ;1^Term^.01^^^^^^^30^^^^^^1^
 ;2^VistA_FDA_NCIT_Code^.03^^^^^^^6^^^^^^2^
 ;3^VistA_HL7_Code^.02^^^^^^^3^^^^^^3^
 ;4^VistA_Textual_Definition^.04^^^^^^^90^^^^^^4^
 ;5^vista_replaced_by^99.97^^^^^^^^^^^VUID^^5^
 ;6^Status^.02^^920.299^^^^^^^^^^^6^
 ;-------------------------------------------------
DATA9203 ;920.3
 ;1^Term^.01^^^^^^^30^^^^^^1^
 ;2^VistA_HL7_Code^.02^^^^^^^4^^^^^^2^
 ;3^vista_replaced_by^99.97^^^^^^^^^^^VUID^^3^
 ;4^Status^.02^^920.399^^^^^^^^^^^4^
 ;----------------------------------------------
DATA9204 ;920.4
 ;1^Term^.01^^^^^^^30^^^^^^1^
 ;2^VistA_CDC_Code^.04^^^^^^^2^^^^^^2^
 ;3^VistA_HL7_Code^.02^^^^^^^10^^^^^^3^
 ;4^VistA_HL7_Code_Set^.05^^^^^^^10^^^^^^4^
 ;5^VistA_Inactive_Flag^.03^^^^^^^1^^^^^^5^
 ;6^VistA_Long_Name^1^^^^^^^99^^^^^^6^
 ;7^VistA_Textual_Definition^2^^^^^^^99^^^^^^7^
 ;8^vista_replaced_by^99.97^^^^^^^^^^^VUID^^8^
 ;9^Status^.02^^920.499^^^^^^^^^^^9^
 ;10^VistA_Precaution^.06^ST^^^^^^1^^^^^^10^
 ;11^vista_applies_to^.01^ST^920.43^^vista_applies_to^^^15^^^0^VUID^^11^
 ;---------------------------------------------
DATA9205 ;920.5
 ;1^Term^.01^^^^^^^30^^^^^^1^
 ;2^VistA_HL7_Code^.02^^^^^^^2^^^^^^2^
 ;3^vista_replaced_by^99.97^^^^^^^^^^^VUID^^3^
 ;4^Status^.02^^920.599^^^^^^^^^^^4^
 ;---------------------------------------------
