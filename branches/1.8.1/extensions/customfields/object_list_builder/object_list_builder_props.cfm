<!--- properties module for Object List Builder --->
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">

<cfscript>
	fieldVersion = "1.1.1"; // Variable for the version of the field - Display in Props UI
	
	// initialize some of the attributes variables
	typeid = attributes.typeid;
	prefix = attributes.prefix;
	formname = attributes.formname;
	currentValues = attributes.currentValues;
	
	// Setup the default values
	defaultValues = StructNew();
	defaultValues.componentPath = "";
	defaultValues.forceScripts = "0";
	
	// This will override the current values with the default values.
	// In normal use this should not need to be modified.
	defaultValueArray = StructKeyArray(defaultValues);
	// Create the unique id
	persistentUniqueID = '';
	valueWithoutParens = '';
	hasParens = 0;
	cfmlFilterCriteria = StructNew();
	if (NOT Len(persistentUniqueID))
		persistentUniqueID = CreateUUID();
	for(i=1;i lte ArrayLen(defaultValueArray); i++)
	{
		// If there is a default value to exists in the current values
		//	AND the current value is an empty string
		//	OR the default value does not exist in the current values
		if( ( StructKeyExists(currentValues, defaultValueArray[i]) 
				AND (NOT LEN(currentValues[defaultValueArray[i]])) )
				OR (NOT StructKeyExists(currentValues, defaultValueArray[i])) )
		{
			currentValues[defaultValueArray[i]] = defaultValues[defaultValueArray[i]];
		}
	}
</cfscript>


<cfif IsStruct(cfmlFilterCriteria)>
	<!--- Add the filter criteria to the session scope --->
	<cflock scope="session" timeout="5" type="Exclusive"> 
	    <cfscript>
			Session['#persistentUniqueID#'] = cfmlFilterCriteria;
		</cfscript>
	</cflock>
</cfif>

<cfoutput>
<script type="text/javascript">

	fieldProperties['#typeid#'].paramFields = "#prefix#componentPath,#prefix#forceScripts";


</script>
<table cellpadding="2" cellspacing="2" summary="" border="0">
	<tr>
		<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Component Name:</td>
		<td class="cs_dlgLabelSmall"><input type="text" name="#prefix#componentPath" id="#prefix#componentPath" value="#currentValues.componentPath#" size="50">
			
			<!--- <input type="text" name="#prefix#customElement" id="#prefix#customElement" value="#currentValues.customElement#" size="40"> --->
		</td>
	</tr>
	<tbody id="childInputs">
		<tr>
			<td class="cs_dlgLabelBold" valign="top" nowrap="nowrap">Force Loading Scripts:</td>
			<td class="cs_dlgLabelSmall">
				<label style="color:black;font-size:12px;font-weight:normal;">Yes <input type="radio" id="#prefix#forceScripts" name="#prefix#forceScripts" value="1" <cfif currentValues.forceScripts EQ "1">checked</cfif>></label>
				&nbsp;&nbsp;&nbsp;
				<label style="color:black;font-size:12px;font-weight:normal;">No <input type="radio" id="#prefix#forceScripts" name="#prefix#forceScripts" value="0" <cfif currentValues.forceScripts EQ "0">checked</cfif>></label>
				<br />Force the JQuery script to load.
			</td>
		</tr>
	</tbody>
	<tr>
		<td class="cs_dlgLabelSmall" colspan="2" style="font-size:7pt;">
			<hr noshade="noshade" size="1" align="center" width="98%" />
			ADF Custom Field v#fieldVersion#
		</td>
	</tr>				
</table>
</cfoutput>							