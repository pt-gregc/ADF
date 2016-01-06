<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2016.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files 
in this directory, you agree to the terms and conditions of the applicable 
end user license agreement.
--->

<!---
/* ***************************************************************
/*
Author: 	PaperThin, INC
			G. Cronkright
Name:
	value-to-yes-no.cfm
Summary:
	Convert a the value of a cell to a yes or a no.
	- If the value is boolean value of 1, true or yes... display a 'Yes' 
	- If the value is not boolean, an empty string, false or '0'... display a 'No' 
ADF Requirements:
	na
History:
	2011-05-15 - GAC - Created
--->
<cfscript>
	activeValue = 'No';
	if ( LEN(TRIM(request.datasheet.currentColumnValue)) AND IsBoolean(request.datasheet.currentColumnValue) AND request.datasheet.currentColumnValue ) 
		activeValue = 'Yes';
</cfscript>

<cfsavecontent variable="tdHTML">
	<cfoutput>
		<td align="center">#activeValue#</td>
	</cfoutput>
</cfsavecontent>

<cfset request.datasheet.currentFormattedValue = tdHTML>
<cfset request.datasheet.currentSortValue = activeValue>