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
	fields_1_0.cfc
Summary:
	Custom Field Type functions for the ADF Library
Version:
	1.0
History:
	2013-12-09 - MFC - Created
	2014-08-04 - GAC - Added new methods getCEFieldID and getCEFieldName
	2015-02-06 - GAC - Added the new method renderHiddenControlsFromQueryString
	2015-02-24 - GAC - Added the new method renderHiddenControlsFromRequestParams
--->
<cfcomponent displayname="fields_1_0" extends="ADF.core.Base" hint="Custom Field Type functions for the ADF Library">

<cfproperty name="version" value="1_0_5">
<cfproperty name="type" value="transient">
<cfproperty name="wikiTitle" value="Fields_1_0">

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$renderDataValueStringfromFieldMask
Summary:
	Returns the string of data values from field mask. 
	Used with the Custom Element Field Select CFT
Returns:
	string
Arguments:
	Struct - fieldDataStruct
	string - fieldMaskStr
History:
 	2010-12-06 - RAK - Created
	2013-11-14 - DJM - Pulled out from the Custom Element Select Field render file and converted to its own method
	2013-11-14 - GAC - Moved from the Custom Element Select Field to the Forms_1_1 lib
	2013-12-18 - GAC - Moved from the Forms_1_1 LIB to the new Field_1_0 LIB
--->
<cffunction name="renderDataValueStringfromFieldMask" hint="Returns the string of data values from field mask" access="public" returntype="string">
	<cfargument name="fieldDataStruct" type="struct" required="true" hint="Struct with the field key/value pair">
	<cfargument name="fieldMaskStr" type="string" required="true" hint="String mask of <fieldNames> used build the field value display">
	<cfscript>
		var displayField = arguments.fieldMaskStr;
		var startChar = chr(171);
		var endChar = chr(187);
		var value = '';
		var foundIndex = 0;
		var foundEndIndex = 0;
		
		// While we still detect the upper ascii start character loop through
		while ( Find(startChar,displayField) ) {
			foundIndex = Find(startChar,displayField);
			foundEndIndex = Find(endChar,displayField);
			//Grab the content in between the start and end character
			value = mid(displayField,foundIndex+1,foundEndIndex-foundIndex-1);
			if ( StructKeyExists(arguments.fieldDataStruct,value) ) {
				// We found it. Replace the <value> with the actual value
				displayField = Replace(displayField,"#startChar##value##endChar#", arguments.fieldDataStruct[value],"ALL");
			}
			else {
				// Something is messed up... tell them so in the field!
				displayField = Replace(displayField,"#startChar##value##endChar#", "Field '#value#' does not exist!");
			}
		}
		
		return displayField;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$isFieldReadOnly
Summary:
	Given xparams determines if the field is readOnly
Returns:
	boolean
Arguments:
	Struct - xparams
	String - fieldPermission
History:
	2010-12-06 - RAK - Created
	2011-11-22 - GAC - Added a fieldPermission argument and logic to handle 6.x field security
	2012-12-03 - GAC - Fixed the logic when checking the fieldPermission value for CS 6.0+ to only return ReadOnly when the fieldPermission value equals 1
	2013-12-05 - GAC - Added parameters for the CFTs fqFieldName and the attributes.currentValues struct
					 - Added the CS 9+ fqFieldName_doReadonly check to see if the field is forces to be read only
	2014-01-06 - GAC - Moved from the Forms_1_1 LIB to the new Field_1_0 LIB
--->
<cffunction name="isFieldReadOnly" access="public" returntype="boolean" hint="Given xparams determines if the field is readOnly">
	<cfargument name="xparams" type="struct" required="true" hint="the CFT xparams struct">
	<cfargument name="fieldPermission" type="string" required="false" default="" hint="fieldPermission attribute for CS 6.x and above: 0 (no rights), 1 (read only), 2 (edit)">
	<cfargument name="fqfieldName" type="string" required="false" default="" hint="the CFT's fqfieldName">
	<cfargument name="currentValues" type="struct" required="false" default="#StructNew()#" hint="the CFT attributes.currentValues struct">
	<cfscript>
		var readOnly = true;
		var productVersion = ListFirst(ListLast(request.cp.productversion," "),".");
		var commonGroups = "";
		
		// Determine if this field should be read only due to "Use Explicit Security"
		
		// Check the CS version
		if ( productVersion GTE 6 ) {
			// Check to see if this field is FORCED to be READ ONLY by looking for the CS 9+ fqFieldName_doReadonly struct key
			if ( LEN(TRIM(arguments.fqFieldName)) AND StructKeyExists(arguments.currentValues,"#TRIM(arguments.fqFieldName)#_doReadonly") ) 
				readOnly = true;
			else {
				// For CS 6.x and above
				// - If the user has ready only rights (fieldPermission = 1) readOnly will be true
				if ( LEN(TRIM(arguments.fieldPermission)) AND arguments.fieldPermission EQ 1 ) 
					readOnly = true;
				else
					readOnly = false;
			}				
		}
		else {
			// For CS 5.x 
			// Get the list permissions and compare
			commonGroups = application.ADF.data.ListInCommon(request.user.grouplist, arguments.xparams.pedit);
			// Check if the user does have edit permissions
			if ( (arguments.xparams.UseSecurity EQ 0) OR ( (arguments.xparams.UseSecurity EQ 1) AND (ListLen(commonGroups)) ) )
				readOnly = false;	
		}
		
		return readOnly;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$wrapFieldHTML
Summary:
	Wraps the given information with valid html for the current commonspot and configuration
Returns:
	String
Arguments:
	String - fieldInputHTML
	Query - fieldQuery
	Struct - attr
	String - fieldPermission
	Boolean - includeLabel
	Boolean - includeDescription
History:
 	2010-12-06 - RAK - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
	2011-09-09 - GAC - Added doHiddenFieldSecurity to convert field to a hidden field if "Use Explicit Security" and user is not part of an Edit or View group
	2011-11-07 - GAC - Addressed table formatting issues with the includeLabel argument 
					 - Added an includeDescription argument to allow the description to be turned off
	2011-11-22 - GAC - Added a fieldPermission argument and logic to handle 6.x field security
	2013-12-06 - GAC - Added nowrap="nowrap" to the Label table cell
					 - Added a TRIM to the label variable
	2014-01-06 - GAC - Added the labelClass variable the Field Label to specify optional or required class to the label tag
					 - Moved from the Forms_1_1 LIB to the new Field_1_0 LIB
	2014-03-03 - GAC - Added a class and a class varialbe to the field's label TD for required fields
--->
<cffunction name="wrapFieldHTML" access="public" returntype="String" hint="Wraps the given information with valid html for the current commonspot and configuration">
	<cfargument name="fieldInputHTML" type="string" required="true" default="" hint="HTML for the field input, do a cfSaveContent on the input field and pass that in here">
	<cfargument name="fieldQuery" type="query" required="true" default="" hint="fieldQuery value">
	<cfargument name="attr" type="struct" required="true" default="" hint="Attributes value">
	<cfargument name="fieldPermission" type="string" required="false" default="" hint="fieldPermission attribute for CS 6.x and above: 0 (no rights), 1 (read only), 2 (edit)">
	<cfargument name="includeLabel" type="boolean" required="false" default="true" hint="Set to false to remove the label on the left">
	<cfargument name="includeDescription" type="boolean" required="false" default="true" hint="Set to false to remove the description under the field">
	<cfscript>
		var returnHTML = '';
		var productVersion = ListFirst(ListLast(request.cp.productversion," "),".");
		var row = arguments.fieldQuery.currentRow;
		var fqFieldName = "fic_#arguments.fieldQuery.ID[row]#_#arguments.fieldQuery.INPUTID[row]#";
		var description = arguments.fieldQuery.DESCRIPTION[row];
		var fieldName = arguments.fieldQuery.fieldName[row];
		var xparams = arguments.attr.parameters[arguments.fieldQuery.inputID[row]];
		var currentValue = arguments.attr.currentValues[fqFieldName];
		var labelClass = "cs_dlgLabelOptional";
		var labelStart = arguments.attr.itemBaselineParamStart;
		var labelEnd = arguments.attr.itemBaseLineParamEnd;
		var tdClass = "CS_Form_Label_Baseline";
		var renderMode =  arguments.attr.rendermode;
		var renderSimpleFormField = false;
		var doHiddenFieldSecurity = false; // No Edit / No Readonly ... just a hidden field
		var editGroups = "";
		var viewGroups = "";
		
		//If the fields are required change the label start and end
		if ( xparams.req eq "Yes" )
		{
			labelClass = "cs_dlgLabelRequired";
			labelStart = arguments.attr.reqItemBaselineParamStart;
			labelEnd = arguments.attr.reqItemBaseLineParamEnd;
			tdClass = "CS_Form_Required_Baseline";
		}

		// Determine if this is rendererd in a simple form or the standard custom element interface
		if ( (StructKeyExists(request, "simpleformexists")) AND (request.simpleformexists EQ 1) )
		{
			renderSimpleFormField = true;
		}
		
		// Determine if this field should be hidden due to "Use Explicit Security"
		// - Check the CS version
		if ( productVersion GTE 6 )
		{
			// For CS 6.x and above
			// - If the user has no rights (fieldSecurity = 0) to the field then doHiddenSecurity should be true
			if ( LEN(TRIM(arguments.fieldPermission)) AND arguments.fieldPermission LTE 0 ) 
			{
				doHiddenFieldSecurity = true;		
			}	
			
			// TODO: determine if this conditional logic is needed to display the description or not (fieldPermission is new to CS6.x)
			//if ( renderMode NEQ 'standard' OR fieldpermission LTE 0 )
				//arguments.includeDescription = false;
		}
		else
		{
			// For CS 5.x 
			// Get the list permissions and compare for security
			editGroups = application.ADF.data.ListInCommon(request.user.grouplist, xparams.pedit);
			viewGroups = application.ADF.data.ListInCommon(request.user.grouplist, xparams.pread);
			// - If user is part for the edit or view groups doHiddenSecurity should remain false
			if ( xparams.UseSecurity AND ListLen(viewGroups) EQ 0 AND ListLen(editGroups) EQ 0 )
			{
				doHiddenFieldSecurity = true;
			}
		}
	</cfscript>
	<cfsavecontent variable="returnHTML">
		<cfoutput>
			<cfif NOT doHiddenFieldSecurity>
				<tr id="#fqFieldName#_FIELD_ROW">
					<cfif arguments.includeLabel>
						<td valign="top" nowrap="nowrap" class="#tdClass#">
							#labelStart#
							<label for="#fqFieldName#" id="#fqFieldName#_LABEL" class="#labelClass#">#TRIM(xParams.label)#:</label>
							#labelEnd#
						</td>
					</cfif>
					<td<cfif NOT arguments.includeLabel> colspan="2"</cfif>>
						#arguments.fieldInputHTML#
					</td>
				</tr>
				<cfif Len(description) AND arguments.includeDescription>
					<!--- // If there is a description print out a new row and the description --->
					<tr id="#fqFieldName#_DESCRIPTION_ROW">
						<cfif arguments.includeLabel>
						<td></td>
						</cfif>
						<td<cfif NOT arguments.includeLabel> colspan="2"</cfif>>
							#arguments.attr.descParamStart#
							#description#
							<br/><br/>
							#arguments.attr.descParamEnd#
						</td>
					</tr>
				</cfif>
			<cfelse>
				<input type="hidden" name="#fqFieldName#" id="#fqFieldName#" value="#currentValue#">
			</cfif>
			<cfif renderSimpleFormField>
				<input type="hidden" name="#fqFieldName#_FIELDNAME" id="#fqFieldName#_FIELDNAME" value="#ReplaceNoCase(fieldName, 'fic_','')#">
			</cfif>
		</cfoutput>
	</cfsavecontent>
	<cfreturn returnHTML>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCEFieldID
Summary:
	Given the Custom element Name and the name of the field, return the Field's ID
	Aborts if the field cannot be found.
Returns:
	numeric
Arguments:
	String - ceNameOrID
	String - FieldName
History:
	2014-07-02 - GAC - Added
--->
<cffunction name="getCEFieldID" access="public" output="No" returntype="numeric">
	<cfargument name="ceNameOrID" type="string" required="Yes">
	<cfargument name="FieldName" type="string" required="Yes">

	<cfscript>
		var FieldID = 0;
		var formID = 0;
		var qry = QueryNew("temp");
		
		if( isNumeric(arguments.ceNameOrID) )
		{
			formID = arguments.ceNameOrID;
			formName = application.ADF.ceData.getCENameByFormID(FormID=arguments.ceNameOrID);
		}
		else
		{	
			formName = arguments.ceNameOrID;
			formID = application.ADF.ceData.getFormIDByCEName(CEName=arguments.ceNameOrID);
		}
			
		//if ( StructKeyExists( request.site.AvailControlsByName,"custom:#arguments.ceNameOrID#") )
		//	formID = request.site.AvailControlsByName['custom:#arguments.ceNameOrID#'].ID;
	</cfscript>

	<!--- // Look up the FieldID for the provided Custom Element  --->	
	<cfquery name="qry" datasource="#request.site.datasource#">
 		SELECT ID 
			FROM FormInputControl 
		WHERE ID IN ( SELECT FieldID FROM FormInputControlMap WHERE formid = <cfqueryparam cfsqltype="cf_sql_integer" value="#formID#"> ) 
			AND FieldName = <cfqueryparam cfsqltype="cf_sql_varchar" value="FIC_#arguments.fieldName#">	
	</cfquery>
	
	<cfif qry.recordCount neq 1>
		<cfabort showerror="Can't find the #arguments.FieldName# column for the #formName# Custom Element">
	</cfif>
		
	<cfreturn qry.ID>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCEFieldName
Summary:
	Given the Custom element Name and the id of the field, return the Field's name
	Aborts if the field cannot be found.
Returns:
	boolean
Arguments:
	String - ceNameOrID
	Numeric - FieldName
	Boolean - useFIC
History:
	2014-07-09 - GAC - Added
--->
<cffunction name="getCEFieldName" access="public" output="No" returntype="string">
	<cfargument name="ceNameOrID" type="string" required="true">
	<cfargument name="FieldID" type="numeric" required="true">
	<cfargument name="useFIC" type="boolean" required="false" default="false">
	
	<cfscript>
		var formID = 0;
		var formName = "";
		var fieldName = "";
		var qry = QueryNew("temp");
		
		if( isNumeric(arguments.ceNameOrID) )
		{
			formID = arguments.ceNameOrID;
			formName = application.ADF.ceData.getCENameByFormID(FormID=arguments.ceNameOrID);
		}
		else
		{	
			formName = arguments.ceNameOrID;
			formID = application.ADF.ceData.getFormIDByCEName(CEName=arguments.ceNameOrID);
		}
	</cfscript>

	<!--- // Look up the FieldName for the provided Custom Element --->	
	<cfquery name="qry" datasource="#request.site.datasource#">
 		SELECT FieldName 
			FROM FormInputControl 
		WHERE ID IN ( SELECT FieldID FROM FormInputControlMap WHERE formid = <cfqueryparam cfsqltype="cf_sql_integer" value="#formID#"> ) 
			AND ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.FieldID#">	
	</cfquery>
	
	<cfif qry.recordCount neq 1>
		<cfabort showerror="Can't find the Field ID:#arguments.FieldID# column in the #formName# Custom Element">
	</cfif>
	
	<cfscript>
		if ( arguments.useFIC )
			fieldName = qry.FieldName;
		else
			fieldName = ReplaceNoCase( qry.FieldName, 'FIC_', '', 'ALL' );
		
		return fieldName;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$renderHiddenControlsFromQueryString
Summary:
	Renders hidden input controls based on the url query string
Returns:
	String 
Arguments:
	String queryString
	String excludedParamList
	Boolean preventDups 
	String tagClass
	String tagIDprefix
Usage:
	renderHiddenControlsFromQueryString(URLparams,excludedParamList,preventDups)
History:
	2015-02-04 - GAC - Created
	2015-02-18 - GAC - Added a delimiter between the tagIDprefix and the KEY for the input tag ID
	2015-02-24 - GAC - Rename the excludedKeyList parameter to excludedParamList for consistency
					 - Moved all of the rendering code and logic to the renderHiddenControlsFromRequestParams() method
 --->
<cffunction name="renderHiddenControlsFromQueryString" returntype="string" access="public" hint="Render hidden input controls based on a url query string">
	<cfargument name="queryString" type="string" required="false" default="#Request.CGIVars.QUERY_STRING#" hint="URL query sting to parse">
	<cfargument name="excludedParamList" type="string" required="false" default="" hint="The query param key list for controls that should NOT rendered has hidden input controls.">
	<cfargument name="preventDups" type="boolean" required="false" default="true" hint="Set to true to prevent duplicate hidden input controls.">
	<cfargument name="tagClass" type="string" required="false" default="" hint="A class or space delimited list of classes to be added to the input control.">
 	<cfargument name="tagIDprefix" type="string" required="false" default="" hint="A prefix to be added key to make the ID for the input control unique on the form.">
	
	<cfscript>
		var qParamData = application.ADF.data.queryStringToStruct(inString=arguments.queryString);

		return renderHiddenControlsFromRequestParams(paramsStruct=qParamData,
														excludedParamList=arguments.excludedParamList,
														preventDups=arguments.preventDups,
														tagClass=arguments.tagClass,
														tagIDprefix=arguments.tagIDprefix);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$renderHiddenControlsFromRequestParams
Summary:
	Render hidden input controls based on the request.params url and form param struct
Returns:
	String 
Arguments:
	Struct paramsStruct
	String allowedParamList 
	String excludedKeyList
	Boolean preventDups 
	String tagClass
	String tagIDprefix
Usage:
	renderHiddenControlsFromRequestParams(paramsStruct,allowedParamList,excludedParamList,preventDups,tagClass,tagIDprefix)
History:
	2015-02-24 - GAC - Created
	2015-09-09 - KE  - Updated the hidden field VALUE to use the HTML entity for double quotes so if the value contains a 
						double quote it will render the hidden field properly
 --->
<cffunction name="renderHiddenControlsFromRequestParams" returntype="string" access="public" hint="Render hidden input controls based on the request.params data url and form param struct">
	<cfargument name="paramsStruct" type="struct" required="false" default="#request.params#" hint="request.params data structure to parse">
	<cfargument name="allowedParamList" type="string" required="false" default="" hint="A comma-delimited list of allowed query or form params that should be rendered as hidden input controls. If empty all params will be allowed.">
	<cfargument name="excludedParamList" type="string" required="false" default="" hint="A comma-delimited list of query or form params that should NOT rendered has hidden input controls.">
	<cfargument name="preventDups" type="boolean" required="false" default="true" hint="Set to true to prevent duplicate hidden input controls.">
	<cfargument name="tagClass" type="string" required="false" default="" hint="A class or space delimited list of classes to be added to the input control.">
 	<cfargument name="tagIDprefix" type="string" required="false" default="" hint="A prefix to be added key to make the ID for the input control unique on the form.">
	
	<cfscript>
		var retHTML = "";
		var paramsData = StructNew();
		var aKey = "";
		var pKey = "";
		var pValue = "";
		var paramDupList = "";
		
		// Rebuild the paramData struct will only the allowed params
		// !!! if no allowed params are passed, then allow the whole request.params struct to pass through !!!
		if ( ListLen(arguments.allowedParamList) EQ 0 )
			paramsData = arguments.paramsStruct;
		else
	   	{
		   	for ( aKey IN arguments.paramsStruct )
			{
				if ( ListFindNoCase(arguments.allowedParamList,aKey,",") )	
					paramsData[aKey] = arguments.paramsStruct[aKey]; 
			}
	   	}
		
		// Loop over the paramData from request.Params
		for ( pKey IN paramsData ) 
		{
			pValue = paramsData[pKey];
			if ( LEN(TRIM(pValue)) 
				AND ListFindNoCase(arguments.excludedParamList,pKey,",") EQ 0 
				AND ListFindNoCase(paramDupList,pKey) EQ 0 )
			{
				pValue = Replace(pValue,'"','&quot;','ALL');
				retHTML = retHTML & '<input type="hidden" name="#pKey#" value="#pValue#"';
				if ( LEN(TRIM(arguments.tagIDprefix)) )
					retHTML = retHTML & ' id="#tagIDprefix#_#pKey#"';
				else
					retHTML = retHTML & ' id="#pKey#"';
				if ( LEN(TRIM(arguments.tagClass)) )
					retHTML = retHTML & ' class="#arguments.tagClass#"';
				retHTML = retHTML & ' />';
				
				// Build a key list so we can check for and prevent dups
				if ( arguments.preventDups )
					paramDupList = ListAppend(paramDupList,pKey);
			}
		}
		
		return retHTML;
	</cfscript>
</cffunction>

</cfcomponent>