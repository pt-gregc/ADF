<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2015.
All Rights Reserved.
 
By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable
end user license agreement.
--->

<cfcomponent displayname="link_builder" extends="ADF.lib.ceData.ceData_1_0">

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$renderLinks
Summary:
	Returns the HTML for the list of the Links for the block.
Returns:
	String - HTML
Arguments:
	Numeric - formID - CE Form ID
	String - uuidlist - Link Builder data UUID record
History:
	2009-00-00 - MFC - Created
	2015-06-09 - DRM - Update application.cs -> Server.CommonSpot.udf, CommonSpot change
--->
<cffunction name="renderLinks" access="public" returntype="string" hint="">
	<cfargument name="formID" type="numeric" required="true" hint="CE Form ID">
	<cfargument name="uuidList" type="string" required="true" hint="Link Builder data UUID record">
	<cfargument name="fieldName" type="string" required="true" hint="">
	
	<cfscript>
		var retHTML = "";
		// Get the data for the link builder data
		var linkDataArray = ArrayNew(1);
		var i = 1;
		var currText = "";
		var currURL = "";
		var currEditLink = "";
		var currRemoveLink = "";
		
		// check that we have a UUID List values
		if ( ListLen(arguments.uuidList) )
		{
			linkDataArray = application.ADF.ceData.getCEData(application.ADF.ceData.getCENameByFormID(arguments.formID), "uuid", arguments.uuidlist);
		
			// Check that we have linkDataArray
			if ( ArrayLen(linkDataArray) )
			{
				// Loop over the linkDataArray records
				for ( i = 1; i LTE ArrayLen(linkDataArray); i = i + 1 )
				{
					currText = Server.CommonSpot.udf.data.fromHTML(linkDataArray[i].Values.title);
					currText = ReplaceList(currText, "<p>,</p>", ",");
					// Set the link for the field
					if ( LEN(linkDataArray[i].Values.cspage) )
						currURL = linkDataArray[i].Values.cspage;
					else 
						currURL = linkDataArray[i].Values.extpage;
					
					currEditLink = "[<a href='javascript:;' class='link_builder_edit' id='#linkDataArray[i].Values.uuid#'>edit</a>]";
					currRemoveLink = "[<a href='javascript:;' class='link_builder_remove' id='#linkDataArray[i].Values.uuid#'>remove</a>]";
					retHTML = retHTML & "<div class='link_builder_item' id='#linkDataArray[i].Values.uuid#'><span class='ui-icon ui-icon-arrowthick-2-n-s' style='position:absolute; margin-left:-1.3em;'></span>#Trim(currText)#<br/>" & currEditLink & currRemoveLink & "</div>";
					//retHTML = retHTML & currEditLink & currRemoveLink;
				}
			}
			else
				retHTML = "No links";
		}
		else
			retHTML = "No links";
		
	</cfscript>
	<cfreturn retHTML>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$htmlAddEditLinkBuilder
Summary:
	Returns the HTML for the Add/Edit Link Builder CE data form.
Returns:
	String - HTML
Arguments:
	String - callbackFunct - Callback function
	String - linkType - Link Type
	Numeric - formID - CE Form ID
	Numeric - dataPageID - CE record data page ID
History:
	2009-10-06 - MFC - Created
	2014-03-05 - JTP - Var declarations
--->
<cffunction name="htmlAddEditLinkBuilder" access="public" returntype="string" hint="Returns the HTML for the Add/Edit Link Builder CE data form.">
	<cfargument name="callbackFunct" type="string" required="true" hint="Callback function">
	<cfargument name="linkType" type="string" required="true" hint="Link Type">
	<cfargument name="formID" type="numeric" required="true" hint="CE Form ID">
	<cfargument name="dataPageID" type="numeric" required="false" default="0" hint="CE record data page ID">
	<cfargument name="renderResult" type="boolean" required="false" default="0">
	<cfargument name="linkUUID" type="string" required="false" default="">
	
	<cfscript>
		var APIPostToNewWindow = true;
		var retHTML = "";
		var formResultHTML = "";
		var formElementFlds = application.ADF.forms.getCEFieldNameData("Link Builder Data");
		var formContainRTE = application.ADF.ceData.containsFieldType(arguments.formID, "formatted_text_block");
		var cbAction = '';	
		var linkBuilderUUID = "";
		
		// Set the record UUID so that we know what it is to send back to the field
		// check if we have the UUID from arguments
		if ( LEN(arguments.linkUUID) ) {
			// Get the data record for the element
			linkBuilderUUID = arguments.linkUUID;
		}
		else {
			// else we are creating a new record, so make the UUID
			linkBuilderUUID = createUUID();
		}
		request.params.linkBuilderUUID = linkBuilderUUID;
	</cfscript>
	<!--- Result from the Form Submit --->
	<cfsavecontent variable="formResultHTML">
		<cfoutput>
		<cfscript>
			application.ADF.scripts.loadJQuery('1.3.2');
			application.ADF.scripts.loadADFLightbox();
		</cfscript>
		<cfif arguments.dataPageID GT 0>
			<cfset cbAction = "edit">
		<cfelse>
			<cfset cbAction = "add">
		</cfif>
		<script type="text/javascript">
			//alert("test");
			
			// Build the call back argument for updated list of  
			var outArgsArray = new Array();
	    	outArgsArray[0] = "#request.params.linkBuilderUUID#";
			outArgsArray[1] = "#cbAction#";
			
			getCallback("#arguments.callbackFunct#", outArgsArray);
			closeLB();
		</script>
		</cfoutput>
	</cfsavecontent>
	<cfif NOT arguments.renderResult>
		<!--- Check if this form has an RTE field --->
		<cfif formContainRTE>
			<!--- Set the form result HTML --->
			<cfsavecontent variable="formResultHTML">
				<cfoutput>
				<cfscript>
					application.ADF.scripts.loadJQuery('1.3.2', 1);
				</cfscript>
				<!--- Close the lightbox on click --->
				<script type='text/javascript'>
					window.opener.location.href = window.opener.location.href + "&renderResult=1&linkUUID=#request.params.linkBuilderUUID#";
					// Close the window
					if (jQuery.browser.msie){
						window.open('','_self','');
	           			window.close();
				    }else{
				    	window.close();
				    } 
				</script>
				</cfoutput>
			</cfsavecontent>
		</cfif>
		<!--- HTML for the form --->
		<cfsavecontent variable="retHTML">	
			<cfoutput>
				<!--- Call the UDF function --->
				#server.CommonSpot.UDF.UI.RenderSimpleForm(arguments.dataPageID, arguments.formID, APIPostToNewWindow, formResultHTML)#
			</cfoutput>
		</cfsavecontent>
	<cfelse>
		<cfset retHTML = formResultHTML>
	</cfif>
	<cfreturn retHTML>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$removeLink
Summary:
	Deletes the Link Builder UUID record from the CE.
Returns:
	Boolean - T/F
Arguments:
	String - uuidList - Link Builder UUID element records.
History:
	2009-09-18 - MFC - Created
--->
<cffunction name="removeLink" access="public" returntype="boolean" hint="Deletes the Link Builder UUID record from the CE.">
	<cfargument name="formID" type="numeric" required="true" hint="CE Form ID">
	<cfargument name="datapageID" type="numeric" required="true" hint="CE Form ID">

	<cfscript>
		var status = true;
		// Delete the data page id for the CE element
		application.ADF.ceData.deleteCE(arguments.datapageID);
	</cfscript>
	<cfreturn status>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$listManagement
Summary:
	Returns the updated data list for the item data and action.
Returns:
	String - UUID List
Arguments:
	String - currUUIDList - Current UUID List
	String - UUIDItem - UUID item to work into the list
	String - actionType - Action to perform on the list
History:
	2009-09-18 - MFC - Created
--->
<cffunction name="listManagement" access="public" returntype="string" hint="Returns the updated data list for the item data and action.">
	<cfargument name="currList" type="string" required="true" hint="">
	<cfargument name="currItem" type="string" required="true" hint="">
	<cfargument name="actionType" type="string" required="true" hint="">
	
	<cfscript>
		var retList = arguments.currList;
		// Handle the ADD action
		if ( arguments.actionType EQ "add" )
			retList = ListAppend(retList, arguments.currItem);
		else if ( arguments.actionType EQ "remove" )
		{
			// Handle the REMOVE action
			// Check if the value is in the list
			if ( ListFindNoCase(retList, arguments.currItem) )
			{
				retList = ListDeleteAt(retList, ListFindNoCase(retList, arguments.currItem));
			}
		}
	</cfscript>
	<cfreturn retList>
</cffunction>

</cfcomponent>