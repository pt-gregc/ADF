<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$formID-CE-Name.cfm
Summary:
	Renders the CE Name for the CE Form ID
History:
	2010-03-12 - MFC - Created
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