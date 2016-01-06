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
	pageIDlist-to-linkList.cfm
Summary:
	Based on pageID-to-link.cfm but converts PageID list to an Page Link with a Page Title 
History:
	2010-11-05 - MFC - Created
	2011-12-19 - GAC - Updated to handle converting a list of pageIDs into stacked lists of PageURL links with pageTitles
--->
<cfscript>
	navPageIDList = Request.Datasheet.currentColumnValue;
	
	p = 1;
	navPageID = "";
	navPageURL = "";
	navPageTitle = "";
	navPageInfo = StructNew();
	counter = 1;
	sortValue = "";
</cfscript>

<cfsavecontent variable="request.datasheet.currentFormattedValue">
	<cfoutput><td>
		<cfloop from="1" to="#ListLen(navPageIDList)#" index="p">
			<cfset navPageID = ListGetAt(navPageIDList,p)>
			<cfset navPageTitle = "">
			<cfset navPageURL = "">
			<cfif IsNumeric(navPageID)>
				<!--- // Get the Page URL  --->
				<cfset navPageURL = application.ADF.csData.getCSPageURL(navPageID)>
				<!--- // Get the Page Title from the page Standard MetaData --->
				<cfset navPageInfo = application.ADF.csData.getStandardMetadata(navPageID)> 
				<cfif StructKeyExists(navPageInfo,"title") AND LEN(TRIM(navPageInfo.Title))>
					<cfset navPageTitle = navPageInfo.Title>
					<cfset navPageTitle = REREPLACE(navPageTitle,"[\s]","&nbsp;","all")>
				<cfelse>
					<cfset navPageTitle = "[No&nbsp;Page&nbsp;Found]">
				</cfif>
				<!--- // Set the first item in the list to be the Sort value  --->
				<cfif counter EQ 1>
					<cfif LEN(TRIM(navPageTitle))>
						<cfset sortValue = navPageTitle>
					<cfelse>
						<cfset sortValue = navPageURL>
					</cfif>
				</cfif>
				<!--- // Create the list of Titles and URLs --->
				<!--- (#navPageID#)&nbsp; --->
				<cfif LEN(TRIM(navPageURL))><a href="#navPageURL#" title="#navPageURL#" target="_blank"></cfif><cfif LEN(TRIM(navPageTitle))>#navPageTitle#<cfelse>#navPageURL#</cfif><cfif LEN(TRIM(navPageURL))></a></cfif><br/>
				<cfset counter = counter + 1>
			</cfif>
		</cfloop>
	</td></cfoutput>
</cfsavecontent>
<cfset request.datasheet.currentSortValue = sortValue>