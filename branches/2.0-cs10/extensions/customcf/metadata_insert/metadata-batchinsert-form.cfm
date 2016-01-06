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
$Id: metadata-batchinsert-form.cfm,v 0.1 08-06-2007 11:00:00 paperthin Exp $

Description:
	Form used to update metadata for multiple pages at once instead of updating each page one by one
Parameters:
	none
Usage:
	none
Documentation:
	08-06-2007 - Documentation added - Queries written for MS SQL Server, will have to rewritten slightly for Oracle and MySQL
Based on:
	none
--->

<cfoutput>
<cfset strDSN = "commonspot-demo">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>

<head>
	<title>Custom Properties Batch Insert</title>
</head>

<body>

<!--- Select all available templates --->
<cfquery name="rstTemplates" datasource="#strDSN#">
	SELECT		ID, Name, Title, PageType
	FROM		SitePages
	WHERE		PageType = 1
	ORDER BY 	Title
</cfquery>

<!--- Select all the form fields for the available templates --->
<cfquery name="rstFormFields" datasource="#strDSN#">
	SELECT 		FormControl.FormName, SUBSTRING(FormInputControl.FieldName, 5, LEN(FormInputControl.FieldName)) AS FieldName, fm.FormID, 
        		FormInputControl.ID AS FieldID
	FROM 		FormControlMap AS fm
	INNER JOIN	FormControl ON fm.FormID = FormControl.ID
	INNER JOIN	FormInputControlMap ON FormControl.ID = FormInputControlMap.FormID
	INNER JOIN	FormInputControl ON FormInputControlMap.FieldID = FormInputControl.ID
	WHERE		fm.ClassConstant = 1
</cfquery>
<form action="metadata-batchinsert.cfm" method="post">
	<table cellspacing="2" cellpadding="2" border="0">
	<tr>
		<td>Parent Template:</td>
		<td>
			<!--- Display all the available templates in a drop down menu list --->
			<select name="lstTemplates">
				#server.CommonSpot.UDF.tag.optionSetFromQuery(query=rstTemplates, valuesCol="ID", displayCol="Title")#
			</select>
		</td>
	</tr>
	<tr>
		<td>Select Form and Field:</td>
		<td>
			<!--- Display the forms and their form fields --->
			<select name="lstFormFields">
				<cfloop query="rstFormFields">#server.CommonSpot.UDF.tag.option(value="#rstFormFields.FormID#,#rstFormFields.FieldID#", display="[#rstFormFields.FormName#][#rstFormFields.FieldName#]")#</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<!--- Type in the new value for the field --->
		<td align="left" width="200px">New Form Value:</td>
		<td align="left">#server.CommonSpot.UDF.tag.input(type="Text", name="txtValue")#</td>
	</tr>
	<tr>
		<td colspan="2">
			#server.CommonSpot.UDF.tag.input(type="hidden", name="txtDSN", value=strDSN)#
			#server.CommonSpot.UDF.tag.input(type="submit")#
		</td>
	</tr>
	</table>
</form>
</body>
</html>
</cfoutput>