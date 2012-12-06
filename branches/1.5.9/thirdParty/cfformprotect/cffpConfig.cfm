<cfset iniPath = "#Request.site.csAppsDir#config/">

<!--- Load the ini file into a structure in the application scope --->

<cfif NOT StructKeyExists(application,'cfformprotect')>
	<cfset application.cfformprotect = structNew()>
</cfif>

<cfif NOT StructKeyExists(application.cfformprotect,'config')>
	<cfset application.cfformprotect.iniFileStruct = getProfileSections("#iniPath#/cffp.ini.cfm")>
	<cfset application.cfformprotect.iniFileEntries = application.cfformprotect.iniFileStruct["CFFormProtect"]>
	<cfset application.cfformprotect.config = structNew()>
	<cfloop list="#application.cfformprotect.iniFileEntries#" index="iniEntry">
		<cfset application.cfformprotect.config[iniEntry] = getProfileString("#iniPath#/cffp.ini.cfm","CFFormProtect",iniEntry)>
	</cfloop>
</cfif>

<!---<cfdump var="#application.cfformprotect#" label="application.cfformprotect - cffpConfig.cfm" expand="no">--->