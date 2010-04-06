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

<!---
/* ***************************************************************
/*
Author: 	
	PaperThin, Inc. 
Name:
	Base.cfc
Summary:
	Base component for Custom Application Common Framework
History:
	2009-05-11 - MFC - Created
--->
<cfcomponent name="Base" hint="Base component for Custom Application Common Framework">

<cfproperty name="version" value="1_0_0">
	
<cffunction name="init" output="true" returntype="any">
	<cfscript>
		if(StructKeyExists(super, 'init'))
			super.init(argumentCollection=arguments);
		StructAppend(variables, arguments, false);
		return this;
	</cfscript>
</cffunction>

</cfcomponent>
