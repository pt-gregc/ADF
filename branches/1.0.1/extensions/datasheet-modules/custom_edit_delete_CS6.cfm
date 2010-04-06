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
		<td>
			<a style="float: left;" href="javascript:doActionCol(paramList_#attributes.CONTROLID#_#request.DatasheetRow.getRow()#,'edit-form-data.cfm','edit',#attributes.CONTROLID#,'actiontarget');" title='Edit'>			
				<div class='ds-icons ui-state-default ui-corner-all' title='edit' >
					<div style='margin-left:auto;margin-right:auto;' class='ui-icon ui-icon-pencil'></div>
				</div>
			</a>
			<a style="float: left; margin-left: 3px; margin-right: 3px;" href="javascript:doActionCol(paramList_#attributes.CONTROLID#_#request.DatasheetRow.getRow()#,'delete-form-data.cfm','delete',#attributes.CONTROLID#,'actiontarget');" title='Delete'>
				<div class='ds-icons ui-state-default ui-corner-all' title='delete' >
					<div style='margin-left:auto;margin-right:auto;' class='ui-icon ui-icon-trash'></div>
				</div>
			</a>
			<span style="clear: both;">&nbsp;</span>
		</td>
	</cfoutput>
</cfsavecontent>