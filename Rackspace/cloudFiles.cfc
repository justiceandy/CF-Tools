<cfcomponent>

	<!---
		Rackspace CDN Component. Handles Requests for Rackspace uploads and container information.
		1.0 Authenticate
		-Authenticates Application with rackspace servers
		1.1 Upload File
		-Uploads specified File to rackspace
		-Requires Filename, container, file
		--->

	<!--- Component Variables --->
	<cfset variables.username = "RACKSPACE-USERNAME" />
	<cfset variables.apiKey = "RACKSPACE-API-KEY" />
	<!---Authenticates API Token--->

	<cffunction name="authenticate" access="public" output="false" returntype="any" hint="Use this method to test if supplied user credentials are valid.">
		<cfargument name="username" 	required="true" 	type="string" 	hint="The cloud files account username" />
		<cfargument name="apiKey" 		required="true" 	type="string" 	hint="The cloud files account API key" />
		<cfset var cfhttp 			= "" />
		<cfset var boolReturn 		= false />
		<cfset var stuResponse		= StructNew() />
		<cfset var stuStatusCheck 	= StructNew() />
		<cfhttp url="https://auth.api.rackspacecloud.com/v1.0" method="get" useragent="cloudFiles">
			<cfhttpparam name="X-Auth-User" type="header" value="#username#" />
			<cfhttpparam name="X-Auth-Key" 	type="header" value="#apiKey#" />
		</cfhttp>
		<cfreturn cfhttp />
	</cffunction>

	<!--- 1.1 Uploads a file to rackspace--->

	<cffunction name="upFile" access="public" hint="This function uploads the specified file to the specified container">
		<cfargument name="container" type="string" required="true" />
		<cfargument name="file" type="string" required="true" />
		<cfargument name="fileName" type="string" required="true" />
		<!--- Authenticate --->
		<cfinvoke component="cloudFiles" method="authenticate" returnVariable="auth">
			<cfinvokeargument name="username" value="#variables.username#">
			<cfinvokeargument name="apiKey" value="#variables.apiKey#">
		</cfinvoke>
		<!--- Set Vars that we need --->
		<cfset XAuthToken = auth.responseHeader["X-Auth-Token"] />
		<cfset CDNmanageURL = auth.responseHeader["X-CDN-Management-Url"] />
		<cfset ServerManagURL = auth.responseHeader["X-Server-Management-Url"] />
		<cfset storageToken = auth.responseHeader["X-Storage-Token"] />
		<cfset storageURL = auth.responseHeader["X-Storage-Url"] />
		<!--- Get content size --->
		<cfset length = createObject("java","java.io.File").init("#arguments.file#").length() />
		<cftry>
			<!--- Upload --->
			<cfhttp getasbinary="yes" method="put" result="cloudList" url="#storageURL#/#arguments.container#/#arguments.fileName#" useragent="cloudFiles">
				<cfhttpparam name="X-Auth-Token" type="header" value="#XAuthToken#">
				<cfhttpparam name="Content-Length" type="header" value="#length#">
				<cfhttpparam name="Host" type="header" value="storage.clouddrive.com">
				<cfhttpParam name="file" type="file" file="#file#">
			</cfhttp>
			<cfset message = "Sucessfully Uploaded #arguments.file# to #arguments.container#" />
			<cfcatch>
				<cfset message = "Failed to upload #arguments.file#. Please Try again" />
			</cfcatch>
		</cftry>
		<!--- Return result --->
		<cfreturn message />
	</cffunction>

	<!---Get List of Containers --->

	<cffunction name="getListOfContainers" access="public" hint="Get all containers">
		<!--- Authenticate --->
		<cfinvoke component="cloudFiles" method="authenticate" returnVariable="auth">
			<cfinvokeargument name="username" value="#variables.username#">
			<cfinvokeargument name="apiKey" value="#variables.apiKey#">
		</cfinvoke>
		<!--- Set Vars that we need --->
		<cfset XAuthToken = auth.responseHeader["X-Auth-Token"] />
		<cfset CDNmanageURL = auth.responseHeader["X-CDN-Management-Url"] />
		<cfset ServerManagURL = auth.responseHeader["X-Server-Management-Url"] />
		<cfset storageToken = auth.responseHeader["X-Storage-Token"] />
		<cfset storageURL = auth.responseHeader["X-Storage-Url"] />
		<cfset  result = ArrayNew(1) />
		<cfhttp method="GET" charset="utf-8" url="#storageURL#"><cfhttpparam type="header" name="X-Auth-Token" value="#XAuthToken#" /></cfhttp>
		<cfswitch expression="#ListFirst(cfhttp.statusCode, " ")#">
		<!--- no containers --->
		<cfcase value="204"><cfset result = ArrayNew(1) /></cfcase>
		<!--- found containers --->
		<cfcase value="200">
			<cfset result = ListToArray(cfhttp.filecontent, Chr(10), false) />
			<cfset ArraySort(result, "text") />
		</cfcase>
		</cfswitch>
		<cfreturn result />
	</cffunction>

	<!---Get Container Files--->
	<cffunction name="getContainerFiles" access="public" hint="This function lists all the files in a specified container">
		<cfargument name="container" type="string" required="true" />
		<cfargument name="prefix" type="string" required="false" default="" />
		<cfargument name="limit" type="numeric" required="false" default="0" />
		<cfargument name="offset" type="numeric" required="false" default="0" />
		<cfset var result = ArrayNew(1) />
		<!--- Authenticate --->
		<cfinvoke component="cloudFiles" method="authenticate" returnVariable="auth">
			<cfinvokeargument name="username" value="#variables.username#">
			<cfinvokeargument name="apiKey" value="#variables.apiKey#">
		</cfinvoke>
		<!--- Set Vars that we need --->
		<cfset XAuthToken = auth.responseHeader["X-Auth-Token"] />
		<cfset CDNmanageURL = auth.responseHeader["X-CDN-Management-Url"] />
		<cfset ServerManagURL = auth.responseHeader["X-Server-Management-Url"] />
		<cfset storageToken = auth.responseHeader["X-Storage-Token"] />
		<cfset storageURL = auth.responseHeader["X-Storage-Url"] />
		<cfhttp method="GET" charset="utf-8" url="#storageURL#/#arguments.container#">
			<cfif Len(arguments.prefix)>
				<cfhttpparam type="URL" name="prefix" value="#arguments.prefix#" />
			</cfif>
			<cfif arguments.limit gt 0>
				<cfhttpparam type="URL" name="limit" value="#arguments.limit#" />
			</cfif>
			<cfif arguments.offset gt 0>
				<cfhttpparam type="URL" name="offset" value="#arguments.offset#" />
			</cfif>
			<cfhttpparam type="header" name="X-Auth-Token" value="#XAuthToken#" />
		</cfhttp>
		<cfswitch expression="#ListFirst(cfhttp.statusCode, " ")#">
		<!--- no objects in container --->
		<cfcase value="204"><cfset result = ArrayNew(1) /></cfcase>
		<!--- container not found --->
		<cfcase value="404">
			<cfthrow message="Container not found (#arguments.container#)." errorCode="#ListFirst(cfhttp.statusCode, " ")#" />
		</cfcase>
		<!--- found objects --->
		<cfcase value="200">
			<cfset result = ListToArray(cfhttp.filecontent, Chr(10), false) />
			<cfset ArraySort(result, "text") />
		</cfcase>
		</cfswitch>
		<cfreturn result />
	</cffunction>

	<!---Get cdn url--->
	<cffunction name="getCDNUrl" access="public" hint="Get the CDN url">
		<cfargument name="container" type="string" required="true" />
		<cfargument name="ttl" type="numeric" required="false" />
		<!--- Authenticate --->
		<cfinvoke component="cloudFiles" method="authenticate" returnVariable="auth">
			<cfinvokeargument name="username" value="#variables.username#">
			<cfinvokeargument name="apiKey" value="#variables.apiKey#">
		</cfinvoke>
		<!--- Set Vars that we need --->
		<cfset result = "">
		<cfset XAuthToken = auth.responseHeader["X-Auth-Token"] />
		<cfset CDNmanageURL = auth.responseHeader["X-CDN-Management-Url"] />
		<cfset ServerManagURL = auth.responseHeader["X-Server-Management-Url"] />
		<cfset storageToken = auth.responseHeader["X-Storage-Token"] />
		<cfset storageURL = auth.responseHeader["X-Storage-Url"] />
		<cfhttp method="PUT" charset="utf-8" url="#CDNmanageURL#/#arguments.container#">
			<cfhttpparam type="header" name="X-Auth-Token" value="#XAuthToken#" />
			<cfif isDefined("arguments.ttl")>
				<cfhttpparam type="header" name="X-TTL" value="#arguments.ttl#" />
			</cfif>
		</cfhttp>
		<cfswitch expression="#ListFirst(cfhttp.statusCode, " ")#">
		<!--- container enabled --->
		<cfcase value="201"><cfset result = cfhttp.responseheader["X-CDN-URI"] /></cfcase>
		<!--- container TTL adjusted --->
		<cfcase value="202"><cfset result = cfhttp.responseheader["X-CDN-URI"] /></cfcase>
		<cfcase value="404">
			<cfthrow message="Container not found (#arguments.container#)." errorCode="#ListFirst(cfhttp.statusCode, " ")#" />
		</cfcase>
		</cfswitch>
		<cfreturn result />
	</cffunction>

	<!--- Delete the object from container --->

	<cffunction name="deleteObject" access="public" returnType="any" output="no">
		<cfargument name="container" type="string" required="true" />
		<cfargument name="objectName" type="string" required="true" />

		<cfinvoke component="cloudFiles" method="authenticate" returnVariable="auth">
			<cfinvokeargument name="username" value="#variables.username#">
			<cfinvokeargument name="apiKey" value="#variables.apiKey#">
		</cfinvoke>

		<!--- Set Vars that we need --->
		<cfset XAuthToken = auth.responseHeader["X-Auth-Token"] />
		<cfset CDNmanageURL = auth.responseHeader["X-CDN-Management-Url"] />
		<cfset ServerManagURL = auth.responseHeader["X-Server-Management-Url"] />
		<cfset storageToken = auth.responseHeader["X-Storage-Token"] />
		<cfset storageURL = auth.responseHeader["X-Storage-Url"] />


		<cfhttp method="DELETE" charset="utf-8" url="#storageURL#/#arguments.container#/#arguments.objectName#">
			<cfhttpparam type="header" name="X-Auth-Token" value="#XAuthToken#" />
		</cfhttp>
		<cfswitch expression="#ListFirst(cfhttp.statusCode, " ")#">

		<!---If returns 204, Item was deleted --->
		<cfcase value="204" >
			<cfset result = 1>
			<cfreturn result>
		</cfcase>
		<!---If returns 404, Object not found --->
		<cfcase value="404">
			<cfset result = -1>
			<cfreturn result>
		</cfcase>
		<cfdefaultcase>
			<cfset result = 0>
			<cfreturn result>
		</cfdefaultcase>
		</cfswitch>
	</cffunction>


</cfcomponent>
