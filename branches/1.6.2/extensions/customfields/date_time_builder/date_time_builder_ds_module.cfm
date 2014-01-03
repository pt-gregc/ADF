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
	PaperThin Inc.
	M. Carroll
Name:
	date_time_builder_ds_module.cfm
Summary:
	Datasheet-Module for column rendering.
	Custom field to build the Date/Time records.
	This field generates a collection of Date and Times for the field.
Version:
	1.0.0
History:
	2010-09-16 - MFC - Created
--->
<cfscript>
	//dateTimeDataArray = application.ADF.ceData.getCEData("Date Time Builder Data", "uuid", request.datasheet.currentColumnValue);
	dateTimeDataArray = application.ADF.date_time_builder.buildDateTimeRenderData(request.datasheet.currentColumnValue);
	sortValue = "";
</cfscript>
<cfsavecontent variable="tdHTML">
	<cfoutput><td align="left"></cfoutput>
		<cfloop index="k" from="1" to="#ArrayLen(dateTimeDataArray)#">
			<cfoutput>#dateTimeDataArray[k].renderString#<br /></cfoutput>
			<!--- Check if first record to store as sort value --->
			<cfif k EQ 1>
				<cfset sortValue = dateTimeDataArray[k].renderString>
			</cfif>
		</cfloop>
	<cfoutput></td></cfoutput>
</cfsavecontent>
<cfset request.datasheet.currentFormattedValue = tdHTML>
<cfset request.datasheet.currentSortValue = sortValue>