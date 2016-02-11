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
	PaperThin, Inc.
Custom Field Type:
	cfformprotect
Name:
	cfformprotect_props.cfm
Summary:
	Gives a text field allowing user to enter file locations. Then verifies them.
ADF Requirements:
History:
	2014-01-02 - GAC - Added comment header block
					 - Added the CFSETTING tag to disable CF Debug results in the props module
	2014-01-03 - GAC - Added the fieldVersion variable
	2014-09-19 - GAC - Removed deprecated doLabel and jsLabelUpdater js calls
	2015-09-02 - DRM - Add getResourceDependencies support, bump version
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<cfscript>
	// Variable for the version of the field - Display in Props UI.
	fieldVersion = "1.0.4";
	
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
	if( not structKeyExists(currentValues, "cfformprotect") )
		currentValues.cfformprotect = "/ADF/thirdParty/cfformprotect/cffp.cfm";
</cfscript>

<cfoutput>
	<script language="JavaScript" type="text/javascript">
		// register the fields with global props object
		fieldProperties['#typeid#'].paramFields = '#prefix#cfformprotect';
		// allows this field to have a common onSubmit Validator
		//fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';

		/*	function #prefix#doValidate()
		{
			//set the default msgvalue
			document.#formname#.#prefix#msg.value = 'Please enter some text to be converted';
			if( document.#formname#.#prefix#foo.value.length == 0 )
			{
				alert('please Enter some data for foo');
				return false;
			}
			return true;
		}
		*/
	</script>
	<table>
		<tr>
			<td class="cs_dlgLabelSmall">Script Path:</td>
			<td class="cs_dlgLabelSmall">
			<input type="text" name="#prefix#cfformprotect" id="#prefix#cfformprotect" class="cs_dlgControl" value="#currentValues.cfformprotect#" size="60"><br/>
			<span>Please enter the relative path and script to cfinclude (i.e. /ADF/thirdParty/cfformprotect/cffp.cfm)</span></td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall" colspan="2" style="font-size:7pt;">
				<hr />
				ADF Custom Field v#fieldVersion#
			</td>
		</tr>
	</table>
</cfoutput>