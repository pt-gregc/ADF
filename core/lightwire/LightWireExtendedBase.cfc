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

<cfcomponent name="LightWireExtendedBase" extends="ADF.thirdParty.lightwire.LightWire" output="false">

<cfproperty name="version" value="1_0_0">

<cffunction name="refreshBean" access="public" returntype="void">
	<cfargument name="beanName" type="string" required="true">
	
	<cfscript>
	/* 	var key = arguments.beanName;
		// Create every singleton
  		if (variables.Config[key].Singleton)
  		{
application.cs.mx.dodump(variables.Singleton);	
			
			if(not StructKeyExists(variables.Singleton,key)) 
			{
				// Only create if hasn't already been created as dependency of earlier singleton
				variables.Singleton[key] = variables.getObject(key,"Singleton");
			}
  		} 
  	*/
  		
  		// TODO: FIX THIS!! It just reloads the entire object factory
  		application.ADF.objectFactory = createObject("component","ADF.core.lightwire.LightWireExtendedBase").init(application.ADF.beanConfig);
  		
  	</cfscript>
</cffunction>

<cffunction name="AddNewObject" returntype="any" access="public" output="false" hint="I create a object.">
	<cfargument name="ObjectName" type="string" required="yes" hint="I am the name of the object to create.">
	<cfargument name="ObjectType" type="string" required="yes" hint="I am the type of object to create. Singleton or Transient.">
	<cfscript>
		var ReturnObject = "";
		var InitStruct = StructNew();
		var TempObjectName = "";
		var Count = 0;
		var ObjectPath = "";
		var ObjectFactory = "";
		var ObjectMethod = "";
		var key = "";
		// Get any constructor properties
		If (StructKeyExists(variables.Config[arguments.ObjectName], "ConstructorProperties"))
			{InitStruct = variables.Config[arguments.ObjectName].ConstructorProperties;}
		// Get any constructor dependencies		
		If (StructCount(variables.Config[arguments.ObjectName].ConstructorDependencyStruct))
		For (Key in variables.Config[arguments.ObjectName].ConstructorDependencyStruct)
   		{
			InitStruct[variables.Config[arguments.ObjectName].ConstructorDependencyStruct[key]] = variables.getBean(Key);
   		};		


		// See whether the object has a path - if not it is a factory created bean
		If (StructKeyExists(variables.Config[arguments.ObjectName], "Path"))
		{
			// The object has a path - create it
			// Get the configured object path
			ObjectPath = "#variables.Config[arguments.ObjectName].Path#";
			If (Len(variables.LightWire.BaseClassPath) GT 0)
				ObjectPath = variables.LightWire.BaseClassPath & "." & ObjectPath;
			// if the objectPath is empty correct the dot path
			ObjectPath = Replace(ObjectPath,"..",".","all");
			
			// Create the object and initialize it
			ReturnObject = CreateObject("component",ObjectPath).init(ArgumentCollection=InitStruct);
		}
		Else
		{
			// The object doesn't have a path - get the factory info and ask the factory for it (using getSingleton to get the factory)
			ObjectFactory = getSingleton(variables.config[arguments.ObjectName].FactoryBean);
			ObjectMethod = variables.config[arguments.ObjectName].FactoryMethod;
			ReturnObject = evaluate("ObjectFactory.#ObjectMethod#(ArgumentCollection=InitStruct)");
		};

		// Give it the Lightwire methods to allow for mixin injection and annotations
		ReturnObject.lightwireMixin = variables.lightwireMixin;
		ReturnObject.lightwireGetAnnotations = variables.lightwireGetAnnotations;
	
		refreshBean(arguments.ObjectName);
	</cfscript>
	<cfreturn ReturnObject>
</cffunction>

</cfcomponent>



