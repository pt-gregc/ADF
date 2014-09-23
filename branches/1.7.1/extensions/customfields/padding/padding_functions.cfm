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
	PaperThin Inc.
Name:
	padding_functions.cfm
Summary:
	Common functions for the padding custom field
Version:
	1.0.0
History:
	2014-09-15 - Created
--->

<cffunction name="renderSelectionList" access="public" output="Yes" returntype="void" hint="renders a selection list of possible padding values.">
	<cfargument name="Show" type="Boolean" required="Yes">
	<cfargument name="Label" type="String" required="Yes">
	<cfargument name="FieldID" type="string" required="Yes">
	<cfargument name="name" type="string" required="Yes">
	<cfargument name="value" type="string" required="Yes">
	<cfargument name="possibleValues" type="string" required="Yes">
	
	<cfif arguments.show>
		<cfoutput>
			#arguments.label#
			<select id="#arguments.FieldID#_#arguments.Name#" name="#arguments.FieldID#_#arguments.Name#" onchange="onChange_#FieldID#();">
				<cfloop index="index" list="#arguments.possibleValues#">
					<option <cfif arguments.value eq index>selected="selected"</cfif>>#index#</option>
				</cfloop>
			</select>
		</cfoutput>	
	<cfelse>
		<cfoutput><input type="hidden" id="#arguments.FieldID#_#arguments.Name#" name="#arguments.FieldID#_#arguments.Name#" value="#arguments.value#"></cfoutput>
	</cfif>
</cffunction>