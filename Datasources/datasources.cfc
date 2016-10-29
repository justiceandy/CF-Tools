<cfcomponent>

  <!--- Get Current Datasources in CFIDE --->
  <cffunction name="getDatasources" access="remote" returnFormat="plain">
    <cfargument name="cfpassword" type="string" required="true" hint="Coldfusion Admin Password">
    <cfargument name="returnType" default="json" type="string">

    <!--- Log in to the CF admin --->
    <cfset adminAPI = createObject( 'component', 'cfide.adminapi.administrator' ) />
    <cfset adminAPI.login( arguments.cfpassword ) />
    	<cfscript>
      	dsnAPI = createObject( 'component', 'cfide.adminapi.datasource' );
        datasources = dsnAPI.getDatasources();
    	</cfscript>
      <cfif arguments.returnType EQ "Json">
        <cfreturn serializeJson(datasources)>
      <cfelse>
        <cfreturn datasources>
      </cfif>
  </cffunction>

  <!--- Create Application Datasources [usefull for fresh installs of CF, new instance init]--->
  <cffunction name="createAppDatabases" access="remote" returnFormat="plain">
    <cfargument name="cfpassword" type="string" required="true" hint="Coldfusion Admin Password">
    <cfargument name="user" type="string" default="root" hint="Datasource User Name">
    <cfargument name="password" type="string" required="true" hint="Datasource User Password">
    <cfargument name="host" type="string" default="localhost" hint="Datasource Host">
    <cfargument name="datasources" type="array" required="true" hint="Array of Structs for Datasources to Add">

    <!--- Log in to the CF admin  --->
    <cfset adminAPI = createObject( 'component', 'cfide.adminapi.administrator' ) />
    <cfset adminAPI.login( arguments.cfpassword ) />

    <!--- Inspired by Ben Nadel's Post, only turned into a loop --->
    <cfloop from="1" to="#arrayLen(arguments.datasources)#" index="i">
    	<cfscript>
    	dsnAPI = createObject( 'component', 'cfide.adminapi.datasource' );
    	dsn = {
    		driver = 'mysql5',
    		name = arguments.datasources[i].name,
    		host = datasources[i].host,
    		port = datasources[i].port,
    		database = datasources[i].database,
    		username = datasources[i].username,
    		password = datasources[i].password,
    		args = 'allowMultiQueries=true'
    	};
    	dsnAPI.setMySQL5( argumentCollection = dsn );
    	</cfscript>
    </cfloop>
    <cfreturn serializeJson(datasources)>
  </cffunction>





</cfcomponent>
