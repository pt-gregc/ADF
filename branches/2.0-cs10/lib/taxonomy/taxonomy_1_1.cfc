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
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:
	taxonomy_1_1.cfc
Summary:
	Taxonomy functions for the ADF Library
Version:
	1.1
History:
	2011-01-14 - MFC - Created
	2015-06-10 - ACW - Updated the component extends to no longer be dependant on the 'ADF' in the extends path
	2015-09-09 - Added the getTaxonomyInfo method
			   - Added the handleTaxonomyFileImport methond
--->
<cfcomponent displayname="taxonomy_1_1" extends="taxonomy_1_0" hint="Taxonomy functions for the ADF Library">

<cfproperty name="version" value="1_1_5">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="Taxonomy_1_1">

<!---
/* *************************************************************** */
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
	2011-01-11 - MFC - Modified - Updated the ValueList to use the "termID" column from the query.
--->
<cffunction name="getTopTermIDArrayForFacet" access="public" returntype="array" output="no" hint="Taxonomy function to return top term IDs for the facet ID">
	<cfargument name="facetID" type="numeric" required="yes" hint="Facet ID">
	<cfargument name="taxonomyID" type="numeric" required="yes" hint="Taxonomy ID">
	<cfargument name="orderby" type="string" default="" required="no" hint="Order By 'ID' (the term id) or 'NAME' (the term name)">
	
	<cfscript>
		var getTopTerms = getTopTermsQueryForFacet(arguments.facetID,arguments.taxonomyID,arguments.orderby);
	</cfscript>

	<cfreturn ListToArray(ValueList(getTopTerms.termID))>
</cffunction>

<!---
/* *************************************************************** */
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
	2010-07-01 - GAC - Modified - Broke the getTopTerms query out as a separate function
	2010-12-06 - SFS - Rewritten for ADF 1.5 release to eliminate need for taxonomy calls and uses taxonomy DB views instead
	2012-05-30 - GAC - Updated the orderby logic to fix an issue with the termID and termName text concatenation with the CFParam
--->
<cffunction name="getTopTermsQueryForFacet" access="public" returntype="query" output="no" hint="Taxonomy function to return top terms as a query for the facet ID">
	<cfargument name="facetID" type="numeric" required="yes" hint="Facet ID">
	<cfargument name="taxonomyID" type="numeric" required="yes" hint="Taxonomy ID">
	<cfargument name="orderby" type="string" default="" required="no" hint="Order By 'ID' (the term id) or 'NAME' (the term name)">
	
	<cfscript>
		var getTopTerms = QueryNew("temp");
		var orderByText = "";
		var orderByOptions = "ID,TermID,Name,TermName";		
		
		// Handle the ORDERBY parameter options
		if ( LEN(TRIM(arguments.orderby)) AND ListFindNoCase(orderByOptions,arguments.orderby) )
		{
			if ( arguments.orderby EQ "ID" )
				orderByText = "TermID";
			else if ( arguments.orderby EQ "Name" )
				orderByText = "TermName";
			else
				orderByText = arguments.orderby;		
		}
	</cfscript>

	<cfquery name="getTopTerms" datasource="#request.site.datasource#">
		SELECT *
		FROM TaxonomyDataView
		WHERE taxonomyid = <CFQUERYPARAM VALUE="#arguments.taxonomyID#" CFSQLTYPE="CF_SQL_INTEGER">
		AND facetid = <CFQUERYPARAM VALUE="#arguments.facetID#" CFSQLTYPE="CF_SQL_INTEGER">
		AND (toptermname is null <cfif request.site.sitedbtype is not 'oracle'>OR toptermname = ''</cfif>)
		<cfif LEN(TRIM(orderByText))>
		ORDER BY #orderByText#
		</cfif>
	</cfquery>

	<cfreturn getTopTerms>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$getTermQryByFacet
Summary:
	Returns a Query of the taxonomy terms for the taxonomy and facet arguments.
	Function params allow to pass in the Facet Name or Facet ID.
Returns:
	query
Arguments:
	string
	string
	numeric
History:
	2011-01-04 - MFC - Created
--->
<cffunction name="getTermQryByFacet" access="public" returntype="query" output="true" hint="Returns a Query of the taxonomy terms for the taxonomy and facet arguments.">
	<cfargument name="taxonomyName" type="string" required="true" hint="Taxonomy Name">
	<cfargument name="facetName" type="string" required="false" default="" hint="Facet Name">
	<cfargument name="facetID" type="numeric" required="false" default="0" hint="Facet ID">
	
	<cfset var termQry = QueryNew("null")>
	<!--- Check if either the facet name or ID has a value for the query --->
	<cfif LEN(arguments.facetName) OR (arguments.facetID GT 0)>
		<!--- Query the TaxonomyDataView table --->
		<cfquery name="termQry" datasource="#request.site.datasource#">
			SELECT 	*
			FROM 	TaxonomyDataView
			WHERE	TaxonomyName = <cfqueryparam value="#arguments.taxonomyName#" cfsqltype="cf_sql_varchar">
			<cfif LEN(arguments.facetName)>
				AND FacetName = <cfqueryparam value="#arguments.facetName#" cfsqltype="cf_sql_varchar">
			<cfelse>
				AND FacetID = <cfqueryparam value="#arguments.facetID#" cfsqltype="cf_sql_integer">
			</cfif>
			ORDER BY TermName
		</cfquery>
	</cfif>
	<cfreturn termQry>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$getTermByRelationships
Summary:
	Returns a query of the taxonomy terms that have a reltionship to the target term ID argument.
	Additional parameters to filter results based on the facet ID and Relationship Name.
Returns:
	query
Arguments:
	numeric
	numeric
	numeric
	string
History:
	2011-01-04 - MFC - Created
	2011-03-02 - RAK - Added sorting on target term as a secondary sort.
	2011-05-10 - RAK - Added the ability to specify the sourceTermIDList and made targettermIDList optional
	2014-01-03 - GAC - Updated SQL 'IN' statements to use the CS module 'handle-in-list.cfm'
--->
<cffunction name="getTermByRelationships" access="public" returntype="query" output="true" hint="Returns a query of the taxonomy terms that have a reltionship to the target term ID argument.">
	<cfargument name="taxonomyID" type="numeric" required="true" hint="Taxonomy ID to search in">
	<cfargument name="targetTermIDList" type="string" required="false" default="" hint="Target termID list">
	<cfargument name="targetFacetID" type="numeric" required="false" default="0" hint="Target facet ID">
	<cfargument name="relationshipName" type="string" required="false" default="" hint="Relationship name">
	<cfargument name="sourceTermIDList" type="string" required="false"  default="" hint="Source term ID's">
	
	<cfset var termQry = QueryNew("null")>
	<!--- Query the term relationships --->
	<cfquery name="termQry" datasource="#request.site.datasource#">
		SELECT   	TaxonomyDataView.TaxonomyID, TaxonomyDataView.Taxonomyname, 
				        TaxonomyRelationshipType.TypeName AS AssociationName, TaxonomyRelationshipType.TypeDescription AS AssociationDescription, 
				        TaxonomyDataView.TermName AS SourceTerm, TaxonomyDataView.TermID AS SourceTermID, 
				        TaxonomyDataView.FacetID AS SourceFacetID, TaxonomyDataView.FacetName AS SourceFacetName, 
				        TaxonomyDataView_1.TermName AS TargetTerm, TaxonomyDataView_1.TermID AS TargetTermID, TaxonomyDataView_1.FacetID AS TargetFacetID, 
				        TaxonomyDataView_1.FacetName AS TargetFacetName
		FROM 		Term_Relationship INNER JOIN
						TaxonomyRelationshipType ON Term_Relationship.TaxonomyID = TaxonomyRelationshipType.TaxonomyID AND 
						Term_Relationship.RelationshipType = TaxonomyRelationshipType.TypeName INNER JOIN
						TaxonomyDataView ON Term_Relationship.TaxonomyID = TaxonomyDataView.TaxonomyID AND 
						Term_Relationship.IdSource = TaxonomyDataView.TermID INNER JOIN
						TaxonomyDataView AS TaxonomyDataView_1 ON Term_Relationship.TaxonomyID = TaxonomyDataView_1.TaxonomyID AND 
						Term_Relationship.IdTarget = TaxonomyDataView_1.TermID
		WHERE 		TaxonomyDataView.TaxonomyID = <cfqueryparam value="#arguments.taxonomyID#" cfsqltype="cf_sql_integer">
		<cfif Len(targetTermIDList)>
			AND <CFMODULE TEMPLATE="/commonspot/utilities/handle-in-list.cfm" FIELD="TaxonomyDataView_1.TermID" LIST="#arguments.targetTermIDList#">
			<!--- AND 		TaxonomyDataView_1.TermID IN (<cfqueryparam value="#arguments.targetTermIDList#" cfsqltype="cf_sql_integer" list="true">) --->
		<cfelseif Len(sourceTermIDList)>
			AND <CFMODULE TEMPLATE="/commonspot/utilities/handle-in-list.cfm" FIELD="TaxonomyDataView.TermID" LIST="#arguments.sourceTermIDList#">
	        <!--- AND 		TaxonomyDataView.TermID IN (<cfqueryparam value="#arguments.sourceTermIDList#" cfsqltype="cf_sql_integer" list="true">) --->
		</cfif>
		<cfif arguments.targetFacetID GT 0>
			AND		TaxonomyDataView_1.FacetID = <cfqueryparam value="#arguments.targetFacetID#" cfsqltype="cf_sql_integer">
		</cfif>
		<cfif LEN(arguments.relationshipName) GT 0>
			AND		TaxonomyRelationshipType.TypeName = <cfqueryparam value="#arguments.relationshipName#" cfsqltype="cf_sql_varchar">
		</cfif>
		ORDER BY 	SourceTerm, targetTerm
	</cfquery>
	<cfreturn termQry>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$getActiveTaxonomies
Summary:
	Returns a query with the active taxonomies for the site.
Returns:
	query
Arguments:
	void
History:
	2010-01-04 - MFC - Created
--->
<cffunction name="getActiveTaxonomies" access="public" returntype="query" output="true" hint="Returns a query with the active taxonomies for the site.">

	<cfset var taxQry = QueryNew("null")>
	<!--- Query the term relationships --->
	<cfquery name="taxQry" datasource="#request.site.datasource#">
		SELECT   	*
		FROM 		Taxonomy
		WHERE 		state = 1
		ORDER BY 	Name
	</cfquery>
	<cfreturn taxQry>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$getFacetQryForTaxonomy
Summary:
	Returns a Struct for the facet terms and IDs for the taxonomy.
Returns:
	struct
Arguments:
	numeric
History:
	2011-01-07 - MFC - Created
--->
<cffunction name="getFacetStructForTaxonomy" access="public" returntype="struct" output="true" hint="Returns a Struct for the facet terms and IDs for the taxonomy.">
	<cfargument name="taxonomyID" type="numeric" required="true" hint="Taxonomy ID to get facet struct for">
	
	<cfset var taxQry = QueryNew("null")>
	<cfset var facetStruct = StructNew()>
	<!--- Query the term relationships --->
	<cfquery name="taxQry" datasource="#request.site.datasource#">
		SELECT DISTINCT FacetID, FacetName
		FROM 		TaxonomyDataView
		WHERE 		TaxonomyID = <cfqueryparam value="#arguments.taxonomyID#" cfsqltype="cf_sql_varchar">
		ORDER BY 	FacetName
	</cfquery>
	<cfscript>
		if( taxQry.recordCount )
			facetStruct = server.ADF.objectFactory.getBean("Data_1_0").queryColumnsToStruct(taxQry, "FacetID", "FacetName");
	</cfscript>
	<cfreturn facetStruct>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$getTopTermStructForFacet
Summary:
	Returns a Struct for the Top Terms for the Facet.
Returns:
	struct
Arguments:
	numeric
History:
	2011-01-11 - MFC - Created
--->
<cffunction name="getTopTermStructForFacet" access="public" returntype="struct" output="true" hint="Returns a Struct for the Top Terms for the Facet.">
	<cfargument name="facetID" type="numeric" required="true" hint="Facet ID to get top term struct">
	<cfargument name="taxonomyID" type="numeric" required="true" hint="Taxonomy ID to get top term struct">
	<cfargument name="orderby" type="string" default="" required="no" hint="Order By 'ID' (the term id) or 'NAME' (the term name)">
	
	<cfscript>
		var getTopTermsQry = getTopTermsQueryForFacet(arguments.facetID,arguments.taxonomyID,arguments.orderby);
		var termStruct = StructNew();
	
		if( getTopTermsQry.recordCount )
			termStruct = application.ADF.data.queryColumnsToStruct(getTopTermsQry, "TermID", "TermName");
	</cfscript>
	<cfreturn termStruct>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$getFacetTermNestingArray
Summary:
	Returns an array of structs containing a full tree of the facets terms
Returns:
	array
Arguments:

History:
 	2011-09-08 - RAK - Created
	2011-10-10 - MFC - Moved function Taxonomy v1.1
--->
<cffunction name="getFacetTermNestingArray" access="public" returntype="array" hint="Returns an array of structs containing a full tree of the facets terms">
	<cfargument name="taxName" type="string" required="true" default="" hint="Taxonomy Name">
	<cfargument name="facetName" type="string" required="true" default="" hint="Facet Name">
	<cfscript>
		var taxObj = getCSTaxObj(arguments.taxName);
		var rtnArray = ArrayNew(1);
		var facetID = taxObj.getFacetID(arguments.facetName);
		var topTermArray = getTopTermIDArrayForFacet(facetID,taxObj.getID());
		var i = 1;
		for(i=1;i<=ArrayLen(topTermArray);i++){
			rtnArray[i] = StructNew();
			rtnArray[i].termID = topTermArray[i];
			rtnArray[i].children = getNarrowerTermArrayOfStructs(taxObj.getID(),facetID,topTermArray[i]);
		}
		return rtnArray;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$getNarrowerTermArrayOfStructs
Summary:
	Returns an array of narrower term ids with their values in an array
Returns:
	array
Arguments:

History:
 	2011-09-08 - RAK - Created
	2011-10-10 - MFC - Moved function Taxonomy v1.1
--->
<cffunction name="getNarrowerTermArrayOfStructs" access="public" returntype="array" hint="Returns an array of narrower term ids with their values in an array">
	<cfargument name="taxID" type="string" required="true" default="" hint="Taxonomy ID">
	<cfargument name="facetID" type="string" required="true" default="" hint="Facet ID">
	<cfargument name="termID" type="string" required="true" default="" hint="TermID to start the recursion from">
	<cfscript>
		var i = 1;
		var csTaxObj = createObject("component", "commonspot.components.taxonomy.taxonomy");
		var rtnArray = ArrayNew(1);
		var termIDS = "";
		csTaxObj.init(taxID, "false");
		termIDS = csTaxObj.getNarrowerTermArray(facetID,termID,false);
		for(i=1;i<=ArrayLen(termIDS);i++){
			rtnArray[i] = StructNew();
			rtnArray[i].termID = termIDS[i];
			rtnArray[i].children = getNarrowerTermArrayOfStructs(taxID,facetID,termIDS[i]);
		}
		return rtnArray;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$getTaxonomyInfo
Summary:
	Returns a struct of taxonomy info
Returns:
	struct
Arguments:
	Numeric taxonomyID
Usage:
	application.ADF.taxonomy.getTaxonomyInfo(taxonomyID)
History:
	2015-08-24 - GAC - Created 
--->
<cffunction name="getTaxonomyInfo" returntype="struct" access="public" hint="Returns a struct of taxonomy info">
	<cfargument name="taxonomyID" type="numeric" required="yes">
	
	<cfscript>
		var retData = StructNew();
		var taxComponent = Server.CommonSpot.api.getObject('Taxonomy');
		var taxInfoQry = taxComponent.getList();
	</cfscript>	
	
	<!--- // Filter the Taxonomy Information Query by the provided taxonomy ID  --->
	<cfquery name="taxInfoQry" dbtype="query">
		SELECT * 
		FROM taxInfoQry 
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.taxonomyID#">
	</cfquery>

	<cfscript>
		if ( taxInfoQry.RecordCount )
		{
			retData.ID = taxInfoQry.ID[1];
			retData.NAME = taxInfoQry.NAME[1];
			retData.DESCRIPTION = taxInfoQry.DESCRIPTION[1];
			retData.VERSION = taxInfoQry.VERSION[1];
			retData.STATUS = taxInfoQry.STATUS[1];
		}
		return retData;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$handleTaxonomyFileImport
Summary:
	Allow importing of properly formated taxonomy XML file. 
Returns:
	struct
Arguments:
	String filePath
	Numeric taxonomyID
Usage:
	application.ADF.taxonomy.handleTaxonomyFileImport(taxonomyID)
History:
	2015-08-24 - GAC - Created 
--->
<cffunction name="handleTaxonomyFileImport" returntype="struct" access="public" hint="Allow importing of properly formated taxonomy XML file. ">
	<cfargument name="filePath" type="string" required="yes">
	<cfargument name="taxonomyID" type="numeric" required="no" default="0">
	
	<cfscript>
		var retData = StructNew();
		var taxComponent = Server.CommonSpot.api.getObject('Taxonomy');
	
		retData = taxComponent.xmlFile(xmlFile=arguments.filePath,taxonomyID=arguments.taxonomyID);

		return retData;
	</cfscript>
</cffunction>

</cfcomponent>