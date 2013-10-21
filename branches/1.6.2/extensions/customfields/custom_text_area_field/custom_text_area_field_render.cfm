<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2013.
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
	2009-08-14 - GAC - Converted to Custom Text Area With Class
	2009-08-20 - GAC - Added code for the required field option
	2010-07-08 - DMB - Added support for custom field name
	2010-08-02 - DMB - Modified to display the label using Commonspot CSS for a required field.
	2011-12-06 - GAC - Updated to use the wrapFieldHTML from ADF lib forms_1_1
	2012-01-05 - GAC - Added a default variables for the props parameters
	2012-01-10 - GAC - Removed obsolete show/hide field description logic
	2012-04-11 - GAC - Changed the includeDescription option to be true by default
					 - Updated the readOnly check to use the cs6 fieldPermission parameter
					 - Updated the wrapFieldHTML explanation comment block
	2012-04-13 - GAC - Fixed an issue with the Textarea Field ID not getting a value if a xparams.fldName was not entered in the props 
					 - Added an optional parameter to assign a CSS property to the textarea field resizing handle
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

	if ( NOT StructKeyExists(xparams, "fldName") OR LEN(TRIM(xparams.fldName)) EQ 0 )
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
	if ( NOT StructKeyExists(xparams,"resizeHandleOption" ) )
		xparams.resizeHandleOption = "default";
	if ( NOT LEN(currentvalue) AND StructKeyExists(xparams,"defaultValue") )
		currentValue = xparams.defaultValue;
	
	// Valid Textarea resize handle options
	resizeOptions = "none,both,horizontal,vertical"; 
	
	// Set defaults for the label and description 
	includeLabel = true;
	includeDescription = true;	
	
	//-- Update for CS 6.x / backwards compatible for CS 5.x --
	//   If it does not exist set the Field Security variable to a default value
	if ( NOT StructKeyExists(variables,"fieldPermission") )
		variables.fieldPermission = "";
		
	//-- Read Only Check w/ cs6 fieldPermission parameter --
	readOnly = application.ADF.forms.isFieldReadOnly(xparams,variables.fieldPermission);
</cfscript>

<cfoutput>
	<!--- // If the browser supports a textarea resizing handle apply the option --->
	<cfif LEN(TRIM(xparams.resizeHandleOption)) AND ListFindNoCase(resizeOptions,xparams.resizeHandleOption)>
	<style>
		textarea###xparams.fldName# {
			<cfif xparams.resizeHandleOption EQ "none">
			resize: #xparams.resizeHandleOption#;
			<cfelse>
			overflow: auto; /* overflow is needed */  
    		resize: #xparams.resizeHandleOption#; 
			</cfif> 
		}
	</style>
	</cfif>
	
	<cfsavecontent variable="inputHTML">
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
			if ( fieldLen <= #xparams.maxLength# )
			{
				return true;
			}
			else
			{
				alert(#fqFieldName#.msg);
				return false;			
			}
		} */ --->
	</script>

	<!---
		This CFT is using the forms lib wrapFieldHTML functionality. The wrapFieldHTML takes
		the Form Field HTML that you want to put into the TD of the right section of the CFT 
		table row and helps with display formatting, adds the hidden simple form fields (if needed) 
		and handles field permissions (other than read-only).
		Optionally you can disable the field label and the field discription by setting 
		the includeLabel and/or the includeDescription variables (found above) to false.  
	--->
	<!--- // Added the CS6 fieldPermission parameter  --->
	#application.ADF.forms.wrapFieldHTML(inputHTML,fieldQuery,attributes,variables.fieldPermission,includeLabel,includeDescription)#
</cfoutput>