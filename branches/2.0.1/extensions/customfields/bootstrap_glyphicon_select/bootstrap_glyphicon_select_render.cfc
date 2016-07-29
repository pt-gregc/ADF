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
	PaperThin Inc.
Name:
	bootstrap_glyphicon_select_render.cfc
Summary:
	renders field for bootstrap glyphicon custom field type
Version:
	1.0
History:
	2015-09-15 - Created
	2016-02-19 - DRM - Implement loadResourceDependencies()
							 Remove bogus comment about FontAwesome
	2016-02-19 - GAC - Added the option to include the base icon class in the save class string data
--->
<cfcomponent displayName="BootstrapGlyphiconSelect_Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cfscript>
	variables.defaultBootstrapVersion = "3.3";	
	variables.defaultGlyphIconDataFile = "/ADF/thirdParty/jquery/bootstrap/#variables.defaultBootstrapVersion#/data/glyphicon-data.csv";
	variables.defaultIconClass = "glyphicon";
</cfscript>

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfscript>
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value
		var readOnly = (arguments.displayMode EQ 'readonly') ? true : false;
		var glyphiconDataArr = ArrayNew(1);
		var fontArray = ArrayNew(1);
		var glyphiconDataFilePath = '';
		var cftErrMsg = '';
		var curVal = '';
		var selected_index = '';
		var a = 0;
		var i = 0;
		var selected = "";
		var s = "";
		var cftPath = "/ADF/extensions/customfields/bootstrap_glyphicon_select";
		var iconClass = variables.defaultIconClass;
		var previewIconCurrentValue = "";
		var previewTextCurrentValue = "";
		var selectedCurrentValue = "";
		
		inputParameters = setDefaultParameters(argumentCollection=arguments);
		
		if ( StructKeyExists(inputParameters,"glyphiconDataFile") AND LEN(TRIM(inputParameters.glyphiconDataFile)) ) 
			glyphiconDataFilePath = ExpandPath(inputParameters.glyphiconDataFile);
		
		// Get the Full File Path to the IconDataFile		
		// Make sure the data file exists
		if ( FileExists(glyphiconDataFilePath) )
		{
			// Convert the CSV file to an array
			glyphiconDataArr = application.ADF.data.csvToArray(file=glyphiconDataFilePath,Delimiter=",");
		}
		else
		{
			cftErrMsg = "Unable to load glyph icon data file!";
			if ( StructKeyExists(inputParameters,"glyphiconDataFile") AND LEN(TRIM(inputParameters.glyphiconDataFile)) ) 
				cftErrMsg = cftErrMsg & "<br/>'#inputParameters.glyphiconDataFile#'";
		}

		// Build the Font Awesome Icons array
		for ( a=1; a LTE ArrayLen(glyphiconDataArr); a=a+1 )
		{
			ArrayAppend( fontArray, glyphiconDataArr[a][1] ); 
		}

		// Set the curVal - NOT USED
		/*for( i=1; i lte ArrayLen(fontArray); i=i+1 )
		{
			if ( fontArray[i] eq currentValue )
			{
				curVal = fontArray[i];
				break;
			}
		}*/
		
		// Clear value if switching ICON libraries
		if ( inputParameters.addIconClass AND FindNoCase(iconClass,currentValue,1) EQ 0 )
			currentValue = ""; // TODO: Find similarly named icon in new icon library
		
		if ( LEN(TRIM(currentValue)) )
		{
			if ( inputParameters.addIconClass )
			{
				if ( ListFindNoCase(currentValue,iconClass,' ') EQ 0 )
					 currentValue = iconClass & ' ' & currentValue;
				 
				previewIconCurrentValue = currentValue;
				previewTextCurrentValue = currentValue;
				if ( ListLen(currentValue,' ') GTE 2 )
					previewTextCurrentValue = TRIM(ListGetAt(currentValue,2,' '));
				selectedCurrentValue = previewTextCurrentValue;
			
				//previewTextCurrentValue = ListFirst(TRIM(ReplaceNoCase(currentValue,iconClass&' ','')), ' '); - OLD WAY			
			}
			else
			{
				if ( ListFindNoCase(currentValue,iconClass,' ') NEQ 0 )
					currentValue = TRIM(ReplaceNoCase(currentValue,iconClass&' ',''));
			
				previewIconCurrentValue = iconClass & ' ' & currentValue;
				previewTextCurrentValue = currentValue;
				if ( ListLen(currentValue,' ') GTE 1 )
					previewTextCurrentValue = TRIM(ListGetAt(currentValue,1,' '));
				selectedCurrentValue = previewTextCurrentValue;
			
				//previewTextCurrentValue = ListFirst(currentValue, ' '); - OLD WAY
			}
		}
	</cfscript>
	
	<cfif NOT StructKeyExists(Request,'cftBootstrapGlyphiconSelectCSS')>
		<cfoutput>
			<link rel="stylesheet" type="text/css" href="#cftPath#/bootstrap_glyphicon_select_styles.css" />
			<cfif !inputParameters.ShowSize>
			<style>
				##icon_#inputParameters.fldID# { font-size: 2em; }
			</style>
			</cfif>
			<!--- <style>
				.glyphicon-lg { font-size: 1.33333em; }
				<cfloop index="s" from="2" to="10">
				.glyphicon-#s#x { font-size: #s#em; }
				</cfloop>
			</style> --->
		</cfoutput>
		<cfset Request.cftBootstrapGlyphiconSelectCSS = 1>
	</cfif>
	<cfscript>
		renderJSFunctions(argumentCollection=arguments, fieldParameters=inputParameters);
	</cfscript>
	<cfoutput>
		<div class="bsgi-selectedDataDiv">
			<span id="icon_#inputParameters.fldID#" class="#previewIconCurrentValue#" aria-hidden="true"></span>
			<span id="sel_#inputParameters.fldID#">#previewTextCurrentValue#</span>
		</div>
		<input type="text" name="bsgi_search_#inputParameters.fldID#" id="bsgi_search_#inputParameters.fldID#" value="" <cfif readOnly>disabled="disabled"</cfif> class="bsgi-searchInput" placeholder="Type to filter list of Glyphicons">
		<input class="clsPushButton bsgi-clearButton" type="button" value="Clear" onclick="clearInput_#arguments.fieldName#()">
		<input type="hidden" name="#arguments.fieldName#" id="#inputParameters.fldID#" value="#currentValue#"> 			
		<div class="bsgi-cols-3-outer">
			<cfif LEN(TRIM(cftErrMsg))>#cftErrMsg#</cfif>
			<div id="icondata_#inputParameters.fldID#" class="bsgi-cols-3">
				<ul>
					<cfloop index="i" from="1" to="#ArrayLen(fontArray)#" step="1">
						<cfif selectedCurrentValue EQ ListFirst(fontArray[i])>
							<cfset selected = "selected">
							<cfset selected_index = '#ListLast(fontArray[i])# #ListFirst(fontArray[i])#'>
						<cfelse>	
							<cfset selected = "">
						</cfif>
						<li>
							<div class="fonticon #selected#" data-code="#ListLast(fontArray[i])#" data-name="#ListFirst(fontArray[i])#">
                                <!---<i class="fa #ListFirst(fontArray[i])#"></i> #ListFirst(fontArray[i])#--->
                                <span class="glyphicon #ListFirst(fontArray[i])#" aria-hidden="true"></span> #ListFirst(fontArray[i])#
                            </div>
                        </li>
					</cfloop>
				</ul>
			</div>
		</div>
		<div id="options_#inputParameters.fldID#" class="bsgi-optionsDiv">
			<cfif inputParameters.ShowSize>
			Size: <select name="size_#inputParameters.fldID#" id="size_#inputParameters.fldID#">
					<option value="">Normal</option>
					<option value="glyphicon-lg" <cfif FindNoCase('glyphicon-lg',currentValue)>selected="selected"</cfif>>Large</option>
					<cfloop index="s" from="2" to="10">
						<option value="glyphicon-#s#x" <cfif FindNoCase('glyphicon-#s#x',currentValue)>selected="selected"</cfif>>#s#x</option>
					</cfloop>
				</select> &nbsp; 
			</cfif>
		</div> 
	</cfoutput>
</cffunction>

<cffunction name="renderJSFunctions" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="fieldParameters" type="struct" required="yes">
	
	<cfscript>
		var inputParameters = application.ADF.data.duplicateStruct(arguments.fieldParameters);
	</cfscript>

<cfoutput>
<script type="text/javascript">
<!--
jQuery(function(){
    // Add Key up event
    jQuery('##bsgi_search_#inputParameters.fldID#').keyup(function( event ) {
	        var theval = jQuery('##bsgi_search_#inputParameters.fldID#').val();
	        findFunction_#arguments.fieldName#( theval );
	    }).keydown(function( event ) {
	        if ( event.which == 13 ) 
	            event.preventDefault();
   		});

    // add Click event for each font li div
    jQuery('##icondata_#inputParameters.fldID# .fonticon').click(function( event ) {
        var name = jQuery(this).attr('data-name');
        var code = jQuery(this).attr('data-code');

        // set display selection to that value (icon name)
        jQuery("##sel_#inputParameters.fldID#").text( name );

        // de-select old one
        if( jQuery("##icondata_#inputParameters.fldID# li div.selected") )
            jQuery("##icondata_#inputParameters.fldID# li div.selected").removeClass('selected');

        // select new one
        jQuery(this).addClass('selected');

        // assign just name portion to real hidden field
        buildClasses_#arguments.fieldName#();
    });

    // add Click event for options div
    jQuery('##options_#inputParameters.fldID#').click(function( event ) {
        buildClasses_#arguments.fieldName#();
    });
});
	
function findFunction_#arguments.fieldName#(inString)
{
	// Check if we have a string defined
	if ( inString.length > 0 )
	{
		// Hide everything to start
		jQuery('##icondata_#inputParameters.fldID# li div.fonticon').hide();
	
		// Find the rows that contain the search terms
		jQuery('##icondata_#inputParameters.fldID# li div[data-name*="' + inString.toLowerCase() + '"]').each(function() {
			// Display the row
			jQuery(this).show();
		});

		// Find the selected rows 
		jQuery('##icondata_#inputParameters.fldID# li div.selected').show();
	}
	else 
	{
		// Show Everything
		jQuery('##icondata_#inputParameters.fldID# li div.fonticon').show();
	}
}

function buildClasses_#arguments.fieldName#()
{
	var iconClass = '#variables.defaultIconClass#';
	var previewClass = '';
	var name = '';
	var val = '';
	var size = '';

	// get selected item
	if( jQuery("##icondata_#inputParameters.fldID# li div.selected").length )
		name = jQuery("##icondata_#inputParameters.fldID# li div.selected").attr('data-name');
	
	<cfif inputParameters.ShowSize>
	if( document.getElementById('size_#inputParameters.fldID#') instanceof Object )
		size = jQuery('##size_#inputParameters.fldID#').val();
	</cfif>
	
	if( name.length > 0 )
	{
		val = name;
		if( size.length > 0 )
			val = val + ' ' + size;
			
		<cfif inputParameters.addIconClass>
			// Add the Base Icon Class
			val = iconClass + ' ' + val;
			// Use the generated value for the Preview Icon Class
			previewClass = val;
		<cfelse>
			// Build Preview Icon Class with the Base Icon Class
			previewClass = iconClass + ' ' + val;
		</cfif>
		
		// set display div
		jQuery('##sel_#inputParameters.fldID#').text( name );		
		jQuery('##icon_#inputParameters.fldID#').attr( 'class', previewClass );		
	}

	// set hidden value
	jQuery('###inputParameters.fldID#').val( val );	
}

function clearInput_#arguments.fieldName#()
{
	jQuery('##bsgi_search_#inputParameters.fldID#').val('');
	jQuery('##sel_#inputParameters.fldID#').text('');		
	jQuery('##icon_#inputParameters.fldID#').attr( 'class', '');		
	jQuery('###inputParameters.fldID#').val('');		

	// de-select old one
	if( jQuery("##icondata_#inputParameters.fldID# li div.selected") )
		jQuery("##icondata_#inputParameters.fldID# li div.selected").removeClass('selected');

	findFunction_#arguments.fieldName#('');
}
//-->
</script></cfoutput>
</cffunction>

<cffunction name="setDefaultParameters" returntype="struct" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfscript>
		var defaultBootstrapVersion = variables.defaultBootstrapVersion;
        var defaultGlyphIconDataFile = variables.defaultGlyphIconDataFile;
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);

		// Set the defaults
		if( NOT StructKeyExists(inputParameters,'addIconClass') OR !inputParameters.addIconClass )
			inputParameters.addIconClass = false;
		if( NOT StructKeyExists(inputParameters,'ShowSize') )
			inputParameters.ShowSize = 0;
			
		if( NOT StructKeyExists(inputParameters,'glyphiconDataFile') OR LEN(TRIM(inputParameters.glyphiconDataFile)) EQ 0 )
			inputParameters.glyphiconDataFile = defaultGlyphIconDataFile;
			
		// Validate if the property field has been defined
		if ( NOT StructKeyExists(inputParameters, "fldID") OR LEN(inputParameters.fldID) LTE 0 )
			inputParameters.fldID = arguments.fieldName;
		
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
		return listAppend(super.getResourceDependencies(), "jQuery,Bootstrap");
	}
	public void function loadResourceDependencies()
	{
		application.ADF.scripts.loadJQuery();
		application.ADF.scripts.loadBootstrap();
	}
	
	private boolean function isMultiline()
	{
		return true;
	}
</cfscript>

</cfcomponent>