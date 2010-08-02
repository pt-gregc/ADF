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

History:
	2009-07-06 - MFC - Created
	2009-08-14 - GAC - Modified - Converted to Custom Text Area With Class
	2009-08-20 - GAC - Modified - Added code for the required field option
	2010-07-08 - DMB - Modified - Added support for custom field name
	2010-08-02 - DMB - Modified - Modified to display the label using Commonspot CSS for a required field.
--->
<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	//if ( structKeyExists(xparams, "wrap") EQ 0 )
		//xparams.wrap = virtual;
		
	// set the Max Length Default
	maxLen = 0;
	// set the default for the validationJS variable
	validationJS = "";
	
	//if ( structKeyExists(xparams, "maxLength") EQ 0 )
		//maxLen = xparams.maxLength;
		
	if ( structKeyExists(xparams, "wrap") EQ 0 )
		xparams.wrap = 'virtual';
	
	if ( NOT StructKeyExists(xparams, "fldName") )
		xparams.fldName = fqFieldName;
		
	// find if we need to render the simple form field
	renderSimpleFormField = false;
	if ( (StructKeyExists(request, "simpleformexists")) AND (request.simpleformexists EQ 1) )
		renderSimpleFormField = true;
</cfscript>

<cfscript>
	if ( structKeyExists(request, "element") )
	{
			if (xparams.req is "Yes") {
				thisVal="Required";
			}
			else
			{
				thisVal="Label";
			}
		labelText = '<span class="CS_Form_#thisVal#_Baseline"><label for="#fqFieldName#">#xParams.label#:</label></span>';
		tdClass = 'CS_Form_Label_Baseline';
	}
	else
	{
		labelText = '<label for="#fqFieldName#">#xParams.label#:</label>';
		tdClass = 'cs_dlgLabel';
	}
</cfscript>

<cfoutput>
	
	<tr>
		<td class="#tdClass#" valign="top">
				#labelText#
		</td>
		<td class="cs_dlgLabelSmall">
			<textarea name="#fqFieldName#" id="#xparams.fldName#" cols="#xparams.columns#" rows="#xparams.rows#"<cfif LEN(TRIM(xparams.fldClass))> class="#xparams.fldClass#"</cfif> wrap="#xparams.wrap#">#currentValue#</textarea><!--- wrap="#xparams.wrap#" --->
			<CFIF attributes.rendermode EQ 'standard'>
				<CFIF fieldpermission gt 0>
					<CFOUTPUT>#description_row#</CFOUTPUT>
				</CFIF>
			</CFIF>
		</td>
	</tr>
	<cfset xparams.fieldname = right(xparams.fieldname,len(xparams.fieldname)-4)>
	<input type="hidden" value="#xparams.fieldName#" name="#fqFieldName#_fieldName" class="ref_core_71"/>
	
	<!--- // include hidden field for simple form processing --->
	<cfif renderSimpleFormField>
		<input type="hidden" name="#fqFieldName#_FIELDNAME" id="#fqFieldName#_FIELDNAME" value="#ReplaceNoCase(xParams.fieldName, 'fic_','')#">
	</cfif>
	
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
				return false;
			}
		} */ --->
	</script>
</cfoutput>