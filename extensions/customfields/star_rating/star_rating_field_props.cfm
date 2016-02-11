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
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Custom Field Type:
	Star Rating Custom Field Type
Name:
	star_rating_field_props.cfm
Summary:
	Custom field to render the JQuery UI star ratings.
ADF Requirements:
	scripts_1_0
History:
	2009-11-16 - MFC - Created
	2011-02-02 - RAK - Updated to allow for customizing number of stars and half stars
	2014-01-02 - GAC - Added the CFSETTING tag to disable CF Debug results in the props module
	2014-01-03 - GAC - Added the fieldVersion variable
	2015-05-20 - DJM - Modified the fieldVersion variable to be 2.0
	2015-09-02 - DRM - Add getResourceDependencies support, bump version
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<cfscript>
	// Variable for the version of the field - Display in Props UI.
	fieldVersion = "2.0.4";
	
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
	if( not structKeyExists(currentValues, "numberOfStars") )
		currentValues.numberOfStars = 5;
	if( not structKeyExists(currentValues, "halfStars") )
		currentValues.halfStars = 0;
</cfscript>
<cfoutput>
	<script type="text/javascript">
		fieldProperties['#typeid#'].paramFields = "#prefix#numberOfStars,#prefix#halfStars";
	</script>
	<table>
		<tr>
			<td class="cs_dlgLabelSmall">Number of Stars</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#numberOfStars" id="#prefix#numberOfStars" value="#currentValues.numberOfStars#" size="5">
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall">Half Stars</td>
			<td class="cs_dlgLabelSmall">
	
				<input type="radio" name="#prefix#halfStars" value="1" id="#prefix#halfStars1" <cfif currentValues.halfStars>checked="checked"</cfif>><label for="#prefix#halfStars1">On</label> <br/>
				<input type="radio" name="#prefix#halfStars" value="0" id="#prefix#halfStars0" <cfif !currentValues.halfStars>checked="checked"</cfif>><label for="#prefix#halfStars0">Off</label>
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall" colspan="2" style="font-size:7pt;">
				<hr />
				ADF Custom Field v#fieldVersion#
			</td>
		</tr>
	</table>
</cfoutput>