<!---
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.
 
The Original Code is comprised of the ADF directory
 
The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2016.
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
	page_layout_render.cfc
Summary:
	Custom field to render predefined page layout options in metadata forms.
History:
	2010-09-09 - GAC/MFC - 	Created
	2010-11-11 - MFC - 		Added onclick to the img to select the radio button. 
								Due to problem reported with Mac browser and label 
								select is not checking the radio field.
	2011-03-28 - MFC - Added check for if the photo URL is defined.
	2015-05-11 - DJM - Converted to CFC
	2015-09-11 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean() 
--->
<cfcomponent displayName="PageLayout Render" extends="ADF.extensions.customfields.adf-form-field-renderer-base">

<cffunction name="renderControl" returntype="void" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
		var inputParameters = Server.CommonSpot.UDF.util.duplicateBean(arguments.parameters);
		var currentValue = arguments.value;	// the field's current value	 
		var layoutOptions = ArrayNew(1);
		var newOption = structNew();
		var currOptionName = '';
		var i = 0;
		
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
		
		renderStyles(argumentCollection=arguments);	
	</cfscript>
	
	<cfoutput>
		<div class="main">
			<cfscript>
				application.ADF.scripts.loadJQuery();
			</cfscript>
	</cfoutput>
	<cfscript>
		renderJSFunctions(argumentCollection=arguments);
	</cfscript>
	<cfoutput>
			<!--- Loop over the array of options --->
			<cfloop index="i" from="1" to="#ArrayLen(layoutOptions)#" >
				<!--- Set the current option name b/c we use it multiple times --->
				<cfset currOptionName = layoutOptions[i].name>
				<!--- Check if we have permissions to use this layout option --->
				<cfif showChoice(layoutOptions[i].security)>
					<div class="imageChoice">
						<label for="#currOptionName#">
							<input type="radio" name="#arguments.fieldName#" id="#currOptionName#" value="#currOptionName#"<cfif currentValue eq "#currOptionName#"> checked="checked"</cfif>/>
							<span>#layoutOptions[i].description#</span><br/>
							<!--- Check for if the image field is defined --->
							<cfif LEN(layoutOptions[i].image)>
								<img src="#layoutOptions[i].image#" onclick="#arguments.fieldName#_loadSelection('#currOptionName#');" />
							</cfif>
						</label>
					</div>
				</cfif>
			</cfloop>
		</div>
		<br style="clear: both;">
	</cfoutput>
</cffunction>

<cffunction name="renderStyles" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfoutput>
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
	</cfoutput>
</cffunction>

<cffunction name="renderJSFunctions" returntype="void" access="private">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="fieldDomID" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfoutput>
<script type="text/javascript">
<!--
function #arguments.fieldName#_loadSelection(optionName) {
	var fieldOptionName = "input###arguments.fieldName#_" + optionName;
	// Set the current options radio button to selected
	jQuery(fieldOptionName).attr("checked", "checked");
}
//-->
</script>
</cfoutput>
</cffunction>

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


<cfscript>
	public string function getResourceDependencies()
	{
		return listAppend(super.getResourceDependencies(), "jQuery");
	}
</cfscript>

</cfcomponent>