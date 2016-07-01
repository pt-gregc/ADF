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
	font_awesome_select_render.cfc
Summary:
	renders field for font awesome icon custom field type
Version:
	1.0
History:
	2014-09-15 - Created
	2014-09-29 - GAC - Added an updated list of icon classes and codes using csvToArray on FA icon text data in a CSV text file 
	2014-12-03 - GAC - Updated to fix for bad version folder "Major.Minor.Maintenance" for thirdParty folder. Now is only "Major.Minor" version folder.
	2015-04-15 - DJM - Fixed issue for clear button not working as expected
	2015-04-15 - DJM - Converted to CFC
	2015-04-23 - DJM - Fixed issue for all font awesome fields in a form working as a single control field
	2015-04-23 - DJM - Added own CSS
	2015-09-11 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean() 
					 - Updated the default FA version
	2015-08-16 - GAC - Moved the default value for the Font Awesome versions to the top of the component
					 - Fixed issue with datafile read error message
					 - Fixed clearInput to not show the string '(blank)' after clicking
	2016-02-09 - GAC - Updated duplicateBean() to use data_2_0.duplicateStruct()
	2016-02-19 - GAC - Added loadResourceDependencies support
	                 - Moved resource loading to the loadResourceDependencies() method
	2016-02-19 - GAC - Added the option to include the base icon class in the save class string data
--->
<cfcomponent displayName="FontAwesomeSelect_Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cfscript>
	variables.defaultFAversion = "4.4";
	variables.defaultIconDataFile = "/ADF/thirdParty/css/font-awesome/#variables.defaultFAversion#/data/icon-data.csv";
</cfscript>

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfscript>
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value
		var readOnly = (arguments.displayMode EQ 'readonly') ? true : false;
		var iconDataArr = ArrayNew(1);
		var fontArray = ArrayNew(1);
		var iconDataFilePath = '';
		var cftErrMsg = '';
		var curVal = '';
		var selected_index = '';
		var a = 0;
		var i = 0;
		var selected = "";
		var s = "";
		var cftPath = "/ADF/extensions/customfields/font_awesome_select";
		var iconClass = 'fa';
		var previewIconCurrentValue = "";
		var previewTextCurrentValue = "";
		var selectedCurrentValue = "";
		
		inputParameters = setDefaultParameters(argumentCollection=arguments);
		if ( StructKeyExists(inputParameters,"iconDataFile") AND LEN(TRIM(inputParameters.iconDataFile)) )
			iconDataFilePath = ExpandPath(inputParameters.iconDataFile);
		
		// Get the Full File Path to the IconDataFile		
		// Make sure the data file exists
		if ( FileExists(iconDataFilePath) )
		{
			// Convert the CSV file to an array
			iconDataArr = application.ADF.data.csvToArray(file=iconDataFilePath,Delimiter=",");
		}
		else
		{
			cftErrMsg = "Unable to load icon data file!";
			if ( StructKeyExists(inputParameters,"iconDataFile") AND LEN(TRIM(inputParameters.iconDataFile)) )
				cftErrMsg = cftErrMsg & "<br/>'#inputParameters.iconDataFile#'";
		}
		
		// Build the Font Awesome Icons array
		for ( a=1; a LTE ArrayLen(iconDataArr); a=a+1 )
		{
			ArrayAppend( fontArray, '#iconDataArr[a][1]#,#iconDataArr[a][2]#' ); 
		}

		// Set the curVal - NOT USED
		/*for( i=1; i lte ArrayLen(fontArray); i=i+1 )
		{
			if ( ListFirst(fontArray[i]) eq currentValue )
			{
				curVal = "#ListLast(fontArray[i])# #ListFirst(fontArray[i])#";
				break;
			}
		}*/
		
		// Clear value if switching ICON libraries
		if ( FindNoCase(iconClass,currentValue,1) EQ 0 )
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

	<cfif NOT StructKeyExists(Request,'cftfontAwesomeSelectCSS')>
		<cfoutput>
			<link rel="stylesheet" type="text/css" href="#cftPath#/font_awesome_select_styles.css" />
			<cfif !inputParameters.ShowSize>
			<style>
				##icon_#inputParameters.fldID# { font-size: 2em; }
			</style>
			</cfif>
		</cfoutput>
		<cfset Request.cftfontAwesomeSelectCSS = 1>
	</cfif>
	<cfscript>
		renderJSFunctions(argumentCollection=arguments, fieldParameters=inputParameters);
	</cfscript>
	<cfoutput>
		<div class="fa-selectedDataDiv">
			<i id="icon_#inputParameters.fldID#" class="#previewIconCurrentValue#"></i> 
			<span id="sel_#inputParameters.fldID#">#previewTextCurrentValue#</span>
		</div>
		<input type="text" name="fa_search_#inputParameters.fldID#" id="fa_search_#inputParameters.fldID#" value="" <cfif readOnly>disabled="disabled"</cfif> class="fa-searchInput" placeholder="Type to filter list of icons"> 
		<input class="clsPushButton fa-clearButton" type="button" value="Clear" onclick="clearInput_#arguments.fieldName#()">
		<input type="hidden" name="#arguments.fieldName#" id="#inputParameters.fldID#" value="#currentValue#"> 			
		<div class="fa-cols-3-outer">
			<cfif LEN(TRIM(cftErrMsg))>#cftErrMsg#</cfif>
			<div id="icondata_#inputParameters.fldID#" class="fa-cols-3">
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
								<i class="fa #ListFirst(fontArray[i])#"></i> #ListFirst(fontArray[i])#
							</div>
						</li>
					</cfloop>
				</ul>
			</div>
		</div>
		<div id="options_#inputParameters.fldID#" class="optionsDiv">
			<cfif inputParameters.ShowSize>
			Size: <select name="size_#inputParameters.fldID#" id="size_#inputParameters.fldID#">
					<option value="">Normal</option>
					<option value="fa-lg" <cfif FindNoCase('fa-lg',currentValue)>selected="selected"</cfif>>Large</option>
					<cfloop index="s" from="2" to="10">
						<option value="fa-#s#x" <cfif FindNoCase('fa-#s#x',currentValue)>selected="selected"</cfif>>#s#x</option>
					</cfloop> 
				</select> &nbsp; 
			</cfif>
			
			<cfif inputParameters.ShowFixedWidth>
				<input type="checkbox" id="fw_#inputParameters.fldID#" name="fw_#inputParameters.fldID#" value="fa-fw" <cfif FindNoCase('fa-fw',currentValue)>checked="checked"</cfif>><label for="fw_#inputParameters.fldID#">Fixed Width</label> &nbsp; 
			</cfif>	
			
			<cfif inputParameters.ShowBorder>
				<input type="checkbox" id="border_#inputParameters.fldID#" name="border_#inputParameters.fldID#" value="fa-border" <cfif FindNoCase('fa-border',currentValue)>checked="checked"</cfif>><label for="border_#inputParameters.fldID#">Border</label> &nbsp; 
			</cfif>
			
			<cfif inputParameters.ShowSpin>
				<input type="checkbox" id="spin_#inputParameters.fldID#" name="spin_#inputParameters.fldID#" value="fa-spin" <cfif FindNoCase('fa-spin',currentValue)>checked="checked"</cfif>><label for="spin_#inputParameters.fldID#">Spin</label> &nbsp; 
			</cfif>
			
			<cfif inputParameters.ShowPull>
				Pull: <select id="pull_#inputParameters.fldID#" name="pull_#inputParameters.fldID#">
				<option value="">None</option>
				<option value="pull-left" <cfif FindNoCase('pull-left',currentValue)>selected="selected"</cfif>>Left</option>
				<option value="pull-right" <cfif FindNoCase('pull-right',currentValue)>selected="selected"</cfif>>Right</option>
				</select> 
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
	jQuery('##fa_search_#inputParameters.fldID#').keyup(function( event ) {
		 	var theval = jQuery('##fa_search_#inputParameters.fldID#').val();
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
	var iconClass = 'fa';
	var previewClass = '';
	var name = '';
	var val = '';
	var size = '';
	var fw = '';
	var border = '';
	var spin = '';
	var pull = '';
	
	// get selected item
	if( jQuery("##icondata_#inputParameters.fldID# li div.selected").length )
		name = jQuery("##icondata_#inputParameters.fldID# li div.selected").attr('data-name');
	
	<cfif inputParameters.ShowSize>
	if( document.getElementById('size_#inputParameters.fldID#') instanceof Object )
		size = jQuery('##size_#inputParameters.fldID#').val();
	</cfif>
	
	<cfif inputParameters.ShowFixedWidth>
	if( document.getElementById('fw_#inputParameters.fldID#') instanceof Object )
	{	
		if( jQuery('##fw_#inputParameters.fldID#').prop('checked') )
			fw = jQuery('##fw_#inputParameters.fldID#').val();
	}		
	</cfif>
	
	<cfif inputParameters.ShowBorder>
	if( document.getElementById('border_#inputParameters.fldID#') instanceof Object )
	{	
		if( jQuery('##border_#inputParameters.fldID#').prop('checked') )	
			border = jQuery('##border_#inputParameters.fldID#').val();
	}
	</cfif>
	
	<cfif inputParameters.ShowSpin>		
	if( document.getElementById('spin_#inputParameters.fldID#') instanceof Object )
	{	
		if( jQuery('##spin_#inputParameters.fldID#').prop('checked') )							
			spin = jQuery('##spin_#inputParameters.fldID#').val();
	}
	</cfif>
	
	<cfif inputParameters.ShowPull>			
	if( document.getElementById('pull_#inputParameters.fldID#') instanceof Object )
	{	
		if( jQuery('##pull_#inputParameters.fldID#') )	
			pull = jQuery('##pull_#inputParameters.fldID#').val();
	}
	</cfif>
	
	if( name.length > 0 )
	{
		val = name;
		if( size.length > 0 )
			val = val + ' ' + size;
		if( fw.length > 0 )
			val = val + ' ' + fw;
		if( border.length > 0 )
			val = val + ' ' + border;
		if( spin.length > 0 )
			val = val + ' ' + spin;
		if( pull.length > 0 )
			val = val + ' ' + pull;
			
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
	jQuery('##fa_search_#inputParameters.fldID#').val('');		
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
		var defaultFAversion = variables.defaultFAversion;
		var defaultIconDataFile = variables.defaultIconDataFile;
		var inputParameters = application.ADF.data.duplicateStruct(arguments.parameters);
		
		// Set the defaults
		if( NOT StructKeyExists(inputParameters,'addIconClass') OR !inputParameters.addIconClass )
			inputParameters.addIconClass = false;
		if( NOT StructKeyExists(inputParameters,'ShowSize') )
			inputParameters.ShowSize = 0;
		if( NOT StructKeyExists(inputParameters,'ShowFixedWidth') )
			inputParameters.ShowFixedWidth = 0;
		if( NOT StructKeyExists(inputParameters,'ShowBorder') )
			inputParameters.ShowBorder = 0;
		if( NOT StructKeyExists(inputParameters,'ShowSpin') )
			inputParameters.ShowSpin = 0;
		if( NOT StructKeyExists(inputParameters,'ShowPull') )
			inputParameters.ShowPull = 0;
		
		// Fix for bad version folder "Major.Minor.Maintenance". Should only be "Major.Minor" version.
		// - If the "4.2.0" folder is found, use the default icon data file value 		
		if( NOT StructKeyExists(inputParameters,'iconDataFile') OR LEN(TRIM(inputParameters.iconDataFile)) EQ 0 OR FindNoCase("/ADF/thirdParty/css/font-awesome/4.2.0/",inputParameters.iconDataFile))
			inputParameters.iconDataFile = defaultIconDataFile;

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

	private boolean function isMultiline()
	{
		return true;
	}

	/*
		IMPORTANT: Since loadResourceDependencies() is using ADF.scripts loadResources methods, getResourceDependencies() and
		loadResourceDependencies() must stay in sync by accounting for all of required resources for this Custom Field Type.
	*/
	public void function loadResourceDependencies()
	{
		// Load registered Resources via the ADF scripts_2_0
		application.ADF.scripts.loadJQuery();
		application.ADF.scripts.loadFontAwesome();
	}
	public string function getResourceDependencies()
	{
		return "jQuery,FontAwesome";
	}
</cfscript>

</cfcomponent>