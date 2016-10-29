<cfcomponent>

      <!--- Initialize --->
      <cffunction name="initialize">

            <cfset application.googleAnalytics = structNew()>
            <cfset application.googleAnalytics.adminUser = 2116>
            <cfset application.googleAnalytics.url = "https://www.googleapis.com/analytics/v3/data/ga?">
            <cfset application.googleAnalytics.adminToken = structNew()>
            <cfset application.googleAnalytics.domainPropertyIDs = structNew()>
            <!--- Cache Metrics --->
            <cfinvoke component="analytics" method="cacheMetrics" />
            <cfinvoke component="analytics" method="cacheProfiles" />
      </cffunction>


      <!--- Query Analytics Data --->
      <Cffunction name="query" access="remote" returnFormat="plain">
            <cfargument name="metrics" type="string" required="true" hint="Metrics to return">
            <cfargument name="ids" type="string" required="true" hint="Property ID">
            <cfargument name="enddate" type="string">
            <cfargument name="startDate" type="string">
            <cfargument name="maxResults" type="string" default="50">
            <cfargument name="sort" type="string" default="">
            <cfargument name="dimensions" type="string" default="">
            <cfargument name="filters" type="string" default="">
            <cfargument name="returnType" type="string" default="json">

            <cfif structKeyExists(arguments, "start-date")>
                  <cfset arguments.startDate = arguments['start-date']>
            </cfif>
            <cfif structKeyExists(arguments, "end-date")>
                  <cfset arguments.endDate = arguments['end-date']>
            </cfif>

            <!--- Get Admin Token --->
            <cfif !structKeyExists(application.googleAnalytics.adminToken, "reAuthToken")>
              <cfinvoke component="analytics" method="getAdminToken" returnVariable="adminToken" />
            </cfif>

            <cfif !structKeyExists(application.googleAnalytics.adminToken, "sessionToken")>
              <cfinvoke component="authorize" method="getGoogleSessionToken" returnVariable="sessionToken">
                <cfinvokeargument name="userRefreshToken" value="#application.googleAnalytics.adminToken.reAuthToken#">
              </cfinvoke>
              <Cfset application.googleAnalytics.adminToken.sessionToken = sessionToken.access_token>
            </cfif>


            <cfset qString = "#application.googleAnalytics.url#ids=#arguments.ids#">
            <cfset qString = "#qString#&metrics=#arguments.metrics#&start-date=#arguments.startDate#&end-date=#arguments.enddate#">
            <cfset qString = "#qString#&max-results=#arguments.maxResults#">

            <!--- If Sorting --->
            <cfif arguments.sort NEQ "">
                  <cfset qString = "#qString#&sort=#arguments.sort#">
            </cfif>
            <cfif arguments.filters NEQ "">
                  <cfset qString = "#qString#&filters=#arguments.filters#">
            </cfif>
            <!--- If Dimensions --->
            <cfif arguments.dimensions NEQ "">
                  <cfset qString = "#qString#&dimensions=#arguments.dimensions#">
            </cfif>

            <!--- Initial Post ---->
            <cfhttp url="#qString#" method="get" resolveurl="yes" result="httpResult">
                  <cfhttpparam type="header" name="Authorization" value="Bearer #application.googleAnalytics.adminToken.sessionToken#">
                  <cfhttpparam type="header" name="GData-Version" value="3">
            </cfhttp>

            <!--- If invalid credentials from timed out auth token, retry --->
            <cfif structKeyExists(httpResult.responseHeader, "status_code")
                  and httpResult.responseHeader.status_code EQ "401">
                  <cfinvoke component="cfc.google.authorize" method="getGoogleSessionToken" returnVariable="authToken">
                        <cfinvokeargument name="userRefreshToken" value="#application.googleAnalytics.adminToken.reAuthToken#">
                  </cfinvoke>
                  <cfhttp url="#qString#" method="get" resolveurl="yes" result="httpResult">
                        <cfhttpparam type="header" name="Authorization" value="Bearer #application.googleAnalytics.adminToken.sessionToken#">
                        <cfhttpparam type="header" name="GData-Version" value="3">
                  </cfhttp>
            </cfif>

            <cfif arguments.returnType EQ "json">
                  <cfreturn httpResult.fileContent>
            <cfelse>
                  <cfreturn deserializeJson(httpResult.fileContent)>
            </cfif>
      </cffunction>


      <!--- Get Metrics from API --->
      <cffunction name="getMetrics" access="remote" returnFormat="plain">
            <cfset metricUrl = "https://www.googleapis.com/analytics/v3/metadata/ga/columns?pp=1">
            <cfhttp url="#metricUrl#" method="get" resolveurl="yes" result="httpResult" />
            <cfset metricResult = deserializeJson(httpResult.filecontent)>

            <cfloop from="1" to="#arrayLen(metricResult.items)#" index="i">
                  <cfquery name="insertToDB" datasource="cms_users">
                        insert into analytics_Meta
                        (name,dataType,analytics_Meta.description,analytics_Meta.group,analytics_Meta.status,analytics_Meta.type,uiName,dateCreated)
                        values
                        (<cfqueryparam cfsqltype="cf_sql_varchar" value="#metricResult.items[i].id#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#metricResult.items[i]['attributes']['dataType']#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#metricResult.items[i]['attributes']['description']#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#metricResult.items[i]['attributes']['group']#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#metricResult.items[i]['attributes']['status']#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#metricResult.items[i]['attributes']['type']#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#metricResult.items[i]['attributes']['uiName']#">,
                        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">)
                  </cfquery>
            </cfloop>

      </cffunction>

      <!--- Save Metrics --->
      <cffunction name="saveMetrics" access="remote" returnFormat="plain">
            <cfset metricUrl = "https://www.googleapis.com/analytics/v3/metadata/ga/columns?pp=1">
            <cfhttp url="#metricUrl#" method="get" resolveurl="yes" result="httpResult" />
            <cfset metricResult = deserializeJson(httpResult.filecontent)>

            <cfquery name="deleteMetaData" datasource="cms_users">
                  delete from analytics_meta
            </cfquery>

            <cfloop from="1" to="#arrayLen(metricResult.items)#" index="i">
                  <cfquery name="insertToDB" datasource="cms_users">
                        insert into analytics_Meta
                        (name,dataType,analytics_Meta.description,analytics_Meta.group,analytics_Meta.status,analytics_Meta.type,uiName,dateCreated)
                        values
                        (<cfqueryparam cfsqltype="cf_sql_varchar" value="#metricResult.items[i].id#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#metricResult.items[i]['attributes']['dataType']#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#metricResult.items[i]['attributes']['description']#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#metricResult.items[i]['attributes']['group']#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#metricResult.items[i]['attributes']['status']#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#metricResult.items[i]['attributes']['type']#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#metricResult.items[i]['attributes']['uiName']#">,
                        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">)
                  </cfquery>
            </cfloop>
      </cffunction>


      <!--- Cache Metrics --->
      <cffunction name="cacheMetrics" access="remote" returnFormat="plain">
            <!--- Get Metrics --->
            <cfquery name="getMetrics" datasource="cms_meta">
                  select * from analytics_meta
            </cfquery>

            <cfset application.googleAnalytics.metrics  = structNew()>

            <cfloop query="getMetrics">
                  <cfset application.googleAnalytics.metrics[getMetrics.name] = structNew()>
                  <cfloop list="#getMetrics.columnList#" index="i">
                        <cfset application.googleAnalytics.metrics[getMetrics.name][i] = getMetrics[i][getMetrics.currentRow]>
                  </cfloop>
            </cfloop>
            <cfreturn true>
      </cffunction>


      <!--- Get Profile Data --->
      <cffunction name="getProfiles" access="remote" hint="Returns Profiles linked to logged in user">
            <cfargument name="accountID" type="string" default="~all">
            <cfargument name="webPropertyID" type="string" default="~all">

            <cfset profileURL = "https://www.googleapis.com/analytics/v3/management/accounts/#arguments.accountID#/webproperties/#arguments.webPropertyID#/profiles">

            <!--- Get Admin Token --->
            <cfif !structKeyExists(application.googleAnalytics.adminToken, "reAuthToken")>
              <cfinvoke component="analytics" method="getAdminToken" returnVariable="adminToken" />
            </cfif>

            <cfif !structKeyExists(application.googleAnalytics.adminToken, "sessionToken")>
              <cfinvoke component="authorize" method="getGoogleSessionToken" returnVariable="sessionToken">
                <cfinvokeargument name="userRefreshToken" value="#application.googleAnalytics.adminToken.reAuthToken#">
              </cfinvoke>
              <Cfset application.googleAnalytics.adminToken.sessionToken = sessionToken.access_token>
            </cfif>

            <!--- Get Profiles --->
            <cfhttp url="#profileURL#" method="get" resolveurl="yes" result="httpResult">
                  <cfhttpparam type="header" name="Authorization" value="Bearer #application.googleAnalytics.adminToken.sessionToken#">
                  <cfhttpparam type="header" name="GData-Version" value="3">
            </cfhttp>

            <cfreturn httpResult>
      </cffunction>


      <!--- Cache Profiles --->
      <cffunction name="cacheProfiles" access="remote" returnFormat="plain" hint="Adds Profile Data to domain Cache">

            <!--- Get All Profiles --->
            <cfinvoke component="analytics" method="getProfiles" returnVariable="profileData" />

            <cfset propertyResponse = deserializeJson(profileData.fileContent)>
            <cfloop from="1" to="#arrayLen(propertyResponse.items)#" index="i">
                  <cfif structKeyExists(application.googleAnalytics.domainPropertyIDs, propertyResponse.items[i].webPropertyId)>
                        <CFSET domainID = application.googleAnalytics.domainPropertyIDs[propertyResponse.items[i].webPropertyId].domainID>
                        <cfset application.domains[domainID].gaProfiles[1] = structCopy(propertyResponse.items[i])>
                        <cfdump var="#application.domains[domainID].gaProfiles[1]#">
                        <cfdump var="#domainID#">
                  </cfif>
            </cfloop>
            <cfreturn true>
      </cffunction>


      <cffunction name="getAdminToken" access="public" returnFormat="plain" hint="Gets Admin Token for Google Analytics">

          <cfquery name="getToken" datasource="cms_users">
            select googleApiTokenValue
            from users
            where userID = <cfqueryparam cfsqltype="cf_sql_integer" value="#application.googleAnalytics.adminUser#">
          </cfquery>

          <cfset application.googleAnalytics.adminToken = structNew()>
          <cfset application.googleAnalytics.adminToken.ReauthToken = getToken.googleApiTokenValue>

          <cfinvoke component="analytics" method="getProfiles" returnVariable="profileData" />


      </cffunction>

</cfcomponent>
