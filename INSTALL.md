# Installation and Configuration
## Installation of KIDS file
To download the latest release, click on the
[Releases](https://github.com/shabiel/rpms-immunizations/releases) tab above.
The install is a normal KIDS build install.

Because it uses all the new Immunizations Data Structures in VISTA, you need to
have the latest VISTA Immunization-related KIDS build.

These are:

 * PX\*1.0\*201
 * PX\*1.0\*206
 * PX\*1.0\*209
 * PX\*1.0\*210

These builds can be found at http://foia-vista.osehra.org/Patches_By_Application/PX-PATIENT%20CARE%20ENCOUNTER/.

At the time of the writing, PX\*1.0\*210 has not been released. You can obtain
it from here: http://code.osehra.org/journal/journal/view/472.

## Installation of the Forecaster
While you can use the system without the forecaster, you are highly encouraged
to use it. The port did not change the forecaster. It uses the same forecaster,
which is the Texas Children's Hospital forecaster. Follow the instructions here:
http://www.ihs.gov/RPMS/PackageDocs/BI/TCH_ForecasterInstallInstr_Addendum.pdf.

To test the forecaster, do this:

	nc -v localhost 6708 <<< "20140424^0^0^0^0^TEST,PATIENT  Chart#: 000031^31^19830215^Male^U^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^0^~~~3484^03^20140414^0^0^0|||" &> tch-forcaster-test.txt

You should get a very long output that looks like this:

	&&&TCH Forecaster version 3.10.11^20150402173847^20140424^0^^^^^CREYG,ARLIE
	Chart#:
	000031^31^19830215^Male^~~~3484^03^0^20140414^0^^~~~115^B^1^19900215^19900215^19900215^^^~~~121^^1^^20330215^20430215^20440215^^|||33^^1^^19850215^20480215^20490215^^|||~~~1^1^1^1^1^1^1^1^1^1^1^0^^&&&Texas
	Children's Hospital Forecaster v3.10.11||||||-- ASSUMPTIONS
	---------------------------------------|||Adult assumed to have completed Hep B
	series.         |||Adult assumed to have completed DTaP series.
	|||Adult assumed to have completed MMR series.           |||Adult assumed to
	have completed Varicella series.     |||Adult assumed to have completed Hep A
	series.         ||||||-- EVALUATION
	--------------------------------------------------------|||DATE       CVX
	FORECAST   SCHEDULE DOSE STATUS ||||||-- FORECAST
	----------------------------------------------------------|||VACCINE TYPE
	STATUS           DOSE VALID      DUE        OVERDUE    |||Tdap
	overdue          B    02/15/1990 02/15/1990 02/15/1990 |||Influenza IIV
	overdue          1    07/01/2013 08/01/2013 11/01/2013 |||Influenza LAIV
	contraindicated  1    05/12/2014 05/12/2014 05/12/2014 ||||||-- EXPLANATION OF
	DECISION PROCESS -----------------------------------|||HepB||| + Dose 1 valid
	at birth, 02/15/1983.||| + Adult assumed to have completed Hep B series.|||
	Assumed to be complete after 02/15/2001 12:00:00 AM.|||Tdap||| + Dose 1 valid
	at 6 weeks of age, 03/29/1983.|||   Transitioning because patient is 12 Months
	Old as of 02/11/1984.|||   Patient reached 12 months of age without receiving
	first DTaP,|||   moving to alternate schedule.|||   Now expecting 1st catchup
	dose.||| + Dose 1 valid at 6 weeks of age, 03/29/1983.|||   Transitioning
	because patient is 7 Years Old as of 02/11/1990.|||   Patient reached 7 years
	of age without receiving one valid dose of|||   DTaP, moving to adult catchup
	schedule.|||   Now expecting 1st adult dose.||| + Dose 1 valid at 7 years of
	age, 02/15/1990.|||   Transitioning because patient is Adult assumed to have
	completed|||   DTaP series. as of 02/15/2001.|||   Assuming adult received full
	DTaP series as a child but now needs to|||   receive Tdap.|||   Now expecting
	Tdap Now dose.||| + Dose B valid at 7 years of age, 02/15/1990.||| +
	Forecasting for dose B due at 7 years of age, 02/15/1990.|||Hib||| + Dose 1
	valid at 6 weeks of age, 03/29/1983.|||   Transitioning because patient is 7
	Months Old as of 09/11/1983.|||   Did not receive first dose before 7 months of
	age, switching to 3|||   dose schedule.|||   Now expecting first 7-11 month
	catch-up dose.||| + Dose 1 valid at 6 weeks of age, 03/29/1983.|||
	Transitioning because patient is 12 Months Old as of 02/11/1984.|||   Did not
	receive first dose before 12 months of age, switching to 2|||   dose
	schedule.|||   Now expecting 12-14 month catch-up dose.||| + Dose 1 valid at 1
	year of age, 02/15/1984.|||   Transitioning because patient is 15 Months Old as
	of 05/11/1984.|||   Did not receive first or next dose before 15 months, final
	dose due|||   immediately.|||   Now expecting catch-up booster dose.||| + No
	need for further vaccinations after 19880215.|||PCV13||| + Dose 1 valid at 6
	weeks of age, 03/29/1983.|||   Transitioning because patient is 12 Months Old
	as of 02/11/1984.|||   First valid dose not received by 12 months of age, only
	2 doses|||   needed now.|||   Now expecting 2nd dose 12 month catchup dose.|||
	+ No need for further vaccinations after 19880215.|||IPV||| + Dose 1 valid at 6
	weeks of age, 03/29/1983.||| + Too late to complete. Next dose was expected
	before 02/15/2001|||   12:00:00 AM.|||Rota||| + Dose 1 valid at 6 weeks of age,
	03/29/1983.||| + Too late to complete. Next dose was expected before
	05/31/1983|||   12:00:00 AM.|||MMR||| + Dose 1 valid at 1 year of age,
	02/15/1984.|||   Transitioning because patient is Adult assumed to have
	completed MMR|||   series. as of 02/15/2001.|||   Assuming adult received full
	MMR series as a child.||| + Vaccination series complete, patient vaccinated.|||
	Vaccination series complete.|||Var||| + Dose 1 valid at 1 year of age,
	02/15/1984.|||   Transitioning because patient is Adult assumed to have
	completed|||   Varicella series. as of 02/15/2001.|||   Assuming adult received
	full Varicella series as a child or is|||   immune.||| + Vaccination series
	complete, patient vaccinated.|||   Vaccination series complete.|||MCV4||| +
	Dose 1 valid at 6 weeks of age, 03/29/1983.||| + Too late to complete. Next
	dose was expected before 02/15/2002|||   12:00:00 AM.|||HepA||| + Dose 1 valid
	at 1 year of age, 02/15/1984.||| + Adult assumed to have completed Hep A
	series.|||   Assumed to be complete after 02/15/2001 12:00:00 AM.|||HPV||| +
	Dose 1 valid at 9 years of age, 02/15/1992.||| + Too late to complete. Next
	dose was expected before 02/15/2005|||   12:00:00 AM.|||Influenza IIV||| + Dose
	1 valid at 6 months of age, 08/15/1983.|||   Transitioning because of Flu
	Season Start on 07/01/2013.|||   Now expecting current season dose.||| + Dose 1
	valid at 6 months of age, 08/15/1983.||| + Forecasting for dose 1 due at 1
	month after season start, 08/01/2013.|||Influenza LAIV||| + Dose 1 valid at 6
	months of age, 08/15/1983.|||   Transitioning because of Flu Season Start on
	07/01/2013.|||   Now expecting current season dose.||| + Dose 1 valid at 6
	months of age, 08/15/1983.||| + Forecasting for dose 1 due at 1 month after
	season start, 08/01/2013.||| + Adjusting due date for Influenza LAIV to after
	contraindication|||   black out date of 05/12/2014.|||Zoster||| + Dose 1 valid
	at 50 years of age, 02/15/2033.||| + Forecasting for dose 1 due at 60 years of
	age, 02/15/2043.|||PPSV||| + Dose 1 valid at 2 years of age, 02/15/1985.|||
	Transitioning because patient is 18 Years Old as of 02/15/2001.|||   Now
	expecting 65 Years dose.||| + Dose 1 valid at 2 years of age, 02/15/1985.||| +
	Forecasting for dose 1 due at 65 years of age, 02/15/2048.||||||Texas
	Children's Hospital Forecaster v3.10.11||| + run date: 04/02/2015||| +
	schedule: TCH-2014-11-19|||

## Configuration of the Immunization Package
### Allocation of Security Keys
The main menu is BIMENU; but it's protected by the key BIZMENU. In addition,
you need the manager key (BIZ MANAGER) in order to configure the package.

First, create a user on the system, and then allocate the keys to that user.
You need these keys:

	BIZ MANAGER    BIZMENU        BIZ EDIT PATIENTS

### Package Set-up
Then, you need to get to BIMENU.

Once you run `BIMENU`, you will get this warning message:

                                   WARNING
                                  ---------


     Immunization Site Parameters have NOT been set for the site
     you are logged on as: CAMP MASTER

     At this point you should back out of the Immunization Package
     and contact your site manager or the person in charge of the
     Immunization Software.
     
     Or, if you wish to set up Site Parameters for this site,
     you may proceed to the Edit Site Parameters option and enter
     parameters for this site.  (Menu Synonyms: MGR-->ESP)

That's exactly what we will do.

I like the famous Immunizations Butterfly, which you will see after you hit
enter.

```
                  .. --- ..         *     *         .. --- ..
                *          ~ *.      \   /      .* ~          *
              *                *      \ /      *                *
             (         RPMS      *    (|)    *     Version       )
              *    IMMUNIZATION    *  ***  *         8.5*10     *
                *.                   *   *                   .*
                   *                *     *                *
                     >              *     *              <
                    *                *   *                *
                  *               * *     * *               *
                 *     @        *   *     *   *        @     *
                (             *      *   *      *             )
                 *.        *          ***          *        .*
                   / /-- ~             ~             ~ --\ \

                           MAIN MENU at CAMP MASTER


   PAT    Patient Menu ...
   REP    Reports Menu ...
   MGR    Manager Menu ...
```

Going to MGR > ESP, you will see the following

<pre>
  Immunization v8.5*10
                          *  EDIT SITE PARAMETERS  *



   Select SITE/FACILITY: CAMP MASTER//     NY  VAMC  500            
  Are you adding 'CAMP MASTER' as a new BI SITE PARAMETER (the 1ST)? No// Y

 Immunization v8.5*10         Oct 02, 2015@17:23:51          Page:    1 of    1 

     Edit Site Parameters for: CAMP MASTER
--------------------------------------------------------------------------------
 
   1) Default Case Manager.........: 
   2) Other Location...............: 
   3) Standard Imm Due Letter .....: 
   4) Official Imm Record Letter...: 
   5) Facility Report Header.......: CAMP MASTER
   6) Host File Server Path........: 
   7) Minimum Days Last Letter.....: 60 days
   8) Minimum vs Recommended Age...: Recommended Age
   9) 4-Day Grace Period option....: 4-Day Grace Period NOT Used
  10) Lot Number Options...........: NOT Required, Default Low Supply Alert=50
  11) Pneumo routine age to begin..: Begin Pneumo at 65 years
  12) Forecasting (Imms Due).......: Disabled
  13) Chart# with dashes...........: No Dashes (123456)
  14) User as Default Provider.....: No
  15) IP Address for TCH Forecaster: 127.0.0.1
  16) Communities for Statistics...: No communities selected.
  17) Inpatient Visit Check........: Disabled
  18) High Risk Factor Check.......: Disabled
  19) Import CPT-coded Visits......: Disabled
  20) Visit Selection Menu.........: Disabled (Link Visits automatically)
</pre>

Edit the parameters, filling in 1, 2, 6, turning forecasting on in 12, and 
then adding a zip code for community statistics (make sure that some of your
patients have that zip code).

```
   1) Default Case Manager.........: USER,OPC
   2) Other Location...............: WALGREENS NEXT DOOR
   3) Standard Imm Due Letter .....: 
   4) Official Imm Record Letter...: 
   5) Facility Report Header.......: CAMP MASTER
   6) Host File Server Path........: /tmp/
   7) Minimum Days Last Letter.....: 60 days
   8) Minimum vs Recommended Age...: Recommended Age
   9) 4-Day Grace Period option....: 4-Day Grace Period NOT Used
  10) Lot Number Options...........: NOT Required, Default Low Supply Alert=50
  11) Pneumo routine age to begin..: Begin Pneumo at 65 years
  12) Forecasting (Imms Due).......: Enabled
  13) Chart# with dashes...........: No Dashes (123456)
  14) User as Default Provider.....: No
  15) IP Address for TCH Forecaster: 127.0.0.1
  16) Communities for Statistics...: 1 communities selected.
  17) Inpatient Visit Check........: Disabled
  18) High Risk Factor Check.......: Disabled
  19) Import CPT-coded Visits......: Disabled
  20) Visit Selection Menu.........: Disabled (Link Visits automatically)
```

### Form Letters

Under MGR > LET, create a couple of letter forms, one being a Mail Form; and
the other being a Standard Official Letter form. 

```
  Immunization v8.5*10
                         *  VIEW/EDIT FORM LETTERS  *


     This screen will allow you to add and edit Form Letters.
     
     Please select a Form Letter, or enter the name of a new Form Letter
     you wish to add.  (Enter "?" to see a list of existing Form Letters.)
     
     Select Form Letter: MAIL REMINDER
  Are you adding 'TEST' as a new BI LETTER (the 3RD)? No// Y

                         *  ADD A NEW FORM LETTER  *


     You have chosen to add a new Form Letter.
     In order to save you time, this program will load a Sample Form Letter,
     which you may then edit to suit the purpose of your new Form Letter.
     
     There are three Sample Form Letters to choose from:
     
        1) Standard Due Letter
        2) Official Immunization Record
        3) Standard Due Letter--Forecast First
     
     Or you may choose to copy an existing customized Form Letter and
     then make changes to it under the new Form Letter you are creating.
     
     Please enter "1" to select the Standard Due Letter, "2" to select
     the Official Immunization Record, "3" to select the Standard Due
     Letter (with the Forecast listed first and the History following),
     or enter "C" to copy an existing Form Letter.
     
     Enter 1, 2, 3, or C: 
```

Exit out of the Listman screen without doing any more changes.

Once you create the two letters, you can go back to the Site Parameters (ESP)
and assign them as the official letters for the clinic, so that your parameters
now look like this:

```
   1) Default Case Manager.........: USER,OPC                                   
   2) Other Location...............: WALGREENS NEXT DOOR                        
   3) Standard Imm Due Letter .....: MAIL REMINDER                              
   4) Official Imm Record Letter...: OFFICIAL LETTER                            
   5) Facility Report Header.......: CAMP MASTER                                
   6) Host File Server Path........: /tmp/                                      
```

### Lot numbers
At this point, you need to add a set of lot numbers for testing. On a demo
database with adult patients, you should add lot numbers for TDAP, Influenza,
Zoster, and Pneumovax.

This is done through MGR > LOT. Please note that you may crash due to a bad
index in PX*1.0*210. If that happens, on Cache, type 'G'; on GT.M, type 
'S $EC="" ZC'.

MGR > LOT takes you to this screen. Follow the sequence to add lot numbers.

```
 Immunization v8.5*10         Oct 02, 2015@17:56:34          Page:    0 of    0 
 
                                 CAMP MASTER
                                -------------
                            EDIT LOT NUMBER TABLE
                           (Listed by Unused Doses)

  #  Lot Number            Vaccine     Status  Exp Date  Start Unused  Facility 











          Enter ?? for more actions.                                            
A  Add a Lot Number       E  Edit a Lot Number      D  Display Inactives Yes/No
C  Change List Order      S  Search List            I  Inactivate Old Lots
                                                    H  Help
Select Action: Quit// ADD

 Imm v8.5*10            * * *  ADD A LOT NUMBER  * * *

      Lot Number:   
_______________________________________________________________________________

  Lot Number: TDAP-111               Vaccine: TDAP                             
          Sub-lot:                            (TDAP)      

           Status: Active       Manufacturer: MERCK AND CO., INC.           
  Expiration Date: JAN 1,2016         Source:
      Default NDC:

   Starting Count: 100     Doses Unused: 100     Doses Used: 0    
 Low Supply Alert:                               (calculated)

         Facility:
_______________________________________________________________________________
Exit     Save     Refresh
 
Enter a command or '^' followed by a caption to jump to a specific field.


COMMAND:                                       Press <PF1>H for help    Insert 
```

If you add the rest of the lot numbers, you should get something that looks
like the following:

```
 Immunization v8.5*10         Oct 02, 2015@18:48          Page:    1 of    1 
 
                                 CAMP MASTER
                                -------------
                            EDIT LOT NUMBER TABLE
                           (Listed by Unused Doses)

  #  Lot Number            Vaccine     Status  Exp Date  Start Unused  Facility 
  1  ZOSTER123.............ZOSTER......Active..01/01/16..   10..   10...........
  2  FLU-111...............INFLUENZA, IActive..01/01/16..   50..   50...........
  3  PNEU111...............PNEUMOVAX...Active..01/01/16..  100..  100...........
  4  TDAP-111..............TDAP........Active..01/01/16..  100..  100...........







          Enter ?? for more actions.                                            
A  Add a Lot Number       E  Edit a Lot Number      D  Display Inactives Yes/No
C  Change List Order      S  Search List            I  Inactivate Old Lots
                                                    H  Help
Select Action: Quit// 
```

At this point, you are done with the configuration of the immunization package.
You can now enter immunizations on patients.
