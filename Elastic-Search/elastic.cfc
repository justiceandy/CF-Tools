<cfcomponent>

	<!--- Check if Elastic is Running --->
	<cffunction name="isRunning" access="remote"  returnformat="plain" hint="Returns boolean if Elastic is currently running" >
		<cfargument name="serverAddress" default="#application.elastic.URL#" type="string">
		<cfargument name="returnType" default="json" type="string">

		<cfhttp method="get" url="#arguments.serverAddress#/" result="ping"
		username="#application.elastic.shield.username#"
		password="#application.elastic.shield.password#" />

		<cfif structKeyExists(deserializeJson(ping.filecontent), "version")>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<!--- Setup Elastic --->
	<cffunction name="setupElastic" access="remote" returnFormat="plain">
		<cfargument name="dataWhipe" default="false" type="string">
		<cfif arguments.dataWhipe>
			<cfinvoke component="index" method="deleteAllIndexes" />
		</cfif>
		<cfinvoke component="mappings" method="createAllMappings" />
		<cfinvoke component="index" method="indexAllData" />
	</cffunction>



	<!--- Get index Stats --->
	<cffunction name="getIndexStatus" access="remote" hint="Returns Stats about an Index">
		<cfargument name="serverAddress" default="#application.elastic.URL#" type="string">
		<cfargument name="index" required="true" type="string">
		<cfargument name="returnType" default="json" type="string">

		<cfhttp method="get" url="#arguments.serverAddress#/#arguments.index#/_status" result="status"
		username="#application.elastic.shield.username#"
		password="#application.elastic.shield.password#" />

		<cfif arguments.returnType EQ "json">
			<cfreturn status.fileContent>
		<Cfelse>
			<cfreturn deserializeJson(status.fileContent)>
		</cfif>
	</cffunction>


	<!--- Index Data --->
	<cffunction name="indexData" access="remote" hint="sends a data object to elastic search for indexing">
		<cfargument name="serverAddress" default="#application.elastic.URL#" type="string">
		<cfargument name="index" required="true" type="string">
		<cfargument name="table" required="true" type="string">
		<cfargument name="data" required="true" type="struct">
		<cfargument name="id"  default="">
		<cfargument name="returnType" default="json" type="string">

		<cfhttp method="post" url="#arguments.serverAddress#/#arguments.index#/#arguments.table#/#arguments.id#" result="indexStatus"
		username="#application.elastic.shield.username#"
		password="#application.elastic.shield.password#">
			<cfhttpparam  type="body" value="#serializeJson(arguments.data)#">
		</cfhttp>

		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(indexStatus)>
		<cfelse>
			<cfreturn indexStatus>
		</cfif>
	</cffunction>


	<!--- Create Index --->
	<cffunction name="createIndexDatabase" access="remote" hint="Creates an Elastic Search Database Index">
		<cfargument name="serverAddress" default="#application.elastic.URL#" type="string">
		<cfargument name="index" required="true" type="string" hint="Name of Index to Create">
		<cfargument name="numShards" default="2" type="numeric" hint="Number of Shards for Index">
		<cfargument name="replicas" default="1" type="numeric" hint="Number of Replicas of Index">
		<cfargument name="mappings" required="true" type="struct" hint="Structure of Index Settings">
		<cfargument name="returnType" default="json" type="string">

		<cfset settings = structNew()>
		<cfset settings["index"] = structNew()>
		<cfset settings.index["number_of_shards"] = arguments.numShards>
		<cfset settings.index["number_of_replicas"] = arguments.replicas>
		<cfset settings["mappings"] = structCopy(arguments.mappings)>

		<cfhttp method="post" url="#arguments.serverAddress#/#arguments.index#/" result="indexStatus"
		username="#application.elastic.shield.username#"
		password="#application.elastic.shield.password#" >
			<cfhttpparam  type="body" value="#serializeJson(settings)#">
		</cfhttp>
		<cfdump var="#indexStatus#">
		<cfreturn indexStatus>
	</cffunction>


	<!--- Get Index Contents --->
	<cffunction name="getIndexContents" access="remote" hint="Returns Contents of an elastic Index">
		<cfargument name="serverAddress" default="#application.elastic.URL#" type="string">
		<cfargument name="index" required="true" type="string">
		<cfargument name="items" default="0" type="numeric">
		<cfargument name="returnType" default="json" type="string">

		<cfif arguments.items EQ 0>
			<cfset arguments.items = 10000>
		</cfif>

		<cfset result = structNew()>
		<cfset result.query = structNew()>
		<cfset result.query["match_all"] = structNew()>

		<cfhttp method="get" url="#arguments.serverAddress#/#arguments.index#/_search?&size=#arguments.items#" result="index"
		username="#application.elastic.shield.username#"
		password="#application.elastic.shield.password#">
			<cfhttpparam  type="body" value="#serializeJson(result)#">
		</cfhttp>
		<cfset scrollStruct = deserializeJson(index.fileContent)>
		<cfdump var="#index.fileContent#">
		<cfabort>
	</cffunction>


	<!--- Get Data from Scroll ID --->
	<cffunction name="getScrollData" access="remote" hint="Returns Data from an Elastic Scroll ID">
		<cfargument name="serverAddress" default="#application.elastic.URL#" type="string">
		<cfargument name="scrollID" type="string" required="true">
		<cfargument name="scrollTimeout" type="numeric" default="5" hint="Timeout of Elastics inner scrolling for this search. [Ms]">
		<cfargument name="returnType" default="json" type="string">

		<cfhttp method="get" url="#arguments.serverAddress#/_search/scroll?scroll=#arguments.scrollTimeout#m&scroll_id=#arguments.scrollID#" result="scrollData"
		username="#application.elastic.shield.username#"
		password="#application.elastic.shield.password#"/>

		<cfif arguments.returnType EQ "json">
			<cfreturn scrollData.fileContent>
		<cfelse>
			<cfreturn deserializeJson(scrollData.fileContent)>
		</cfif>
	</cffunction>

	<!--- Search index --->
	<cffunction name="searchIndex" returnFormat="plain" access="remote" hint="Returns Data from index">
		<cfargument name="serverAddress" default="#application.elastic.URL#" type="string">
		<cfargument name="index" default="" type="string">
		<cfargument name="table" default="" type="string">
		<cfargument name="startItem" default="1" type="numeric">
		<cfargument name="endItem" default="10" tyoe="numeric">
		<cfargument name="searchType" default="basic" type="string">
		<cfargument name="includeScrollData" default="false" type="boolean">
		<cfargument name="returnType" default="json" type="string">
		<cfargument name="q" required="true">

		<cfif len(index) and len(table)>
			<cfset variables.serverUrl = "#arguments.serverAddress#/#arguments.index#/#arguments.table#">
		<cfelseif len(index)>
			<cfset variables.serverUrl = "#arguments.serverAddress#/#arguments.index#">
		<cfelse>
			<cfset variables.serverUrl = arguments.serverAddress>
		</cfif>


		<!--- If Basic Search Type --->
		<cfif arguments.searchType EQ "basic">

		<!--- Search Elastic --->
		<cfhttp method="get" url="#variables.serverUrl#/_search?q=#arguments.q#&search_type=scan&scroll=10m&size=10" result="searchResults"
		username="#application.elastic.shield.username#"
		password="#application.elastic.shield.password#"/>



		<!--- If Advanced Search --->
		<cfelse>
			<!--- Build Query Json Struct --->
			<cfhttp method="post" url="#variables.serverUrl#/_search?search_type=scan&scroll=1m&size=10&explain=true" result="searchResults"  charset="utf-8"
			username="#application.elastic.shield.username#"
			password="#application.elastic.shield.password#">

				<cfhttpparam type="body" value="#arguments.q#">
				<cfhttpparam type="header" name="Content-Length" value="#len(arguments.q)#">
				<cfhttpparam type="HEADER" name="Keep-Alive" value="300">
				<cfhttpparam type="HEADER" name="Connection" value="keep-alive">
				<cfhttpparam type="header" name="Content-Type" value="application/json; charset=utf-8" />
			</cfhttp>

		</cfif>

		<cfif arguments.includeScrollData>
			<cfset results = deserializeJson(searchResults.fileContent)>
			<!--- Get Scroll Data for This Page --->
			<cfinvoke component="cfc.elastic.Elastic" method="getScrollData" returnvariable="scrollData">
				<cfinvokeargument name="scrollID" value="#results['_scroll_id']#">
				<cfinvokeargument name="scrollTimeout" value="1">
				<cfinvokeargument name="returnType" value="struct">
			</cfinvoke>

			<cfset result = structNew()>
			<cfset result.searchInitial = structCopy(results)>
			<cfset result.scrollData = structCopy(scrollData)>
			<cfif arguments.returnType EQ "json">
				<cfreturn serializeJson(result)>
			<cfelse>
				<cfreturn result>
			</cfif>
		<cfelse>
			<cfif arguments.returnType EQ "json">
				<cfreturn searchResults.fileContent>
			<cfelse>
				<cfreturn deserializeJson(searchResults.fileContent)>
			</cfif>
		</cfif>

	</cffunction>




	<!--- ReMap Index --->
	<cffunction name="reMapIndex" access="remote" hint="Remaps an index from supplied Mapping Struct">
		<cfargument name="serverAddress" default="#application.elastic.URL#" type="string">
		<cfargument name="index" type="string" required="true">
		<cfargument name="newMapData" type="struct" required="true">
		<cfargument name="returnType" default="json" type="string">

		<!--- Delete Index --->
		<cfinvoke component="elastic" method="deleteIndex" returnvariable="deletedDatabase">
			<cfinvokeargument name="index" value="#arguments.index#">
		</cfinvoke>


		<!--- Create Database --->
		<cfinvoke component="elastic" method="createIndexDatabase" returnvariable="createdDatabase">
			<cfinvokeargument name="index" value="#arguments.index#">
			<cfinvokeargument name="mappings" value="#arguments.newMapData#">
		</cfinvoke>

	</cffunction>


	<!--- Update Index Item --->
	<cffunction name="updateIndexItem" access="remote" hint="Submits a partial Update to an index item">
		<cfargument name="serverAddress" default="#application.elastic.URL#" type="string">
		<cfargument name="index" required="true" type="string">
		<cfargument name="table" default="" type="string">
		<cfargument name="itemID" required="true" type="numeric">
		<cfargument name="updatedItemData" required="true" type="struct">
		<cfargument name="returnType" default="json" type="string">

		<cfif len(index) and len(table)>
			<cfset variables.serverUrl = "#arguments.serverAddress#/#arguments.index#/#arguments.table#">
		<cfelseif len(index)>
			<cfset variables.serverUrl = "#arguments.serverAddress#/#arguments.index#">
		<cfelse>
			<cfset variables.serverUrl = arguments.serverAddress>
		</cfif>

		<cfset result = structNew()>
		<cfset result.doc = structCopy(arguments.updatedItemData)>

		<!--- Send Update Packet --->
		<cfhttp method="post" url="#variables.serverUrl#/#arguments.itemID#/_update?retry_on_conflict=5" result="updateResults"
		username="#application.elastic.shield.username#"
		password="#application.elastic.shield.password#">
			<cfhttpparam type="body" value="#serializeJson(result)#">
		</cfhttp>

		<cfif arguments.returnType EQ "json">
			<cfreturn updateResults.fileContent>
		<Cfelse>
			<cfreturn deserializeJson(updateResults.fileContent)>
		</cfif>
	</cffunction>


	<!--- Delete Index --->
	<cffunction name="deleteIndex" access="remote" hint="Removes an index from elastic">
		<cfargument name="serverAddress" default="#application.elastic.URL#" type="string">
		<cfargument name="index" required="true" type="string">
		<cfargument name="table" default="" type="string">
		<cfargument name="returnType" default="json" type="string">

		<cfif len(arguments.table) and len(arguments.index)>
			<cfhttp method="delete" url="#arguments.serverAddress#/#arguments.index#/#arguments.table#"  result="deleteResults"
			username="#application.elastic.shield.username#"
			password="#application.elastic.shield.password#" />
		<cfelse>
			<cfhttp method="delete" url="#arguments.serverAddress#/#arguments.index#"  result="deleteResults"
			username="#application.elastic.shield.username#"
			password="#application.elastic.shield.password#" />
		</cfif>

		<cfif arguments.returnType EQ "json">
			<cfreturn deleteResults.fileContent>
		<Cfelse>
			<cfreturn deserializeJson(deleteResults.fileContent)>
		</cfif>
	</cffunction>


	<!--- Get Current Indexes --->
	<cffunction name="getCurrentIndexes" access="remote" returnformat="plain" hint="Get Current Indexes in Elastic Search">
		<cfargument name="serverAddress" default="#application.elastic.URL#" type="string">
		<cfargument name="returnType" default="json" type="string">

		<cfhttp method="get" url="#arguments.serverAddress#/_status" result="status"
		username="#application.elastic.shield.username#"
		password="#application.elastic.shield.password#"/>

		<cfif arguments.returnType EQ "json">
			<cfreturn status.fileContent>
		<Cfelse>
			<cfreturn deserializeJson(status.fileContent)>
		</cfif>
	</cffunction>


	<!--- Get Index Settings --->
	<cffunction name="getIndexSettings" access="remote">
		<cfargument name="serverAddress" default="#application.elastic.URL#" type="string">
		<cfargument name="returnType" default="json" type="string">
		<cfargument name="index" required="true" type="string">

		<cfhttp method="get" url="#arguments.serverAddress#/#arguments.index#/_status" result="settings"
		username="#application.elastic.shield.username#"
		password="#application.elastic.shield.password#" />

		<cfif arguments.returnType EQ "json">
			<cfreturn settings.fileContent>
		<Cfelse>
			<cfreturn deserializeJson(settings.fileContent)>
		</cfif>
	</cffunction>


	<!--- Get Mappings for Index --->
	<cffunction name="getIndexMappings" access="remote">
		<cfargument name="serverAddress" default="#application.elastic.URL#" type="string">
		<cfargument name="returnType" default="json" type="string">
		<cfargument name="index" required="true" type="string">
		<cfargument name="table" default="" type="string">

		<cfhttp method="get" url="#arguments.serverAddress#/#arguments.index#/_mapping/#arguments.table#" result="mapping"
		username="#application.elastic.shield.username#"
		password="#application.elastic.shield.password#" />

		<cfif arguments.returnType EQ "json">
			<cfreturn mapping.fileContent>
		<Cfelse>
			<cfreturn deserializeJson(mapping.fileContent)>
		</cfif>
	</cffunction>

</cfcomponent>
