<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2013.
All Rights Reserved.
 
By downloading, modifying, distributing, using and/or accessing any files
in this directory, you agree to the terms and conditions of the applicable
end user license agreement.
--->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright / M. Carroll 
Custom Field Type:
	Page Layout
Name:
	page_layout_render.cfm
Summary:
	Custom field to render predefined page layout options in metadata forms.
History:
	2010-09-09 - GAC/MFC - 	Created
	2010-11-11 - MFC - 		Added onclick to the img to select the radio button. 
								Due to problem reported with Mac browser and label 
								select is not checking the radio field.
	2011-03-28 - MFC - Added check for if the photo URL is defined.
--->
<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];

	
	/* 
		Establish the layout options with security access for specific users.
		
		The layoutOptions Array stores the option name, thumbnail image, and 
			security groups that have permissions to select the option. 
		
		Array contains the following substructures with the fields:
			name 		= Name of the layout option stored in the metadata form.
			description = Description for the layout option - Displayed to the user.
			security 	= Group Names
			image 		= Path to the image file
			
		After the newOption structure is built, it is appended into the layoutOptions Array.
	*/		 
	layoutOptions = ArrayNew(1);
	
	// Home Layout
	newOption = structNew();
	newOption.name = "Home";
	newOption.description = "Home";
	newOption.security = "";
	newOption.image = "/ADF/extensions/customfields/page_layout/thumbs/home.gif";
	ArrayAppend(layoutOptions, newOption);
	
	// Landing Layout
	newOption = structNew();
	newOption.name = "Landing";
	newOption.description = "Landing Page";
	newOption.security = "";
	newOption.image = "/ADF/extensions/customfields/page_layout/thumbs/landing.gif";
	ArrayAppend(layoutOptions, newOption);
	
	// Full Width Layout
	newOption = structNew();
	newOption.name = "Full-Width";
	newOption.description = "Full Width";
	newOption.security = "";
	newOption.image = "/ADF/extensions/customfields/page_layout/thumbs/full_width.gif";
	ArrayAppend(layoutOptions, newOption);
	
	// Equal Width Layout
	newOption = structNew();
	newOption.name = "Equal-Width";
	newOption.description = "Equal Width";
	newOption.security = "";
	newOption.image = "/ADF/extensions/customfields/page_layout/thumbs/equal_width.gif";
	ArrayAppend(layoutOptions, newOption);
	
	// Right Channel Layout
	newOption = structNew();
	newOption.name = "Right-Channel";
	newOption.description = "Right Channel";
	newOption.security = "";
	newOption.image = "/ADF/extensions/customfields/page_layout/thumbs/right_channel.gif";
	ArrayAppend(layoutOptions, newOption);
</cfscript>

<!--- // Show Layout Choice function --->
<cffunction name="showChoice" access="public" returntype="boolean" output="true">
	<!--- <cfargument name="choice"> --->
	<cfargument name="securityGroups">
	<cfscript>
		var showChoice = "true";
		var itm = 1;
		var groupID = 0;
		if( listLen(arguments.securityGroups) )
		{
			// reset value to false then determine if they have access
			showChoice = "false";
			for( itm; itm lte listLen(arguments.securityGroups); itm = itm + 1 )
			{
				if( listFind(request.user.groupList, listGetAt(arguments.securityGroups, itm) ) )
				{
					showChoice = "true";
					break;
				}
			}
		}
	</cfscript>
	<cfreturn showChoice>
</cffunction>

<cfoutput>
	<script>
		// javascript validation to make sure they have text to be converted
		#fqFieldName#=new Object();
		#fqFieldName#.id='#fqFieldName#';
		#fqFieldName#.tid=#rendertabindex#;
		//#fqFieldName#.validator="#fqFieldName#validateSelection()";
		//#fqFieldName#.msg="Please upload a document.";
		// push on to validation array
		//vobjects_#attributes.formname#.push(#fqFieldName#);

		/*function #fqFieldName#validateSelection()
		{
			return true;
		}*/
	</script>
	<style type="text/css">
		.imageChoice{
			width: 143px;
			margin: 2px;
			float: left;
		}
		.imageChoice input{
			text-align: center;
		}
		.imageChoice img{
			background-color: ##c0c0c0;
			width: 100px;
			height: 120px;
			border: 1px ##c0c0c0 solid;
		}
		.imageChoice span{
			font-size: 9px;
		}
		.main {
			width: 590px;
		}
	</style>
<tr>
	<td class="cs_dlgLabelSmall"></td>
	<td class="cs_dlgLabelSmall">
	<div class="main">
		<cfscript>
			application.ADF.scripts.loadJQuery();
		</cfscript>
		<script type="text/javascript">
			function #fqFieldName#_loadSelection(optionName) {
				var fieldOptionName = "input###fqFieldName#_" + optionName;
				// Set the current options radio button to selected
				jQuery(fieldOptionName).attr("checked", "checked");
			}
		</script>
		<!--- Loop over the array of options --->
		<cfloop index="i" from="1" to="#ArrayLen(layoutOptions)#" >
			<!--- Set the current option name b/c we use it multiple times --->
			<cfset currOptionName = layoutOptions[i].name>
			<!--- Check if we have permissions to use this layout option --->
			<cfif showChoice(layoutOptions[i].security)>
				<div class="imageChoice">
					<label for="#currOptionName#">
						<input type="radio" name="#fqFieldName#" id="#currOptionName#" value="#currOptionName#"<cfif currentValue eq "#currOptionName#"> checked="checked"</cfif>/>
						<span>#layoutOptions[i].description#</span><br/>
						<!--- Check for if the image field is defined --->
						<cfif LEN(layoutOptions[i].image)>
							<img src="#layoutOptions[i].image#" onclick="#fqFieldName#_loadSelection('#currOptionName#');" />
						</cfif>
					</label>
				</div>
			</cfif>
		</cfloop>
	</div>
	<br style="clear: both;">
	</td>
</tr>
</cfoutput>