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
--->
<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];

	//--Field Security--
	readOnly = application.ADF.forms.isFieldReadOnly(xparams);

	uiFilterOutList = ".svn,base"; // Add DIRs that need to be filtered from the theme drop down
	defaultVersion = "jquery-ui-1.8";
	jQueryUIurl = "/ADF/thirdParty/jquery/UI/#defaultVersion#";
	jQueryUIpath = ExpandPath(jQueryUIurl);

	// Validate if the property field has been defined
	if ( NOT StructKeyExists(xparams,"fldID") )
		xparams.fldID = fqFieldName;
	else if ( LEN(TRIM(xparams.fldID)) LTE 0 )
		xparams.fldID = ReplaceNoCase(xParams.fieldName,'fic_','');

	if ( NOT StructKeyExists(xparams,"uiVersion") )
		xparams.uiVersion = "jquery-ui-1.8"; //jquery-ui-1.8
		
	if ( NOT StructKeyExists(xparams,"uiVersionPath") )
		xparams.uiVersionPath = defaultVersion & "\css"; 
	else
		xparams.uiVersionPath = xparams.uiVersionPath & "\css";	

	// Load the JQuery Plugin Headers
	//application.ADF.scripts.loadjQuery();
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
		if ( '#xparams.req#' == 'Yes' ){
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

		/*jQuery( function() {
			
		}); */	
	</script>
	
<!---
	This version is using the wrapFieldHTML functionality, what this does is it takes
	the HTML that you want to put into the TD of the right section of the display, you
	can optionally disable this by adding the includeLabel = false (fourth parameter)
	when false it simply creates a TD and puts your content inside it. This wrapper handles
	everything from description to simple form field handling.
--->

	<cfsavecontent variable="inputHTML">
		<cfoutput>
	        <!--- <select id="#xparams.fldID#_select" name="#fqFieldName#_select"> --->
		    <select name="#fqFieldName#" id='#xparams.fldID#' <cfif readOnly>disabled="disabled"</cfif>>
		        <option value=""<cfif LEN(currentValue) EQ 0> selected="selected"</cfif>> - Select - </option>
	            <cfloop query="qThemes">
		           	<cfif ListFindNoCase(uiFilterOutList,qThemes.name) EQ 0>
		           	<option value="#qThemes.name#"<cfif currentValue EQ qThemes.name> selected="selected"</cfif>>#qThemes.name#</option>
	            	</cfif>
				</cfloop>
	        </select> 
			<!--- // hidden field to store the value --->
			<!--- <input type='hidden' name='#fqFieldName#' id='#xparams.fldID#' value='#currentValue#'> --->
		</cfoutput>
	</cfsavecontent>
	#application.ADF.forms.wrapFieldHTML(inputHTML,fieldQuery,attributes)#
	
</cfoutput>