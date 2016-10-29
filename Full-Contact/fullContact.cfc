<!---
      CFC For integrating with Full Contact Api v2
      https://www.fullcontact.com/

      Handles Fetching Contact Info about an Email and storing it in mySQl
      Set elasticCache to true if you have an elastic cluster you would like to replicate the data
      to and then query for future requests
--->
<cfcomponent>

      <!--- Initialize Application Scope Variables --->
      <cffunction name="init">
        
        <!--- Application Scope Variable that Handles all the goodness
          For Most Applications that use Elastic Search, you Probably have your ES Info Stored in another variable. But For Demo
          Purposes I included default values nested in the full contact object
        --->
        <cfset application.fullContact = {
            apiKey: 'YOUR-API-KEY',
            apiURL: 'https://api.fullcontact.com/v2/person.json',
            es: {
              enabled: false,
              host: 'YOUR-ES-HOST',
              index: 'ES-INDEX',
              type: 'ES-TYPE',
              shield: {
                username: 'ES-Shield-User',
                password: 'ES-Shield-Password'
              }
            },
            mysql: {
              enabled: true,
              table: 'fullcontact_api_data',
              db: 'DB-TO-WRITE-DATA'
            }
        }>
      </cffunction>


      <!--- Lookup Email --->
      <cffunction name="lookupEmail" access="remote" returnFormat="plain">
            <cfargument name="email" type="string" required="true">
            <cfargument name="customerID" type="numeric" default="0">
            <cfargument name="force" type="string" default="true">
            <cfargument name="returnType" type="string" default="json">

            <!--- If we dont have full contact object in the application scope, run init function to create it --->
            <cfif !structKeyExists(application.fullContact)>
              <cfinvoke component="fullContact" method="init" />
            </cfif>

            <!--- Create Default Return Struct --->
            <cfset result = {
              hitApi: false,
              email: arguments.email,
              status: true,
              force: arguments.force
            }>

            <!--- If we are using elastic cache --->
            <cfif application.fullContact.elasticCache>

              <!--- Attempt to return contact data from ES --->
              <cfhttp method="get" url="#application.fullContact.es.host#/#application.fullContact.es.index#/#application.fullContact.es.type#/_search?q=#arguments.email#&size=1" result="results"
                username="#application.elastic.shield.username#"
  		          password="#application.elastic.shield.password#"/>

                  <!--- If we have Required Variables from ES Response, Parse  --->
                  <cfif structKeyExists(variables, "results") and structKeyExists(results, "fileContent")>

                        <!--- Convert Json Response to Struct --->
                        <cfset results = deserializeJson(results.fileContent)>

                        <!--- If we have results --->
                        <cfif arrayLen(results.hits.hits)>
                              <!--- If we have multiple Items, we just need the most relevant result --->
                              <cfset contactData = results.hits.hits[1]['_source']>
                              <cfset contactID = results.hits.hits[1]['_id']>
                              <cfset foundInCache = true>
                        <!--- If no results are found --->
                        <cfelse>
                              <cfset foundInCache = false>
                        </cfif>
                  <!--- If we doesnt have results in the response from ES, set found to false --->
                  <cfelse>
                        <cfset foundInCache = false>
                  </cfif>
            </cfif>

            <!--- If we found email in cache --->
            <cfif foundInCache>
                  <cfset result.foundInCache = true>
                  <cfset result.contactData = contactData>
            </cfif>

            <!--- If not found in cache or we are forcing new data fetch --->
            <cfif !foundInCache or arguments.force>
                  <!--- Set Result Variable Reference for Log Data on Finish --->
                  <cfset result.hitApi = true>

                  <!--- Fetch from API --->
                  <cfhttp method="get" url="#application.fullContact.apiURL#" result="fullContactData">
                        <cfhttpparam type="url" name="apiKey" value="#application.fullContact.apiKey#" />
                        <cfhttpparam type="url" name="email" value="#arguments.email#" />
                  </cfhttp>

                  <!--- Parse Data --->
                  <cfset fullContactStruct = deserializeJson(fullContactData.fileContent)>
                  <cfset fullContactStruct.email = arguments.email>
                  <cfset fullContactStruct.customerID = arguments.customerID>

                  <!--- Save In Mysql if we dont have ID already --->
                  <cfif application.fullContact.mySql.enabled and !structKeyExists(variables, "contactID")>

                      <!--- Insert Email Record --->
                      <cfquery name="insertMySQlRecord" datasource="#application.fullContact.mySql.datasource#" result="savedApiResponse">
                            insert into #application.fullContact.mysql.table#
                            (email,lastUpdate,dateCreated,jsonData,statusCode,customerID)
                            values
                            (
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.email#">,
                            <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                            <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#serializeJson(fullContactStruct)#">,
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#fullContactData.responseheader['Status_Code']#">,
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.customerID#">
                            )
                      </cfquery>

                      <!--- Set Result Variable INfo on created record --->
                      <cfset contactID = savedApiResponse.generated_key>
                      <cfset result.mysqlRecord = "created">

                  <!--- If we are forcing, update with most current Data --->
                  <cfelseif application.fullContact.mySqlBackup and structKeyExists(variables, "contactID")>

                        <!--- Execute Update Query of Email Record --->
                        <cfquery name="updateMySQlRecord" datasource="#application.fullContact.mySql.datasource#">
                              update #application.fullContact.mysql.table#
                              set lastUpdate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                                  jsonData = <cfqueryparam cfsqltype="cf_sql_varchar" value="#serializeJson(fullContactStruct)#">,
                                  statusCode= <cfqueryparam cfsqltype="cf_sql_integer" value="#fullContactData.responseheader['Status_Code']#">,
                                  customerID= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.customerID#">)
                              where dataID = <Cfqueryparam cfsqltype="cf_sql_integer" value="#contactID#">
                        </cfquery>

                        <!--- Set Result Variable of updated --->
                        <cfset result.mysqlRecord = "updated">
                  </cfif>

                  <!--- Send Data to Elastic --->
                  <cfinvoke component="cfc.elastic.elastic" method="indexData" returnvariable="indexStatus">
                        <cfinvokeargument name="data" value="#fullContactStruct#">
                        <cfinvokeargument name="index" value="#application.fullContact.es.index#">
                        <cfinvokeargument name="table" value="#application.fullContact.es.table#">
                        <cfinvokeargument name="returnType" value="struct">
                        <cfinvokeargument name="id" value="#contactID#">
                  </cfinvoke>

                  <!--- Elastic Update on Customer ID IF exists --->
                  <cfset result.contactData = fullContactStruct>
            </cfif>

            <!-- If we are returning Json --->
            <cfif arguments.returnType EQ "json">
                <cfreturn serializeJson(result)>
            <!--- Else Return as Struct Variable --->
            <cfelse>
                <cfreturn result>
            </cfif>
      </cffunction>


</cfcomponent>
