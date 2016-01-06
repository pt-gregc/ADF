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
	M. Carroll
Name:
	pageID-to-link.cfm
Summary:
	Renders an anchor tag with the page URL for the page ID
History:
	2010-11-05 - MFC - Created
	2011-02-07 - RAK - Renamed file
--->
<cfscript>
	if ( LEN(Request.Datasheet.currentColumnValue) )
		pageURL = application.ADF.csData.getCSPageURL(Request.Datasheet.currentColumnValue);
	else
		pageURL = "";
</cfscript>
<cfsavecontent variable="request.datasheet.currentFormattedValue">
	<cfoutput><td>
		<cfif LEN(pageURL)>
			<a href="#pageURL#">#pageURL#</a>
		</cfif>
	</td></cfoutput>
</cfsavecontent>
<cfset request.datasheet.currentSortValue = pageURL>