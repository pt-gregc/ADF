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
	Ron West 
Custom Field Type:
	App Config Page
Name:
	app_config_page_render.cfc
ADF Requirements:
	scripts_1_0
	ceData_1_0
	forms_1_1
History:
	RLW - Created
	2010-11-29 - GAC - Added conditional logic inside the select box cfloop to check 
					   the length of filename in the records generated by the pagesContainingRH 
					   or the pagesContainingScript.
	2011-08-11 - GAC - Updated the jQuery so the show help link would toggle the Help text 
					 - Converted the CFT to use the wrapFieldHTML() method
					 - Set to use the application.ADF.scripts instead of the objectFactory.getBean
	2012-04-11 - GAC - Removed renderSimpleFormField check
					 - Added the fieldPermission parameter to the wrapFieldHTML function call
					 - Added the includeLabel and includeDescription parameters to the wrapFieldHTML function call
					 - Added readOnly field security code with the cs6 fieldPermission parameter
					 - Updated the wrapFieldHTML explanation comment block
	2015-04-29 - DJM - Converted to CFC
--->
<cfcomponent displayName="AppConfigPage Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
		var inputParameters = Duplicate(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value
		var readOnly = (arguments.displayMode EQ 'readonly') ? true : false;
		var pageDataArr = ArrayNew(1);
		var itm = '';
		var pageData = '';
		var cftPath = '/ADF/extensions/customfields/app_config_page';
		
		// Load JQuery to the script
		application.ADF.scripts.loadJQuery();
	
		// check the pages that have the attached script or RH in use
		if( inputParameters.scriptType eq "Custom Script" )
			pageDataArr = application.ADF.csData.pagesContainingScript(inputParameters.scriptURL);
		else
			pageDataArr = application.ADF.csData.pagesContainingRH(inputParameters.scriptURL);
			
		renderJSFunctions(argumentCollection=arguments);
	</cfscript>
	
	<cfif NOT StructKeyExists(Request, 'appConfigPageCSS')>
			<cfoutput><link rel="stylesheet" type="text/css" href="#cftPath#/app_config_page_styles.css" /></cfoutput>
		<cfset Request.appConfigPageCSS = 1>
	</cfif>
	
	<cfoutput>
		<select name="#arguments.fieldName#" id="#arguments.fieldName#" size="1">
			<option value="">--Select--</option>
			<cfloop from="1" to="#arrayLen(pageDataArr)#" index="itm">
				<!--- // Make sure each of the records have a fileName --->
				<cfif LEN(TRIM(pageDataArr[itm].fileName))>
					<cfscript>
						if (inputParameters.pagePart eq "pageURL")
							pageData = "#request.subsiteCache[pageDataArr[itm].subsiteID].url##pageDataArr[itm].fileName#";
						else
							pageData = pageDataArr[itm].pageID;
					</cfscript>
					<option value="#pageData#"<cfif currentValue eq pageData> selected="selected"</cfif>>#request.subsiteCache[pageDataArr[itm].subsiteID].url##pageDataArr[itm].fileName#</option>
				</cfif>
			</cfloop>
		</select>
		<br />
		<a href="javascript:;" id="#arguments.fieldName#helpLink" class="smallerLabel">
			<span id="#arguments.fieldName#showHelpLabel">Show Help</span>
			<span id="#arguments.fieldName#hideHelpLabel" style="display:none;">Hide Help</span>
		</a>
		<div id="#arguments.fieldName#helpText" style="display:none;" class="smallerLabel">
		Select the Page URL from the list of pages provided.  Note: if your page does not exist in the list
		then please check the Application installation instructions. It is more than likely you forgot to create the page containing the script: #inputParameters.scriptURL#
		</div>
	</cfoutput>
</cffunction>

<cffunction name="renderJSFunctions" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
<cfoutput><script type="text/javascript">
<!--
jQuery(function(){
	jQuery('###arguments.fieldName#helpLink').click( function() {
		jQuery('###arguments.fieldName#helpText').toggle();
		if ( jQuery('###arguments.fieldName#helpText').is(':hidden') ) {
			
			jQuery('###arguments.fieldName#showHelpLabel').show();
			jQuery('###arguments.fieldName#hideHelpLabel').hide();			
		}
		else
		{
			jQuery('###arguments.fieldName#showHelpLabel').hide();
			jQuery('###arguments.fieldName#hideHelpLabel').show();								
		}
	});		
});
//-->
</script></cfoutput>
</cffunction>

<cfscript>
	private any function getValidationJS(required string formName, required string fieldName, required boolean isRequired)
	{
		if (arguments.isRequired)
			return 'hasValue(document.#arguments.formName#.#arguments.fieldName#, "TEXT")';
		return "";
	}
	
	private string function getValidationMsg()
	{
		return "Please select a page.";
	}
</cfscript>
</cfcomponent>