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
	CE_Select
Name:
	ce_select_render.cfm
Summary:
	Custom Element selection field type.  
	Provides connections with the CE_FIELD_SELECT custom field type.  Define the properties 
	in the CE_FIELD_SELECT and CE_SELECT field to connect the fields. 
ADF Requirements:
	lib/ceData/ceData_1_0
	lib/scripts/scripts_1_0
History:
	2009-05-21 - MFC - Created
--->
<cfscript>
	// Load JQuery to the script
	server.ADF.objectFactory.getBean("scripts_1_0").loadJQuery("1.3.2");
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	
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
		#fqFieldName#.validator="validateCESelection()";
		#fqFieldName#.msg="Please select the Custom Element Name.";
		// push on to validation array
		vobjects_#attributes.formname#.push(#fqFieldName#);
		
		// Validation Function
		function validateCESelection(){
			// Verify that the selected value is not empty
			if (jQuery("select###fqFieldName#").find(':selected').val() != '')
				return true;
			else
				return false;
		}
	
		jQuery(document).ready(function(){
			// Check if we have a current value
			if ( '#currentValue#' != '' )
				#xparams.ceFldsFieldID#('#currentValue#');
			
			// Load the CE Field Select on Change
			jQuery("select###fqFieldName#").change(function () { 
		    	#xparams.ceFldsFieldID#(jQuery(this).find(':selected').val());
		    });
		});
	</script>
	<!--- query to get the Custom Element List --->
	<cfset customElements = server.ADF.objectFactory.getBean("ceData_1_0").getAllCustomElements()>
	<tr>
		<td nowrap="nowrap" align="" width="25%" valign="baseline">
			<font face="Verdana,Arial" color="##000000" size="2">
				<cfif xParams.req EQ "Yes"><strong></cfif>
				<label for="#fqFieldName#">#xparams.label#:</label>
				<cfif xParams.req eq "yes"></strong></cfif>
			</font>
		</td>
		<td class="cs_dlgLabelSmall">
			<select id="#fqFieldName#" name="#fqFieldName#" size="1">
				<option value="" selected> - Select - </option>
				<cfloop query="customElements">
					<option value="#ID#" <cfif currentValue EQ ID>selected</cfif>>#FormName#</option>
				</cfloop>
			</select><br />
		</td>
	</tr>
	<!--- // include hidden field for simple form processing --->
	<cfif renderSimpleFormField>
		<input type="hidden" name="#fqFieldName#_FIELDNAME" id="#fqFieldName#_FIELDNAME" value="#ReplaceNoCase(xParams.fieldName, 'fic_','')#">
	</cfif>
</cfoutput>