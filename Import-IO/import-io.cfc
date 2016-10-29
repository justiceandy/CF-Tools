
  <!--- Component Handles Interacting with Import-IO API
    Crawl Page using Connector and Return JSON Response
    [THIS WAS WRITTEN WHEN IMPORT-IO WAS FREE ;/]
  --->

  <!--- Initialize --->
  <cffunction name="init" access="remote" returnFormat="plain">
    <cfset application.importio = structNew()>
    <cfset application.importio.apiKey = "IMPORT-IO-API-KEY">

      <cfinvoke component="import-io" method="cacheConnectors" />
  </cffunction>


  <!--- Get Crawlers [Refered to as Connectors in API docs] --->
  <cffunction name="getConnectors" access="remote" returnFormat="plain">
    <cfargument name="apiKey" type="string" default="#application.importio.apiKey#">
    <cfargument name="returnType" type="string" default="json">

      <cfset result = structNew()>
      <cfset connectorFetchURL = "https://api.import.io/store/connector/_search?q=*&_perpage=20&_sortDirection=DESC&_type=query_string&_default_operator=OR&_mine=false">
      <cfset connectorFetchURL = "#connectorFetchURL#&_apikey=#urlEncodedFormat(arguments.apiKey)#">

      <cfhttp method="get" url="#connectorFetchURL#" result="apiResponse" />

      <cfset result.connectors = arrayNew(1)>
      <cfset apiResponse = deserializeJson(apiResponse.fileContent)>
      <cfset result.connectors = apiResponse.hits.hits>


      <cfif arguments.returnType EQ "json">
        <cfreturn serializeJson(result)>
      <cfelse>
        <cfreturn result>
      </cfif>
  </cffunction>

  <!--- Send Page to Crawler [Connector] --->
  <cffunction name="crawlPage" access="remote" returnFormat="plain">
    <cfargument name="pageURL" type="string" required="true">
    <cfargument name="connector" type="string" required="true">
    <cfargument name="returnType" type="string" default="json">
    <cfargument name="apiKey" type="string" default="#application.importio.apiKey#">

      <cfset queryURL = "https://api.import.io/store/data/#arguments.connector#/_query?">
      <cfset queryURL = "#queryURL#&_apikey=#urlEncodedFormat(arguments.apiKey)#">


      <cfset q = { "input": {"webpage/url": "#arguments.pageURL#"  }  }>

      <cfhttp method="post" url="#queryURL#" result="postResults">
        <cfhttpparam type="body" value="#serializeJson(q)#">
      </cfhttp>


      <cfset result = deserializeJson(postResults.fileContent)>

      <cfif arguments.returnType EQ "json">
        <cfreturn serializeJson(result)>
      <cfelse>
        <cfreturn result>
      </cfif>
  </cffunction>


  <!--- Store App Crawlers --->
  <cffunction name="cacheConnectors" access="remote" returnFormat="plain">
    <cfinvoke component="import-io" method="getConnectors" returnVariable="connectors">
      <cfinvokeargument name="returnType" value="struct">
    </cfinvoke>
    <cfset application.importio.connectors = connectors.connectors>
  </cffunction>


  <!--- Determine Crawler to Use from URL --->
  <cffunction name="getCrawlerForURL" access="remote" returnFormat="plain">
    <cfargument name="returnType" type="string" default="json">
    <cfargument name="pageURL" type="string" required="true">
    <cfargument name="filter" type="string" default="EXTRACTOR">

      <Cfif !structKeyExists(application, "importio")>
        <cfinvoke component="import-io" method="init" />
      </cfif>

      <cfset pageDomain = reReplace(arguments.pageURL,  "^\w+://([^\/:]+)[\w\W]*$", "\1",  "one") />
      <cfset result.possibleMatches = arrayNew(1)>
      <!--- Find Possible Matches --->
      <cfloop from="1" to="#arrayLen(application.importio.connectors)#" index="i">
        <cfif arrayContains(application.importio.connectors[i].fields.tags, arguments.filter) or arguments.filter EQ "all">
          <cfset thisDom = reReplace(application.importio.connectors[i].fields.source,  "^\w+://([^\/:]+)[\w\W]*$", "\1",  "one") />
          <cfif thisDom EQ pageDomain>
            <cfif left(thisDom, 4) EQ 'www.'>
              <cfset thisDom = right(thisDom, len(thisDom) - 4)>
            </cfif>
            <cfset match = structNew()>
            <cfset match.domain = thisDom>
            <cfset match.exampleURL = application.importio.connectors[i].fields.source>
            <cfset match.tags = application.importio.connectors[i].fields.tags>
            <cfset match.connector = application.importio.connectors[i]['_id']>
            <cfset arrayAppend(result.possibleMatches, match)>
          </cfif>
        </cfif>
      </cfloop>

      <cfif arguments.returnType EQ "json">
        <cfreturn serializeJson(result)>
      <cfelse>
        <cfreturn result>
      </cfif>
  </cffunction>
