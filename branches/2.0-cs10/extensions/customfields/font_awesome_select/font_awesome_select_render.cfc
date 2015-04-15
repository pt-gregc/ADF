<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2014.
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
	font_awesome_select_render.cfm
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
--->
<cfcomponent displayName="FontAwesomeSelect Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="callingElement" type="string" required="yes">
	
	<cfscript>
		var inputParameters = Duplicate(arguments.parameters);
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
		var inputHTML = "";
		
		inputParameters = setDefaultParamaters(argumentCollection=arguments);
		iconDataFilePath = ExpandPath(inputParameters.iconDataFile);
		
		// Get the Full File Path to the IconDataFile		
		// Make sure the data file exists
		if ( FileExists(iconDataFilePath) )
		{
			// Convert the CSV file to a qry
			iconDataArr = application.ADF.data.csvToArray(file=iconDataFilePath,Delimiter=",");
		}
		else
		{
			cftErrMsg = "Unable to load icon data file!<br/>'#xparams.iconDataFile#'";
		}
		
		// Build the Font Awesome Icons array
		for ( a=1; a LTE ArrayLen(iconDataArr); a=a+1 )
		{
			ArrayAppend( fontArray, '#iconDataArr[a][1]#,#iconDataArr[a][2]#' ); 
		}

		// Set the curVal
		for( i=1; i lte ArrayLen(fontArray); i=i+1 )
		{
			if ( ListFirst(fontArray[i]) eq currentValue )
			{
				curVal = "#ListLast(fontArray[i])# #ListFirst(fontArray[i])#";
				break;
			}
		}

		application.ADF.scripts.loadJQuery();
		// Use jQuery to Add Font Awesome CSS to head dynamically
		application.ADF.scripts.loadFontAwesome(dynamicHeadRender=true);
	</cfscript>
	
	<cfsavecontent variable="inputHTML">
		<cfscript>
			renderStyles(argumentCollection=arguments);
			renderJSFunctions(argumentCollection=arguments, fieldParameters=inputParameters);
		</cfscript>
		<cfoutput>
			<div style="display: inline-block; font-size: 12px;  padding: 5px 10px 0px 0px;">
				<i id="icon_#inputParameters.fldID#" class="fa #currentValue#"></i> 
				<span id="sel_#inputParameters.fldID#">#ListFirst(currentValue, ' ')#</span>
			</div>
			<input type="text" name="fa_search_#inputParameters.fldID#" id="fa_search_#inputParameters.fldID#" value="" <cfif readOnly>disabled="disabled"</cfif> style="width: 180px; margin-bottom: 5px; padding-left: 5px;" placeholder="Type to filter list of icons"> 
			<input class="clsPushButton" type="button" value="Clear" style="padding: 1px 5px; vertical-align: baseline;" onclick="clearInput()">
			<input type="hidden" name="#arguments.fieldName#" id="#inputParameters.fldID#" value="#currentValue#"> 			
			<div class="cols-3-outer">
				<cfif LEN(TRIM(cftErrMsg))>#cftErrMsg#</cfif>
				<div class="cols-3">
					<ul>
						<cfloop index="i" from="1" to="#ArrayLen(fontArray)#" step="1">
							<cfif ListFirst(currentValue, ' ') EQ ListFirst(fontArray[i])>
								<cfset selected = "selected">
								<cfset selected_index = '#ListLast(fontArray[i])# #ListFirst(fontArray[i])#'>
							<cfelse>	
								<cfset selected = "">
							</cfif>
							<li>
								<div class="fonticon #selected#" data-code="#ListLast(fontArray[i])#" data-name="#ListFirst(fontArray[i])#"><i class="fa #ListFirst(fontArray[i])#"></i> #ListFirst(fontArray[i])#</div>
							</li>
						</cfloop>
					</ul>
				</div>
			</div>
			<div id="options_#inputParameters.fldID#" style="margin-top: 3px; vertical-align:baseline;">
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
	</cfsavecontent>
	<cfoutput>#inputHTML#</cfoutput>
</cffunction>

<cffunction name="renderStyles" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfscript>
		var styles = "";
	</cfscript>
<cfsavecontent variable="styles">	
<cfoutput>
<style type="text/css">
	.cols-3-outer { overflow-x: scroll; width:650px; height:200px; border: 1px solid ##999; background-color: ##fcfcfc; }
	.cols-3
	{
		height: 180px;
		-webkit-column-count: 3;
		-moz-column-count: 3;
		column-count: 3;
		-webkit-column-gap: 1px;
		-moz-column-gap: 1px;
		column-gap: 1px; 
	}			
	.cols-3 ul li { line-height: 2; font-size: 12px; list-style: none; padding-left: 5px; padding-right: 5px; cursor: pointer; }
	li div:hover { background-color: ##D9E3ED; border: 1px solid ##999; }
	li div.selected { background-color: ##D9E3ED; border: 1px solid ##999; }
	i.fa-border { border-color: ##555 !important; }
</style>
</cfoutput>
</cfsavecontent>
<cfoutput>#styles#</cfoutput>
</cffunction>

<cffunction name="renderJSFunctions" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="fieldParameters" type="struct" required="yes">
	
	<cfscript>
		var js = "";
		var inputParameters = Duplicate(arguments.fieldParameters);
	</cfscript>
	
<cfsavecontent variable="js">
<cfoutput>
<script type="text/javascript">
<!--
//Validation function
function validate_#arguments.fieldName#(){
	if (jQuery("input[name=#arguments.fieldName#]").val() != ''){
		return true;
	}else{
		return false;
	}
}

jQuery(function(){
	// Add Key up event
	jQuery('##fa_search_#inputParameters.fldID#').live( 'keyup', function() {
		var theval = jQuery('##fa_search_#inputParameters.fldID#').val();
		findFunction( theval );
	});

	// add Click event for each font li div
	jQuery(".fonticon").live( 'click', function(){
		var name = jQuery(this).attr('data-name');					
		var code = jQuery(this).attr('data-code');					

		// set display selection to that value (icon name)
		jQuery("##sel_#inputParameters.fldID#").text( name );

		// de-select old one
		if( jQuery("li div.selected") )
			jQuery("li div.selected").removeClass('selected');

		// select new one
		jQuery(this).addClass('selected');

		// assign just name portion to real hidden field
		BuildClasses();
	});		

	// add Click event for options div
	jQuery("##options_#inputParameters.fldID#").live( 'click', function(){
		BuildClasses();
	});
});

function findFunction(inString)
{
	// Check if we have a string defined
	if ( inString.length > 0 )
	{
		// Hide everything to start
		jQuery('li div.fonticon').hide();
	
		// Find the rows that contain the search terms
		jQuery('li div[data-name*="' + inString.toLowerCase() + '"]').each(function() {
				// Display the row
				jQuery(this).show();
			});

		// Find the selected rows 
		jQuery('li div.selected').show();
	}
	else 
	{
		// Show Everything
		jQuery('li div.fonticon').show();
	}
}

function BuildClasses()
{
	var name = '';
	var val = '';
	var size = '';
	var fw = '';
	var border = '';
	var spin = '';
	var pull = '';

	// get selected item
	if( jQuery("li div.selected").length )
		name = jQuery("li div.selected").attr('data-name');

	if( document.getElementById('size_#inputParameters.fldID#') instanceof Object )
		size = jQuery('##size_#inputParameters.fldID#').val();

	if( document.getElementById('fw_#inputParameters.fldID#') instanceof Object )
	{	
		if( jQuery('##fw_#inputParameters.fldID#').prop('checked') )
			fw = jQuery('##fw_#inputParameters.fldID#').val();
	}		
	
	if( document.getElementById('border_#inputParameters.fldID#') instanceof Object )
	{	
		if( jQuery('##border_#inputParameters.fldID#').prop('checked') )	
			border = jQuery('##border_#inputParameters.fldID#').val();
	}
				
	if( document.getElementById('spin_#inputParameters.fldID#') instanceof Object )
	{	
		if( jQuery('##spin_#inputParameters.fldID#').prop('checked') )							
			spin = jQuery('##spin_#inputParameters.fldID#').val();
	}
				
	if( document.getElementById('pull_#inputParameters.fldID#') instanceof Object )
	{	
		if( jQuery('##pull_#inputParameters.fldID#') )	
			pull = jQuery('##pull_#inputParameters.fldID#').val();
	}
	
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

		// set display div
		jQuery('##sel_#inputParameters.fldID#').text( name );		
		jQuery('##icon_#inputParameters.fldID#').attr( 'class', 'fa ' + val );		
	}

	// set hidden value
	jQuery('###inputParameters.fldID#').val( val );	
}

function clearInput()
{
	jQuery('##fa_search_#inputParameters.fldID#').val('');		
	jQuery('##sel_#inputParameters.fldID#').text('(Blank)');		
	jQuery('##icon_#inputParameters.fldID#').attr( 'class', '');		
	jQuery('###inputParameters.fldID#').val('');		

	// de-select old one
	if( jQuery("li div.selected") )
		jQuery("li div.selected").removeClass('selected');

	findFunction('');
}
//-->
</script></cfoutput>
</cfsavecontent>
<cfoutput>#js#</cfoutput>
</cffunction>

<cffunction name="setDefaultParamaters" returntype="struct" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfscript>
		var defaultFAversion = "4.2";
		var defaultIconDataFile = "/ADF/thirdParty/css/font-awesome/#defaultFAversion#/data/icon-data.csv";
		var inputParameters = Duplicate(arguments.parameters);
		
		// Set the defaults
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
			return 'validate_#arguments.fieldName#()';
		return "";
	}
	
	private string function getValidationMsg()
	{
		return "Please select a value for the #arguments.label# field.";
	}
</cfscript>

</cfcomponent>