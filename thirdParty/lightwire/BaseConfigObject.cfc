<cfcomponent name="BaseConfigObject">

<cffunction name="init" returntype="any" hint="I initialize default LightWire config properties." output="false">
	<cfscript>
		setLazyLoad("true");
	</cfscript>
	<cfreturn THIS>
</cffunction>

<cffunction name="setLazyLoad" returntype="void" hint="I set whether Singletons should or shouldn't be laxy loaded." output="false">
	<cfargument name="LazyLoad" required="true" type="boolean" hint="Whether or not to use lazy loading of Singletons.">
	<cfset variables.LazyLoad = LazyLoad>
</cffunction>

<cffunction name="getLazyLoad" returntype="boolean" hint="I return whether Singletons should or shouldn't be lazy loaded." output="false">
	<cfreturn variables.LazyLoad>
</cffunction>

<cffunction name="addSingleton" returntype="void" hint="I add the configuration properties for a Singleton." output="false">
	<cfargument name="FullClassPath" required="true" type="string" hint="The full class path to the bean including its name. E.g. for com.UserService.cfc it would be com.UserService.">
	<cfargument name="BeanName" required="false" default="" type="string" hint="An optional name to be able to use to refer to this bean. If you don't provide this, the name of the bean will be used as a default. E.g. for com.UserService, it'll be named UserService unless you put something else here. If you put UserS, it'd be available as UserS, but NOT as UserService.">
	<cfargument name="InitMethod" required="false" default="" type="string" hint="A default custom initialization method for LightWire to call on the bean after constructing it fully (including setter and mixin injection) but before returning it.">
	<cfscript>
		addBean(FullClassPath, BeanName, 1, InitMethod);
	</cfscript>
</cffunction>

<!---
History:
	2015-07-10 - GAC - Fixed line wrapping of cfscript tag 
--->
<cffunction name="addTransient" returntype="void" hint="I add the configuration properties for a Transient." output="false">
	<cfargument name="FullClassPath" required="true" type="string" hint="The full class path to the bean including its name. E.g. for com.User.cfc it would be com.User.">
	<cfargument name="BeanName" required="false" default="" type="string" hint="An optional name to be able to use to refer to this bean. If you don't provide this, the name of the bean will be used as a default. E.g. for com.User, it'll be named User unless you put something else here. If you put UserBean, it'd be available as UserBean, but NOT as User.">
	<cfargument name="InitMethod" required="false" default="" type="string" hint="A default custom initialization method for LightWire to call on the bean after constructing it fully (including setter and mixin injection) but before returning it.">	
	<cfscript>
		addBean(FullClassPath, BeanName, 0, InitMethod);
	</cfscript>
</cffunction>

<!---
History:
	2015-07-10 - GAC - Fixed line wrapping of cfscript tag
--->
<cffunction name="addBean" returntype="void" hint="I add the configuration properties for a Singleton or Transient." output="false">
	<cfargument name="FullClassPath" required="true" type="string" hint="The full class path to the bean including its name. E.g. for com.UserService.cfc it would be com.UserService.">
	<cfargument name="BeanName" required="false" default="" type="string" hint="An optional name to be able to use to refer to this bean. If you don't provide this, the name of the bean will be used as a default. E.g. for com.UserService, it'll be named UserService unless you put something else here. If you put UserS, it'd be available as UserS, but NOT as UserService.">
	<cfargument name="Singleton" required="true" hint="Whether the bean is a Singleton (1) or Transient(0).">
	<cfargument name="InitMethod" required="false" default="" type="string" hint="A default custom initialization method for LightWire to call on the bean after constructing it fully (including setter and mixin injection) but before returning it.">
	<cfscript>
		// Default the name to the name of the bean if no name list is provided.
		If (Len(trim(BeanName)) LT 1)
		{
			BeanName = ListLast(FullClassPath,".");
		};
		// Set the config properties for the Singleton
		// Create the necessary struct
		variables.config[BeanName] = StructNew();
		// Set it as a Singleton
		variables.config[BeanName].Singleton = Singleton;
		// Set the path
		variables.config[BeanName].Path = FullClassPath;
		// Save the initi method
		variables.config[BeanName].InitMethod = InitMethod;
		// Initialize the dependency lists
		variables.config[BeanName].ConstructorDependencies = "";
		variables.config[BeanName].SetterDependencies = "";
		variables.config[BeanName].MixinDependencies = "";
		variables.config[BeanName].ConstructorDependencyStruct = StructNew();
		variables.config[BeanName].SetterDependencyStruct = StructNew();
		variables.config[BeanName].MixinDependencyStruct = StructNew();
	</cfscript>
</cffunction>

<cffunction name="addSingletonFromFactory" returntype="void" hint="Adds the definition for a given Singleton that is created by a factory to the config file." output="false">
	<cfargument name="FactoryBean" required="true" type="string" hint="The name of the factory to use to create this bean (the factory must also have been defined as a Singleton in the LightWire config file).">
	<cfargument name="FactoryMethod" required="true" type="string" hint="The name of the method to call on the factory bean to create this bean.">
	<cfargument name="BeanName" required="true" type="string" hint="The required name to use to refer to this bean.">
	<cfscript>
		addBeanFromFactory(FactoryBean, FactoryMethod, BeanName, 1);
	</cfscript>
</cffunction>

<cffunction name="addTransientFromFactory" returntype="void" hint="Adds the definition for a given Transient that is created by a factory to the config file." output="false">
	<cfargument name="FactoryBean" required="true" type="string" hint="The name of the factory to use to create this bean (the factory must also have been defined as a Singleton in the LightWire config file).">
	<cfargument name="FactoryMethod" required="true" type="string" hint="The name of the method to call on the factory bean to create this bean.">
	<cfargument name="BeanName" required="true" type="string" hint="The required name to use to refer to this bean.">
	<cfscript>
		addBeanFromFactory(FactoryBean, FactoryMethod, BeanName, 0);
	</cfscript>
</cffunction>

<cffunction name="addBeanFromFactory" returntype="void" hint="I add the configuration properties for a Singleton or Transient that is created by a factory to the config file." output="false">
	<cfargument name="FactoryBean" required="true" type="string" hint="The name of the factory to use to create this bean (the factory must also have been defined as a Singleton in the LightWire config file).">
	<cfargument name="FactoryMethod" required="true" type="string" hint="The name of the method to call on the factory bean to create this bean.">
	<cfargument name="BeanName" required="true" type="string" hint="The required name to use to refer to this bean.">
	<cfargument name="Singleton" required="true" hint="Whether the bean is a Singleton (1) or Transient(0).">
	<cfscript>
		// Set the config properties for the Singleton
		// Create the necessary struct
		variables.config[BeanName] = StructNew();
		// Set it as a Singleton
		variables.config[BeanName].Singleton = Singleton;
		// Set the Factory bean
		variables.config[BeanName].FactoryBean = FactoryBean;
		// Set the Factory method
		variables.config[BeanName].FactoryMethod = FactoryMethod;
		// Initialize the dependency lists
		variables.config[BeanName].ConstructorDependencies = "";
		variables.config[BeanName].SetterDependencies = "";
		variables.config[BeanName].MixinDependencies = "";
	</cfscript>
</cffunction>

<cffunction name="addConstructorDependency" returntype="void" hint="I add a constructor object dependency for a bean." output="false">
	<cfargument name="BeanName" required="true" type="string" hint="The name of the bean to set the constructor dependencies for.">
	<cfargument name="InjectedBeanName" required="true" default="" type="string" hint="The name of the bean to inject.">
	<cfargument name="PropertyName" required="false" default="" type="string" hint="The optional property name to pass the bean into. Defaults to the bean name if not provided.">
	<cfscript>
		// Add the constructor dependencies
		variables.config[BeanName].ConstructorDependencies = ListAppend(variables.config[BeanName].ConstructorDependencies, InjectedBeanName);
		If (len(PropertyName) LT 1)
		{PropertyName = InjectedBeanName;};
		variables.config[BeanName].ConstructorDependencyStruct[InjectedBeanName] = PropertyName;
	</cfscript>
</cffunction>

<cffunction name="addSetterDependency" returntype="void" hint="I add a setter dependency for a bean." output="false">
	<cfargument name="BeanName" required="true" type="string" hint="The name of the bean to set the setter dependencies for.">
	<cfargument name="InjectedBeanName" required="true" default="" type="string" hint="The name of the bean to inject.">
	<cfargument name="PropertyName" required="false" default="" type="string" hint="The optional property name to pass the bean into. Defaults to the bean name if not provided.">
	<cfscript>
		// Add the setter dependencies
		variables.config[BeanName].SetterDependencies = ListAppend(variables.config[BeanName].SetterDependencies, InjectedBeanName);
		If (len(PropertyName) LT 1)
		{PropertyName = InjectedBeanName;};
		variables.config[BeanName].SetterDependencyStruct[InjectedBeanName] = PropertyName;
	</cfscript>
</cffunction>

<cffunction name="addMixinDependency" returntype="void" hint="I add a mixin dependency for a bean." output="false">
	<cfargument name="BeanName" required="true" type="string" hint="The name of the bean to set the mixin dependencies for.">
	<cfargument name="InjectedBeanName" required="true" default="" type="string" hint="The name of the bean to inject.">
	<cfargument name="PropertyName" required="false" default="" type="string" hint="The optional property name to pass the bean into. Defaults to the bean name if not provided.">
	<cfscript>
		// Add the mixin dependencies
		variables.config[BeanName].MixinDependencies = ListAppend(variables.config[BeanName].MixinDependencies, InjectedBeanName);
		If (len(PropertyName) LT 1)
		{PropertyName = InjectedBeanName;};
		variables.config[BeanName].MixinDependencyStruct[InjectedBeanName] = PropertyName;
	</cfscript>
</cffunction>

<cffunction name="addConstructorProperty" returntype="void" hint="I add a constructor property of any type to a bean." output="false">
	<cfargument name="BeanName" required="true" type="string" hint="The name of the bean to add the property to.">
	<cfargument name="PropertyName" required="true" type="string" hint="The name of the property to set.">
	<cfargument name="PropertyValue" required="true" type="any" hint="The value of the property to set.">
	<cfscript>
		// Add the constructor property
		variables.config[BeanName].ConstructorProperties[PropertyName] = PropertyValue;
	</cfscript>
</cffunction>

<cffunction name="addSetterProperty" returntype="void" hint="I add a setter property of any type to a bean." output="false">
	<cfargument name="BeanName" required="true" type="string" hint="The name of the bean to add the property to.">
	<cfargument name="PropertyName" required="true" type="string" hint="The name of the property to set.">
	<cfargument name="PropertyValue" required="true" type="any" hint="The value of the property to set.">
	<cfscript>
		// Add the setter property
		variables.config[BeanName].SetterProperties[PropertyName] = PropertyValue;
	</cfscript>
</cffunction>

<cffunction name="addMixinProperty" returntype="void" hint="I add a mixin property of any type to a bean." output="false">
	<cfargument name="BeanName" required="true" type="string" hint="The name of the bean to add the property to.">
	<cfargument name="PropertyName" required="true" type="string" hint="The name of the property to set.">
	<cfargument name="PropertyValue" required="true" type="any" hint="The value of the property to set.">
	<cfscript>
		// Add the mixin property
		variables.config[BeanName].MixinProperties[PropertyName] = PropertyValue;
	</cfscript>
</cffunction>

<cffunction name="getConfigStruct" returntype="struct" hint="I provide LightWire with the properly configured configuration struct to operate on." output="false">
	<cfreturn variables.config>
</cffunction>

<cffunction name="parseXMLConfigFile" returntype="void" hint="I take the path to a ColdSpring XML config file and use it to set all of the necessary LightWire config properties." output="false">
	<cfargument name="XMLFilePath" required="true" type="string" hint="The path to the XML config file.">
	<cfargument name="properties" required="false" type="struct" hint="A struct of default properties to be used in place of ${key} in XML config file.">
	<cfscript>
		var i = 0;
		// parse coldspring xml bean config
		var xml = XMLParse(arguments.XMLFilePath,false);
		// use XMLSearch to create array of all bean defs
		var beans = XMLSearch(xml,'/beans/bean');
		// loop over beans to create singleton or transient
		For (i = 1; i lte ArrayLen(beans); i = i + 1)
		{
			if (structKeyExists(arguments,"properties"))
			{
				translateBean(beans[i],arguments.properties);
			}
			else
			{
				translateBean(beans[i]);
			}
		}
	</cfscript>
</cffunction>

<cffunction name="translateBean" access="private" output="false" returntype="void" hint="I translate ColdSpring XML bean definitiions to LightWire config.">
	<cfargument name="bean" type="xml" required="true">
	<cfargument name="props" type="struct" required="false">
	<cfscript>
		var beanStruct = StructNew();
		var Key = "";
		// loop over bean tag attributes and create beanStruct keys
		For (key in bean.XmlAttributes)
		{
			if (key eq "factory-bean")
			{
				beanStruct.FactoryBean = bean.XmlAttributes[key];
			};
			if (key eq "factory-method")
			{
				beanStruct.FactoryMethod = bean.XmlAttributes[key];
			};
			if (key eq "singleton")
			{
				beanStruct.Singleton = bean.XmlAttributes[key];
			};
			if (key eq "class")
			{
				beanStruct.FullClassPath = bean.XmlAttributes[key];
			};
			if (key eq "id")
			{
				beanStruct.BeanName = bean.XmlAttributes[key];
			};
			if (key eq "init-method")
			{
				beanStruct.InitMethod = bean.XmlAttributes[key];
			};
			
		};
		// if Singleton is not defined, or if beanStruct has a key Singleton eq false, create transient 
		if (not (structKeyExists(beanStruct,"Singleton")) or (not beanStruct.Singleton))
		{
			// if beanStruct contains key FactoryBean, then create transient from factory 
			if (structKeyExists(beanStruct,"FactoryBean"))
			{
				addTransientFromFactory(argumentCollection=beanStruct);
			}
			else
			{
				addTransient(argumentCollection=beanStruct);
			};
		}
		else
		{
			// if beanStruct contains key FactoryBean, then create singleton from factory
			if (structKeyExists(beanStruct,"FactoryBean"))
			{
				addSingletonFromFactory(argumentCollection=beanStruct);
			}
			else
			{
				addSingleton(argumentCollection=beanStruct);
			};
		};
		
		if (structKeyExists(arguments,"props"))
		{
			// add constructor dependecies and properties
			translateBeanChildren(arguments.bean,'constructor-arg',arguments.props);
			// add setter dependecies and properties
			translateBeanChildren(arguments.bean,'property',arguments.props);
			// add mixin dependecies and properties
			translateBeanChildren(arguments.bean,'mixin',arguments.props);
		}
		else
		{
			// add constructor dependecies and properties
			translateBeanChildren(arguments.bean,'constructor-arg');
			// add setter dependecies and properties
			translateBeanChildren(arguments.bean,'property');
			// add mixin dependecies and properties
			translateBeanChildren(arguments.bean,'mixin');
		}
		
	</cfscript>
</cffunction>

<cffunction name="translateBeanChildren" access="private" output="false" returntype="void">
	<cfargument name="bean" type="XML" required="true">
	<cfargument name="childTagName" type="string" required="true">
	<cfargument name="props" type="struct" required="false">
	<cfscript>
		var children = "";
		var entries = "";
		var hashMap = "";
		var property = "";
		var key = "";
		var i = 1;
		var j = 1;
		// find all constructor properties and dependencies
		children = XMLSearch(bean,arguments.childTagName);
		for (i = 1; i lte ArrayLen(children); i = i + 1)
		{
			// child element "value"
			if (structKeyExists(children[i],"value"))
			{
				if ((structKeyExists(arguments,"props")) and (structKeyExists(arguments.props,children[i].XmlAttributes["name"]))) 
				{
					property = arguments.props[#ReplaceList(children[i].value.XmlText,"${,}",",")#];
				}
				else
				{
					property = children[i].value.XmlText;
				};
				switch (arguments.childTagName) 
				{
					case 'constructor-arg' :
					{
						addConstructorProperty(bean.XmlAttributes["id"],children[i].XmlAttributes["name"],property);
					};
					break;
					case 'property' :
					{
						addSetterProperty(bean.XmlAttributes["id"],children[i].XmlAttributes["name"],property);
					};
					break;
					case 'mixin' :
					{
						addMixinProperty(bean.XmlAttributes["id"],children[i].XmlAttributes["name"],property);
					};
					break;
				};
				
			};
			// child element "map"
			if (structKeyExists(children[i],"map"))
			{
				entries = XMLSearch(children[i],'map/entry');
				hashMap = structNew();
				for (j = 1; j lte ArrayLen(entries); j = j + 1)
				{
					if (structKeyExists(entries[j],"value"))
					{
						hashMap[entries[j].XmlAttributes["key"]] = entries[j].value.XmlText;
					} 
					else if (structKeyExists(entries[j],"ref"))
					{
						hashMap[entries[j].XmlAttributes["key"]] = entries[j].ref.XmlAttributes["bean"];
					}
				}
				switch (arguments.childTagName)
				{
					case 'constructor-arg' :
					{
						addConstructorProperty(bean.XmlAttributes["id"],children[i].XmlAttributes["name"],hashMap);
					};
					break;
					case 'property' :
					{
						addSetterProperty(bean.XmlAttributes["id"],children[i].XmlAttributes["name"],hashMap);
					};
					break;
					case 'mixin' :
					{
						addMixinProperty(bean.XmlAttributes["id"],children[i].XmlAttributes["name"],hashMap);
					};
					break;
				};
			};
			// child element "ref"
			if (structKeyExists(children[i],"ref"))
			{
				switch (arguments.childTagName)
				{
					case 'constructor-arg' :
					{
						addConstructorDependency(bean.XmlAttributes["id"],children[i].ref.XmlAttributes["bean"],children[i].XmlAttributes["name"]);
					};
					break;
					case 'property' :
					{
						addSetterDependency(bean.XmlAttributes["id"],children[i].ref.XmlAttributes["bean"],children[i].XmlAttributes["name"]);
					};
					break;
					case 'mixin' :
					{
						addMixinDependency(bean.XmlAttributes["id"],children[i].ref.XmlAttributes["bean"],children[i].XmlAttributes["name"]);
					};
					break;
				};
			};
			//child element "bean"
			if (structKeyExists(children[i],"bean"))
			{
				// use recursion
				if (structKeyExists(arguments,"props"))
				{
					translateBean(children[i].bean,arguments.props);
				}
				else
				{
					translateBean(children[i].bean);
				}
				switch (arguments.childTagName)
				{
					case 'constructor-arg' :
					{
						addConstructorDependency(bean.XmlAttributes["id"],children[i].XmlAttributes["name"],children[i].bean.XmlAttributes["id"]);
					};
					break;
					case 'property' :
					{
						addSetterDependency(bean.XmlAttributes["id"],children[i].XmlAttributes["name"],children[i].bean.XmlAttributes["id"]);
					};
					break;
					case 'mixin' :
					{
						addMixinDependency(bean.XmlAttributes["id"],children[i].XmlAttributes["name"],children[i].bean.XmlAttributes["id"]);
					};
					break;
				};
			};
		};
	</cfscript>
</cffunction>

<cffunction name="dump" returntype="void" hint="I provide cfdump/cfabort functionality within cfscript blocks." output="false">
	<cfargument name="VariabletoDump" required="true" type="any" hint="The variable to dump to the screen.">
	<cfdump var="#VariabletoDump#">
	<cfabort>
</cffunction>

</cfcomponent>