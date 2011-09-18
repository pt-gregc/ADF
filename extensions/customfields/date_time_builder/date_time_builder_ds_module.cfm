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