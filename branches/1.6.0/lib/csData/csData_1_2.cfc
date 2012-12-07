<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2012.
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
	csData_1_2.cfc
Summary:
	CommonSpot Data Utils functions for the ADF Library
Version:
	1.2
History:
	2012-12-07 - MFC - Created - New v1.1
--->
<cfcomponent displayname="csData_1_2" extends="ADF.lib.csData.csData_1_1" hint="CommonSpot Data Utils functions for the ADF Library">

<cfproperty name="version" value="1_2_1">
<cfproperty name="type" value="singleton">
<cfproperty name="data" type="dependency" injectedBean="data_1_1">
<cfproperty name="taxonomy" type="dependency" injectedBean="taxonomy_1_1">
<cfproperty name="wikiTitle" value="CSData_1_2">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$getCustomMetadataFieldParamValue
Summary:
	Returns the value of a field parameter based on the Custom Metadata form name and field name
Returns:
	String 
Arguments:
	Numeric cspageid
	String fromname - Custom Metadata form name
	String fieldname - Custom Metadata field name
	String fieldparam - Custom Metadata param name
History:
	2012-02-17 - GAC - Created
	2012-02-22 - GAC - Added comments
	2012-03-19 - GAC - Removed the call to application.ADF.ceData
--->
<cffunction name="getCustomMetadataFieldParamValue" access="public" returntype="String" hint="Returns the value of a field parameter based on the Custom Metadata form name and field name">
	<cfargument name="cspageid" type="numeric" required="true" hint="commonspot pageID">
	<cfargument name="formname" type="string" required="true" hint="Custom Metadata form name">
	<cfargument name="fieldname" type="string" required="true" hint="Custom Metadata field name">
	<cfargument name="fieldparam" type="string" required="false" default="label" hint="Custom Metadata field param">
	<cfscript>
		var rtnValue = "";
		// Get the Custom Metadata field struct with params as values
		var cmDataStruct = getCustomMetadataFieldsByCSPageID(cspageid=arguments.cspageid,fieldtype="",addFieldParams=true);
		// Does the provided formname exist in the Custom Metadata field struct
		if ( StructKeyExists(cmDataStruct,arguments.formname) )
		{
			// Does the provided fieldname exist in the Custom Metadata field struct in formname struct
			if  ( StructKeyExists(cmDataStruct[arguments.formname],arguments.fieldname) )
			{
				// Does the provided field aram (default: label) exist in the Custom Metadata field struct in the form[field] struct
				if  ( StructKeyExists(cmDataStruct[arguments.formname][arguments.fieldname],arguments.fieldparam) )
				{
					// if the form[field][param] exists get the value of the param and set it as the return value
					rtnValue = cmDataStruct[arguments.formname][arguments.fieldname][arguments.fieldparam];
				}			
			}
		}
		return rtnValue;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$getCustomMetadatawithFieldLabelsKeys
Summary:
	Returns a custom metadata structure with the field name keys converted to field labels (keeping the values for each)
Returns:
	Struct 
Arguments:
	Numeric cspageid
History:
	2012-02-17 - GAC - Created
--->
<cffunction name="getCustomMetadatawithFieldLabelsKeys" access="public" returntype="Struct" hint="Returns a custom metadata structure with the field name keys converted to field labels (keeping the values for each)">
	<cfargument name="cspageid" type="numeric" required="true" hint="commonspot pageID">
	<!--- <cfargument name="customMetadata" type="struct" required="true" hint="commonspot custom meta data stucture"> --->
	<cfscript>
		var rtnStruct = StructNew();
		var cmDataStuct = getCustomMetadata(pageid=arguments.cspageid,convertTaxonomyTermsToIDs=1);
		//var cmDataStuct = arguments.customMetadata;
		var thisForm = "";
		var thisField = "";
		var paramType = "label";
		var custMetadataLabel = "";
		// Loop over the custom metadata structure that was passed in
		for ( key in cmDataStuct ) {
			// set the Key to the thisForm variable
			thisForm = key;
			// check to see if the thisForm contains stucture
			if ( IsStruct(cmDataStuct[thisForm]) )
			{
				// Create the new return struct for this form
				rtnStruct[thisForm] = StructNew();
				// loop over the field in the current form
				for (key in cmDataStuct[thisForm]) {
					// Set the Key to the thisField variable
					thisField = key;
					// Get the LABEL value for this field
					custMetadataLabel = getCustomMetadataFieldParamValue(cspageid=arguments.cspageid,formname=thisForm,fieldname=thisField,fieldparam=paramType);
					// Set the new LABEL key for the return struct for this form
					rtnStruct[thisForm][custMetadataLabel] = cmDataStuct[thisForm][thisField];
				}
			}
		}	
		return rtnStruct;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$getUserNameFromUserID
Summary:
	Returns CommonSpot username when given a numeric userID.
Returns:
	String
Arguments:
	userID the numeric ID for the user to get data for
History:
	2012-02-03 - GAC - Created
--->
<cffunction name="getUserNameFromUserID" access="public" returntype="String" hint="Returns CommonSpot username when given a numeric userID.">
	<cfargument name="userID" required="yes" type="numeric" default="" hint="the numeric ID for the user to get data for">
	<cfscript>
		var qryData = QueryNew("temp");
	</cfscript>
	<cfquery name="qryData" datasource="#request.site.usersdatasource#" maxrows="1"><!--- USERS DATASOURCE --->
		SELECT UserID AS UserName
		FROM users
		WHERE ID = <cfqueryparam value="#arguments.userID#" cfsqltype="cf_sql_integer">
	</cfquery>
	<cfreturn TRIM(qryData.UserName)>
</cffunction>

</cfcomponent>