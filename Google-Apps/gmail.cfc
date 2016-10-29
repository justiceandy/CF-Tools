<cfcomponent>
  <!---
    Component Handles Google API Requests for GMAIL
  --->

      <!--- Get Messages --->
      <cffunction name="getMessages" access="remote" returnFormat="plain">
            <cfargument name="returnType" type="string" default="json">
            <cfargument name="refreshToken" type="string" default="">
            <cfargument name="q" type="string" default="">

            <cfset apiURL = "https://www.googleapis.com/gmail/v1/users/me/messages">

            <cfif arguments.Q NEQ "">
                  <cfset apiURL = "#apiUrl#?&q=#arguments.q#">
            </cfif>

            <cfset result = structNew()>
            <cfif arguments.refreshToken EQ "">
                  <cfset refreshToken = session.googleToken.refreshToken>
            <cfelse>
                  <cfset refreshToken = arguments.refreshToken>
            </cfif>

            <!--- If we dont have an access token already --->
            <cfif !structKeyExists(session.googleToken, "access_token") and arguments.refreshToken NEQ "">
                  <cfinvoke component="cfc.google.authorize" method="getGoogleSessionToken" returnVariable="authToken">
                        <cfinvokeargument name="userRefreshToken" value="#refreshToken#">
                  </cfinvoke>

                  <cfset accessToken = authToken.access_token>
            <cfelse>
                  <cfset accessToken = session.googleToken.access_token>
            </cfif>


            <cfhttp url="#apiURL#" method="get" resolveurl="yes" result="httpResult">
                  <cfhttpparam type="header" name="Authorization" value="OAuth #accessToken#">
                  <cfhttpparam type="header" name="GData-Version" value="3">
            </cfhttp>

            <!--- If invalid credentials from timed out auth token --->
            <cfif structKeyExists(httpResult.responseHeader, "status_code")
                  and httpResult.responseHeader.status_code EQ "401">
                  <cfinvoke component="cfc.google.authorize" method="getGoogleSessionToken" returnVariable="authToken">
                        <cfinvokeargument name="userRefreshToken" value="#refreshToken#">
                  </cfinvoke>
                  <cfhttp url="#apiURL#" method="get" resolveurl="yes" result="httpResult">
                        <cfhttpparam type="header" name="Authorization" value="Bearer #accesstoken#">
                        <cfhttpparam type="header" name="GData-Version" value="3">
                  </cfhttp>
            </cfif>
            <cfset result.messages = deserializeJson(httpResult.fileContent)>
            <cfset result.messages = result.messages.messages>

            <cfdump var="#result.messages#">
            <cfloop from="1" to="#arrayLen(result.messages)#" index="i">

                  <!--- Check if we have this message info saved --->

                  <cfinvoke component="gmail" method="getMessageData" returnVariable="messageData">
                        <cfinvokeargument name="messageID" value="#result.messages[i].id#">
                        <cfinvokeargument name="returnType" value="struct">
                  </cfinvoke>
                  <cfset result.messages[i]["messageData"] = messageData.messageData>

                  <!--- Lets Save Message Data --->
                  <cfinvoke component="cfc.user.emails" method="archiveGmailAPIEmail" returnVariable="archivedResults">
                        <cfinvokeargument name="messageData" value="#result.messages[i]["messageData"]#">
                  </cfinvoke>

            </cfloop>

            <cfif arguments.returnType EQ "json">
                  <cfreturn serializeJson(result)>
            <cfelse>
                  <cfreturn result>
            </cfif>
      </cffunction>

      <!--- Get Message Data --->
      <cffunction name="getMessageData" access="remote" returnFormat="plain">
            <cfargument name="messageID" type="string" required="true">
            <cfargument name="format" type="string" default="raw">
            <cfargument name="refreshToken" type="string" default="">
            <cfargument name="returnType" type="string" default="json">

            <cfset result = structNew()>
            <cfif arguments.refreshToken EQ "">
                  <cfset refreshToken = session.googleToken.refreshToken>
            <cfelse>
                  <cfset refreshToken = arguments.refreshToken>
            </cfif>

            <cfset apiURL = "https://www.googleapis.com/gmail/v1/users/me/messages/#arguments.messageID#">

            <!--- If we dont have an access token already --->
            <cfif !structKeyExists(session.googleToken, "access_token") and arguments.refreshToken NEQ "">
                  <cfinvoke component="cfc.google.authorize" method="getGoogleSessionToken" returnVariable="authToken">
                        <cfinvokeargument name="userRefreshToken" value="#refreshToken#">
                  </cfinvoke>
                  <cfset accessToken = authToken.access_token>
            <cfelse>
                  <cfset accessToken = session.googleToken.access_token>
            </cfif>

            <cfhttp url="#apiURL#" method="get" resolveurl="yes" result="httpResult">
                  <cfhttpparam type="header" name="Authorization" value="OAuth #accessToken#">
                  <cfhttpparam type="header" name="GData-Version" value="3">
            </cfhttp>

            <!--- If invalid credentials from timed out auth token --->
            <cfif structKeyExists(httpResult.responseHeader, "status_code")
                  and httpResult.responseHeader.status_code EQ "401">
                  <cfinvoke component="cfc.google.authorize" method="getGoogleSessionToken" returnVariable="authToken">
                        <cfinvokeargument name="userRefreshToken" value="#refreshToken#">
                  </cfinvoke>
                  <cfhttp url="#apiURL#" method="get" resolveurl="yes" result="httpResult">
                        <cfhttpparam type="header" name="Authorization" value="Bearer #access_token#">
                        <cfhttpparam type="header" name="GData-Version" value="3">
                  </cfhttp>
            </cfif>

            <cfset result.messageData = deserializeJson(httpResult.fileContent)>

            <cfif arguments.returnType EQ "json">
                  <cfreturn serializeJson(httpResult)>
            <cfelse>
                  <cfreturn result>
            </cfif>
      </cffunction>

</cfcomponent>
