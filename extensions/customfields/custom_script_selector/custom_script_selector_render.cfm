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
--->

<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];

	//--Field Security--
	readOnly = application.ADF.forms.isFieldReadOnly(xparams);
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
<!---
	This version is using the wrapFieldHTML functionality, what this does is it takes
	the HTML that you want to put into the TD of the right section of the display, you
	can optionally disable this by adding the includeLabel = false (fourth parameter)
	when false it simply creates a TD and puts your content inside it. This wrapper handles
	everything from description to simple form field handling.
--->
	<cfsavecontent variable="inputHTML">
		<cfoutput>
			<input name="#fqFieldName#" id='#fqFieldName#' value="#currentValue#" size="50" <cfif readOnly>disabled="disabled"</cfif>>
		</cfoutput>
	</cfsavecontent>
	#application.ADF.forms.wrapFieldHTML(inputHTML,fieldQuery,attributes)#
</cfoutput>