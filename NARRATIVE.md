# Narrative of the Porting of RPMS Immunizations to VISTA
I (Sam Habiel) have always advocated to port the RPMS Immunization package to
VISTA. I consider the immunizations package to be the crown jewel of RPMS.

I was happily given an opportunity to do that through funding from WorldVistA,
in conjunction with the VA V Immunizations Project, to assist in bringing over
RPMS Immunizations to VISTA with a view towards code convergence.

Because of how well written the RPMS code is (in fact, I won't hesitate to say
that Mike Remillard, the original author, writes the best M code that I have
ever seen), it was a pleasure porting the code to work on VISTA.

# General Strategy
In doing the port, rather than plopping down the whole code base in the 
namespace BI in VISTA and then trying to make it work, I decided to take a
structured approach: port all the routines, menus, and keys first, then bring
over the elements for each menu option at the time I am porting it.

You will see a bunch of KIDS builds (33 right now) that contains each discrete
piece of the RPMS package here: <https://github.com/shabiel/rpms-immunizations/tree/master/kids/VISTA-Port>.

# Order of Port
In order to port the package, the most sensible thing to do was start with the
Site Parameters and work my way up. Here's the actual order:

 * Site Parameters
 * Letter Generation
 * Key Allocation
 * Lot Number Management
 * Immunization/Skin Test Enter/Edit for Patients
 ** Patient Characteristics Form
 ** Contraindications Form
 ** Health Summary
 ** Visit creation, very elementary
 * FIRST VISTA KIDS BUILD
 * Visit creation, update to use new elements in VISTA
 * Eligibilities
 * SECOND VISTA KIDS BUILD
 * Due List and Letters option
 * All Report
 * Export patient immunizations

# Philosophical differences between RPMS and VISTA
There are some major differences in the between VISTA and RPMS; and they
inform some of the decisions in the port.

## Master File Server control of the files in VISTA
In VISTA, the Immunization files are locked down; they can only be updated via
the Master File Server. In RPMS, the Immunization package's files are also
standardized; however, the tables are maintained inside routines and are
converted to Fileman files upon request for standardization via a menu option
in the Manager menu.

## Standardized Health Factors in RPMS
Being a smoker affects your forecasting for Pneumovax. It's easy to obtain
this information on RPMS; impossible on VISTA. RPMS represents smoking as a
standardized health factor; in VISTA, health factors are not standardized; and
there is no other standard way to identify smokers.

## RPMS as a Population Health System
RPMS has a strong legacy as a population health system. About a third or more
of the Immunization package deals with population health, for good reason, as
it's useless to have a population that is half-immunized. To that end, there
are a few concepts that I had to translate from RPMS to VISTA:

 * The concept of User Population (At least 1 visit in the last 3 years) and 
   Active Population (2 or more visits to primary clinics in the last 3 years).
 * GPRA Communities, which I translated to zip/postal codes.

# Peculiarities in RPMS
There were a few coding issues in RPMS that presented me with some difficulties.

RPMS has a set of XB routines that is used to for exclusive kills and news
using namespaces. As these are banned by the VISTA SAC, I had to remove them.
These were used in doing List Manager recursion.

Non-compliance with the SAC in network communications even though it is
possible to be compliant.

Older versions of VISTA software on RPMS, like the List Manager, have
incompatible behaviors with regard to control characters: The VISTA List 
Manager (v 1.1) strips them, whereas the one in RPMS (v 1.0), keeps them.
They are used in RPMS to provide highlighting.

# How do you use a single code base?
In order to have a single code base for both VISTA and RPMS, I had to
conditionlize code for each platform via if statements.

E.g.
```
 ; VEN/SMH - For VISTA
 I '$$RPMS^BIUTL9() Q $$ACTCLINV(BIDFN,BIEDATE)
```

`$$RPMS^BIUTL9()` looks like this:

```
RPMS() ; [Public $$] Are we running on RPMS??
 ; Try to do a heuristic determination
 ; Just fiddling with this for now since I don't know the best way yet
 ; I don't want to do this with DUZ("AG") (Agency) since many people may
 ; run RPMS as agency of "Other".
 if $data(^AUTTSITE(0)) quit 1
 quit 0
```

# Differences between VISTA and RPMS Immunization Data and Structures
This is list of tidbits that cumulatively didn't make the port smooth.

The VISTA standard immunization file does not have the short name filled for
all Immunizations. That meant that I had to change some of the code for VISTA
to pull in the .01 full name. That alas made some immunizations not readable 
and made them not fit on the screen.

An improvement in VISTA is that a lot number now has the extra status of
expired. I took advantage of that. In RPMS, there is only active vs inactive.

In the immunization manufacturer file (#9999999.04), the VA programmer made a
mistake and reversed the set of codes meaning in RPMS. In RPMS: 0 = Inactive,
1 = active. VISTA: Vice versa.

In VISTA, rather than import and contraindications file in RPMS, it was decided
to create a new file (#920.4). I had to change the code to use that file, and
I even ported the new better file back to RPMS.

CVX codes from the CDC are stored as numbers in RPMS vs text in VISTA (e.g. 
RPMS: 3, VISTA: 03)

The lot number field in V Immunizations, I believe due to mistake, moved in
VISTA from the existing RPMS field of .05 on the V IMMUNIZATIONS file to 1207. 
The old field still remains.

# Visit file differences between VISTA and RPMS
A visit in VISTA requires a hospital location (i.e. the clinic where it took
place); in RPMS it does not.

The patient index in Visit files in RPMS is "AC"; VISTA is "C". That's
important when doing any data collection.

Different API to file a visit in VISTA. The VISTA API files on modifying
existing V file entries modifies them in place; RPMS's API creates a new entry.
I was mystified for a while wondering why did the software delete the V entry
after editing it; it turned out that it was expecting a new V entry, and so
deleting the old entry. That had to be changed here.

The visit modification date in VISTA is updated automatically.

The VISTA API does not give you back a pointer to the created visit or V file
entry; and the software relied on that to update some elements. I had to 
sneakily find the entry and update some elements on it that are not part of the
V Imm project and as such don't have an updated API.

In reporting, there is an index in RPMS on the V files for the visit date:
"ADT". I re-wrote that code on VISTA to traverse the B index on the VISIT file
and then to use the "AD" index on V Imm to backtrack to that visit date.

# Specific enhancements when filing an immunization in VISTA
To take advantage of the enhancements done in VISTA in the V Imm project, these
changes were made.

 * Split the injection site into Route and Injection Location
 * File and obtain the lot number into the changed V Imm location
 * Split volume to Dose and UCMM dose units
 * VIS given to patient in RPMS represents a date, VIS is now a real file in
   VISTA, so you can point to it, which is what is done now.
 * Capture Hospital Location since it is required in VISTA.

# Skin tests
I ran out of time to do skin tests filing. So it doesn't work right now.

# Specific issues when doing reports
There were some challenges that have to do with reporting.

 * The default filter in all reports is being a Indian/Alaska Native, the
   population whom RPMS serves. This was changed to include all patients.
 * Selection of communities was changed from GPRA communities to a collection
   of zip codes.
 * As mentioned above, the V files patient index in RPMS is "AC" but "C" in
   VISTA
 * As mentioned above, there is an "ADT" index on V files in RPMS for visit
   date. This does not exist in VISTA.
 * At the time of my development, there were no vaccine groups available in
   the Immunization file; but they are used in at least one report. I didn't
   complete that report.
 * VISTA has no concept of User population vs Active population for reporting
   purposes. I created that code.
