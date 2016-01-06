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
Name:
	taxonomy_1_0.cfc
Summary:
	Taxonomy functions for the ADF Library
Version:
	1.0
History:
	2009-06-22 - MFC - Created
	2011-01-14 - MFC - v1.0.1	- Bug fixes to getPageBindingsForTermID.
									Updates to getTermIDs.
--->
<cfcomponent displayname="taxonomy_1_0" extends="ADF.core.Base" hint="Taxonomy functions for the ADF Library">

<cfproperty name="version" value="1_0_3">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="Taxonomy_1_0">

<!--- 
	TODO: Check if is in CS already
 --->
<!---
/* ***************************************************************
/*
Author: 	Michael Carroll
Name:
	getTopTermIDArrayForFacet
Summary:
	Taxonomy function to return top term IDs for the facet ID
Returns:
	Array of term IDs
Arguments:
	Numeric facetID - Facet ID to return the top terms
--->
<cffunction name="getTopTermIDArrayForFacet" access="public" returntype="array" output="no">
	<cfargument name="facetID" type="numeric" required="yes">
	<cfargument name="taxonomyID" type="numeric" required="yes">

	<cfscript>
		var getTopTerms = '';
	</cfscript>

	<cfquery name="getTopTerms" datasource="#request.site.datasource#">
		SELECT t.*
		FROM term t, term_top tt
		WHERE tt.facetid = <CFQUERYPARAM VALUE="#arguments.facetID#" CFSQLTYPE="CF_SQL_INTEGER">
		AND t.taxonomyid = <CFQUERYPARAM VALUE="#arguments.taxonomyID#" CFSQLTYPE="CF_SQL_INTEGER">
		AND t.id = tt.termid
		AND t.taxonomyid = tt.taxonomyid
		AND t.updatestatus = 1
	</cfquery>

	<cfreturn ListToArray(ValueList(getTopTerms.ID))>
</cffunction>
<!---
	/* ***************************************************************
	/*
	Author: 	Ron West
	Name:
		$getCSTaxObj
	Summary:	
		Returns the taxonomy object for a given taxonomy name
	Returns:
		Object csTaxObj	
	Arguments:
		String taxName
	History:
		2009-09-03 - RLW - Created
	--->
<cffunction name="getCSTaxObj" access="public" returntype="any" hint="Returns the taxonomy object for a given taxonomy name">
	<cfargument name="taxName" type="string" required="true">
	<cfscript>
		var csTaxObj = createObject("component", "commonspot.components.taxonomy.taxonomy");
		var getTaxName = queryNew("");
	</cfscript>
	<cfquery name="getTaxName" datasource="#request.site.datasource#">
		select ID
		from taxonomy
		where name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.taxName#">
	</cfquery>
	<cfscript>
		if( getTaxName.recordCount )
			csTaxObj.init(getTaxName.ID, "false");
	</cfscript>
	<cfreturn csTaxObj>
</cffunction>
<!---
/* *************************************************************** */
Author: 	Ron West
Name:
	$getTermIDs
Summary:	
	Returns a list of termIDs from a list of terms and a given initialized taxonomy object
Returns:
	String termIdList
Arguments:
	Object csTaxObj - deprecated
	String termList
History:
	2009-09-03 - RLW - Created
	2010-12-06 - SFS - Rewritten for ADF 1.5 release to eliminate need for taxonomy calls and uses taxonomy DB views instead
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="getTermIDs" access="public" returntype="string" hint="Returns a list of termIDs from a list of terms and a given initialized taxonomy object">
	<cfargument name="csTaxObj" type="any" required="false" hint="No longer required - kept for backward compatibility">
	<cfargument name="termList" type="string" required="true" hint="List of Term String Names that will be converted to Ids">
	<cfscript>
		var termIDList = '';
		var termName = '';
		var getTermIDList = '';
	</cfscript>
	<cfloop list="#arguments.termList#" index="termName">

		<cfif request.cp.versionid EQ "510">
			<cfset termName = server.CommonSpot.UDF.data.fromHTML(termName)>
		<cfelseif val(request.cp.versionid) GTE 600>
			<cfset termName = server.CommonSpot.api.unescapeHTML(termName)>
		</cfif>

		<cfquery name="getTermIDList" datasource="#request.site.datasource#">
			SELECT termid
			FROM taxonomydataview
			WHERE termname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#termName#">
		</cfquery>

		<cfset termIDList = listAppend(termIDList,getTermIDList.termid)>

	</cfloop>

	<cfreturn termIDList>
</cffunction>
<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc
	M. Carroll
Name:
	getPageBindingsForTermID
Summary:
	Return the number of bindings for the Term ID
Returns:
	Struct - Count of bindings and the page id list
Arguments:
	Object csTaxObj
	String TermID - id for the term
	String facet - Facet for the term id
	Numeric - CEFormID - Custom element Form ID to find the taxonomy term.
	Numeric - CEFieldID - Custom element Field ID to find the taxonomy term.
	
History:
	2008-11-17 - MFC - Created - Moved into ADF
	2010-03-04 - GAC - Modified - Removed CF8 specific code
	2011-02-09 - RAK - Var'ing un-var'd variables
	2014-01-03 - GAC - Updated SQL 'IN' statements to use the CS module 'handle-in-list.cfm'
--->
<cffunction name="getPageBindingsForTermID" returntype="struct" access="public" output="yes">
	<cfargument name="csTaxObj" type="any" required="true" hint="CS Taxonomy API Object intialized to the proper taxonomy">
	<cfargument name="TermID" type="string" required="true">
	<cfargument name="facet" type="string" required="true">
	<cfargument name="CEFormID" type="numeric" required="true">
	<cfargument name="CEFieldID" type="numeric" required="true">
	<cfargument name="currTermPageIdList" type="string" required="false" default="">
	
	<cfscript>
		var bind_i = 1;
		var getFieldValues = "";
		var fieldValueList = "";
		
		// get children term id list
		var facetID = arguments.csTaxObj.getFacetID(arguments.facet);
		var childIdArray = arguments.csTaxObj.getNarrowerTermArray(facetID, arguments.TermID, true);
		// Set the return data struct
		var retDataStruct = StructNew();
		
		retDataStruct.bindingCount = 0;
		retDataStruct.pageIDList = "";
		
		// Update the children ID array
		ArrayAppend(childIdArray, TermID);
	</cfscript>
	
	<!--- GET A BINDING COUNT FOR THE TERMS --->
	<!--- Check if the CompareList is empty --->
	<cfloop index="bind_i" from="1" to="#ArrayLen(childIdArray)#">
		<!--- Query for field value --->
		<cfquery name="getFieldValues" datasource="#request.site.datasource#">
			SELECT  PageID, FieldValue as FV
			FROM	data_FieldValue
			WHERE	VersionState = 2
			AND 	fieldID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.CEFieldID#"> 
			AND 	formID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.CEFormID#">
			AND 	FieldValue <> ''
			<cfif len(arguments.currTermPageIdList)>
				AND <CFMODULE TEMPLATE="/commonspot/utilities/handle-in-list.cfm" FIELD="pageid" LIST="#arguments.currTermPageIdList#">
				<!--- AND pageid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.currTermPageIdList#" list="true">) --->
			</cfif>
		</cfquery>
		<!--- Loop over the fieldvalues --->
		<cfloop query="getFieldValues">
			<cfscript>
				// Replace all single quotes to make a numeric list
				fieldValueList = replace(getFieldValues.FV, "'", "", "all");
				// If the any matches then increment binding count
				if ( ListFind(fieldValueList, childIdArray[bind_i]) )
				{
					// Check if the current page id is already in the list
					if ( ListFind(retDataStruct.pageIDList, getFieldValues.PageID) LT 1 )
						retDataStruct.pageIDList = ListAppend(retDataStruct.pageIDList, getFieldValues.PageID);
					// Increment the binding count
					retDataStruct.bindingCount = retDataStruct.bindingCount + 1;
				}
			</cfscript>
		</cfloop>
	</cfloop>
	<cfreturn retDataStruct>
</cffunction>

</cfcomponent>
