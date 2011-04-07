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
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
 edit-delete-native-CS6.cfc
Summary:
	Prints out edit/delete buttons for your datasheet. Renders the default action edit and delete forms.
History:
	2011-02-07 - RAK - Created
	2011-03-11 - MFC - Updated to add class "ADF-Edit-Delete" to TD for custom styling.
						Add align and valign to TD to make standard with the "edit-delete" DS-module.
--->

<!--- Load the JQuery UI Styles --->
<cfscript>
	application.ADF.scripts.loadJQuery();
	application.ADF.scripts.loadJQueryUI();
	// Get the column list from the DS query
	dsColumnList = request.DatasheetRow.ColumnList;
</cfscript>

<!--- Include the action column CommonSpot Script --->
<cfif request.DatasheetRow.getRow() EQ 1>
	<cfinclude template="/commonspot/controls/datasheet/action-js.cfm">
</cfif>

<!--- Setup the paramList for the Row --->
<cfoutput>
<script type="text/javascript">
	<!-- 
	paramList_#attributes.CONTROLID#_#request.DatasheetRow.getRow()# = new Object();
	-->
</script>
</cfoutput>
<!--- Add the column data to the paramList for the Row --->
<cfloop index="i" from="1" to="#ListLen(dsColumnList)#">
<cfoutput>
	<script type="text/javascript">
		<!-- 
		paramList_#attributes.CONTROLID#_#request.DatasheetRow.getRow()#['#LCASE(ListGetAt(dsColumnList,i))#'] = '#request.DatasheetRow[ListGetAt(dsColumnList,i)][request.DatasheetRow.getRow()]#';
		 -->
	</script>
</cfoutput>
</cfloop>

<cfsavecontent variable="Request.Datasheet.CurrentFormattedValue">
	<cfoutput>
		<td align="center" valign="middle" class="ADF-Edit-Delete">
			<!--- <a style="float: left;" href="javascript:doActionCol(paramList_#attributes.CONTROLID#_#request.DatasheetRow.getRow()#,'edit-form-data.cfm','edit',#attributes.CONTROLID#,'actiontarget');" title='Edit'>			 --->
			<a style="float: left;" href="javascript:doActionCol(paramList_#attributes.CONTROLID#_#request.DatasheetRow.getRow()#,1,#attributes.CONTROLID#,'edit','actiontarget','0');" title='Edit'>			
				<div class='ds-icons ui-state-default ui-corner-all' title='edit' >
					<div style='margin-left:auto;margin-right:auto;' class='ui-icon ui-icon-pencil'></div>
				</div>
			</a>
			<!--- <a style="float: left; margin-left: 3px; margin-right: 3px;" href="javascript:doActionCol(paramList_#attributes.CONTROLID#_#request.DatasheetRow.getRow()#,'delete-form-data.cfm','delete',#attributes.CONTROLID#,'actiontarget');" title='Delete'> --->
			<a style="float: left; margin-left: 3px; margin-right: 3px;" href="javascript:doActionCol(paramList_#attributes.CONTROLID#_#request.DatasheetRow.getRow()#,2,#attributes.CONTROLID#,'delete','actiontarget','0');" title='Delete'>
				<div class='ds-icons ui-state-default ui-corner-all' title='delete' >
					<div style='margin-left:auto;margin-right:auto;' class='ui-icon ui-icon-trash'></div>
				</div>
			</a>
			<span style="clear: both;">&nbsp;</span>
		</td>
	</cfoutput>
</cfsavecontent>