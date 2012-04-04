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
	PaperThin, Inc.
	Ryan Kahn
Name:
	$sample_render.cfm
Summary:
	Sample render file, this will output a simple text element for the user to enter data in
History:
 	2011-09-26 - RAK - Created
	2011-12-19 - MFC - Updated the validation for the property fields.
	2012-03-19 - GAC - Added the fieldPermission parameter to the wrapFieldHTML function call
--->
<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];

	// Validate the property fields are defined
	if(!Len(currentvalue) AND StructKeyExists(xparams, "defaultText")){
		currentValue = xparams.defaultText;
	}

	//-- Update for CS 6.x / backwards compatible for CS 5.x --
	//   If it does not exist set the Field Permission variable to a default value
	if ( NOT StructKeyExists(variables,"fieldPermission") )
		variables.fieldPermission = "";

	//--Read Only Field Security--
	readOnly = application.ADF.forms.isFieldReadOnly(xparams);
	
	// Load JQuery
	application.ADF.scripts.loadJQuery();
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
		if ( '#xparams.req#' == 'Yes' ){
			// push on to validation array
			vobjects_#attributes.formname#.push(#fqFieldName#);
		}

		//Validation function
		function validate_#fqFieldName#(){
			if (jQuery("input[name=#fqFieldName#]").val() != ''){
				return true;
			}
			return false;
		}
	</script>
	<cfsavecontent variable="inputHTML">
		<cfoutput>
			<input name="#fqFieldName#" id='#fqFieldName#' value="#currentValue#" <cfif readOnly>disabled="disabled"</cfif>>
		</cfoutput>
	</cfsavecontent>

	<!---
		This version is using the wrapFieldHTML functionality, what this does is it takes
		the HTML that you want to put into the TD of the right section of the display, you
		can optionally disable this by adding the includeLabel = false (fourth parameter)
		when false it simply creates a TD and puts your content inside it. This wrapper handles
		everything from description to simple form field handling.
	--->
	#application.ADF.forms.wrapFieldHTML(inputHTML,fieldQuery,attributes,variables.fieldPermission)#
</cfoutput>