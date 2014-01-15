<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2014.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files 
in this directory, you agree to the terms and conditions of the applicable 
end user license agreement.
--->

<!-------------
Author: 	
	PaperThin, Inc. 
Name:
	$custom_element_select_field_filter.cfm
Summary:
	This module should be used for the ADF Custom Element Select field type.
	
	Input:
		The following 'attribute' scope variables are passed to this module.
		
			attributes.customFieldTypeID
				The ID of this custom field type.
							
			attributes.sourceFormID
				The ID of the custom element/metadata form.  
				
			attributes.sourceFieldID
				The ID of the custom element/metadata field.  Use this in combination with the attributes.sourceFormID value to 
				lookup any properties specific to this field instance.
				
			attributes.fieldNameAttributeValue
				The value to be set in the HTML output for the 'Name' attribute
		
		
	Output: 
		You must set the following 'caller' scope variables;

		
			caller.operators (Optional)
		
					This is a list of one or more operators to display for this field type.  
					Possible values are:
	
						in
						notin
						equals
						notequal
						greaterthan
						greaterthanorequals
						lessthan
						lessthanorequals
						contains
						notcontains
						within
						and
						andnot
						like
						likelist
						notlikelist
						alllist
						anylist
						alllistNOT
						anylistNOT
						inlist
						notinlist
						taxonomycontains
						taxonomynotcontains
						multitaxonomycontains
						multitaxonomynotcontains
						multitaxonomyalllist
						multitaxonomyalllistNOT
	
				If no caller.operators string is defined, or it is an empty string, the following operators will be used:
			
						equals,notequal,contains,notcontains,lessthan,lessthanorequals,greaterthan,greaterthanorequals,inlist,notinlist
				
				If your field is a text field list we recommend the default.
				If your field is a date field list we recommend the following operators:
						equals,within,lessthan,lessthanorequals,greaterthan,greaterthanorequals
				If your field is a multi-select list we recommend the following operators:
						equals,notequal,likelist,notlikelist,anylist,anylistNOT,alllist,alllistNOT
						
			caller.fieldHTML
				
					This is the HTML that will be displayed after the operator.  You must render an HTML form field with the both the 
					name and id attributes having a value of #attributes.fieldNameAttributeValue#.  
					
					For example:
						<input type="hidden" id="#attributes.fieldNameAttributeValue#" name="#attributes.fieldNameAttributeValue#" value="">
					or
						<select id="#attributes.fieldNameAttributeValue#" name="#attributes.fieldNameAttributeValue#">...</select>
			
			caller.jsSetValueFunction
				
					This is the javascript code that defines a function to be called to set the value of the field when the dialog initially loads.  
					The function needs to be named setvalue_{CustomFieldTypeID}, where CustomFieldTypeID is the ID of the custom field type. 
					The code for this function will be included once, no matter how many fields of that type are in the operators list.						
					
					For example: if your HTML outputs a simple text <input> control, the function might look like this
							function setValue_#attributes.CustomFieldTypeID#(fieldid,value)
							{
								document.getElementById(fieldid).value = value;
							}						
History:
	2014-01-14 - TP - Created						

-------------->
<cfscript>
	caller.operators = "";
	optionsStruct = StructNew();
	cfmlInputParams = '';
</cfscript>

<!--- Get the properties for the form and field IDs passed --->
<cfquery name="getProperties" datasource="#Request.Site.DataSource#">
	SELECT d2.params as InputParams, d3.FieldID, d2.fieldName
	  FROM FormInputControl d2
   	INNER JOIN FormInputControlMap d3 ON d3.FieldID = d2.ID 
	INNER JOIN FormControl d1 ON d1.ID = d3.FormID   	 
	LEFT OUTER JOIN CustomFieldTypes cft ON d2.Type = cft.Type
	 WHERE d3.FormID = #attributes.sourceFormID#
	 AND cft.ID = #attributes.customFieldTypeID#
	 AND d3.FieldID = #attributes.sourceFieldID#
</cfquery>

<cfif getProperties.RecordCount>
	<cfwddx action="wddx2cfml" input="#getProperties.InputParams#" output="cfmlInputParams">
	
	<cfscript>
		if (cfmlInputParams.CustomElement NEQ '' AND cfmlInputParams.DisplayField NEQ '' AND cfmlInputParams.ValueField NEQ '')
			optionsStruct = createOptionsStructure(propertiesStruct=cfmlInputParams); // Call function that would buid up the options struct
			
		if( NOT StructKeyExists( cfmlInputParams,'MultipleSelect' ) )
			cfmlInputParams.MultipleSelect = 0;			
	</cfscript>
</cfif>

<cfsavecontent variable="fieldHTML">
	<cfif StructCount(optionsStruct)>
		<cfoutput><select name="#attributes.fieldNameAttributeValue#" id="#attributes.fieldNameAttributeValue#" style="font-family:#Request.CP.Font#;font-size:10" multiple="#cfmlInputParams.MultipleSelect#"></cfoutput>
		<cfloop collection="#optionsStruct#" item="i">
			<cfoutput><option value="#optionsStruct[i]#">#i#</option></cfoutput>
		</cfloop>
		<cfoutput></select></cfoutput>
	<cfelse>
		<cfoutput>No values found</cfoutput>
	</cfif>
</cfsavecontent>
<cfset caller.fieldHTML = fieldHTML>

<cfsavecontent variable="jsSetValue">
	<cfif StructCount(optionsStruct)>
		<cfoutput>
		function setValue_#attributes.CustomFieldTypeID#(fieldid,values)
		{
			var selectObj = document.getElementById(fieldid);
			var valuesArr = values.split(',');

			for (var j=0; j<valuesArr.length; j++)
			{
				 for (var i = 0; i < selectObj.options.length; i++)
			    {
			        if (selectObj.options[i].value == valuesArr[j])
			        {
			            selectObj.options[i].selected = true;
			            break;
			        }
			    }
			}
		}
		</cfoutput>
	<cfelse>
	<cfoutput>
		function setValue_#attributes.CustomFieldTypeID#(fieldid,value)
		{
			return;
		}
	</cfoutput>
	</cfif>
</cfsavecontent>
<cfset caller.jsSetValueFunction = jsSetValue>

<cffunction name="createOptionsStructure" returntype="struct" hint="Creates the data-display pair for the options of the selection list" output="Yes">
	<cfargument name="propertiesStruct" type="struct" required="yes" hint="Input the properties values">
		
	<cfscript>
		var cfmlInputParams = arguments.propertiesStruct;
		var optionsStruct = StructNew();
		var i = 0;
		var value = 0;
		var display = '';
		var recs = ArrayNew(1);

		// get the records for this custom element
		recs = application.adf.cedata.getCEData( cfmlInputParams.CustomElement ); 
	
		for( i=1; i lte ArrayLen(recs); i=i+1 )
		{
			display = recs[i].values[cfmlInputParams.DisplayField];
			value = recs[i].values[cfmlInputParams.ValueField];
		
			if( NOT StructKeyExists( optionsStruct, display ) )
			{
				optionsStruct[ display ] = value;
			}	
		}
	</cfscript>	
	
	<cfreturn optionsStruct>
</cffunction>