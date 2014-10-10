<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2014.
All Rights Reserved.
 
By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable
end user license agreement.
--->
<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$tab_index_render.cfm
Summary:
	Tab Index custom field to add the "tabindex" attributes to the fields in the 
		simple form.
History:
 	2012-11-27 - MFC - Created
--->
<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];

		//-- Update for CS 6.x / backwards compatible for CS 5.x --
	//   If it does not exist set the Field Permission variable to a default value
	//if ( NOT StructKeyExists(variables,"fieldPermission") )
	//	variables.fieldPermission = "";

	//--Read Only Field Security--
	//readOnly = application.ADF.forms.isFieldReadOnly(xparams);
	
	// Load JQuery
	application.ADF.scripts.loadJQuery();
</cfscript>
<cfoutput>
	<script>
		// javascript validation to make sure they have text to be converted
		#fqFieldName#=new Object();
		#fqFieldName#.id='#fqFieldName#';
		#fqFieldName#.tid=#rendertabindex#;
		//#fqFieldName#.msg="Please select a value for the #xparams.label# field.";
		//#fqFieldName#.validator = "validate_#fqFieldName#()";

		jQuery(document).ready(function() {
			serializeTabIndex();
		});
		
		function serializeTabIndex(){
			// Get all the input and textarea fields in the form
			var tabindex = 1;
			jQuery('form.cs_default_form').find('input,textarea,select,iframe').each(function() {
				// If not a hidden field
				if ( this.type != "hidden" ) {
					jQuery(this).attr("tabindex", tabindex);
				    tabindex++;
				}
			});
		}
	</script>
	
	<!--- <tr>
		<td class="cs_dlgLabelSmall" valign="top">#xParams.label#</td>
		<td class="cs_dlgLabelSmall">
			<p>Tab Index Field</p>
		</td>
	</tr> --->
</cfoutput>