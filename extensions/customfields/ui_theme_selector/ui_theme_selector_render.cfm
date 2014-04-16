<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2011.
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
	ui_theme_selector_render.cfm
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
--->
<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];

	uiFilterOutList = ".svn,base"; 		// Add DIRs that need to be filtered from the theme drop down	
	defaultVersion = "jquery-ui-1.8";
	defaultTheme = ""; 					//ui-lightness
	
	jQueryUIurl = "/ADF/thirdParty/jquery/ui/";
	jQueryUIpath = ExpandPath(jQueryUIurl); 

	defaultVersionURL = jQueryUIurl & defaultVersion & "/";
	defaultVersionPath = ExpandPath(defaultVersionURL);	

	if ( NOT StructKeyExists(xparams,"uiVersionPath") )
		xparams.uiVersionPath = defaultVersionPath & "/css/"; 
	else
		xparams.uiVersionPath = xparams.uiVersionPath & "/css/";

	// Convert slashes
	xparams.uiVersionPath = Replace(xparams.uiVersionPath,"\","/","all");  // D:/data/web/ADF/thirdParty/jquery/ui/jquery-ui-1.8/css/
		
	if ( LEN(TRIM(currentValue)) EQ 0 )
		currentValue = defaultTheme; 
		
	// Set defaults for the label and description 
	includeLabel = true;
	includeDescription = true; 

	//-- Update for CS 6.x / backwards compatible for CS 5.x --
	//   If it does not exist set the Field Permission variable to a default value
	if ( NOT StructKeyExists(variables,"fieldPermission") )
		variables.fieldPermission = "";

	//-- Read Only Check w/ cs6 fieldPermission parameter --
	readOnly = application.ADF.forms.isFieldReadOnly(xparams,variables.fieldPermission);	
</cfscript>

<!--- // Get a list of jQuery UI themes for the version of jQuery --->
<cfdirectory action="list" directory="#xparams.uiVersionPath#" name="qThemes" type="dir">

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
			if ( jQuery("select[name=#fqFieldName#]").val() != '' )
			{
				return true;
			}
			return false;
		}
	</script>

	<cfsavecontent variable="inputHTML">
		<cfoutput>
			<cfif qThemes.RecordCount>
			    <select name='#fqFieldName#' id='#fqFieldName#'<cfif readOnly> disabled="disabled"</cfif>>
			        <option value=''<cfif LEN(currentValue) EQ 0> selected="selected"</cfif>> - Select - </option>
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
	        	<input type='text' name='#fqFieldName#' id='#fqFieldName#' value='#currentValue#'>
	        </cfif>
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
	
	#application.ADF.forms.wrapFieldHTML(inputHTML,fieldQuery,attributes,variables.fieldPermission,includeLabel,includeDescription)#
</cfoutput>