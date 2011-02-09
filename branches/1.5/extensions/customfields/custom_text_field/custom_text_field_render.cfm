<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2010.
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
	
	// find if we need to render the simple form field
	renderSimpleFormField = false;
	if ( (StructKeyExists(request, "simpleformexists")) AND (request.simpleformexists EQ 1) )
		renderSimpleFormField = true;
</cfscript>
<cfoutput>
	<script>
		// javascript validation to make sure they have text to be converted
		#fqFieldName# = new Object();
		#fqFieldName#.id = '#fqFieldName#';
		#fqFieldName#.tid = #rendertabindex#;
		//#fqFieldName#.validator = "validateLength()";
		//#fqFieldName#.msg = "Please upload a document.";
		// push on to validation array
		//vobjects_#attributes.formname#.push(#fqFieldName#);
	</script>
	<!--- hidden field to store the value --->
	
	<cfscript>
		if ( structKeyExists(request, "element") )
		{
			labelText = '<span class="CS_Form_Label_Baseline"><label for="#fqFieldName#">#xParams.label#:</label></span>';
			tdClass = 'CS_Form_Label_Baseline';
		}
		else
		{
			labelText = '<label for="#fqFieldName#">#xParams.label#:</label>';
			tdClass = 'cs_dlgLabel';
		}
	</cfscript>
	<tr>
		<td class="#tdClass#" valign="top">
			<font face="Verdana,Arial" color="##000000" size="2">
				<cfif xparams.req eq "Yes"><strong></cfif>
				#labelText#
				<cfif xparams.req eq "Yes"></strong></cfif>
			</font>
		</td>
		<td class="cs_dlgLabelSmall">
			<cfscript>
				// Get the list permissions and compare
				commonGroups = server.ADF.objectFactory.getBean("data_1_0").ListInCommon(request.user.grouplist, xparams.pedit);
				// Set the read only 
				readOnly = true;
				// Check if the user does have edit permissions
				if ( (xparams.UseSecurity EQ 0) OR ( (xparams.UseSecurity EQ 1) AND (ListLen(commonGroups)) ) )
					readOnly = false;
				// Check the Edit Once flag
				if ( LEN(currentValue) AND xparams.editOnce )
					readOnly = true;
			</cfscript>
			<!--- Render the input field --->
			<input type="text" name="#fqFieldName#" value="#currentValue#" id="#xparams.fldID#" size="#xparams.fldSize#"<cfif LEN(TRIM(xparams.fldClass))> class="#xparams.fldClass#"</cfif> tabindex="#rendertabindex#" <cfif readOnly>readonly="true"</cfif>>
			<!--- // include hidden field for simple form processing --->
			<cfif renderSimpleFormField>
				<input type="hidden" name="#fqFieldName#_FIELDNAME" id="#fqFieldName#_FIELDNAME" value="#ReplaceNoCase(xParams.fieldName, 'FIC_', '')#">
			</cfif>
		</td>
	</tr>
</cfoutput>