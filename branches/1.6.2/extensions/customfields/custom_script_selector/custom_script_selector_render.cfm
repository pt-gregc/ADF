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
/* *********************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	custom_script_selector_render.cfm
Summary:
	Renders a form to select and verify a custom script
History:
	2011-03-29 - RAK - Created
	2012-01-06 - GAC - Renamed file and renamed folder
	2012-04-11 - GAC - Added the fieldPermission parameter to the wrapFieldHTML function call
					 - Added the includeLabel and includeDescription parameters to the wrapFieldHTML function call
					 - Added readOnly field security code with the cs6 fieldPermission parameter
					 - Updated the wrapFieldHTML explanation comment block
--->

<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];

	// Set defaults for the label and description 
	includeLabel = true;
	includeDescription = true; 

	//-- Update for CS 6.x / backwards compatible for CS 5.x --
	//   If it does not exist set the Field Permission variable to a default value
	if ( NOT StructKeyExists(variables,"fieldPermission") )
		variables.fieldPermission = "";

	//-- Read Only Check w/ cs6 fieldPermission parameter --
	readOnly = application.ADF.forms.isFieldReadOnly(xparams,variables.fieldPermission);
</cfscript>

<cfoutput>
	<script>
		// javascript validation to make sure they have text to be converted
		#fqFieldName#=new Object();
		#fqFieldName#.id='#fqFieldName#';
		#fqFieldName#.tid=#rendertabindex#;
<!---		#fqFieldName#.msg="Please select a value for the #xparams.label# field.";--->
		#fqFieldName#.validator = "#fqFieldName#_validateScript()";
		vobjects_#attributes.formname#.push(#fqFieldName#);

		function #fqFieldName#_validateScript(){
			var templatePath = jQuery("###fqFieldName#").val();
			var params = {
				bean: "utils_1_0",
				method: "scriptExists",
				templatePath: templatePath
			}
			var rtn = true;
			jQuery.ajax({
				url:"#application.ADF.ajaxProxy#?"+jQuery.param(params),
				success: function(results){
					// show the results
					if( results != "YES" ){
						alert("Could not validate the entered script. Please make sure the path is correct.");
						rtn = false;
					}
				},
				async: false
			});
			return rtn;
		}
	</script>

	<cfsavecontent variable="inputHTML">
		<cfoutput>
			<input name="#fqFieldName#" id='#fqFieldName#' value="#currentValue#" size="50" <cfif readOnly>disabled="disabled"</cfif>>
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