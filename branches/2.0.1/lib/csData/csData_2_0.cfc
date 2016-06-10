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
	csData_2_0.cfc
Summary:
	CommonSpot Data Utils functions for the ADF Library
Version:
	2.0
History:
	2015-01-08 - GAC - Created - New v2.0	
	2016-05-09 - DMB - Added getPageCategoryIDbyName function.
--->
<cfcomponent displayname="csData_2_0" extends="csData_1_3" hint="CommonSpot Data Utils functions for the ADF Library">

<cfproperty name="version" value="2_0_2">
<cfproperty name="type" value="singleton">
<cfproperty name="data" type="dependency" injectedBean="data_2_0">
<cfproperty name="taxonomy" type="dependency" injectedBean="taxonomy_2_0">
<cfproperty name="wikiTitle" value="CSData_2_0">

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$getPageCategoryName
Summary:
	Given a CS page categoryID return if the page category name.
Returns:
	String
Arguments:
	Numeric  categoryID
History:
	2015-06-23 - GAC - Created
--->
<cffunction name="getPageCategoryName" access="public" output="yes" returntype="string">
	<cfargument name="categoryID" type="numeric" required="Yes">

	<cfscript>
		var catCom = server.CommonSpot.api.getObject('Categories');
		var catQry = catCom.getList(type="Document");
	</cfscript>

	<cfquery name="catQry" dbtype="query">
		SELECT NAME
		FROM catQry
		WHERE id = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.categoryID#">
	</cfquery>

	<cfscript>
		if ( catQry.recordCount )
			return catQry.NAME;
		else
			return "";
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$getPageCategoryIDbyName
Summary:
	Given a CS page categoryName return if the page category ID.
Returns:
	String
Arguments:
	Numeric  categoryID
History:
	2016-05-09 - DMB - Created
--->
<cffunction name="getPageCategoryIDbyName" access="public" output="yes" returntype="number">
	<cfargument name="categoryName" type="string" required="Yes">

	<cfquery name="catQry" datasource="#request.site.datasource#">
		SELECT CategoryTypeID
		FROM generalCategories 
		WHERE category = <cfqueryparam cfsqltype="CF_SQL_varchar" value="#arguments.categoryName#">
	</cfquery>

	<cfscript>
		if ( catQry.recordCount )
			return catQry.categoryTypeID;
		else
			return "";
	</cfscript>
</cffunction>

</cfcomponent>