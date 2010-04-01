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

<cfscript>
	// the fields current value
	currentValue = attributes.currentValues[fqFieldName];
	// the param structure which will hold all of the fields from the props dialog
	xparams = parameters[fieldQuery.inputID];

	// variables for Group Names (makes it easier to see who is bound where)
	constants.HomeAdmins = 9;
	constants.LandingAdmins = 8;

	// establish the security framework for access to the different sections
	accessStruct = structNew();
	accessStruct["Full Width"] = "";
	accessStruct["Equal Width"] = "";
	accessStruct["Right Channel"] = "";
	accessStruct["Landing"] = "#constants.LandingAdmins#";
	accessStruct["Home"] = "#constants.HomeAdmins#";

	fakeList = 9;
</cfscript>

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
			margin: 2px;
			float:left;
		}
		.imageChoice input{
			text-align: center;
		}
		.imageChoice img{
			background-color: ##c0c0c0;
			width: 100px;
			height: 120px;
		}
		.imageChoice span{
			font-size: 10px;
		}
		.main {
			width: 320px;
		}
	</style>

	<div class="main">
		<cfif showChoice("Full Width")>
			<div class="imageChoice">
				<input type="radio" name="#fqFieldName#" id="full_width" value="Full width" checked="checked"/> <span>Full width</span><br/>
				<label for="full_width">
				<img src="/ADF/extensions/customfields/page_layout/thumbs/full_width.gif"/>
				</label>
			</div>
		</cfif>
		<cfif showChoice("Equal Width")>
			<div class="imageChoice">
				<input type="radio" name="#fqFieldName#" id="equal_width" value="Equal width"<cfif currentValue eq "Equal width"> checked="checked"</cfif>/> <span>Equal width</span><br/>
				<label for="equal_width">
				<img src="/ADF/extensions/customfields/page_layout/thumbs/equal_width.gif"/>
				</label>
			</div>
		</cfif>
		<cfif showChoice("Right Channel")>
			<div class="imageChoice">
				<input type="radio" name="#fqFieldName#" id="right_channel" value="Right Channel"<cfif currentValue eq "Right channel"> checked="checked"</cfif>/> <span>Right channel</span><br/>
				<label for="right_channel">
				<img src="/ADF/extensions/customfields/page_layout/thumbs/right_channel.gif"/>
				</label>
			</div>
		</cfif>
		<cfif showChoice("Landing")>
			<div class="imageChoice">
				<input type="radio" name="#fqFieldName#" id="landing" value="Landing"<cfif currentValue eq "Landing"> checked="checked"</cfif>/> <span>Landing</span><br/>
				<label for="landing">
				<img src="/ADF/extensions/customfields/page_layout/thumbs/landing.gif"/>
				</label>
			</div>
		</cfif>
		<cfif showChoice("Home")>
			<div class="imageChoice">
				<input type="radio" name="#fqFieldName#" id="home" value="Home"<cfif currentValue eq "Home"> checked="checked"</cfif>/> <span>Home</span><br/>
				<label for="home">
				<img src="/ADF/extensions/customfields/page_layout/thumbs/home.gif"/>
				</label>
		</div>
		</cfif>
		<!--- <div class="imageChoice">
			<img src="/ADF/extensions/customfields/page_layout/thumbs/"/>
			<input type="radio" name="#fqFieldName#" value="Full width"/>
		</div> --->
	</div>
	<br style="clear: both;">
</cfoutput>
<cffunction name="showChoice" access="public" returntype="boolean" output="true">
	<cfargument name="choice">
	<cfscript>
		var showChoice = "true";
		var itm = 1;
		var groupID = 0;
		if( listLen(accessStruct["#arguments.choice#"]) )
		{
			// reset value to false then determine if they have access
			showChoice = "false";
			for( itm; itm lte listLen(accessStruct[arguments.choice]); itm = itm + 1 )
			{
				if( listFind(request.user.groupList, listGetAt(accessStruct[arguments.choice], itm) ) )
				{
					showChoice = "true";
					break;
				}
			}
		}
	</cfscript>
	<cfreturn showChoice>
</cffunction>