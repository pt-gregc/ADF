<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2011.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files 
in this directory, you agree to the terms and conditions of the applicable 
end user license agreement.
--->

<cfcomponent name="BeanConfig" extends="ADF.core.lightwire.LightWireConfigExtendedBase" hint="A LightWire configuration bean.">
<!--- 
BEAN DEFINITION SYNTAX
SINGLETONS:
addSingleton(FullClassPath, NameList)
Adds the definition for a given Singleton to the config file.
- FullClassPath:string:required - The full class path to the bean including its name. E.g. for com.UserService.cfc it would be com.UserService. 
- BeanName:string:optional - An optional name to be able to use to refer to this bean. If you don't provide this, the name of the bean will be used as a default. E.g. for com.UserService, it'll be named UserService unless you put something else here. If you put UserS, it'd be available as UserS, but NOT as UserService.

addSingletonFromFactory(FactoryBean, FactoryMethod, BeanName)
Adds the definition for a given Singleton that is created by a factory to the config file.
- FactoryBean:string:required - The name of the factory to use to create this bean (the factory must also have been defined as a Singleton in the LightWire config file).
- FactoryMethod:string:required - The name of the method to call on the factory bean to create this bean.
- BeanName:string:required - The required name to use to refer to this bean. 

TRANSIENTS:
addTransient(FullClassPath, NameList)
Adds the definition for a given Transient to the config file.
- FullClassPath:string:required - The full class path to the bean including its name. E.g. for com.UserBean.cfc it would be com.UserBean.
- BeanName:string:optional - An optional name to be able to use to refer to this bean. If you don't provide this, the name of the bean will be used as a default. E.g. for com.UserBean, it'll be named UserService unless you put something else here. If you put User, it'd be available as User, but NOT as UserBean.

addTransientFromFactory(FactoryBean, FactoryMethod, BeanName)
Adds the definition for a given Transient that is created by a factory to the config file.
- FactoryBean:string:required - The name of the factory to use to create this bean (the factory must also have been defined as a Singleton in the LightWire config file).
- FactoryMethod:string:required - The name of the method to call on the factory bean to create this bean.
- BeanName:string:required - The required name to use to refer to this bean. 

BEAN Dependency and PROPERTIES
Once you have defined a given bean, you also want to describe its Dependency and properties. Any bean can have 0..n constructor, setter and/or mixin Dependency and properties. Dependency handle LightWire initialized objects that need to be injected into your beans. Properties handle all other elements (strings, bits, structs, etc.). Please note: constructor Dependency are passed to the init() method, so you need a correspondingly named argument in your init file. Setter Dependency are injected using set#BeanName#() after calling the init() method but before returning the bean, so you need to have the appropriate setter. Mixin injections are auto injected into variables scope for you after calling the init() method but before returning the bean, but you don't need to have a setter() method - it used a generic setter injected automatically into all of your beans (lightwireMixin()).


addConstructorDependency(BeanName, InjectedBeanName, PropertyName)
Adds one or more constructor Dependency to a bean. If you call this more than once on the same bean, the additional Dependency will just be added to the list so it is valid to call this multiple times to build up a dependency list if required.
- BeanName:string:required - The name of the bean (Singleton or Transient) to add the Dependency to. You MUST have defined the bean using addSingleton() AddTransient(), addSingletonFromFactory() or addTransientFromFactory() before you add Dependency to the bean.
- InjectedBeanName:string:required - The name of the bean to inject.
- PropertyName:string:optional - The optional property name to pass the bean into. Defaults to the bean name if not provided.

addSetterDependency(BeanName, InjectedBeanName, PropertyName)
Adds one or more setter Dependency to a bean. If you call this more than once on the same bean, the additional Dependency will just be added to the list so it is valid to call this multiple times to build up a dependency list if required.
- BeanName:string:required - The name of the bean (Singleton or Transient) to add the Dependency to. You MUST have defined the bean using addSingleton() AddTransient(), addSingletonFromFactory() or addTransientFromFactory() before you add Dependency to the bean.
- InjectedBeanName:string:required - The name of the bean to inject.
- PropertyName:string:optional - The optional property name to pass the bean into. Defaults to the bean name if not provided.

addMixinDependency(BeanName, InjectedBeanName, PropertyName)
Adds one or more mixin Dependency to a bean. If you call this more than once on the same bean, the additional Dependency will just be added to the list so it is valid to call this multiple times to build up a dependency list if required.
- BeanName:string:required - The name of the bean (Singleton or Transient) to add the Dependency to. You MUST have defined the bean using addSingleton() AddTransient(), addSingletonFromFactory() or addTransientFromFactory() before you add Dependency to the bean.
- InjectedBeanName:string:required - The name of the bean to inject.
- PropertyName:string:optional - The optional property name to pass the bean into. Defaults to the bean name if not provided.

addConstructorProperty(PropertyName, PropertyValue)
Adds a constructor property to a bean. 
- BeanName:string:required - The name of the bean (Singleton or Transient) to add the property to. You MUST have defined the bean using addSingleton() AddTransient(), addSingletonFromFactory() or addTransientFromFactory() before you add properties to the bean.
- PropertyName:string:required - The name of the property to add.
- PropertyValue:any:required - The value of the property to add. Can be of any simple or complex type (anything from a string or a boolean to a struct or even an object that isn't being managed by LightWire).

addSetterProperty(PropertyName, PropertyValue)
Adds a setter property to a bean. 
- BeanName:string:required - The name of the bean (Singleton or Transient) to add the property to. You MUST have defined the bean using addSingleton() AddTransient(), addSingletonFromFactory() or addTransientFromFactory() before you add properties to the bean.
- PropertyName:string:required - The name of the property to add.
- PropertyValue:any:required - The value of the property to add. Can be of any simple or complex type (anything from a string or a boolean to a struct or even an object that isn't being managed by LightWire).

addMixinProperty(PropertyName, PropertyValue)
Adds a constructor property to a bean. 
- BeanName:string:required - The name of the bean (Singleton or Transient) to add the property to. You MUST have defined the bean using addSingleton() AddTransient(), addSingletonFromFactory() or addTransientFromFactory() before you add properties to the bean.
- PropertyName:string:required - The name of the property to add.
- PropertyValue:any:required - The value of the property to add. Can be of any simple or complex type (anything from a string or a boolean to a struct or even an object that isn't being managed by LightWire).
--->

<cfproperty name="version" value="1_5_0">

<cffunction name="init" output="true" returntype="any" hint="I initialize the config bean.">
	
	<cfscript>
		// LIGHTWIRE BEAN CONFIG CODE
		// Call the base init() method to set sensible defaults. Do NOT remove this.
		Super.init();
		// OPTIONAL: Set lazy loading: true or false. If true, Singletons will only be created when requested. If false, they will all be created when LightWire is first initialized. Default if you don't set: LazyLoad = true.
		setLazyLoad("false");
		
		/*
		 *
		 *		ADF CONFIGURATION CODE
		 *
		 *		
		 */
		
		/*
		 *	Build bean objects for all components in the ADF\LIB directory
		 *		directoryPath = Directory to recurse for component files
		 *		excludeSubDirs = Director names to exclude
		 *		objFactoryType = Variable space to load the ADF Lib
		 */
		loadADFLibComponents(directoryPath="ADF/lib/", objFactoryType="server");
		
		/*
		 *	Load the singleton for the Core Config file
		 */
		addSingleton("ADF.core.Config", "CoreConfig");
		
		/*
		 *	Load the ADF application bean configuration files (appBeanConfig.cfc)
		 */
		loadADFAppBeanConfig();
	</cfscript>
	<cfreturn THIS>
</cffunction>

</cfcomponent>