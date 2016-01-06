<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc.  Copyright (c) 2009-2016.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files 
in this directory, you agree to the terms and conditions of the applicable 
end user license agreement.
--->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	subsiteID-to-link.cfm
Summary:	
	Used as a column Render Handler for the Datasheet element
	This module will take a subsite ID and render the URL
	for the subsite
History:
	2009-07-30 - RLW - Created
	2010-01-12 - GAC - Modified - Added URL text Sorting
	2011-02-07 - RAK - Renamed file
	2011-04-28 - RAK - Fixed so that it wont throw an error if they try to translate a bad subsite.
	2011-12-06 - SFS - Added the other bad subsite fix that was missed about the currentSortValue as well.
	2013-06-26 - GAC - Added IsNumeric checks around the subsiteID values
					 - Added logic to always generate a currentSortValue
	2013-08-09 - GAC - Added extra check to make sure the column value is a number 
			   and that a SubsiteCace URL value is available for the provided subsiteID
	2013-09-06 - GAC - Added fall back to check for subsite URL info from using the getSubsiteURLbySubsiteID function  
--->
<cfscript>
	ssID = request.datasheet.currentColumnValue;
	ssURL = "";
	
	// Is the SubsiteID value passed a numeric value
	if ( LEN(TRIM(ssID)) AND IsNumeric(ssID) ) {
		// If the CS subsiteCache has a URL value then use it... 
		// if not, then check the CS Subsite table using the getSubsiteURLbySubsiteID function
		if ( StructKeyExists(request,"subsiteCache") AND StructKeyExists(request.subsiteCache,ssID) AND StructKeyExists(request.subsiteCache[ssID],"url") AND LEN(TRIM(request.subsiteCache[ssID].url)) )
			ssURL = request.subsiteCache[ssID].url;
		else 
			ssURL = application.ADF.csData.getSubsiteURLbySubsiteID(subsiteID=ssID);			
	}
</cfscript>

<cfsavecontent variable="tdHTML">
<cfoutput>
	<td>
		<cfif LEN(TRIM(ssURL))>
			<a href="#ssURL#">
				#ssURL#
			</a>
		<cfelse>
			Subsite does not exist.
		</cfif>
	</td>
</cfoutput>
</cfsavecontent>

<cfif LEN(TRIM(ssURL))>
	<cfset Request.datasheet.currentSortValue = ssURL>
<cfelse>
	<cfset Request.datasheet.currentSortValue = "">	
</cfif>
<cfset request.datasheet.currentFormattedValue = tdHTML>