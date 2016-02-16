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
Custom Field Type:
	Star Rating Custom Field Type
Name:
	star_rating_field_render.cfc
Summary:
	Custom field to render the JQuery UI star ratings.
ADF Requirements:
	scripts_1_0
	data_1_0
History:
	2009-11-16 - MFC - Created
	2011-02-02 - RAK - Updated to allow for customizing number of stars and half stars
	2012-01-03 - MFC - Commented out JS code to prevent JS error in the form.
	2015-05-20 - DJM - Converted to CFC
	2015-09-11 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean()
	2016-02-09 - GAC - Updated duplicateBean() to use data_2_0.duplicateStruct()
	2016-02-16 - GAC - Added getResourceDependencies support
	                 - Added loadResourceDependencies support
	                 - Moved resource loading to the loadResourceDependencies() method
--->
<cfcomponent displayName="StarRatingField Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfscript>
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
		var numberOfStars = 5;
		var halfStars = 0;
		var currentValue = arguments.value;	// the field's current value
		var readOnly = (arguments.displayMode EQ 'readonly') ? true : false;
		var currentVal = '';
		var i = 0;
		
		if(StructKeyExists(inputParameters,"numberOfStars"))
			numberOfStars = inputParameters.numberOfStars;
		
		if(StructKeyExists(inputParameters,"halfStars"))
			halfStars = inputParameters.halfStars;

		renderJSFunctions(argumentCollection=arguments, halfStars=halfStars);
	</cfscript>
<cfoutput>
	<div id="#arguments.fieldName#_renderStars">
		<select name='#arguments.fieldName#_select' id='#arguments.fieldName#_select' <!--- onchange='#arguments.fieldName#_loadSelection()' ---> <cfif readOnly>disabled='disabled'</cfif>>
			<cfloop from="1" to="#numberOfStars#" index="i">
				<cfset currentVal = i>
				<cfif halfStars>
					<cfset currentVal = i/2>
				</cfif>
				<option value="#currentVal#" <cfif currentValue EQ currentVal>selected</cfif>>#currentVal#</option>
			</cfloop>
		</select>
	</div>
	<!--- hidden field to store the value --->
	<input type='hidden' name='#arguments.fieldName#' id='#arguments.fieldName#' value='#currentValue#'>
</cfoutput>
</cffunction>

<cffunction name="renderJSFunctions" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">	
	<cfargument name="halfStars" type="numeric" required="yes">	
<cfoutput><script type="text/javascript">
<!--
jQuery(document).ready(function(){ 
	jQuery("###arguments.fieldName#_renderStars").stars({
		inputType: "select",
		<cfif arguments.halfStars>
		split: 2,
		</cfif>
		callback: function(ui, type, value){
			// Callback for the selection, get the object value
			selectObj = jQuery("###arguments.fieldName#_renderStars").stars("select", value);
			// put the selected value into the field
			jQuery("input###arguments.fieldName#").val(value);
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
		return '';
	}
	
	private string function getValidationMsg()
	{
		return "Please select a value for the #arguments.label# field.";
	}

    /*
		IMPORTANT: Since loadResourceDependencies() is using ADF.scripts loadResources methods, getResourceDependencies() and
		loadResourceDependencies() must stay in sync by accounting for all of required resources for this Custom Field Type.
	*/
	public void function loadResourceDependencies()
	{
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
		
		if ( !StructKeyExists(inputParameters,"uiTheme") )
			inputParameters.uiTheme = "ui-lightness";
		
		// Load registered Resources via the ADF scripts_2_0
		application.ADF.scripts.loadJQuery();
		application.ADF.scripts.loadJQueryUI(themeName=inputParameters.uiTheme);
		application.ADF.scripts.loadJQueryUIStars();
	}
	public string function getResourceDependencies()
	{
		return "jQuery,jQueryUI,jQueryStars";
	}
</cfscript>

</cfcomponent>