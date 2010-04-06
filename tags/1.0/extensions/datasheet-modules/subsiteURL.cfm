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
	/* ***************************************************************
	/*
	Author: 	Ron West
	Name:
		$subsiteURL.cfm
	Summary:	
		Used as a column Render Handler for the Datasheet element
		This module will take a subsite ID and render the URL
		for the subsite
	History:
		2009-07-30 - RLW - Created
--->
<cfscript>
	subsiteID = request.datasheet.currentColumnValue;
</cfscript>

<cfsavecontent variable="tdHTML">
	<cfoutput>
		<td><!--- <a href="#request.subsiteCache[subsiteID].url#"> --->#request.subsiteCache[subsiteID].url#<!--- </a> ---></td>
	</cfoutput>
</cfsavecontent>

<cfset request.datasheet.currentFormattedValue = tdHTML>