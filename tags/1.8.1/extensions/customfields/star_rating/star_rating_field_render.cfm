<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2015.
All Rights Reserved.
 
By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable
end user license agreement.
--->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Custom Field Type:
	Star Rating Custom Field Type
Name:
	star_rating_field_render.cfm
Summary:
	Custom field to render the JQuery UI star ratings.
ADF Requirements:
	scripts_1_0
	data_1_0
History:
	2009-11-16 - MFC - Created
	2011-02-02 - RAK - Updated to allow for customizing number of stars and half stars
	2012-01-03 - MFC - Commented out JS code to prevent JS error in the form.
--->

<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	numberOfStars = 5;
	if(StructKeyExists(xparams,"numberOfStars")){
		numberOfStars = xparams.numberOfStars;
	}
	halfStars = 0;
	if(StructKeyExists(xparams,"halfStars")){
		halfStars = xparams.halfStars;
	}
	// Load the scripts
	application.ADF.scripts.loadJQuery();
	application.ADF.scripts.loadJQueryUI();
	application.ADF.scripts.loadJQueryUIStars();


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
		//#fqFieldName#.tid = #rendertabindex#;
		#fqFieldName#.validator = "validate_#fqFieldName#()";
		#fqFieldName#.msg = "Please select a value for the #xparams.label# field.";
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
		
		jQuery(document).ready(function(){ 
			jQuery("###fqFieldName#_renderStars").stars({
				inputType: "select",
				<cfif halfStars>
			   	split: 2,
				</cfif>
				callback: function(ui, type, value){
					// Callback for the selection, get the object value
					selectObj = jQuery("###fqFieldName#_renderStars").stars("select", value);
					// put the selected value into the field
					jQuery("input###fqFieldName#").val(value);
				}
			});
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
	<tr id="#fqFieldName#_fieldRow">
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
			</cfscript>
			<div id="#fqFieldName#_renderStars">
				<select name='#fqFieldName#_select' id='#fqFieldName#_select' <!--- onchange='#fqFieldName#_loadSelection()' ---> <cfif readOnly>disabled='disabled'</cfif>>
					<cfloop from="1" to="#numberOfStars#" index="i">
						<cfset currentVal = i>
						<cfif halfStars>
							<cfset currentVal = i/2>
						</cfif>
						<option value="#currentVal#" <cfif currentValue EQ currentVal>selected</cfif>>#currentVal#</option>
					</cfloop>
				</select>
			</div>
		</td>
	</tr>
	<!--- hidden field to store the value --->
	<input type='hidden' name='#fqFieldName#' id='#fqFieldName#' value='#currentValue#'>
	<!--- // include hidden field for simple form processing --->
	<cfif renderSimpleFormField>
		<input type="hidden" name="#fqFieldName#_FIELDNAME" id="#fqFieldName#_FIELDNAME" value="#ReplaceNoCase(xParams.fieldName, 'fic_','')#">
	</cfif>
</cfoutput>