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
	2015-04-23 - DJM - Fixed issue for all font awesome fields in a form working as a single control field
--->
<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	
	cftErrMsg = "";
	
	if( NOT StructKeyExists(xparams,'ShowSize') )
		xparams.ShowSize = 0;
	if( NOT StructKeyExists(xparams,'ShowFixedWidth') )
		xparams.ShowFixedWidth = 0;
	if( NOT StructKeyExists(xparams,'ShowBorder') )
		xparams.ShowBorder = 0;
	if( NOT StructKeyExists(xparams,'ShowSpin') )
		xparams.ShowSpin = 0;
	if( NOT StructKeyExists(xparams,'ShowPull') )
		xparams.ShowPull = 0;
	
	defaultFAversion = "4.2";
	defaultIconDataFile = "/ADF/thirdParty/css/font-awesome/#defaultFAversion#/data/icon-data.csv";
		
	if( NOT StructKeyExists(xparams,'iconDataFile') OR LEN(TRIM(xparams.iconDataFile)) EQ 0 )
	{
		xparams.iconDataFile = defaultIconDataFile;
	}
	
	// Fix for bad version folder "Major.Minor.Maintenance". Should only be "Major.Minor" version.
	// - If the "4.2.0" folder is found, use the default icon data file value 
	if ( FindNoCase("/ADF/thirdParty/css/font-awesome/4.2.0/",xparams.iconDataFile) ) 
	{		
		xparams.iconDataFile = defaultIconDataFile;	
	}

	// Validate if the property field has been defined
	if ( NOT StructKeyExists(xparams, "fldID") OR LEN(xparams.fldID) LTE 0 )
		xparams.fldID = fqFieldName;

	// Set defaults for the label and description 
	includeLabel = true;
	includeDescription = true; 

	//-- Update for CS 6.x / backwards compatible for CS 5.x --
	//   If it does not exist set the Field Permission variable to a default value
	if ( NOT StructKeyExists(variables,"fieldPermission") )
		variables.fieldPermission = "";

	//-- Read Only Check w/ cs6 fieldPermission parameter --
	readOnly = application.ADF.forms.isFieldReadOnly(xparams,variables.fieldPermission);
	
	// Get the Full File Path to the IconDataFile
	iconDataFilePath = ExpandPath(xparams.iconDataFile);
	iconDataArr = ArrayNew(1);
	
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
	fontArray = ArrayNew(1);
	for ( a=1; a LTE ArrayLen(iconDataArr); a=a+1 )
	{
		ArrayAppend( fontArray, '#iconDataArr[a][1]#,#iconDataArr[a][2]#' ); 
	}

	// Set the curval
	for( i=1; i lte ArrayLen(fontArray); i=i+1 )
	{
		if ( ListFirst(fontArray[i]) eq currentvalue )
		{
			curval = "#ListLast(fontArray[i])# #ListFirst(fontArray[i])#";
			break;
		}
	}

	application.ADF.scripts.loadJQuery();
	// Use jQuery to Add Font Awesome CSS to head dynamically
	application.ADF.scripts.loadFontAwesome(dynamicHeadRender=true);
</cfscript>

<cfoutput>
	<script>
		// javascript validation to make sure they have text to be converted
		#fqFieldName#=new Object();
		#fqFieldName#.id='#fqFieldName#';
		#fqFieldName#.tid=#rendertabindex#;
		#fqFieldName#.msg="Please select a value for the #xparams.label# field.";
		#fqFieldName#.validator = "validate_#fqFieldName#()";
		
		//If the field is required
		if ( '#xparams.req#' == 'Yes' )
		{
			// push on to validation array
			vobjects_#attributes.formname#.push(#fqFieldName#);
		}

		//Validation function
		function validate_#fqFieldName#(){
			if (jQuery("input[name=#fqFieldName#]").val() != ''){
				return true;
			}else{
				return false;
			}
		}
	</script>
</cfoutput>

	<cfsavecontent variable="inputHTML">
		<cfoutput>
			<style>
				.cols-3-outer { overflow-x: scroll; width:650px; height:200px; border: 1px solid ##999; background-color: ##fcfcfc; }
				.cols-3
				{
				   /* width:580px; */
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
			
			<script>
				jQuery(function(){
			
					// Add Key up event
					jQuery('##fa_search_#xparams.fldID#').live( 'keyup', function() {
						var theval = jQuery('##fa_search_#xparams.fldID#').val();
						findFunction_#fqFieldName#( theval );
					});

					// add Click event for each font li div
					jQuery("##icondata_#xparams.fldID# .fonticon").live( 'click', function(){
						var name = jQuery(this).attr('data-name');					
						var code = jQuery(this).attr('data-code');					

						// set display selection to that value (icon name)
						jQuery("##sel_#xparams.fldID#").text( name );
					
						// de-select old one
						if( jQuery("##icondata_#xparams.fldID# li div.selected") )
							jQuery("##icondata_#xparams.fldID# li div.selected").removeClass('selected');
					
						// select new one
						jQuery(this).addClass('selected');
					
						// assign just name portion to real hidden field
						BuildClasses_#fqFieldName#();
					});		
				
					// add Click event for options div
					jQuery("##options_#xparams.fldID#").live( 'click', function(){
						BuildClasses_#fqFieldName#();
					});
				});
				
				function findFunction_#fqFieldName#(inString)
				{
					// Check if we have a string defined
					if ( inString.length > 0 )
					{
						// Hide everything to start
						jQuery('##icondata_#xparams.fldID# li div.fonticon').hide();
					
						// Find the rows that contain the search terms
						jQuery('##icondata_#xparams.fldID# li div[data-name*="' + inString.toLowerCase() + '"]').each(function() {
								// Display the row
								jQuery(this).show();
							});

						// Find the selected rows 
						jQuery('##icondata_#xparams.fldID# li div.selected').show();
					}
					else 
					{
						// Show Everything
						jQuery('##icondata_#xparams.fldID# li div.fonticon').show();
					}
				}
			
				function clearInput_#fqFieldName#()
				{
					jQuery('##fa_search_#xparams.fldID#').val('');		
					jQuery('##sel_#xparams.fldID#').text('(Blank)');		
					jQuery('##icon_#xparams.fldID#').attr( 'class', '');		
					jQuery('###xparams.fldID#').val('');		
				
					// de-select old one
					if( jQuery("##icondata_#xparams.fldID# li div.selected") )
						jQuery("##icondata_#xparams.fldID# li div.selected").removeClass('selected');
				
					findFunction_#fqFieldName#('');
				}
			
				function BuildClasses_#fqFieldName#()
				{
					var name = '';
					var val = '';
					var size = '';
					var fw = '';
					var border = '';
					var spin = '';
					var pull = '';

					// get selected item
					if( jQuery("##icondata_#xparams.fldID# li div.selected").length )
						name = jQuery("##icondata_#xparams.fldID# li div.selected").attr('data-name');
				
					if( document.getElementById('size_#xparams.fldID#') instanceof Object )
						size = jQuery('##size_#xparams.fldID#').val();
				
					if( document.getElementById('fw_#xparams.fldID#') instanceof Object )
					{	
						if( jQuery('##fw_#xparams.fldID#').prop('checked') )
							fw = jQuery('##fw_#xparams.fldID#').val();
					}		
					
					if( document.getElementById('border_#xparams.fldID#') instanceof Object )
					{	
						if( jQuery('##border_#xparams.fldID#').prop('checked') )	
							border = jQuery('##border_#xparams.fldID#').val();
					}
								
					if( document.getElementById('spin_#xparams.fldID#') instanceof Object )
					{	
						if( jQuery('##spin_#xparams.fldID#').prop('checked') )							
							spin = jQuery('##spin_#xparams.fldID#').val();
					}
								
					if( document.getElementById('pull_#xparams.fldID#') instanceof Object )
					{	
						if( jQuery('##pull_#xparams.fldID#') )	
							pull = jQuery('##pull_#xparams.fldID#').val();
					}
							
					// console.log( name + ' ' + size + ' ' + fw + ' ' + border + ' ' + spin + ' ' + pull  );

					val = '';
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
						jQuery('##sel_#xparams.fldID#').text( name );		
						jQuery('##icon_#xparams.fldID#').attr( 'class', 'fa ' + val );		
					}
				
					// set hidden value
					jQuery('###xparams.fldID#').val( val );	
				}
			</script>
 
			<div style="display: inline-block; font-size: 12px;  padding: 5px 10px 0px 0px;">
				<i id="icon_#xparams.fldID#" class="fa #currentvalue#"></i> 
				<span id="sel_#xparams.fldID#">#ListFirst(currentValue, ' ')#</span>
			</div>
			<input type="text" name="fa_search_#xparams.fldID#" id="fa_search_#xparams.fldID#" value="" <cfif readOnly>disabled="disabled"</cfif> style="width: 180px; margin-bottom: 5px; padding-left: 5px;" placeholder="Type to filter list of icons"> 
			<input class="clsPushButton" type="button" value="Clear" style="padding: 1px 5px; vertical-align: baseline;" onclick="clearInput_#fqFieldName#()">
			<input type="hidden" name="#fqFieldName#" id="#xparams.fldID#" value="#currentValue#"> 			
			<div class="cols-3-outer">
			<cfif LEN(TRIM(cftErrMsg))>#cftErrMsg#</cfif>
			<div id="icondata_#xparams.fldID#" class="cols-3">
				<ul>
					<cfset selected_index = ''>
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
			<div id="options_#xparams.fldID#" style="margin-top: 3px; vertical-align:baseline;">
				<cfif xparams.ShowSize>
				Size: <select name="size_#xparams.fldID#" id="size_#xparams.fldID#">
						<option value="">Normal</option>
						<option value="fa-lg" <cfif FindNoCase('fa-lg',currentvalue)>selected="selected"</cfif>>Large</option>
						<cfloop index="s" from="2" to="10">
							<option value="fa-#s#x" <cfif FindNoCase('fa-#s#x',currentvalue)>selected="selected"</cfif>>#s#x</option>
						</cfloop> 
					</select> &nbsp; 
				</cfif>
				
				<cfif xparams.ShowFixedWidth>
				<input type="checkbox" id="fw_#xparams.fldID#" name="fw_#xparams.fldID#" value="fa-fw" <cfif FindNoCase('fa-fw',currentvalue)>checked="checked"</cfif>><label for="fw_#xparams.fldID#">Fixed Width</label> &nbsp; 
				</cfif>	
				
				<cfif xparams.ShowBorder>
				<input type="checkbox" id="border_#xparams.fldID#" name="border_#xparams.fldID#" value="fa-border" <cfif FindNoCase('fa-border',currentvalue)>checked="checked"</cfif>><label for="border_#xparams.fldID#">Border</label> &nbsp; 
				</cfif>
				
				<cfif xparams.ShowSpin>
				<input type="checkbox" id="spin_#xparams.fldID#" name="spin_#xparams.fldID#" value="fa-spin" <cfif FindNoCase('fa-spin',currentvalue)>checked="checked"</cfif>><label for="spin_#xparams.fldID#">Spin</label> &nbsp; 
				</cfif>
				
				<cfif xparams.ShowPull>
				Pull: <select id="pull_#xparams.fldID#" name="pull_#xparams.fldID#">
					<option value="">None</option>
					<option value="pull-left" <cfif FindNoCase('pull-left',currentvalue)>selected="selected"</cfif>>Left</option>
					<option value="pull-right" <cfif FindNoCase('pull-right',currentvalue)>selected="selected"</cfif>>Right</option>
					</select> 
				</cfif>	
			</div> 
		</cfoutput>
		
		
	</cfsavecontent>
	
	<!---
		This CFT is using the forms lib wrapFieldHTML functionality. The wrapFieldHTML takes
		the Form Field HTML that you want to put into the TD of the right section of the CFT 
		table row and helps with display formatting, adds the hidden simple form fields (if needed) 
		and handles field permissions (other than read-only).
		Optionally you can disable the field label and the field discription by setting 
		the includeLabel and/or the includeDescription variables (found above) to false.  
	--->
<cfoutput>
	#application.ADF.forms.wrapFieldHTML(inputHTML,fieldQuery,attributes,variables.fieldPermission,includeLabel,includeDescription)#
</cfoutput>


