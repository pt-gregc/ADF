<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2014.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files 
in this directory, you agree to the terms and conditions of the applicable 
end user license agreement.
--->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	pageID-to-link-for-local-ce-records.cfm
Summary:
	Renders an anchor tag with the page URL for the page ID of the current record
History:
	2014-02-19 - GAC - Created
--->
<cfscript>
	pageURL = application.ADF.csData.getCSPageURL(Request.DatasheetRow.pageid);
</cfscript>
<cfsavecontent variable="request.datasheet.currentFormattedValue">
	<cfoutput><td>
		<a href="#pageURL#">#request.datasheet.currentColumnValue#</a> 
	</td></cfoutput>
</cfsavecontent>
<cfset request.datasheet.currentSortValue = request.datasheet.currentColumnValue>