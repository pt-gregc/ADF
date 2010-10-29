<cfif len(request.Datasheet.CurrentColumnValue)>
	<cfscript>
		application.ADF.scripts.loadJQuery();
		application.ADF.scripts.loadADFLightbox();
		AjaxPath = application.ADF.ajaxProxy;
		AjaxBean = "forms_2_0";
		AjaxMethod = "renderAddEditForm";
		
		AjaxDeleteBean = "forms_1_0";
		AjaxDeleteMethod = "renderDeleteForm";
		
		formID = edata.MetadataForm;
	</cfscript>
	<cfsavecontent variable="tdHTML">
		<cfoutput>
			<td align="center" valign="middle">
				<style>
					div.ds-icons {
						padding: 1px 10px;
						text-decoration: none;
						margin-left: 20px;
						width: 30px;
					}
					div.ds-icons:hover{
						cursor:pointer;
					}
				</style>
				<script>
					jQuery(document).ready(function(){
						// Hover states on the static widgets
						jQuery("div.ds-icons").hover(
							function() { 
								$(this).addClass('ui-state-hover');
							},
							function() { 
								$(this).removeClass('ui-state-hover');
							}
						);
					});
				</script>
				<table>
					<tr>
						<td>
							<div rel="#ajaxPath#?bean=#AjaxBean#&method=#AjaxMethod#&formid=#formID#&dataPageId=#Request.DatasheetRow.pageid#&lbAction=refreshparent&title=Edit" title="Edit" class="ADFLightbox">
								<div class='ds-icons ui-state-default ui-corner-all' title='edit' >
									<div style='margin-left:auto;margin-right:auto;' class='ui-icon ui-icon-pencil'>
									</div>
								</div>
							</div>
						</td>
						<td>
							<div rel="#ajaxPath#?bean=#AjaxDeleteBean#&method=#AjaxDeleteMethod#&formid=#formID#&dataPageid=#Request.DatasheetRow.pageid#&title=Delete" title="Delete" class="ADFLightbox">
								<div class='ds-icons ui-state-default ui-corner-all' title='delete' >
									<div style='margin-left:auto;margin-right:auto;' class='ui-icon ui-icon-trash'>
									</div>
								</div>
							 </div>
						</td>
					</tr>
				</table>
			</td>
		</cfoutput>
	</cfsavecontent>
	<cfif eparam.permitClientSideSort>
		<cfset tdHTML="Please disable 'Allow JavaScript data sorting' under Layout">
	</cfif>
	<cfset request.datasheet.currentFormattedValue = tdHTML>
</cfif>