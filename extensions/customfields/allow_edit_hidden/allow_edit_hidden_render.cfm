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
	PaperThin, Inc.
	Ron West
Custom Field Type:
	allow_edit_hidden
Name:
	allow_edit_hidden_render.cfm
Summary:
	Hidden field type that will run the default value on edit of the data.
	
	Primarily used to store the user id for the last updated.
ADF Requirements:
	None.
History:
	2009-06-29 - RLW - Created
	2010-11-04 - MFC - Updated props and render for the defaultValue in the paramFields variable.
	2012-10-01 - MFC - Updated to support fieldname containing "_" in a simple form.
--->
<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];

	// reset the currentValue to the currentDefault
	try
	{
		// if there is a user defined function for the default value
		if( xParams.useUDef )
			currentValue = evaluate(xParams.DEFAULTVALUE);
		else // standard text value
			currentValue = xParams.DEFAULTVALUE;
	}
	catch( any e)
	{
		; // let the current default value stand
	}
	
	// find if we need to render the simple form field
	renderSimpleFormField = false;
	if ( (StructKeyExists(request, "simpleformexists")) AND (request.simpleformexists EQ 1) )
		renderSimpleFormField = true;
</cfscript>
<cfoutput>
	<script>
		// javascript validation to make sure they have text to be converted
		#fqFieldName#=new Object();
		#fqFieldName#.id='#fqFieldName#';
		#fqFieldName#.tid=#rendertabindex#;
		//#fqFieldName#.validator="validateBlogName()";
		#fqFieldName#.msg="Please upload a document.";
		// push on to validation array
		//vobjects_#attributes.formname#.push(#fqFieldName#);
	</script>
	<input type="hidden" id="#fqFieldName#" name="#fqFieldName#" value="#currentValue#">
	<!--- // include hidden field for simple form processing --->
	<cfif renderSimpleFormField>
		<input type="hidden" name="#fqFieldName#_FIELDNAME" id="#fqFieldName#_FIELDNAME" value="#ReplaceNoCase(xParams.fieldName, 'fic_','')#">
	</cfif>
</cfoutput>