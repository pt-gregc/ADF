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
/* *********************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	active-row-highlight.cfm
Summary:
	Highlights the row if the value of this field is 1
History:
	2011-09-01 - RAK - Created
--->
<cfset color = "##BBBBAA">
<cfsavecontent variable="request.datasheet.currentFormattedValue">
	<cfoutput>
		<td>
			<cfif request.datasheet.currentColumnValue eq 1
				or request.datasheet.currentColumnValue eq 'Yes'
				or request.datasheet.currentColumnValue eq 'Active'>
				<cfset id = createUUID()>
				<span highlightFinder="#id#">Active</span>
				<script>
					jQuery(function(){
						jQuery('[highlightFinder="#id#"]').closest('tr').css("backgroundColor","#color#");
					});
				</script>
			<cfelse>
				Inactive
			</cfif>
		</td>
	</cfoutput>
</cfsavecontent>
