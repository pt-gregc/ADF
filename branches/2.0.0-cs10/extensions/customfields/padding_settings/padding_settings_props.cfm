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
	PaperThin Inc.
Name:
	padding_props.cfm
Summary:
	Renders 4 input controls to capture padding values.
Version:
	1.0.0
History:
	2014-09-15 - Created
	2014-09-29 - GAC - Added Padding Value normalization to remove the label from the default values
	2015-05-12 - DJM - Updated the field version to 2.0
	2015-09-02 - DRM - Add getResourceDependencies support, bump version
--->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<cfscript>
	prefix = attributes.prefix;
	currentValues = attributes.currentValues;
	typeid = attributes.typeid;
	formname = attributes.formname;	
// writedump( var="#currentValues#", expand="no" );
	
	// Variable for the version of the field - Display in Props UI.
	fieldVersion = "2.0.3";
	
	// initialize some of the attributes variables
	top = 0;
	left = 0;
	right = 0;
	bottom = 0;
	
	showTop = 1;
	showRight = 1;
	showBottom = 1;
	showLeft = 1;
	
	// Possible Values List
	PossibleValues = '10,9,8,7,6,5,4,3,2,1,0';
	
	if( StructKeyExists(currentValues, "PossibleValues") )
		PossibleValues = application.ADF.paddingSettings.normalizePaddingValues(PaddingValues=currentValues.PossibleValues);
	
	if( StructKeyExists(currentValues, "Top") )
		top = application.ADF.paddingSettings.normalizePaddingValues(PaddingValues=currentValues.top);
	if( StructKeyExists(currentValues, "Right") )	
		right = application.ADF.paddingSettings.normalizePaddingValues(PaddingValues=currentValues.right);
	if( StructKeyExists(currentValues, "Bottom") )	
		Bottom = application.ADF.paddingSettings.normalizePaddingValues(PaddingValues=currentValues.bottom);
	if( StructKeyExists(currentValues, "Left") )	
		left = application.ADF.paddingSettings.normalizePaddingValues(PaddingValues=currentValues.left);

	if( StructKeyExists(currentValues, "ShowTop") )
		ShowTop = currentValues.ShowTop;
	if( StructKeyExists(currentValues, "ShowRight") )	
		ShowRight = currentValues.ShowRight;
	if( StructKeyExists(currentValues, "ShowBottom") )	
		ShowBottom = currentValues.ShowBottom;
	if( StructKeyExists(currentValues, "ShowLeft") )	
		Showleft = currentValues.ShowLeft;
</cfscript>

<cfoutput>
	<script type="text/javascript"]>
		fieldProperties['#typeid#'].paramFields = "#prefix#PossibleValues,#prefix#Top,#prefix#Right,#prefix#Bottom,#prefix#Left,#prefix#ShowTop,#prefix#ShowRight,#prefix#ShowBottom,#prefix#ShowLeft";
	</script>
	<table>
		<tr>
			<td class="cs_dlgLabelSmall" nowrap="nowrap" valign="top">Possible Values:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#PossibleValues" id="#prefix#PossibleValues" class="cs_dlgControl" value="#PossibleValues#" size="60">
				<br/>If Possible Values are specified, then the user is presented with a selection list of values. 
				<br/>Otherwise an input control will be presented.
				<br/><br/>
			</td>
		</tr>

		<tr>
			<td class="cs_dlgLabelSmall" nowrap="nowrap" valign="top">Show:</td>
			<td class="cs_dlgLabelSmall">
				<input type="checkbox" name="#prefix#ShowTop" id="#prefix#ShowTop" value="1" class="cs_dlgControl" <cfif ShowTop eq 1>checked="checked"</cfif>><label for="#prefix#ShowTop">Top</label> &nbsp;
				<input type="checkbox" name="#prefix#ShowRight" id="#prefix#ShowRight" value="1" class="cs_dlgControl" <cfif ShowRight eq 1>checked="checked"</cfif>><label for="#prefix#ShowRight">Right</label> &nbsp;
				<input type="checkbox" name="#prefix#ShowBottom" id="#prefix#ShowBottom" value="1" class="cs_dlgControl" <cfif ShowBottom eq 1>checked="checked"</cfif>><label for="#prefix#ShowBottom">Bottom</label> &nbsp;
				<input type="checkbox" name="#prefix#ShowLeft" id="#prefix#ShowLeft" value="1" class="cs_dlgControl" <cfif ShowLeft eq 1>checked="checked"</cfif>><label for="#prefix#ShowLeft">Left</label> &nbsp;
			</td>
		</tr>
		
		
		<tr>
			<td class="cs_dlgLabelSmall" nowrap="nowrap" valign="top">Top Default:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#Top" id="#prefix#Top" class="cs_dlgControl" value="#top#" size="4" style="text-align:right;">px
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall" nowrap="nowrap" valign="top">Right Default:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#Right" id="#prefix#Right" class="cs_dlgControl" value="#right#" size="4" style="text-align:right;">px
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall" nowrap="nowrap" valign="top">Bottom Default:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#Bottom" id="#prefix#Bottom" class="cs_dlgControl" value="#bottom#" size="4" style="text-align:right;">px
			</td>
		</tr>
		<tr>
			<td class="cs_dlgLabelSmall" nowrap="nowrap" valign="top">Left Default:</td>
			<td class="cs_dlgLabelSmall">
				<input type="text" name="#prefix#Left" id="#prefix#Left" class="cs_dlgControl" value="#left#" size="4" style="text-align:right;">px
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