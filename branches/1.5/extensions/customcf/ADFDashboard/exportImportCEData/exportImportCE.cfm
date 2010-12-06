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
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	exportImportCE.cfm
Summary:
	This page renders the export/import GUI for custom element data
History:
	Dec 4, 2010 - RAK - Created
--->

<cfoutput>
	#application.ADF.scripts.loadJQuery()#
	#application.ADF.scripts.loadJQueryUI()#
	<script>
		jQuery(document).ready(function() {
			jQuery("##importExportTabs").tabs();
		});
	</script>
	<div id="importExportTabs">
		<ul>
			<li><a href="##export"><span>Export</span></a></li>
			<li><a href="##import"><span>Import</span></a></li>
		</ul>
		<div id="export">
			<cfscript>
				//Export Code
				if(StructKeyExists(request.params,"ceName")){
					renderexport(request.params.ceName);
				}else{
					renderForm();
				}
			</cfscript>
		</div>
		<div id="import">
			<cfscript>
				if(StructKeyExists(request.params,"existing")){
					processExistingImport();
				}else if(StructKeyExists(request.params,"upload")){
					processUploadImport();
				}else{
					displayImportForm();
				}
			</cfscript>
		</div>

	</div>
	<br/><br/>
</cfoutput>












<!---*****************************************************************************--->
<!---*****************************************************************************--->
<!--- *********************************IMPORTING**********************************--->
<!---*****************************************************************************--->
<!---*****************************************************************************--->

<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$processUploadImport
Summary:
	Given a new file upload process the import.
Returns:
	void
Arguments:

History:
 	Dec 4, 2010 - RAK - Created
--->
<cffunction name="processUploadImport" access="private" returntype="void" hint="Given a new file upload process the import.">
	<cfscript>
		if(StructKeyExists(request.params,"importFile")
			and Len(request.params.importFile)){
			clean = false;
			if(StructKeyExists(request.params,"clean")){
				clean = true;
			}
			doImport(request.params.importFile,clean);
		}else{
			displayImportForm();
		}
	</cfscript>
</cffunction>


<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$processExistingImport
Summary:
	Process the import using the existing files
Returns:
	void
Arguments:

History:
 	Dec 4, 2010 - RAK - Created
--->
<cffunction name="processExistingImport" access="private" returntype="void" hint="Process the import using the existing files">
	<cfscript>
		if(StructKeyExists(request.params,"element") and StructKeyExists(request.params,"date")){
			//We have our date in seconds since epoch. Get this to a real date
			formattedDate = DateAdd("s",request.params.date/1000,DateConvert("utc2Local", "January 1 1970 00:00"));
			formattedDate = DateFormat(formattedDate,"YYYY-MM-DD")&"-"&TimeFormat(formattedDate,"HH-mm");
			clean = false;
			if(StructKeyExists(request.params,"clean")){
				clean = true;
			}
			fileLocation = "#request.site.CSAPPSWEBURL#dashboard/ceExports/#element#--#formattedDate#.txt";
			doImport(ExpandPath(fileLocation),clean);
		}else{
			displayImportForm();
		}
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$doImport
Summary:
	given the file location execute the import and display the proper code
Returns:
	void
Arguments:

History:
 	Dec 4, 2010 - RAK - Created
--->
<cffunction name="doImport" access="private" returntype="void" hint="given the file location execute the import and display the proper code">
	<cfargument name="filePath" type="string" required="true" default="" hint="File path for the import">
	<cfargument name="clean" type="boolean" required="false" default="false" hint="Remove existing entries?">
	<cfscript>
		importResults = application.ADF.ceData.importCEData(filePath,clean);
	</cfscript>
	<cfoutput>
		<cfif importResults.success>
			<script type="text/javascript">
			jQuery(document).ready(function(){
				jQuery("##importExportTabs").tabs("select","import");
			});
			</script>
			#application.ADF.scheduler.getScheduleHTML(importResults.scheduleID)#<br/><br/>
			<a href="">Import Another Element</a>
		<cfelse>
			The import was not successful! <br/>
			#importResults.msg#<br/>
			Please check the logs for more details.<br/><br/>
			<a href="">Back to the form</a>
		</cfif>

	</cfoutput>
</cffunction>



<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$displayImportForm
Summary:
	displays the import code for existing files and the option of uploading your own file!
Returns:

Arguments:

History:
 	Dec 4, 2010 - RAK - Created
--->
<cffunction name="displayImportForm" access="private" returntype="void" hint="displays the import code for existing files and the option of uploading your own file!">
	<cfset ceDir = ExpandPath("#request.site.CSAPPSWEBURL#dashboard/ceExports/")>
	<cfdirectory directory = "#ceDir#" action = "list" listinfo="name"  name = "customElements">
	<cfoutput>
		#application.ADF.scripts.loadJQuery()#
		#application.ADF.scripts.loadJQueryUI()#
		#application.ADF.scripts.loadJQuerySelectboxes()#
		<script type="text/javascript">
			jQuery(document).ready(function(){
				jQuery("[name='uploadType']").change(handleRadioChange);
				handleRadioChange();
			});
			function handleRadioChange(){
				selected = jQuery('[name="uploadType"]:checked').val();
				console.log(selected);
				if(selected == "Upload"){
					jQuery(".upload").show();
					jQuery(".existing").hide();
				}else if(selected == "Existing"){
					jQuery(".upload").hide();
					jQuery(".existing").show();
				}else{
					jQuery(".upload").hide();
					jQuery(".existing").hide();
				}
			}
		</script>

		<input type="radio" id="uploadRadio" name="uploadType" value="Upload">
		<label for="uploadRadio">Upload</label>
		<br/>
		<input type="radio" id="existingRadio" name="uploadType" value="Existing">
		<label for="existingRadio">Existing</label>
		<br/>
		<br/>
		<br/>


		<style type="text/css">
			.upload, .existing{
				display:none;
			}
		</style>
		<div class="upload">
			<form action="" enctype="multipart/form-data" method="post">
				<input type="hidden" value="upload" name="upload"/>
				<input type="file" name="importFile">
				<br/>
				<input type="checkbox" id="wipeExistingForUpload" name="clean" value="true">
				<label for="wipeExistingForUpload">Wipe Existing Data</label>
				<br/>
				<input type="submit" value="Upload and Import">
			</form>
		</div>
		<div class="existing">
			<cfset counterStruct = StructNew()>
			<script type="text/javascript">
				var exportedElements = new Array();
				jQuery(document).ready(function(){
					<cfloop query="customElements">
						<cfscript>
							delimLoc = Find("--",name);
							elementName = Left(name,delimLoc-1);
							exportedDate = Replace(name,".txt","");
							exportedDate = Replace(exportedDate,"#elementName#--","");
							if( !StructKeyExists(counterStruct,elementName)){
								counterStruct[elementName] = -1;
							}
							counterStruct[elementName] = counterStruct[elementName] + 1;
						</cfscript>
						<cfif counterStruct[elementName] eq 0>
							exportedElements["#elementName#"] = new Array();
						</cfif>
						<!--- Oh how I hate dates... create a new javascript date like so: new date("2010","12","04","16","02")--->
						exportedElements["#elementName#"]["#counterStruct[elementName]#"] = new Date("#Mid(exportedDate,1,4)#","#Mid(exportedDate,6,2)-1#","#Mid(exportedDate,9,2)#","#Mid(exportedDate,12,2)#","#Mid(exportedDate,15,2)#");
					</cfloop>
					updateSelectedElement();
					jQuery(".element").change(updateSelectedElement);
				});
				function updateSelectedElement(){
					elementList = exportedElements[jQuery(".element").val()];
					printList = new Object();
					for(i=0;i<elementList.length;i++){
						printList[elementList[i].getTime()] = elementList[i];
					}
					console.log(printList);
					jQuery(".date").removeOption(/./);
					jQuery(".date").addOption(printList);
					jQuery(".date").show();
				}
			</script>
			<form action="" method="post">
				<input type="hidden" value="existing" name="existing"/>
				<select name="element" class="element">
					<cfloop from="1" to="#ListLen(structKeyList(counterStruct))#" index="i">
						<option value="#listGetAt(structKeyList(counterStruct),i)#">#listGetAt(structKeyList(counterStruct),i)#</option>
					</cfloop>
				</select>
				<br/>
				<select name="date" class="date" style="display:none;"></select>
				<br/>
				<input type="checkbox" id="wipeExistingForImport" name="clean" value="true">
				<label for="wipeExistingForImport">Wipe Existing Data</label>
				<br/>
				<input type="submit" value="Import Selected">
			</form>
		</div>
	</cfoutput>
</cffunction>










<!---*****************************************************************************--->
<!---*****************************************************************************--->
<!--- *********************************EXPORTING**********************************--->
<!---*****************************************************************************--->
<!---*****************************************************************************--->

<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$renderForm
Summary:
	renders the selection form for exporting custom elements
Returns:
	void
Arguments:

History:
 	Dec 4, 2010 - RAK - Created
--->
<cffunction name="renderForm" access="private" returntype="void" hint="renders the selection form for exporting custom elements">
	<cfscript>
		//Get every custom element
		allCustomElements = application.ADF.ceData.getAllCustomElements();
	</cfscript>
	<cfoutput>
		<form action="##export">
			<select name="ceName">
				<cfloop query="allCustomElements">
					<option value="#formName#">#formName#</option>
				</cfloop>
			</select>
			<input type="submit" value="Export"/>
		</form>
	</cfoutput>
</cffunction>

<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$renderExport
Summary:
	Exports the content then renders a link pointing to the exported file
Returns:
	void
Arguments:

History:
 	Dec 4, 2010 - RAK - Created
--->
<cffunction name="renderExport" access="private" returntype="void" hint="Exports the content then renders a link pointing to the exported file">
	<cfargument name="ceName" type="string" required="true" default="" hint="CE name to export and render link for">
	<cfscript>
		exportResult = application.ADF.ceData.exportCEData(arguments.ceName);
		if(len(exportResult)){
			exportResult = Replace(exportResult,"/","\","all");
			exportResult = "#request.site.CSAPPSWEBURL#dashboard/ceExports/#ListLast(exportResult,'\')#";
		}
	</cfscript>
	<cfoutput>
		<cfif Len(exportResult)>
			Export success!<br/><br/>
			<a href="#exportResult#">Download</a>
		<cfelse>
			Export failed. Please check the logs.
		</cfif>
	</cfoutput>
</cffunction>

