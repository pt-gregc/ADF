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

<!--- // include the standard delete-form process for a datasheet --->
<cfinclude template="#request.subsiteCache[1].url#datasheet-modules/delete-form-data.cfm">
<!--- // if we are returning then handle the delete --->
<cfif Request.Params.doDelete neq 0>
	<cfset forms = server.ADF.objectFactory.getBean("forms_1_0")>
	<cfoutput><h2>Record deleted successfully</h2></cfoutput>
	<cfoutput>#forms.closeLBAndRefresh()#</cfoutput>
</cfif>
