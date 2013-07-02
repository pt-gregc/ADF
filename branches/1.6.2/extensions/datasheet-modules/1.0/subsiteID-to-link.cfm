<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2010.
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
--->
<cfscript>
	subsiteID = request.datasheet.currentColumnValue;
</cfscript>

<cfsavecontent variable="tdHTML">
	<cfoutput>
		<td>
			<cfif IsNumeric(subsiteID) AND StructKeyExists(request.subsiteCache,subsiteID)>
				<a href="#request.subsiteCache[subsiteID].url#">
					#request.subsiteCache[subsiteID].url#
				</a>
			<cfelse>
				Subsite does not exist.
			</cfif>
		</td>
	</cfoutput>
</cfsavecontent>

<cfif IsNumeric(subsiteID) AND StructKeyExists(request.subsiteCache,subsiteID)>
	<cfset Request.datasheet.currentSortValue = request.subsiteCache[subsiteID].url>
<cfelse>
	<cfset Request.datasheet.currentSortValue = 0>	
</cfif>
<cfset request.datasheet.currentFormattedValue = tdHTML>