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
	$Id: .cfm,v 0.1 2006/12/14 11:00:00 Exp $

	Description:
		
	Parameters:
		none
	Usage:
		none
	Documentation:
		none
	Based on:
		none
	History:
		
--->
<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];
	// load the jQuery library
	scripts = server.ADF.objectFactory.getBean("scripts_1_0");
	scripts.loadJQuery();
	scripts.loadJQueryUI("1.7.2", "smoothness");
	scripts.loadJQuerySelectboxes();
	scripts.loadJQueryTools();
	scripts.loadADFLightbox();
</cfscript>


<cfoutput>
	<script type="text/javascript">
		var options = {};
		// handle on start processing
		jQuery(document).ready( function($){
			$("input[name='submitbutton']").addClass("ui-button ui-state-default ui-corner-all");
			$("input[name='submitbutton']").hover(
				function(){ 
					$(this).addClass("ui-state-hover"); 
				},
				function(){ 
					$(this).removeClass("ui-state-hover"); 
				}
			)
			// load the list of subsites
			loadSubsites();		
		});
		
		// get the list of subsites and load them into the select list
		function loadSubsites()
		{
			jQuery.get("#application.ADF.ajaxProxy#",
				{ 	bean: "csData_1_0",
					method: "getSubsiteStruct",
					subsiteURL: "#request.subsite.url#",
					returnFormat: "json" },
				function( subsiteStruct )
				{
					jQuery.each(subsiteStruct, function(i, val) {
						jQuery("###fqFieldName#").addOption(i, val);
					});
					jQuery("###fqFieldName#").sortOptions();
					// make the current subsite selected
					jQuery("###fqFieldName#").selectOptions("#currentValue#");
				},
				"json"
			);
		}
		
		function #fqFieldName#addSubsite(name, displayName, description)
		{
			// get values from the form fields
			var subsiteName = $("###fqFieldName#_name").attr("value");
			var displayName = $("###fqFieldName#_display").attr("value");
			var description = $("###fqFieldName#_descr").attr("value");
			var parentSubsiteID = $("###fqFieldName#").selectedValues();
			// make the call to add the subsite
			$.post("#application.ADF.ajaxProxy#", { 
				bean: "BlogService",
				method: "addSubsite",
				name: subsiteName,
				displayName: displayName,
				description: description,
				parentSubsiteID: parentSubsiteID,
				returnFormat: "json" },
			 function(newSubsiteID){
			 	// reload the subsite listing
			 	loadSubsites();
			 	// select the new subsite
			 	$("###fqFieldName#").selectOptions(newSubsiteID);
			 	// close the dialog and show the "add message"
			 	$("###fqFieldName#_add").dialog("close");
			 	$("###fqFieldName#_add_msg").show("blind", options, 500, callback);
			 	$("###fqFieldName#_add_msg").hide("blind", options, 1500, callback);
			 },
			 "json"
			);
		}
		
		// javascript validation to make sure they have text to be converted
		/*#fqFieldName# = new Object();
		#fqFieldName#.id = '#fqFieldName#';
		#fqFieldName#.tid = #rendertabindex#;
		#fqFieldName#.validator = "validateLength()";
		#fqFieldName#.msg = "Please upload a document.";
		// push on to validation array
		vobjects_#attributes.formname#.push(#fqFieldName#);
		
		function validateLength()
		{	
			// get the current value of the hidden field
			obj = document.getElementById('#fqFieldName#_upload');
			
			// do your validation on the field against the parameters	
			if( obj.value == "" )
				return false;
			else
				return true;	
		}*/
		;		
	</script>	
	<tr>
		<td class="cs_dlgLabel" valign="top">Choose Main Subsite:</td>
		<td class="cs_dlgLabel" id="#fqFieldName#_subsite">
			<!--- <div id="#fqFieldName#_add_msg" style="display:none;">
				Subsite Added
			</div> --->
			<select name="#fqFieldName#" id="#fqFieldName#" size="1"></select><br/><div class="cs_dlgLabelSmall"><!---// field description goes here ---></div>
			<!---// TODO: resolve after 6.0 launch 
				<br /><button rel="/ADF/extensions/customfields/subsite_select/add_subsite.cfm?fqfieldName=#fqFieldName#" class="ui-button ui-state-default ui-corner-all ADFLightbox" id="#fqFieldName#_new_button">New Subsite</button>
			--->
		</td>
	</tr>
</cfoutput>