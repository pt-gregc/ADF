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
	PaperThin Inc.
	G. Cronkright
Name:
	ui_theme_selector_render.cfc
Summary:
	CFT to render a list for jquery UI theme options
Version:
	1.0.0
History:
	2011-06-14 - GAC - Created
	2011-06-16 - GAC - Fixed the default jqueryUIurl and slashes for non Windows OS's
	2012-01-11 - GAC - set jqueryUIurl to match the case of the directory stucture
					 - cleaned up some unused jquery code
					 - added text input if no records are returned by the theme directory query
	2012-02-21 - GAC - added additional fixes for slashes 
					 - combined forked versions
					 - file cleanup
	2012-04-11 - GAC - Added the fieldPermission parameter to the wrapFieldHTML function call
					 - Added the includeLabel and includeDescription parameters to the wrapFieldHTML function call
					 - Added readOnly field security code with the cs6 fieldPermission parameter
					 - Updated the wrapFieldHTML explanation comment block
	2012-07-01 - GAC - Updated the default jQuery version
	2015-04-29 - DJM - Added own CSS
--->
<cfcomponent displayName="UIThemeSelector Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">

	<cfscript>
		var inputParameters = Duplicate(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value
		var readOnly = (arguments.displayMode EQ 'readonly') ? true : false;
		var uiFilterOutList = ".svn,base"; 		// Add DIRs that need to be filtered from the theme drop down	
		var defaultVersion = "jquery-ui-1.9";
		var defaultTheme = ""; 					//ui-lightness
		var jQueryUIurl = "/ADF/thirdParty/jquery/ui/";
		var jQueryUIpath = ExpandPath(jQueryUIurl); 
		var defaultVersionURL = jQueryUIurl & defaultVersion & "/";
		var defaultVersionPath = ExpandPath(defaultVersionURL);
		var qThemes = QueryNew('');
		
		inputParameters = setDefaultParameters(argumentCollection=arguments);		
		
		if ( LEN(TRIM(currentValue)) EQ 0 )
			currentValue = defaultTheme;
		
		// jQuery Headers
		application.ADF.scripts.loadJQuery();	
	</cfscript>

	<!--- // Get a list of jQuery UI themes for the version of jQuery --->
	<cfdirectory action="list" directory="#inputParameters.uiVersionPath#" name="qThemes" type="dir">

	<cfoutput>
		<cfif qThemes.RecordCount>
			<select name='#arguments.fieldName#' id='#arguments.fieldName#'<cfif readOnly> disabled="disabled"</cfif>>
				<option value=''<cfif LEN(currentValue) EQ 0> selected="selected"</cfif>> -- select -- </option>
				<cfloop query="qThemes">
					<cfif ListFindNoCase(uiFilterOutList,qThemes.name) EQ 0>
					<option value='#qThemes.name#'<cfif currentValue EQ qThemes.name> selected='selected'</cfif>>#qThemes.name#</option>
					</cfif>
				</cfloop>
			</select> 
		<cfelse>
			<div class="cs_dlgLabelSmall">
				There seems to be an issue with the path to the UI Theme directories for this field.<br/>
				A theme list drop down could not be generated.
				<ul>
					<li>To fix the Custom Field Type issue:
						<ol>
							<li>Open the UI Selector field properties and select the correct jQueryUI version</li> 
							<li>Re-save the field</li>
							<li>Reload this form</li>
						</ol>
					</li> 
					<li>Or type in a valid UI theme name below:</li>
				</ul>
			</div>
			<input type='text' name='#arguments.fieldName#' id='#arguments.fieldName#' value='#currentValue#'>
		</cfif>
	</cfoutput>
</cffunction>
	
<cffunction name="setDefaultParameters" returntype="struct" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
		var inputParameters = Duplicate(arguments.parameters);
		
		if ( NOT StructKeyExists(inputParameters,"uiVersionPath") )
			inputParameters.uiVersionPath = defaultVersionPath & "/css/"; 
		else
			inputParameters.uiVersionPath = inputParameters.uiVersionPath & "/css/";

		// Convert slashes
		inputParameters.uiVersionPath = Replace(inputParameters.uiVersionPath,"\","/","all");  // D:/data/web/ADF/thirdParty/jquery/ui/jquery-ui-1.8/css/
		
		return inputParameters;
	</cfscript>
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
		return "Please select a value for the #arguments.label# field.";
	}

	public string function getResourceDependencies()
	{
		return listAppend(super.getResourceDependencies(), "jQuery");
	}
</cfscript>
</cfcomponent>