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
/* ***************************************************************
/*
Author: 	
	PaperThin, Inc.
	Michael Carroll 
Custom Field Type:
	Custom Text Field
Name:
	custom_text_field_render.cfm
Summary:
	Custom text field to specify a field ID and action property set to allow one edit, 
		then the field is read only.
ADF Requirements:
	data_1_0
History:
	2009-10-15 - MFC - Created
	2011-02-08 - MFC - Updated the "fldName" prop to "fldID" variable.
	2011-06-30 - MFC - Changed ADF server object call to Data_1_0 to call "application.ADF.data".
	2013-01-10 - MFC - Updated the field to use the "forms.wrapFieldHTML" function.
	2013-02-14 - GAC - Updated to add in the CS6+ security setting for the wrapFieldHTML function
					 - Cleaned up old and unnecessary code
--->
<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	
	if ( NOT StructKeyExists(xparams, "fldName") )
		xparams.fldName = fqFieldName;
		
	// Set the field ID from the field name
	xparams.fldID = xparams.fldName;
	
	if ( NOT StructKeyExists(xparams, "fldClass") )
		xparams.fldClass = "";
	if ( not structKeyExists(xparams, "fldSize") )
		xparams.fldSize = "40";
	if ( NOT StructKeyExists(xparams, "editOnce") )
		xparams.editOnce = 0;
	// if no current value entered
	if ( NOT LEN(currentValue) ){
		// reset the currentValue to the currentDefault
		try
		{
			// if there is a user defined function for the default value
			if( xParams.useUDef )
				currentValue = evaluate(xParams.currentDefault);
			else // standard text value
				currentValue = xParams.currentDefault;
		}
		catch( any e)
		{
			; // let the current default value stand
		}
	}
	
	// Set defaults for the label and description 
	includeLabel = true;
	includeDescription = true; 

	//-- Update for CS 6.x / backwards compatible for CS 5.x --
	//   If it does not exist set the Field Permission variable to a default value
	if ( NOT StructKeyExists(variables,"fieldPermission") )
		variables.fieldPermission = "";

	//-- Read Only Check w/ cs6 fieldPermission parameter --
	readOnly = application.ADF.forms.isFieldReadOnly(xparams,variables.fieldPermission);
	
	// Check the Edit Once flag 
	if ( LEN(currentValue) AND xparams.editOnce )
		readOnly = true;
		
	// Load JQuery
	application.ADF.scripts.loadJQuery();
</cfscript>

<cfoutput>
	<script>
		// javascript validation to make sure they have text to be converted
		#fqFieldName#=new Object();
		#fqFieldName#.id='#fqFieldName#';
		#fqFieldName#.tid=#rendertabindex#;
		#fqFieldName#.msg="Please enter a value for the #xparams.label# field.";
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
			<!--- // Render the input field --->
			<input type="text" name="#fqFieldName#" value="#currentValue#" id="#xparams.fldID#" size="#xparams.fldSize#"<cfif LEN(TRIM(xparams.fldClass))> class="#xparams.fldClass#"</cfif> tabindex="#rendertabindex#" <cfif readOnly>readonly="true"</cfif>>
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