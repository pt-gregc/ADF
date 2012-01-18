<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2011.
All Rights Reserved.
 
By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable
end user license agreement.
--->

<!---
/* *************************************************************** */
Author: 	
	PaperThin Inc.
	G. Cronkright
Name:
	ui_theme_selector_props.cfm
Summary:
	CFT to render a list for jquery UI theme options
Version:
	1.0.0
History:
	2011-06-14 - GAC - Created
	2011-06-16 - GAC - Fixed the default jqueryUIurl and slashes for non Windows OS's
	2011-07-07 - GAC - Fixed a typo in the property field label
--->
<cfscript>
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
	
	uiFilterStr = "jquery-ui";
	defaultVersion = "jquery-ui-1.8";
	jQueryUIurl = "/ADF/thirdParty/jquery/ui";
	jQueryUIpath = ExpandPath(jQueryUIurl);
//application.ADF.utils.doDump(jQueryUIpath);	
	
	if( not structKeyExists(currentValues, "uiVersionPath") )
		currentValues.uiVersionPath = jQueryUIpath & "/" & defaultVersion;

//application.ADF.utils.doDump(currentValues,"currentValues",0);	
				 
</cfscript>

<!--- // Get a list of jQuery UI versions --->
<cfdirectory action="list" directory="#jQueryUIpath#" name="qVersions" type="dir">
<!--- <cfdump var ="#qVersions#" expand="false"> --->

<cfoutput>
	<script language="JavaScript" type="text/javascript">
		// register the fields with global props object
		fieldProperties['#typeid#'].paramFields = '#prefix#uiVersionPath';
	
		// allows this field to support the orange icon (copy down to label from field name)
		fieldProperties['#typeid#'].jsLabelUpdater = '#prefix#doLabel';
		// allows this field to have a common onSubmit Validator
		//fieldProperties['#typeid#'].jsValidator = '#prefix#doValidate';
		// handling the copy label function
		function #prefix#doLabel(str)
		{
			document.#formname#.#prefix#label.value = str;
		}
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
			<td class="cs_dlgLabelSmall" valign="top" nowrap="nowrap">Select an installed jQuery UI Version:</td>
			<td class="cs_dlgLabelSmall">
				<select name="#prefix#uiVersionPath" id="#prefix#uiVersionPath" class="cs_dlgControl">
		           	<cfloop query="qVersions">
			           	<cfif FindNoCase(uiFilterStr,name)>
				           	<cfset uiThemePath = qVersions.directory & "/" & qVersions.name>
				           	<option value="#uiThemePath#"<cfif currentValues.uiVersionPath EQ uiThemePath> selected="selected"</cfif>>#qVersions.name#</option>
		            	</cfif>
					</cfloop>
		        </select>
				<!--- <br/><span>Prop Field Description Text.</span> --->
			</td>
		</tr>
	</table>
</cfoutput>