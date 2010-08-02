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
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:
	taxonomy_1_0.cfc
Summary:
	Taxonomy functions for the ADF Library
History:
	2009-06-22 - MFC - Created
--->
<cfcomponent displayname="taxonomy_1_0" extends="ADF.core.Base" hint="Taxonomy functions for the ADF Library">

<cfproperty name="version" value="1_0_0">
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
	Numeric taxonomyID - Taxonomy ID to return the top terms
	String orderby - Order By Field (ID or NAME)
History:
	2009-06-22 - MFC - Created
	2010-07-01 - GAC - Modified - Broke the getTopTerm query out as a seperate function
--->
<cffunction name="getTopTermIDArrayForFacet" access="public" returntype="array" output="no" hint="Taxonomy function to return top term IDs for the facet ID">
	<cfargument name="facetID" type="numeric" required="yes">
	<cfargument name="taxonomyID" type="numeric" required="yes">
	<cfargument name="orderby" type="string" default="" required="no" hint="Order By 'ID' (the term id) or 'NAME' (the term name)">
	
	<cfscript>
		var getTopTerms = getTopTermsQueryForFacet(arguments.facetID,arguments.taxonomyID,arguments.orderby);
	</cfscript>

	<cfreturn ListToArray(ValueList(getTopTerms.ID))>
</cffunction>

<!---
/* ***************************************************************
/*
Author: Michael Carroll
Name:
	getTopTermsQueryForFacet
Summary:
	Taxonomy function to return top terms as a query for the facet ID
Returns:
	Query of Terms
Arguments:
	Numeric facetID - Facet ID to return the top terms
	Numeric taxonomyID - Taxonomy ID to return the top terms
	String orderby - Order By Field (ID or NAME)
History:
	2009-06-22 - MFC - Created
	2010-07-01 - GAC - Modified - Broke the getTopTerms query out as a seperate function
--->
<cffunction name="getTopTermsQueryForFacet" access="public" returntype="query" output="no" hint="Taxonomy function to return top terms as a query for the facet ID">
	<cfargument name="facetID" type="numeric" required="yes">
	<cfargument name="taxonomyID" type="numeric" required="yes">
	<cfargument name="orderby" type="string" default="" required="no" hint="Order By 'ID' (the term id) or 'NAME' (the term name)">
	
	<cfscript>
		var getTopTerms = QueryNew("temp");
	</cfscript>

	<cfquery name="getTopTerms" datasource="#request.site.datasource#">
		SELECT t.*
		FROM term t, term_top tt
		WHERE tt.facetid = <CFQUERYPARAM VALUE="#arguments.facetID#" CFSQLTYPE="CF_SQL_INTEGER">
		AND t.taxonomyid = <CFQUERYPARAM VALUE="#arguments.taxonomyID#" CFSQLTYPE="CF_SQL_INTEGER">
		AND t.id = tt.termid
		AND t.taxonomyid = tt.taxonomyid
		AND t.updatestatus = 1
		<cfif LEN(TRIM(arguments.orderby)) AND (arguments.orderby IS "NAME" OR arguments.orderby IS "ID")>
		ORDER BY t.#arguments.orderby#
		</cfif>
	</cfquery>

	<cfreturn getTopTerms />
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
	/* ***************************************************************
	/*
	Author: 	Ron West
	Name:
		$getTermIDs
	Summary:	
		Returns a list of termIDs from a list of terms and a given initialized taxonomy object
	Returns:
		String termIdList
	Arguments:
		Object csTaxObj
		String termList
	History:
		2009-09-03 - RLW - Created
	--->
<cffunction name="getTermIDs" access="public" returntype="string" hint="Returns a list of termIDs from a list of terms and a given initialized taxonomy object">
	<cfargument name="csTaxObj" type="any" required="true" hint="CS Taxonomy API Object intialized to the proper taxonomy">
	<cfargument name="termList" type="string" required="true" hint="List of Term String Names that will be converted to Ids">
	<cfscript>
		var termIDList = "";
		var termName = "";
		// loop through the list of terms and get termId's
		for( itm=1; itm lte listLen(arguments.termList); itm=itm+1 )
		{
			termName = "";
			// check to see if either the original term or the non-html entity term exists (e.g. Arts & Entertainment vs. Arts &amp; Entertainment)
			if( arguments.csTaxObj.termExistsWithName(listGetAt(arguments.termList, itm)))
				termName = listGetAt(arguments.termList, itm);
			else if (arguments.csTaxObj.termExistsWithName(Server.commonspot.UDF.data.fromHTML(listGetAt(arguments.termList, itm))))
				termName = Server.commonspot.UDF.data.fromHTML(listGetAt(arguments.termList, itm));
			if( len(termName) )
				termIDList = listAppend(termIDList, arguments.csTaxObj.getTermID(termName));
		}
	</cfscript>
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
			<cfif len(arguments.currTermPageIdList)>AND pageid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.currTermPageIdList#" list="true">)</cfif>
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
