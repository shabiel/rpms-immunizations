# Description of the similarities and differences between VA Imm Patches and RPMS tables

VA VISTA Released the following patches to support Immunizations in VISTA:
 
 * PX\*1.0\*200
 * PX\*1.0\*201
 * PX\*1.0\*208
 * PX\*1.0\*206
 * PX\*1.0\*209
 * PX\*1.0\*210

VA VISTA patch PX\*1.0\*201 introduced enhanced support for capturing
immunization data in VISTA. Previously immunization data in VISTA was captured
with no intelligence as it its meaning; essentially in a book keeping sense;
mirrioring the way health factors and exams are captured.

PX\*1.0\*201 mainly introduces data structures; no operational code is actually
supplied. A post install routine `PXVP201` moves data from unused fields in V
IMMUNIZATION which happen to collide with RPMS fields into newly created
multiples outside of the RPMS field space.

PX\*1.0\*200 adds support for PCE calls to save Immunizations; this is updated
in PX\*1.0\*209 to support extra fields.

PX\*1.0\*206 expands MFS control to all the 920 series of files; brings in
920.4 (Contraindications) and 920.5 (Refusal Reasons); adds 2D barcode values
to the VIS file (#920) sent in PX\*1.0\*201. It brings in as well a standardized
skin test file. Finally, it turns on auditing for all MFS controlled files.

PX\*1.0\*208 is a quick fix for an omission earlier.

PX\*1.0\*209 adds the ability to file new fields in the DATA2PCE^PXAPI,
including CVX Code, Event Information Source, Dosage, Route of Administration,
Site of Administration, Lot number, Manufacturer, and Expiration Date.

PX\*1.0\*210 is a big patch. One of its main functions is to provide a 
Reminders Index for V Immunizations subscripted by CVX. DATA2PCE^PXAPI now
supports VIS Offered/Given To Patient, Remarks, and Ordering Provider. 
VIS^PXAPI is a new API that returns info on the VIS given to the patient. The
patch also says that it updates PCE skin test documentation process and the 
PCE immunization documentation process; but I can't find how the new code gets
invoked. A token inventory management system is introduced by it as well. It
also updates V Immunization, V Skin Test, and Immunization Lot files.

# Description of data in PX\*1.0\*201 and PX\*1.0\*206
Since the content of these patchs is almost all data dictionaries and data,
they are described below:

| File Number   | File Name     | Partial?     | Has Data?     | MFS Controlled? | In RPMS?      | Sent in      |
| ------------- | ------------- |------------- | ------------- | --------------- | ------------- | ------------ | 
| 9000010.11    | V Immunization | No          | No            |                 |     Yes       | PX\*1.0\*201 & 210 |
| 9999999.04    | Immunization Manufacturer | No | Yes         | Yes             |     Yes       | PX\*1.0\*201 |
| 9999999.14    | Immuniaztion  | No           | Yes           | Yes             |     Yes       | PX\*1.0\*201 |
| 9999999.41    | Immunization Lot | No        | No            |                 |     Yes       | PX\*1.0\*201 & 210 |
| 9999999.28    | Skin Test     | No           | Yes           | Yes             |     Yes       | PX\*1.0\*206 |
| 9000010.12    | V Skin Test   | No           | No            |                 |     Yes       | PX\*1.0\*210 |
| 920.1         | Immunization Information Source | No | Yes   | Yes             |     No        | PX\*1.0\*201 |
| 920.2         | Immunization Administration Route | No | Yes | Yes             |     No        | PX\*1.0\*201 |
| 920.3         | Immunization Administration Site | No | Yes  | Yes             |     No        | PX\*1.0\*201 |
| 920.4         | Imm Contraindication Reasons | No   | Yes    | Yes             |     No        | PX\*1.0\*206 |
| 920.5         | Imm Refusal Reasons  | No           | Yes    | Yes             |     No        | PX\*1.0\*206 |
| 920           | Vaccine Information Sheets | No | Yes        | Yes             |     No        | PX\*1.0\*201 |

At this point, we can come up with some conclusions. The 920\* files are
actually completely new. A look through the RPMS files shows that the 920\*
files actually represent data that is not captured in RPMS (#920) or consists
of data that is stored in RPMS but is stored as sets of codes; not permitting
further terminologic definition of it (#920.2 or 920.3) or is stored in RPMS in
external data structures (#920.1 is stored as part of the VISIT file (#9000010)
in RPMS.

# Differences in specific files
Overall, the pattern of differences is that fields used by IHS are kept, but
a lot of the fields characteristics have changed; indexes/cross-references are
most often what changes. E.g. Indexes having to do with Q-Man are removed.

There are two incompatible changes that are made on a field level, but overall,
the fields are mostly the same in meaning.

## 9000010.11 (V IMMUNIZATIONS)
That is the file that has the most changes; due to how large it is. Many
indexes are removed; and many fields are added. Here is a comparison of the
fields. Note all the fields that VISTA adds. (NB: Updated for PX*1.0*210. Look
for *210 in the fields for those added by this patch.).

```
== RPMS ==                                                                |  == VISTA ==

.01,0)="IMMUNIZATION^RP9999999.14'^AUTTIMM(^0;1^Q"                        |  .01,0)="IMMUNIZATION^R*P9999999.14'a^AUTTIMM(^0;1^S DIC(""S"")=""I $P(^(0
.02,0)="PATIENT NAME^RP9000001'I^AUPNPAT(^0;2^Q"                          |  .02,0)="PATIENT NAME^RP9000001'Ia^AUPNPAT(^0;2^Q"
.03,0)="VISIT^R*P9000010'I^AUPNVSIT(^0;3^S DIC(""S"")=""I $P(^(0),U,5)=$P |  .03,0)="VISIT^R*P9000010'Ia^AUPNVSIT(^0;3^S DIC(""S"")=""I $P(^(0),U,5)=$
.04,0)="SERIES^S^P:PARTIALLY COMPLETE;C:COMPLETE;B:BOOSTER;1:SERIES 1;2:S |  .04,0)="SERIES^*Sa^P:PARTIALLY COMPLETE;C:COMPLETE;B:BOOSTER;1:SERIES 1;2
.05,0)="LOT^*P9999999.41'^AUTTIML(^0;5^S DIC(""S"")=""I $P(^(0),U,3)=0,$D |  .05,0)="LOT^*P9999999.41'a^AUTTIML(^0;5^S DIC(""S"")=""I $P(^(0),U,3)=0,$
.06,0)="REACTION^P9002084.8'^BIREC(^0;6^Q"                                |  .06,0)="REACTION^Sa^1:FEVER;2:IRRITABILITY;3:LOCAL REACTION OR SWELLING;4
.07,0)="*CONTRAINDICATED^S^1:YES (DO NOT REPEAT THIS VACCINE).;0:NO (OK T |  .07,0)="CONTRAINDICATED^Sa^1:YES (DO NOT REPEAT THIS VACCINE).;0:NO (OK T
.08,0)="DOSE OVERRIDE^S^0:@;1:INVALID--BAD STORAGE;2:INVALID--DEFECTIVE;3 |  .08,0)="DOSE OVERRIDE^Sa^0:@;1:INVALID--BAD STORAGE;2:INVALID--DEFECTIVE;
.09,0)="INJECTION SITE^S^LTI:Left Thigh IM;LTS:Left Thigh SQ;RTI:Right Th |  .09,0)="INJECTION SITE^Sa^LTI:Left Thigh IM;LTS:Left Thigh SQ;RTI:Right T
.11,0)="VOLUME^NJ4,2^^0;11^K:+X'=X!(X>5)!(X<0)!(X?.E1"".""3N.N) X"        |  .11,0)="VOLUME^NJ4,2a^^0;11^K:+X'=X!(X>5)!(X<0)!(X?.E1"".""3N.N) X"
.12,0)="DATE OF VAC INFO STATEMENT^D^^0;12^S %DT=""EX"" D ^%DT S X=Y K:Y< |  .12,0)="DATE OF VAC INFO STATEMENT^Da^^0;12^S %DT=""EX"" D ^%DT S X=Y K:Y
.13,0)="CREATED BY V CPT ENTRY^NJ9,0^^0;13^K:+X'=X!(X>999999999)!(X<0)!(X |  .13,0)="CREATED BY V CPT ENTRY^NJ9,0a^^0;13^K:+X'=X!(X>999999999)!(X<0)!(
.14,0)="VAC ELIGIBILITY^P9002084.83'^BIELIG(^0;14^Q"                      |  .14,0)="VAC ELIGIBILITY^P9002084.83'a^BIELIG(^0;14^Q"
.15,0)="IMPORT FROM OUTSIDE REGISTRY^S^1:IMPORTED;0:NOT IMPORTED;2:EDITED |  .15,0)="IMPORT FROM OUTSIDE REGISTRY^Sa^1:IMPORTED;0:NOT IMPORTED;2:EDITE
.16,0)="NDC^P9002084.95'^BINDC(^0;16^Q"                                   |  .16,0)="NDC^P9002084.95'a^BINDC(^0;16^Q"
1,0)="ADMINISTRATIVE NOTES^F^^1;1^K:$L(X)>160!($L(X)<1) X"                |  1,0)="ADMINISTRATIVE NOTES^Fa^^1;1^K:$L(X)>160!($L(X)<1) X"
                                                                          >  2,0)="VIS OFFERED/GIVEN TO PATIENT^9000010.112PA^^2;0"
                                                                          >  3,0)="OTHER DIAGNOSIS^9000010.113P^^3;0"
1101,0)="REMARKS^9000010.1111^^11;0"                                         1101,0)="REMARKS^9000010.1111^^11;0"
1201,0)="EVENT DATE AND TIME^D^^12;1^S %DT=""EST"" D ^%DT S X=Y K:Y<1 X"  |  1201,0)="EVENT DATE AND TIME^DXa^^12;1^S %DT=""ET"" D ^%DT S X=Y K:Y<1!$$
1202,0)="ORDERING PROVIDER^*P200'X^VA(200,^12;2^S DIC(""S"")=""I $D(^VA(2 |  1202,0)="ORDERING PROVIDER^P200'a^VA(200,^12;2^Q"
1203,0)="CLINIC^P40.7'^DIC(40.7,^12;3^Q"                                  |  1203,0)="CLINIC^P40.7'a^DIC(40.7,^12;3^Q"
1204,0)="ENCOUNTER PROVIDER^P200'^VA(200,^12;4^Q"                         |  1204,0)="ENCOUNTER PROVIDER^P200'a^VA(200,^12;4^Q"
1208,0)="PARENT^P9000010.11'^AUPNVIMM(^12;8^Q"                            |  1205,0)="DATE/TIME RECORDED^Da^^12;5^S %DT=""ETXR"" D ^%DT S X=Y K:Y<1 X"
1209,0)="EXTERNAL KEY^F^^12;9^K:$L(X)>20!($L(X)<1) X"                     |  1206,0)="IMMUNIZATION DOCUMENTER^P200'a^VA(200,^12;6^Q"
1210,0)="OUTSIDE PROVIDER NAME^F^^12;10^K:$L(X)>30!($L(X)<1) X"           |  1207,0)="LOT NUMBER^*P9999999.41'a^AUTTIML(^12;7^S DIC(""S"")=""I '$P(^(0
1213,0)="ANCILLARY POV^P80'^ICD9(^12;13^Q"                                |  1208,0)="PARENT^P9000010.11'a^AUPNVIMM(^12;8^Q"
1214,0)="USER LAST UPDATE^P200'^VA(200,^12;14^Q"                          |  1209,0)="EXTERNAL KEY^Fa^^12;9^K:$L(X)>20!($L(X)<1) X"
1215,0)="ORDERING LOCATION^P44'^SC(^12;15^Q"                              |  1210,0)="OUTSIDE PROVIDER NAME^Fa^^12;10^K:$L(X)>30!($L(X)<1) X"
1216,0)="DATE/TIME ENTERED^D^^12;16^S %DT=""ESTXR"" D ^%DT S X=Y K:Y<1 X" |  1213,0)="ANCILLARY POV^P80'a^ICD9(^12;13^Q"
1217,0)="ENTERED BY^P200'^VA(200,^12;17^Q"                                |  1214,0)="USER LAST UPDATE^P200'a^VA(200,^12;14^Q"
1218,0)="DATE/TIME LAST MODIFIED^D^^12;18^S %DT=""ESTXR"" D ^%DT S X=Y K: |  1215,0)="ORDERING LOCATION^P44'a^SC(^12;15^Q"
1219,0)="LAST MODIFIED BY^P200'^VA(200,^12;19^Q"                          |  1216,0)="DATE/TIME ENTERED^Da^^12;16^S %DT=""ESTXR"" D ^%DT S X=Y K:Y<1 X
                                                                          >  1217,0)="ENTERED BY^P200'a^VA(200,^12;17^Q"
                                                                          >  1218,0)="DATE/TIME LAST MODIFIED^Da^^12;18^S %DT=""ESTXR"" D ^%DT S X=Y K
                                                                          >  1219,0)="LAST MODIFIED BY^P200'a^VA(200,^12;19^Q"
                                                                          >  1301,0)="EVENT INFORMATION SOURCE^R*P920.1'a^PXV(920.1,^13;1^S DIC(""S"")
                                                                          >  1302,0)="ROUTE OF ADMINISTRATION^*P920.2'a^PXV(920.2,^13;2^S DIC(""S"")="
                                                                          >  1303,0)="SITE OF ADMINISTRATION (BODY)^*P920.3'a^PXV(920.3,^13;3^S DIC(""
                                                                          >  1304,0)="PRIMARY DIAGNOSIS^*P80'Xa^ICD9(^13;4^S DIC(""S"")=""D ^AUPNSICD"
                                                         *210             >  1312,0)="DOSE^NJ6,2aO^^13;12^K:+X'=X!(X>999)!(X<0)!(X?.E1"".""3N.N) X"
                                                         *210             >  1312.5,0)="DOSAGE^CJ10^^ ; ^S X=$$DOSAGE^PXVUTIL(D0)"
                                                         *210             >  1313,0)="DOSE UNITS^P757.5'aO^LEX(757.5,^13;13^Q"
                                                         *210             >  1401,0)="RESULTS^Sa^T:TAKE;N:NO TAKE;I:INDETERMINATE;^14;1^Q"
                                                         *210             >  1402,0)="READING^NJ2,0a^^14;2^K:+X'=X!(X>40)!(X<0)!(X?.E1"".""1N.N) X"
                                                         *210             >  1403,0)="DATE/TIME READ^DXa^^14;3^S %DT=""ET"" D ^%DT S X=Y K:Y<1!$$TIME^
                                                         *210             >  1404,0)="READER^P200'a^VA(200,^14;4^Q"
                                                         *210             >  1405,0)="READING RECORDED^Da^^14;5^S %DT=""ETXR"" D ^%DT S X=Y K:Y<1 X"
                                                         *210             >  1406,0)="HOURS READ POST-INOCULATION^NJ3,0a^^14;6^K:+X'=X!(X>100)!(X<0)!(
                                                         *210             >  1501,0)="READING COMMENT^Fa^^15;1^K:$L(X)>245!($L(X)<1) X"
2601,0)="SNOMED CT^9000010.1126A^^26;0"                                      2601,0)="SNOMED CT^9000010.1126A^^26;0"
2701,0)="LOINC CODES^9000010.1127A^^27;0"                                    2701,0)="LOINC CODES^9000010.1127A^^27;0"
80101,0)="EDITED FLAG^S^1:EDITED;^801;1^Q"                                |  80101,0)="EDITED FLAG^Sa^1:EDITED;^801;1^Q"
80102,0)="AUDIT TRAIL^F^^801;2^K:$L(X)>85!($L(X)<2) X"                    |  80102,0)="AUDIT TRAIL^Fa^^801;2^K:$L(X)>85!($L(X)<2) X"
81101,0)="COMMENTS^F^^811;1^K:$L(X)>245!($L(X)<1) X"                      |  81101,0)="COMMENTS^Fa^^811;1^K:$L(X)>245!($L(X)<1) X"
81201,0)="VERIFIED^SI^1:ELECTRONICALLY SIGNED;2:VERIFIED BY PACKAGE;^812; |  81201,0)="VERIFIED^SIa^1:ELECTRONICALLY SIGNED;2:VERIFIED BY PACKAGE;^812
81202,0)="PACKAGE^P9.4'I^DIC(9.4,^812;2^Q"                                |  81202,0)="PACKAGE^P9.4'Ia^DIC(9.4,^812;2^Q"
81203,0)="DATA SOURCE^P839.7'I^PX(839.7,^812;3^Q"                         |  81203,0)="DATA SOURCE^P839.7'Ia^PX(839.7,^812;3^Q"
```

## 9999999.04 (IMM MANUFACTURER)
Changes in this file are more straight-forward. They are mostly field additions,
with one rather notable exception: Field .03 has been renamed and its meaning
has been REVERSED!

```
== RPMS ==                                                      |  == VISTA ==
.01,0)="NAME^RF^^0;1^K:$L(X)>30!($L(X)<3)!'(X'?1P.E)!(X'?.ANP)  |  .01,0)="NAME^RF^^0;1^K:$L(X)>75!($L(X)<3)!'(X'?1P.E) X"
.02,0)="MVX CODE^F^^0;2^K:$L(X)>3!($L(X)<2) X"                  |  .02,0)="MVX CODE^RF^^0;2^K:$L(X)>3!($L(X)<2) X"
.03,0)="ACTIVE^S^0:INACTIVE;1:ACTIVE;^0;3^Q"                    |  .03,0)="STATUS^S^1:INACTIVE;0:ACTIVE;^0;3^Q"
.04,0)="FULL NAME^F^^0;4^K:$L(X)>150!($L(X)<3) X"               |  .04,0)="FULL NAME^F^^0;4^K:$L(X)>110!($L(X)<3) X"
.05,0)="SYNONYM #1^F^^0;5^K:$L(X)>50!($L(X)<3) X"                  .05,0)="SYNONYM #1^F^^0;5^K:$L(X)>50!($L(X)<3) X"
                                                                >  99.97,0)="REPLACED BY VHA STANDARD TERM^P9999999.04'I^AUTTIMAN(
                                                                >  99.98,0)="MASTER ENTRY FOR VUID^RSI^1:YES;0:NO;^VUID;2^Q"
                                                                >  99.99,0)="VUID^RFXI^^VUID;1^S X=+X K:$L(X)>20!($L(X)<1)!'(X?1.2
                                                                >  99.991,0)="EFFECTIVE DATE/TIME^9999999.0499DA^^TERMSTATUS;0"
                                                                >  201,0)="CDC NOTES^F^^2;1^K:$L(X)>245!($L(X)<1) X"
                                                                >  1101,0)="VACCINE^9999999.0411A^^11;0"
                                                                >  8801,0)="MNEMONIC^F^^88;1^K:X[""""""""!($A(X)=45) X I $D(X) K:$
```

## 9999999.14 (IMMUNIZATION)
As before, all RPMS fields have been preserved, although the "ACTIVE" field
was correctly renamed without changing the meaning. VISTA has several new
fields

```
== RPMS ==                                                                |  == VISTA ==
.01,0)="NAME^RFI^^0;1^K:$L(X)>100!($L(X)<3)!'(X'?1P.E)!(X'?.ANP) X"       |  .01,0)="NAME^RFXa^^0;1^K:$L(X)>100!($L(X)<3)!'(X'?1P.E)!(X'?.ANP) X I $D(
.02,0)="SHORT NAME^RFI^^0;2^K:X[""""""""!($A(X)=45) X I $D(X) K:$L(X)>10! |  .02,0)="SHORT NAME^Fa^^0;2^K:X[""""""""!($A(X)=45) X I $D(X) K:$L(X)>10!(
.03,0)="HL7-CVX CODE^RNXJ3,0I^^0;3^K:+X'=X!(X>999)!(X<0)!(X?.E1"".""1N.N) |  .03,0)="CVX CODE^FXa^^0;3^K:$S(X'?1.3N:1,$L(X)=3:$E(X)=""0"",1:X<1) X I $
.04,0)="DEFAULT LOT#^*P9999999.41^AUTTIML(^0;4^S DIC(""S"")=""I $P(^(0),U |  .04,0)="DEFAULT LOT#^*P9999999.41a^AUTTIML(^0;4^S DIC(""S"")=""I $P(^(0),
.05,0)="MAXIMUM# DOSES IN SERIES^NJ1,0I^^0;5^K:+X'=X!(X>9)!(X<0)!(X?.E1"" |  .05,0)="MAX # IN SERIES^Sa^0:NON-SERIES;1:1;2:2;3:3;4:4;5:5;6:6;7:7;8:8;^
                                                                          >  .06,0)="CHILDHOOD IMMUNIZATION^Sa^0:NO;1:YES;^0;6^Q"
 .07,0)="ACTIVE^S^0:ACTIVE;1:INACTIVE;^0;7^Q"                             |  .07,0)="INACTIVE FLAG^Sa^1:INACTIVE;^0;7^Q"
 .08,0)="SKIN TEST^S^0:NOT A SKIN TEST;1:SKIN TEST;^0;8^Q"                |  .08,0)="SKIN TEST^Sa^0:NOT A SKIN TEST;1:SKIN TEST;^0;8^Q"
 .09,0)="VACCINE GROUP (SERIES TYPE)^P9002084.93'I^BISERT(^0;9^Q"         |  .09,0)="VACCINE GROUP (SERIES TYPE)^P9002084.93'Ia^BISERT(^0;9^Q"
 .1,0)="ALTERNATE SHORT NAME^FI^^0;10^K:$L(X)>10!($L(X)<2) X"             |  .1,0)="ALTERNATE SHORT NAME^FIa^^0;10^K:$L(X)>10!($L(X)<2) X"
 .11,0)="CPT CODE^P81'I^ICPT(^0;11^Q"                                     |  .11,0)="CPT CODE^P81'Ia^ICPT(^0;11^Q"
 .12,0)="RELATED CONTRAIND HL7 CODES^FI^^0;12^K:$L(X)>100!($L(X)<1) X"    |  .12,0)="RELATED CONTRAIND HL7 CODES^FIa^^0;12^K:$L(X)>30!($L(X)<1) X"
 .13,0)="VIS DEFAULT DATE^D^^0;13^S %DT=""EX"" D ^%DT S X=Y K:Y<1 X"      |  .13,0)="VIS DEFAULT DATE^Da^^0;13^S %DT=""EX"" D ^%DT S X=Y K:Y<1 X"
 .14,0)="ICD DIAGNOSIS CODE^FI^^0;14^K:$L(X)>8!($L(X)<1) X"               |  .14,0)="ICD DIAGNOSIS CODE^FIa^^0;14^K:$L(X)>8!($L(X)<1) X"
 .15,0)="ICD PROCEDURE CODE^FI^^0;15^K:$L(X)>8!($L(X)<1) X"               |  .15,0)="ICD PROCEDURE CODE^FIa^^0;15^K:$L(X)>8!($L(X)<1) X"
 .16,0)="INCLUDE IN FORECAST^S^0:YES, INCLUDE;1:NO, EXCLUDE;^0;16^Q"      |  .16,0)="INCLUDE IN FORECAST^Sa^0:YES, INCLUDE;1:NO, EXCLUDE;^0;16^Q"
 .17,0)="INCLUDE IN VAC ACCOUNT REPORT^SI^1:YES;0:NO;^0;17^Q"             |  .17,0)="INCLUDE IN VAC ACCOUNT REPORT^SIa^1:YES;0:NO;^0;17^Q"
 .18,0)="DEFAULT VOLUME^NJ4,2^^0;18^K:+X'=X!(X>5)!(X<0)!(X?.E1"".""3N.N) X|  .18,0)="DEFAULT VOLUME^NJ4,2a^^0;18^K:+X'=X!(X>5)!(X<0)!(X?.E1"".""3N.N) 
                                                                          |  .2,0)="COMBINATION IMMUNIZATION (Y/N)^Sa^0:NO;1:YES;^0;20^Q"
 .21,0)="COMPONENT #1^P9999999.14'^AUTTIMM(^0;21^Q"                       |  .21,0)="COMPONENT #1^P9999999.14'a^AUTTIMM(^0;21^Q
 .22,0)="COMPONENT #2^P9999999.14'^AUTTIMM(^0;22^Q"                       |  .22,0)="COMPONENT #2^P9999999.14'a^AUTTIMM(^0;22^Q"
 .23,0)="COMPONENT #3^P9999999.14'^AUTTIMM(^0;23^Q"                       |  .23,0)="COMPONENT #3^P9999999.14'a^AUTTIMM(^0;23^Q"
 .24,0)="COMPONENT #4^P9999999.14'^AUTTIMM(^0;24^Q"                       |  .24,0)="COMPONENT #4^P9999999.14'a^AUTTIMM(^0;24^Q"
 .25,0)="COMPONENT #5^P9999999.14'^AUTTIMM(^0;25^Q"                       |  .25,0)="COMPONENT #5^P9999999.14'a^AUTTIMM(^0;25^Q"
 .26,0)="COMPONENT #6^P9999999.14'^AUTTIMM(^0;26^Q"                       |  .26,0)="COMPONENT #6^P9999999.14'a^AUTTIMM(^0;26^Q"
 1.01,0)="BRAND #1^F^^1;1^K:$L(X)>30!($L(X)<1) X"                         |  1.01,0)="BRAND #1^Fa^^1;1^K:$L(X)>30!($L(X)<1) X"
 1.03,0)="BRAND #2^F^^1;3^K:$L(X)>30!($L(X)<1) X"                         |  1.03,0)="BRAND #2^Fa^^1;3^K:$L(X)>30!($L(X)<1) X"
 1.05,0)="BRAND #3^F^^1;5^K:$L(X)>30!($L(X)<1) X"                         |  1.05,0)="BRAND #3^Fa^^1;5^K:$L(X)>30!($L(X)<1) X"
 1.07,0)="BRAND #4^F^^1;7^K:$L(X)>30!($L(X)<1) X"                         |  1.07,0)="BRAND #4^Fa^^1;7^K:$L(X)>30!($L(X)<1) X"
 1.09,0)="BRAND #5^F^^1;9^K:$L(X)>30!($L(X)<1) X"                         |  1.09,0)="BRAND #5^Fa^^1;9^K:$L(X)>30!($L(X)<1) X"
 1.14,0)="FULL NAME^F^^1;14^K:$L(X)>80!($L(X)<3) X"                       >  1.14,0)="FULL NAME^Fa^^1;14^K:$L(X)>80!($L(X)<3) X"
 1.15,0)="CPT CODE 2ND^P81'I^ICPT(^1;15^Q"                                >  1.15,0)="CPT CODE 2ND^P81'Ia^ICPT(^1;15^Q"
                                                                          >  2,0)="CDC FULL VACCINE NAME^9999999.142^^2;0"
                                                                          >  3,0)="CODING SYSTEM^9999999.143^^3;0"
                                                                          >  4,0)="VACCINE INFORMATION STATEMENT^9999999.144P^^4;0"
                                                                          >  5,0)="CDC PRODUCT NAME^9999999.145^^5;0"
                                                                          >  10,0)="SYNONYM^9999999.141^^10;0"
                                                                          >  99.97,0)="REPLACED BY VHA STANDARD TERM^P9999999.14'Ia^AUTTIMM(^VUID;3^Q"
                                                                          >  99.98,0)="MASTER ENTRY FOR VUID^RSIa^1:YES;0:NO;^VUID;2^Q"
                                                                          >  99.99,0)="VUID^RFXIa^^VUID;1^S X=+X K:$L(X)>20!($L(X)<1)!'(X?1.20N) X"
                                                                          >  99.991,0)="EFFECTIVE DATE/TIME^9999999.1499DA^^TERMSTATUS;0"
                                                                          >  100,0)="CLASS^Sa^N:NATIONAL;V:VISN;L:LOCAL;^100;1^Q"
                                                                          >  8801,0)="MNEMONIC^Fa^^88;1^K:X[""""""""!($A(X)=45) X I $D(X) K:$L(X)>3!($
                                                                          >  8802,0)="ACRONYM^Fa^^88;2^K:$L(X)>20!($L(X)<1) X"
                                                                          >  8803,0)="SELECTABLE FOR HISTORIC^RSa^Y:YES;N:NO;^6;1^Q"
```
                                                                          

## 9999999.41 (IMMUNIZATION LOT)
Changes here are straight forward. Like the file above, .03 has been redefined
in an incompatible away. The VA points to the NDC field in the pharmacy package,
something IHS couldn't do due to the fact that they do not maintain these files.

```
== RPMS ==                                                                |  == VISTA ==
.01,0)="LOT NUMBER^RFX^^0;1^K:$L(X)>25!($L(X)<3)!'(X'?1P.E) X S X=$$UPPER |  .01,0)="LOT NUMBER^RF^^0;1^K:$L(X)>25!($L(X)<3)!'(X'?1P.E) X"
.02,0)="MANUFACTURER^R*P9999999.04'^AUTTIMAN(^0;2^S DIC(""S"")=""I $P(^AU |  .02,0)="MANUFACTURER^R*P9999999.04'^AUTTIMAN(^0;2^S DIC(""S"")=""I '$P(^A
.03,0)="STATUS^RS^0:ACTIVE;1:INACTIVE;^0;3^Q"                             |  .03,0)="STATUS^S^2:EXPIRED;1:INACTIVE;0:ACTIVE;^0;3^Q"
.04,0)="VACCINE^R*P9999999.14'^AUTTIMM(^0;4^S DIC(""S"")=""I '$P(^(0),U,7 |  .04,0)="VACCINE^*P9999999.14'^AUTTIMM(^0;4^S DIC(""S"")=""I '$P(^(0),U,7)
.05,0)="VACCINE #2^P9999999.14'^AUTTIMM(^0;5^Q"                              .05,0)="VACCINE #2^P9999999.14'^AUTTIMM(^0;5^Q"
.06,0)="VACCINE #3^P9999999.14'^AUTTIMM(^0;6^Q"                              .06,0)="VACCINE #3^P9999999.14'^AUTTIMM(^0;6^Q"
.07,0)="VACCINE #4^P9999999.14'^AUTTIMM(^0;7^Q"                              .07,0)="VACCINE #4^P9999999.14'^AUTTIMM(^0;7^Q"
.08,0)="VACCINE #5^P9999999.14'^AUTTIMM(^0;8^Q"                              .08,0)="VACCINE #5^P9999999.14'^AUTTIMM(^0;8^Q"
.09,0)="EXPIRATION DATE^D^^0;9^S %DT=""EX"" D ^%DT S X=Y K:Y<1 X"            .09,0)="EXPIRATION DATE^D^^0;9^S %DT=""EX"" D ^%DT S X=Y K:Y<1 X"
.11,0)="STARTING COUNT^NJ5,0^^0;11^K:+X'=X!(X>99999)!(X<1)!(X?.E1"".""1.N |  .11,0)="STARTING COUNT^NJ5,0^^0;11^K:+X'=X!(X>99999)!(X<1)!(X?.E1"".""1N.
.12,0)="DOSES UNUSED^NJ7,0^^0;12^K:+X'=X!(X>1000000)!(X<0)!(X?.E1"".""1.N |  .12,0)="DOSES UNUSED^NJ5,0X^^0;12^K:$S(+X'=X:1,X>99999:1,X<0:1,X?.E1"".""
.13,0)="VACCINE SOURCE^S^v:VFC;n:NON-VFC;o:Other State;i:IHS/Tribal;^0;13    .13,0)="VACCINE SOURCE^S^v:VFC;n:NON-VFC;o:Other State;i:IHS/Tribal;^0;13
.14,0)="HEALTH CARE FACILITY^*P9999999.06'^AUTTLOC(^0;14^S DIC(""S"")=""I |  .14,0)="HEALTH CARE FACILITY^P9999999.06'^AUTTLOC(^0;14^Q"
.15,0)="LOW SUPPLY ALERT^NJ4,0^^0;15^K:+X'=X!(X>9999)!(X<0)!(X?.E1"".""1N |  .15,0)="LOW SUPPLY ALERT^NJ5,0X^^0;15^K:$S(+X'=X:1,X>99998:1,X<0:1,X?.E1"
.16,0)="LOT NUMBER FOR EXPORT^F^^0;16^K:$L(X)>12!($L(X)<3) X"                .16,0)="LOT NUMBER FOR EXPORT^F^^0;16^K:$L(X)>12!($L(X)<3) X"
.17,0)="NDC CODE^P9002084.95'^BINDC(^0;17^Q"                                 .17,0)="NDC CODE^P9002084.95'^BINDC(^0;17^Q"
                                                                          >  .18,0)="NDC CODE (VA)^P50.67'^PSNDF(50.67,^0;18^Q"
```

## 9999999.28 (SKIN TEST)

VISTA Adds several fields for MFS control. All the other fields are almost the
same as the RPMS equivalents.

```
.01,0)="NAME^RF^^0;1^K:$L(X)>10!($L(X)<3)!'(X'?1P.E)!(X'?.ANP) X"         |  .01,0)="NAME^RFXa^^0;1^K:$L(X)>30!($L(X)<3)!'(X'?1P.E)!(X'?.ANP) X"
.02,0)="CODE^RFX^^0;2^K:X[""""""""!($A(X)=45) X I $D(X) K:$L(X)>2!($L(X)< |  .02,0)="CODE^FXIa^^0;2^K:X[""""""""!($A(X)=45) X I $D(X) K:$L(X)>2!($L(X)
.03,0)="INACTIVE FLAG^S^1:INACTIVE;^0;3^Q"                                |  .03,0)="INACTIVE FLAG^Sa^1:INACTIVE;^0;3^Q"
.11,0)="CPT CODE^P81'^ICPT(^0;11^Q"                                       |  .11,0)="CPT CODE^P81'Ia^ICPT(^0;11^Q"
8801,0)="MNEMONIC^F^^88;1^K:X[""""""""!($A(X)=45) X I $D(X) K:$L(X)>2!($L |  3,0)="CODING SYSTEM^9999999.283^^3;0"
                                                                          >  99.97,0)="REPLACED BY VHA STANDARD TERM^P9999999.28'aI^AUTTSK(^VUID;3^Q"
                                                                          >  99.98,0)="MASTER ENTRY FOR VUID^RSaI^1:YES;0:NO;^VUID;2^Q"
                                                                          >  99.99,0)="VUID^RFXIa^^VUID;1^S X=+X K:$L(X)>20!($L(X)<1)!'(X?1.20N) X"
                                                                          >  99.991,0)="EFFECTIVE DATE/TIME^9999999.2899DA^^TERMSTATUS;0"
                                                                          >  100,0)="CLASS^Sa^N:NATIONAL;V:VISN;L:LOCAL;^100;1^Q"
                                                                          >  1201,0)="PRINT NAME^Fa^^12;1^K:$L(X)>15!($L(X)<3) X"
                                                                          >  8801,0)="MNEMONIC^Fa^^88;1^K:X[""""""""!($A(X)=45) X I $D(X) K:$L(X)>2!($
```

## 9000010.12 (V SKIN TEST)

```
== RPMS ==                                                                |  == VISTA ==
.01,0)="SKIN TEST^R*P9999999.28'^AUTTSK(^0;1^S DIC(""S"")=""I $P(^(0),U,3 |  .01,0)="SKIN TEST^R*P9999999.28'a^AUTTSK(^0;1^S DIC(""S"")=""I $P(^(0),U,
.02,0)="PATIENT NAME^RP9000001'I^AUPNPAT(^0;2^Q"                          |  .02,0)="PATIENT NAME^RP9000001'Ia^AUPNPAT(^0;2^Q"
.03,0)="VISIT^R*P9000010'I^AUPNVSIT(^0;3^S DIC(""S"")=""I $P(^(0),U,5)=$P |  .03,0)="VISIT^R*P9000010'Ia^AUPNVSIT(^0;3^S DIC(""S"")=""I $P(^(0),U,5)=$
.04,0)="RESULTS^SX^P:POSITIVE;N:NEGATIVE;D:DOUBTFUL;O:NO TAKE;^0;4^I X="" |  .04,0)="RESULTS^SXa^P:POSITIVE;N:NEGATIVE;D:DOUBTFUL;O:NO TAKE;^0;4^I X="
.05,0)="READING^NJ2,0X^^0;5^K:+X'=X!(X>40)!(X<0)!(X?.E1"".""1N.N) X I $D( |  .05,0)="READING^NJ2,0Xa^^0;5^K:+X'=X!(X>40)!(X<0)!(X?.E1"".""1N.N) X"
.06,0)="DATE READ^DX^^0;6^S %DT=""EX"" D ^%DT S X=Y K:X>DT!(X<AUPNDOB) X  |  .06,0)="DATE READ^DXa^^0;6^S %DT=""ET"" D ^%DT S X=Y K:Y<1!$$TIME^PXVUTL 
                                                                          |  .07,0)="READER^P200'a^VA(200,^0;7^Q"
.08,0)="TEST READER^P200'^VA(200,^0;8^Q"                                  |
.09,0)="INJECTION SITE^S^L:LEFT FOREARM;R:RIGHT FOREARM;^0;9^Q"           |
.11,0)="VOLUME^NJ4,2^^0;11^K:+X'=X!(X>5)!(X<0)!(X?.E1"".""3N.N) X"        |
.14,0)="LOT NUMBER^P9999999.41'^AUTTIML(^0;14^Q"                          |
																	      |  3,0)="CODING SYSTEM^9000010.123^^3;0"
																	      |  801,0)="PRIMARY DIAGNOSIS^*P80'a^ICD9(^80;1^S DIC(""S"")=""D ^AUPNSICD" "
																	      |  802,0)="DIAGNOSIS 2^*P80'a^ICD9(^80;2^S DIC(""S"")=""D ^AUPNSICD"" D ^D IC
																	      |  803,0)="DIAGNOSIS 3^*P80'a^ICD9(^80;3^S DIC(""S"")=""D ^AUPNSICD"" D ^D IC
																	      |  804,0)="DIAGNOSIS 4^*P80'a^ICD9(^80;4^S DIC(""S"")=""D ^AUPNSICD"" D ^D IC
																	      |  805,0)="DIAGNOSIS 5^*P80'a^ICD9(^80;5^S DIC(""S"")=""D ^AUPNSICD"" D ^D IC
																	      |  806,0)="DIAGNOSIS 6^*P80'a^ICD9(^80;6^S DIC(""S"")=""D ^AUPNSICD"" D ^D IC
																	      |  807,0)="DIAGNOSIS 7^*P80'a^ICD9(^80;7^S DIC(""S"")=""D ^AUPNSICD"" D ^D IC
																	      |  808,0)="DIAGNOSIS 8^*P80'a^ICD9(^80;8^S DIC(""S"")=""D ^AUPNSICD"" D ^D IC
1201,0)="EVENT DATE AND TIME^D^^12;1^S %DT=""EST"" D ^%DT S X=Y K:Y<1 X"  |  1201,0)="EVENT DATE AND TIME^DXa^^12;1^S %DT=""ET"" D ^%DT S X=Y K:Y<1!$$ 
1202,0)="ORDERING PROVIDER^*P200'X^VA(200,^12;2^S DIC(""S"")=""I $D(^VA(2 |  1202,0)="ORDERING PROVIDER^P200'a^VA(200,^12;2^Q"                         
1203,0)="CLINIC^P40.7'^DIC(40.7,^12;3^Q"                                  |
1204,0)="ENCOUNTER PROVIDER^P200'^VA(200,^12;4^Q"                            1204,0)="ENCOUNTER PROVIDER^P200'a^VA(200,^12;4^Q"                         
1205,0)="HOSPITAL LOCATION^P44'^SC(^12;5^Q"                               |
1206,0)="SERVICE CREDIT STOP^P40.7'^DIC(40.7,^12;6^Q"                     |
1207,0)="SECONDARY VISIT^P9000010'^AUPNVSIT(^12;7^Q"                      |
1208,0)="PARENT^P9000010.12'^AUPNVSK(^12;8^Q"
1209,0)="EXTERNAL KEY^F^^12;9^K:$L(X)>20!($L(X)<1) X"
1210,0)="OUTSIDE PROVIDER NAME^F^^12;10^K:$L(X)>30!($L(X)<1) X"
                                                                          |  1211,0)="SKIN TEST PLACEMENT RECORDED^Da^^12;11^S %DT=""ETXR"" D ^%DT S X
                                                                             1212,0)="ANATOMIC LOCATION OF PLACEMENT^*P920.3'a^PXV(920.3,^12;12^S DIC(
1213,0)="ANCILLARY POV^P80'^ICD9(^12;13^Q"
                                                                             1214,0)="HOURS READ POST-PLACEMENT^NJ3,0Ia^^12;14^K:+X'=X!(X>100)!(X<0)!(  
1215,0)="ORDERING LOCATION^P44'^SC(^12;15^Q"
1216,0)="DATE/TIME ENTERED^D^^12;16^S %DT=""ESTXR"" D ^%DT S X=Y K:Y<1 X"
1217,0)="ENTERED BY^P200'^VA(200,^12;17^Q"                                   
1218,0)="DATE/TIME LAST MODIFIED^D^^12;18^S %DT=""ESTXR"" D ^%DT S X=Y K: |
1219,0)="LAST MODIFIED BY^P200'^VA(200,^12;19^Q"                          |
                                                                             1220,0)="SKIN TEST READING RECORDED^Da^^12;20^S %DT=""ETXR"" D ^%DT S X=Y
                                                                             1301,0)="READING COMMENTS^Fa^^13;1^K:$L(X)>245!($L(X)<1) X"  
80101,0)="EDITED FLAG^S^1:EDITED;^801;1^Q"                                |  80101,0)="EDITED FLAG^Sa^1:EDITED;^801;1^Q"                              
80102,0)="AUDIT TRAIL^F^^801;2^K:$L(X)>85!($L(X)<2) X"                    |  80102,0)="AUDIT TRAIL^Fa^^801;2^K:$L(X)>85!($L(X)<2) X"                  
81101,0)="COMMENTS^F^^811;1^K:$L(X)>245!($L(X)<1) X"                      <  81101,0)="PLACEMENT COMMENTS^Fa^^811;1^K:$L(X)>245!($L(X)<1) X"         2
81201,0)="VERIFIED^SI^1:ELECTRONICALLY SIGNED;2:VERIFIED BY PACKAGE;^812; <  81201,0)="VERIFIED^SIa^1:ELECTRONICALLY SIGNED;2:VERIFIED BY PACKAGE;^81 
81202,0)="PACKAGE^P9.4'I^DIC(9.4,^812;2^Q"                                   81202,0)="PACKAGE^P9.4'Ia^DIC(9.4,^812;2^Q"                              
81203,0)="DATA SOURCE^P839.7'I^PX(839.7,^812;3^Q"                            81203,0)="DATA SOURCE^P839.7'Ia^PX(839.7,^812;3^Q"                       
```

# Overall pattern of differences
Overall, the VA version of the fields are much better documented. Reference
files are locked down to be updated by MFS (see above). For reference files,
the IHS programmer keeps the reference data in routines and separate files so
that it can be recreated at will using the Restandardize Tables option in RPMS.

As far as the actual data contents go, in files Immuniaztion (#9999999.14) and
Immunization Manufacturer (#9999999.04) have conceptually the same contents
but very different data order, different data names, and especially
Immunization has decently different contents as a difference set of fields are
populated.

With the exceptions noted above dealing with the active/inactive field in
various files, the VA has tried to be backwards compatible with RPMS to the
extent possible given their needs to repurpose the files for their use.

Due to the great improvements in the file structures created by the VA, it is
incumbent on IHS to take back the changes as they are very useful.
