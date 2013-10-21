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
/* ***************************************************************
/*
Author: 	
	PaperThin, Inc.
	Ryan Kahn
Custom Field Type:
	file uploader
Name:
	generic_uploader_props.cfm
Summary:
	Gives a text field allowing user to enter file locations. Then verifies them.
ADF Requirements:
History:
	2010-10-26 - RAK - Created
	2011-12-28 - MFC - Force JQuery to "noconflict" mode to resolve issues with CS 6.2.
--->
<cfscript>
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
	if( not structKeyExists(currentValues, "filePath") )
		currentValues.filePath = "";
	if( not structKeyExists(currentValues, "filetypes") )
		currentValues.filetypes = "txt,pdf";
		
	application.ADF.scripts.loadJQuery(noConflict=true);
</cfscript>
<cfoutput>
<script type="text/javascript">
	fieldProperties['#typeid#'].paramFields = "#prefix#filePath,#prefix#filetypes";
	fieldProperties['#typeid#'].jsLabelUpdater = '#prefix#doLabel';
	fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';
	// handling the copy label function
	function #prefix#doLabel(str){
		document.#formname#.#prefix#label.value = str;
	}
	function #prefix#doValidate(){
		filePath = jQuery("###prefix#filePath");
		if(filePath.length == 0){
			alert("Please specify a filepath.");
			return false;
		}
		return true;
	}

</script>
<table>
	<tr>
		<td class="cs_dlgLabelSmall">File Path:</td>
		<td class="cs_dlgLabelSmall">
			<input type="text" name="#prefix#filePath" id="#prefix#filePath" value="#currentValues.filePath#" size="40">
		</td>
	</tr>
	<tr>
		<td class="cs_dlgLabelSmall">Accepted Filetypes (txt,pdf):</td>
		<td class="cs_dlgLabelSmall">
			<input type="text" name="#prefix#filetypes" id="#prefix#filetypes" value="#currentValues.filetypes#" size="40">
		</td>
	</tr>
</table>
</cfoutput>