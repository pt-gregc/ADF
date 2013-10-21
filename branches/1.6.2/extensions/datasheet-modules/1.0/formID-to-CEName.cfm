<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2013.
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
	formID-to-CEName.cfm
Summary:
	Renders the CE Name for the CE Form ID
History:
	2010-03-12 - MFC - Created
	2011-02-07 - RAK - Renamed file
--->
<cfscript>
	ceName = application.ADF.cedata.getCENameByFormID(request.datasheet.currentColumnValue);
</cfscript>
<cfsavecontent variable="tdHTML">
	<cfoutput>
		<td align="left">#ceName#</td>
	</cfoutput>
</cfsavecontent>
<cfset request.datasheet.currentFormattedValue = tdHTML>
<cfset request.datasheet.currentSortValue = ceName>