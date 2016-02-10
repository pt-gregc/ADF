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
/* *********************************************************************** */
Author:
	PaperThin, Inc.
	R. Kahn
Name:
	custom_script_selector_render.cfc
Summary:
	Renders a form to select and verify a custom script
History:
	2011-03-29 - RAK - Created
	2012-01-06 - GAC - Renamed file and renamed folder
	2012-04-11 - GAC - Added the fieldPermission parameter to the wrapFieldHTML function call
					 - Added the includeLabel and includeDescription parameters to the wrapFieldHTML function call
					 - Added readOnly field security code with the cs6 fieldPermission parameter
					 - Updated the wrapFieldHTML explanation comment block
	2014-01-02 - GAC - Added the CFSETTING tag to disable CF Debug results in the props module
	2015-05-13 - DJM - Converted to CFC
	2015-09-11 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean()
	2016-02-09 - GAC - Updated duplicateBean() to use data_2_0.duplicateStruct()
--->
<cfcomponent displayName="CustomScriptSelector Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value
		var readOnly = (arguments.displayMode EQ 'readonly') ? true : false;
		
		renderJSFunctions(argumentCollection=arguments);
	</cfscript>

	<cfoutput>
		<input name="#arguments.fieldName#" id='#arguments.fieldName#' value="#currentValue#" size="50" <cfif readOnly>disabled="disabled"</cfif>>
	</cfoutput>
</cffunction>

<cffunction name="renderJSFunctions" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">

<cfoutput>
<script type="text/javascript">
<!--
function #arguments.fieldName#_validateScript(){
	var templatePath = jQuery("###arguments.fieldName#").val();
	var params = {
		bean: "utils_1_0",
		method: "scriptExists",
		templatePath: templatePath
	};
	var rtn = true;
	jQuery.ajax({
		url:"#application.ADF.ajaxProxy#?"+jQuery.param(params),
		success: function(results){
			// show the results
			if( results != "YES" ){
				alert("Could not validate the entered script. Please make sure the path is correct.");
				rtn = false;
			}
		},
		async: false
	});
	return rtn;
}
//-->
</script></cfoutput>
</cffunction>

<cfscript>
	private any function getValidationJS(required string formName, required string fieldName, required boolean isRequired)
	{
		return "#arguments.fieldName#_validateScript()";
	}
	
	private string function getValidationMsg()
	{
		return "";
	}
</cfscript>

</cfcomponent>