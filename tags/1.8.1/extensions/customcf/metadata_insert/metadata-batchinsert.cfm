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
	$Id: metadata-batchinsert.cfm,v 0.1 08-06-2007 11:00:00 paperthin Exp $

	Description:
		Action page that updates the selected pages' metadata from metadata-batchinsert-form.cfm
	Parameters:
		none
	Usage:
		none
	Documentation:
		08-06-2007 - Documentation added
	Based on:
		none
--->

<!--- Init some variables --->
<cfset strDSN="#form.txtDSN#">
<cfset intFormID=listfirst(#form.lstFormFields#)>
<cfset intFieldID=listlast(#form.lstFormFields#)>
<cfset intTemplateID=#form.lstTemplates#>
<cfset strFieldVal="#txtValue#">
<cfset intPageCount=1>
<cfset strStamp='#DateFormat(now(),'yyyy-mm-dd')# #TimeFormat(now(),'hh:mm:ss')#'>

<!--- Delete all the form field values for this particular form --->
<CFMODULE template="/commonspot/metadata/tags/data_control/deletefieldvalue.cfm"
	id="#intFieldID#"
	formID="#intFormID#">

<!--- Select all the pages that are not the base template, not an uploaded document, but are regular CommonSpot pages or templates --->
<cfquery datasource="#strDSN#" name="rstPages">
	SELECT *
	  FROM SitePages
	 WHERE (CharIndex('#intTemplateID#', InheritedTemplateList) > 0)
		AND Uploaded = 0
		AND PageType IN (0, 1)
</cfquery>

<!--- Warning to the user --->
<cfoutput>
	<strong>NOTE:</strong> When all pages are complete, follow these steps:<br>
	1) Login to your <em>Subsite Admininstration</em> (/admin.cfm), select <em>Subsite Properties</em><br>
	2) Under "Caching", clear cache for all appropriate browsers<br>
	3) Browse to <em>Site Admin</em> (linked from top toolbar)<br>
	4) Under "Administrative Tools" run utlitity to "Rebuild Stub Files" <br><br>
</cfoutput>

<!--- Loop over the pages found and update their metadata --->
<cfloop query="rstPages">
	<cfoutput>###intPageCount# - Updating "#rstPages.Title#" (FormID:FieldID) #intFormID#:#intFieldID# to value:"#strFieldVal#"</cfoutput>
	<CFMODULE template="/commonspot/utilities/getid.cfm" targetVar="newListID">
	<!--- Delete the relevant metadata fields for this page --->
	<cfquery datasource="#strDSN#" name="qClearListItems">
		DELETE FROM Data_ListItems
		 WHERE StrItemValue = <CFQUERYPARAM VALUE="#strFieldVal#" CFSQLTYPE="CF_SQL_VARCHAR">
			AND PageID=<CFQUERYPARAM VALUE="#rstPages.ID#" CFSQLTYPE="CF_SQL_INTEGER">
	</cfquery>
	<!--- Insert new metadata fields for this page --->
	<cfquery datasource="#strDSN#" name="qInsertListID">
		INSERT INTO Data_ListItems
			(ListID, Position, PageID, StrItemValue)
		VALUES
			(<CFQUERYPARAM VALUE="#newListID#" CFSQLTYPE="CF_SQL_INTEGER">, 1,
			 <CFQUERYPARAM VALUE="#rstPages.ID#" CFSQLTYPE="CF_SQL_INTEGER">,
			 <CFQUERYPARAM VALUE="#strFieldVal#" CFSQLTYPE="CF_SQL_VARCHAR">)
	</cfquery>
	<!--- Insert the new metadata for this page --->
	<cfquery datasource="#strDSN#" name="qInsertFieldValue">
		INSERT INTO Data_FieldValue
			(PageID, DateAdded, DateApproved, FieldID, FormID, FieldValue, IsSubmitted, ListID)
		VALUES
			(<CFQUERYPARAM VALUE="#rstPages.ID#" CFSQLTYPE="CF_SQL_INTEGER">,
			 <CFQUERYPARAM VALUE="#strStamp#" CFSQLTYPE="CF_SQL_VARCHAR">,
			 <CFQUERYPARAM VALUE="#strStamp#" CFSQLTYPE="CF_SQL_VARCHAR">,
			 <CFQUERYPARAM VALUE="#intFieldID#" CFSQLTYPE="CF_SQL_INTEGER">,
			 <CFQUERYPARAM VALUE="#intFormID#" CFSQLTYPE="CF_SQL_INTEGER">,
			 <CFQUERYPARAM VALUE="#strFieldVal#" CFSQLTYPE="CF_SQL_VARCHAR">, 1,
			 <CFQUERYPARAM VALUE="#newListID#" CFSQLTYPE="CF_SQL_INTEGER">)
	</cfquery>
	<cfoutput> Complete<BR></cfoutput>
	<cfscript>
		intPageCount=intPageCount+1;
	</cfscript>
</cfloop>