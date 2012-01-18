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
Custom Field Type:
	Custom Text Area Field
Name:
	custom_text_area_field_render.cfm
Summary:
	Allows for an text area field to have a specific class name. 
ADF Requirements:
	forms_1_1
Version:
	2.0.0
History:
	2009-07-06 - MFC - Created
	2009-08-14 - GAC - Modified - Converted to Custom Text Area With Class
	2009-08-20 - GAC - Modified - Added code for the required field option
	2010-07-08 - DMB - Modified - Added support for custom field name
	2010-08-02 - DMB - Modified - Modified to display the label using Commonspot CSS for a required field.
	2011-12-06 - GAC - Modified - Updated to use the wrapFieldHTML from ADF lib forms_1_1
	2012-01-05 - GAC - Modified - Added a default variables for the props parameters
	2012-01-10 - GAC - Modified - Removed obsolete show/hide field description logic
--->
<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
		
	// set the Max Length Default
	maxLen = 0;
	// set the default for the validationJS variable
	validationJS = "";
	
	// Set defaults for the label and description 
	includeLabel = true;
	includeDescription = false; // set to false to all conditional logic below to determine when it should be true
	
	if ( NOT StructKeyExists(xparams, "fldName") )
		xparams.fldName = fqFieldName;
	//if ( StructKeyExists(xparams, "maxLength") EQ 0 )
		//maxLen = xparams.maxLength;
	if ( NOT StructKeyExists(xparams, "columns") )
		xparams.columns = "40";
	if ( NOT StructKeyExists(xparams, "rows") )
		xparams.rows = "4";
	if ( NOT StructKeyExists(xparams, "wrap") )
		xparams.wrap = 'virtual';
	if ( NOT StructKeyExists(xparams, "fldClass") )
		xparams.fldClass = "";
	if ( NOT LEN(currentvalue) AND StructKeyExists(xparams,"defaultValue") )
		currentValue = xparams.defaultValue;
		
	//-- Update for CS 6.x / backwards compatible for CS 5.x --
	//   If it does not exist set the Field Security variable to a default value
	if ( NOT StructKeyExists(variables,"fieldPermission") )
		variables.fieldPermission = "";
		
	//-- Read Only Check w/ cs6 fieldPermission parameter --
	readOnly = application.ADF.forms.isFieldReadOnly(xparams,variables.fieldPermission);
</cfscript>

<cfoutput>
	<!---
		This version is using the wrapFieldHTML functionality, what this does is it takes
		the HTML that you want to put into the TD of the right section of the display, you
		can optionally disable this by adding the includeLabel = false (fourth parameter)
		when false it simply creates a TD and puts your content inside it. This wrapper handles
		everything from description to simple form field handling.
	--->

	<cfsavecontent variable="inputHTML">
	<!--- <cfdump var="#attributes.renderMode#" expand="false"><br>	
	<cfdump var="#variables.fieldpermission#" expand="false"><br> --->
	
	<cfoutput>
	<textarea name="#fqFieldName#" id="#xparams.fldName#" cols="#xparams.columns#" rows="#xparams.rows#"<cfif LEN(TRIM(xparams.fldClass))> class="#xparams.fldClass#"</cfif> wrap="#xparams.wrap#"<cfif readOnly> readonly="readonly"</cfif>>#currentValue#</textarea>
	</cfoutput>
	</cfsavecontent>
	
	<!--- JavaScript validation --->
	<script type="text/javascript">
		// javascript validation to make sure they have text to be converted
		#fqFieldName# = new Object();
		#fqFieldName#.id = '#fqFieldName#';
		#fqFieldName#.tid = #rendertabindex#;
		#fqFieldName#.validator='checkTxtArea(document.#attributes.formname#.#fqFieldName#.value, "#xparams.label#", #maxLen#, "#lcase(xparams.req)#")';
		<!--- // #fqFieldName#.validator="validateMaxLength()"; --->
		<!--- // #fqFieldName#.msg = 'Please enter a valid #xParams.label# value'; --->
		// push on to validation array
		// vobjects_#attributes.formname#.push(#fqFieldName#);
		vobjects_#attributes.formname#[vobjects_#attributes.formname#.length] = #fqFieldName#;
		
		<!--- /* function validateMaxLength()
		{
			//fieldLen = document.getElementById('#fqFieldName#').value.length;
			fieldLen = document.#attributes.formname#.#fqFieldName#.value.length;
			//alert(fieldLen);
			if (fieldLen <= #xparams.maxLength#)
			{
				return true;
			}
			else
			{
				alert(#fqFieldName#.msg);
				return false;			}
		} */ --->
	</script>

	<!--- // Added the CS6 fieldPermission parameter  --->
	#application.ADF.forms.wrapFieldHTML(inputHTML,fieldQuery,attributes,variables.fieldPermission,includeLabel,includeDescription)#
</cfoutput>