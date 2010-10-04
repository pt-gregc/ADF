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
	$Id: subsite_select_props.cfm,v 0.1 2007/01/24 12:50:00 Exp $

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
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
</cfscript>
<cfparam name="currentValues.allowSubsiteAdd" default="No">
<cfoutput>
	<script type="text/javascript">
		// this establishes that we have a parameter
		fieldProperties['#typeid#'].paramFields = "#prefix#allowSubsiteAdd";
		// add the default function for the orange copy down icon
		fieldProperties['#typeid#'].jsLabelUpdater = '#prefix#doLabel';
		function #prefix#doLabel(str)
		{
			document.#formname#.#prefix#label.value = str;
		}
	</script>
<table>
	<tr>
		<td class="cs_DlgLabel">Allow Subsite Add</td>
		<td class="cs_DlgLabel">
			<select name="#prefix#allowSubsiteAdd" id="#prefix#allowSubsiteAdd" size="1">
				<option value="Yes"<cfif currentValues.allowSubsiteAdd eq "Yes"> selected="selected"</cfif>>Yes</option>
				<option value="No"<cfif currentValues.allowSubsiteAdd eq "No"> selected="selected"</cfif>>No</option>
			</select>
		</td>
	</tr>
</table>
</cfoutput>