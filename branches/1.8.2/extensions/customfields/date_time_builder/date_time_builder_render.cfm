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
	PaperThin Inc.
	M. Carroll
Name:
	date_time_builder_render.cfm
Summary:
	Custom field to build the Date/Time records.
	This field generates a collection of Date and Times for the field.
Version:
	1.0.0
History:
	2010-09-15 - MFC - Created
--->
<cfscript>
	// Create a script obj
	application.ADF.scripts.loadJQuery();
	application.ADF.scripts.loadJQueryUI(themeName="ui-lightness");
	application.ADF.scripts.loadADFLightbox();
	
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	if ( NOT StructKeyExists(xparams, "fieldID") )
		xparams.fieldID = fqFieldName;
	if ( (NOT StructKeyExists(xparams, "fieldClass")) OR ( LEN(TRIM(xparams.fieldClass)) LTE 0) )
		xparams.fieldClass = "";
	// find if we need to render the simple form field
	renderSimpleFormField = false;
	if ( (StructKeyExists(request, "simpleformexists")) AND (request.simpleformexists EQ 1) )
		renderSimpleFormField = true;
		
	// Get the action page URL
	actionPage = xparams.actionPage;
	
	// Get the formid
	linkDataFormID = application.ADF.ceData.getFormIDByCEName("Date Time Builder Data");
</cfscript>

<cfoutput>
	<style>
		div.link_builder_item {
			margin-top: 4px;
			margin-bottom: 4px;
			border: 1px solid ##000000;
			padding: 5px;
			font-size: 10pt;
			padding-left: 20px;
			background-color: ##FFFFFF;
		}
		a.addLink_#fqFieldName#{
			float:right;
			font-size: 10pt;
		}
	</style>
	<script>
		// javascript validation to make sure they have text to be converted
		#fqFieldName# = new Object();
		#fqFieldName#.id = '#fqFieldName#';
		//#fqFieldName#.tid = #rendertabindex#;
		#fqFieldName#.validator = "validate_#fqFieldName#()";
		#fqFieldName#.msg = "Please enter a link.";
		// Check if the field is required
		if ( '#xparams.req#' == 'Yes' ){
			// push on to validation array
			vobjects_#attributes.formname#.push(#fqFieldName#);
		}
		function validate_#fqFieldName#()
		{
			//alert(fieldLen);
			if (jQuery("input[name=#fqFieldName#]").val() != '')
			{
				return true;
			}
			else
			{
				alert(#fqFieldName#.msg);
				return false;
			}
		}
		
		jQuery(document).ready(function() {
			renderLinks_#fqFieldName#();
		});
	</script>
	<cfscript>
		if ( structKeyExists(request, "element") ) {
			labelText = '<span class="CS_Form_Label_Baseline"><label for="#fqFieldName#">#xParams.label#:</label></span>';
			tdClass = 'CS_Form_Label_Baseline';
		} else {
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
			<cfinclude template="/ADF/extensions/customfields/date_time_builder/date_time_builder_js.cfm">
			<cfscript>
				// Get the list permissions and compare
				commonGroups = application.ADF.data.ListInCommon(request.user.grouplist, xparams.pedit);
				// Set the read only 
				readOnly = true;
				// Check if the user does have edit permissions
				if ( (xparams.UseSecurity EQ 0) OR ( (xparams.UseSecurity EQ 1) AND (ListLen(commonGroups)) ) )
					readOnly = false;
			</cfscript>
			<!--- <div id="addLink_#fqFieldName#" onclick="addLink_#fqFieldName#();">Add New Link</div> --->
			<a href="javascript:;" class="addLink_#fqFieldName#" onclick="addLink_#fqFieldName#();">Add New Date/Time</a>
			<div style="clear: both;"></div>
			<div id="form_#fqFieldName#">
			</div>
			
			<!--- hidden field to store the value --->
			<input type="hidden" name="#fqFieldName#" value="#currentValue#" id="#xparams.fieldID#" class="#xparams.fieldClass#" >
	
			<!--- // include hidden field for simple form processing --->
			<cfif renderSimpleFormField>
				<input type="hidden" name="#fqFieldName#_FIELDNAME" id="#fqFieldName#_FIELDNAME" value="#ReplaceNoCase(xParams.fieldName, 'FIC_', '')#">
			</cfif>
		</td>
	</tr>
</cfoutput>

