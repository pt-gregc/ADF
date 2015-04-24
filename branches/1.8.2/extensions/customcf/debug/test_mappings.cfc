<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2015.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files 
in this directory, you agree to the terms and conditions of the applicable 
end user license agreement.
--->

<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
Name:
	cfmapping.cfc
Summary:
	A simple test component to verify the cfmapping for the '/ADF' is setup correctly
History:
	2009-06-11 - GAC - Created
	2011-02-09 - GAC - Removed self-closing tag slash
--->
<cfcomponent name="Test_Mapping" hint="A component to test the CF Mapping for the Application Development Framework">

	<cffunction name="verifyMapping" output="true" returntype="boolean">
		<cfreturn true>
	</cffunction>
</cfcomponent>