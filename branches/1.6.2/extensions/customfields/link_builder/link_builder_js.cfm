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

<cfoutput>
<script type="text/javascript">
	
	// Function to render the links for the record
	function renderLinks_#fqFieldName#() {
		//alert("Render Links");
		
		// get the current vals
		var currVals = jQuery("input[name=#fqFieldName#]").val();
		
		// load the initial list items based on the top terms from the chosen facet
		jQuery.get( "#application.ADF.ajaxProxy#",
		{ 	
			bean: "link_builder",
			method: 'renderLinks',
			formid: '#linkDataFormID#',
			uuidlist: currVals,
			fieldname: '#fqFieldName#'
		},
		function(msg){
			jQuery("##form_#fqFieldName#").html(msg);
		
			// Load the click events for the links
			loadEvents_#fqFieldName#();
			
			jQuery("##form_#fqFieldName#").sortable({ stop: function(event, ui) { #fqFieldName#_serialize() } });
		});
	}
	
	// serialize the selections
	function #fqFieldName#_serialize() {
		// load current values into the form field
		jQuery("input[name=#fqFieldName#]").val(jQuery('##form_#fqFieldName#').sortable( 'toArray' ));
	}
	
	//function cbFunct_#fqFieldName#(newUUID, action) {
	function cbFunct_#fqFieldName#(inArgsArray) {
		newUUID = inArgsArray[0];
		action = inArgsArray[1];
		
		// Update the fqFieldName field with the new UUID
		var currVal = jQuery("input[name=#fqFieldName#]").val();
		
		// load the initial list items based on the top terms from the chosen facet
		jQuery.get( "#application.ADF.ajaxProxy#",
		{ 	
			bean: "link_builder",
			method: 'listManagement',
			currList: currVal,
			currItem: newUUID,
			actionType: action
		},
		function(msg){
			// Set the value back into the save field
			jQuery("input[name=#fqFieldName#]").val(msg);
			// Reload the render links content
			renderLinks_#fqFieldName#();
		});
	}
	
	function loadEvents_#fqFieldName#() {
		jQuery("a.link_builder_edit").click(function () { 
	    	var currUUID = jQuery(this).attr("id");
	    	editLink_#fqFieldName#(currUUID);
	    });
	    jQuery("a.link_builder_remove").click(function () { 
	    	var currUUID = jQuery(this).attr("id");
	    	removeLinks_#fqFieldName#(currUUID);
	    });
	}
	
	// Function to render the links for the record
	function removeLinks_#fqFieldName#(uuid) {
		openLB("#actionPage#?action=remove&formid=#linkDataFormID#&uuid=" + uuid + "&cbFunct=cbFunct_#fqFieldName#&height=250&width=400&title=Remove Link");
	}
	
	// Function to render the links for the record
	function editLink_#fqFieldName#(uuid) {
		openLB("#actionPage#?action=form&formid=#linkDataFormID#&uuid=" + uuid + "&cbFunct=cbFunct_#fqFieldName#&width=700&height=575&title=Edit Link");
	}
	
	// Function to render the links for the record
	function addLink_#fqFieldName#() {
		openLB("#actionPage#?action=select&formid=#linkDataFormID#&cbFunct=cbFunct_#fqFieldName#&width=375&height=150&title=Add Link");
	}
</script>
</cfoutput>