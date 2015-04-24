<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2015.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files 
in this directory, you agree to the terms and conditions of the applicable 
end user license agreement.
--->

<!---
/* ***************************************************************
/*
Author: 	PaperThin, INC
			M. Carroll
Name:
	userID-to-name.cfm
Summary:
	Placed on a userid value column in a datasheet - this module will
	render the full name for the user account.
ADF Requirements:
	csData_1_0
History:
	2009-06-29 - MFC - Created
	2011-02-07 - RAK - Renamed File
--->
<cfscript>
	contactName = "";
	if ( LEN(request.datasheet.currentColumnValue) ) {
		contactData = application.ADF.csData.getContactData(request.datasheet.currentColumnValue);
		if ( contactData.RecordCount ) {
			contactName = contactData.lastname;
			if ( LEN(contactData.firstname) )
				contactName = contactName & ", " & contactData.firstname;
		} else 
			contactName = "No User Name";
	}
</cfscript>

<cfsavecontent variable="tdHTML">
	<cfoutput>
		<td align="center">#contactName#</td>
	</cfoutput>
</cfsavecontent>

<cfset request.datasheet.currentFormattedValue = tdHTML>
<cfset request.datasheet.currentSortValue = contactName>