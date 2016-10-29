<cfcomponent hint="Handles google authorize functions">
	<!---
		Handles O Auth 2.0 Authorization Requests


	--->

	<!--- Init Function --->
	<cffunction name="init" access="public" hint="Initialize Variables">
			<cfif !structKeyExists(application, "googleApi")>
				<cfset application.googleApi = structNew()>
			  <cfset application.googleApi.clientid="GOOGLE-API-CLIENTID">
	      <cfset application.googleApi.clientsecret="GOOGLE-API-CLIENT-SECRET">
	      <cfset application.googleApi.callback="http://MY-DOMAIN.com/cfc/google/authorize.cfc?method=authCallBack">
			  <cfset application.googleApi.publicApiKey = "GOOGLE-API-PUBLIC-KEY">
	      <cfset application.userSkipList = "USERNAMES,TO,SKIP">
			</cfif>
		<cfreturn this>
	</cffunction>


 	<!--- Set Application Scopes --->
	 <cffunction name="setAppPermissionScope" access="public" hint="Sets permission scope and determines what APIs will request authorization from a user">

	 	 <cfif !structKeyExists(application, "googleApi")>
	  	  <cfset init()>
	  </cfif>

 		<cfset application.googleApi.scopeItems = structNew()>
 		 <cfset application.googleApi.enabled_scopes = "">
		 <cfset i = 1>
 		<!--- Google User Info --->
		<cfset application.googleApi.scopeItems[1] = structNew()>
        <cfset application.googleApi.scopeItems[1].url = "https://www.googleapis.com/auth/userinfo.profile">
        <cfset application.googleApi.scopeItems[1].name = "Profile Information">
        <cfset application.googleApi.scopeItems[1].status = "Enabled">
		<cfset i++>
        <!--- Drive API --->
        <cfset application.googleApi.scopeItems[i] = structNew()>
        <cfset application.googleApi.scopeItems[i].url = "https://www.googleapis.com/auth/drive">
        <cfset application.googleApi.scopeItems[i].name = "Drive API Full Authority">
        <cfset application.googleApi.scopeItems[i].status = "Enabled">
		<cfset i++>
		<cfset application.googleApi.scopeItems[i] = structNew()>
        <cfset application.googleApi.scopeItems[i].url = "https://www.googleapis.com/auth/drive.appdata">
        <cfset application.googleApi.scopeItems[i].name = "Drive Apps Configuration Access">
        <cfset application.googleApi.scopeItems[i].status = "Enabled">
		<cfset i++>
		<cfset application.googleApi.scopeItems[i] = structNew()>
        <cfset application.googleApi.scopeItems[i].url = "https://www.googleapis.com/auth/drive.scripts">
        <cfset application.googleApi.scopeItems[i].name = "Google Drive Script Access">
        <cfset application.googleApi.scopeItems[i].status = "Enabled">
		<cfset i++>
		 <!--- Calendar API --->
        <cfset application.googleApi.scopeItems[i] = structNew()>
        <cfset application.googleApi.scopeItems[i].url = "https://www.googleapis.com/auth/calendar">
       	<cfset application.googleApi.scopeItems[i].name = "Calendar Data API">
        <cfset application.googleApi.scopeItems[i].status = "Enabled">
		<cfset i++>
        <!--- Analytics API ---->
        <cfset application.googleApi.scopeItems[i] = structNew()>
        <cfset application.googleApi.scopeItems[i].url = "https://www.googleapis.com/auth/analytics">
        <cfset application.googleApi.scopeItems[i].name = "Google Analytics Full Control">
      	<cfset application.googleApi.scopeItems[i].status = "Enabled">
		<cfset i++>
		<cfset application.googleApi.scopeItems[i] = structNew()>
        <cfset application.googleApi.scopeItems[i].url = "https://www.googleapis.com/auth/analytics.manage.users">
        <cfset application.googleApi.scopeItems[i].name = "Google Analytics User Control">
      	<cfset application.googleApi.scopeItems[i].status = "Enabled">
		 <cfset i++>
        <!--- Email Info --->
        <cfset application.googleApi.scopeItems[i] = structNew()>
        <cfset application.googleApi.scopeItems[i].url = "https://www.googleapis.com/auth/userinfo.email">
        <cfset application.googleApi.scopeItems[i].name = "Email Infomation">
        <cfset application.googleApi.scopeItems[i].status = "Enabled">
		<cfset i++>
        <!--- Contacts API --->
        <cfset application.googleApi.scopeItems[i] = structNew()>
        <cfset application.googleApi.scopeItems[i].url = "https://www.google.com/m8/feeds/">
        <cfset application.googleApi.scopeItems[i].name = "Contacts">
        <cfset application.googleApi.scopeItems[i].status = "Enabled">
		<cfset i++>
       <!--- URL Shortener API --->
      	<cfset application.googleApi.scopeItems[i] = structNew()>
        <cfset application.googleApi.scopeItems[i].url = "https://www.googleapis.com/auth/urlshortener">
        <cfset application.googleApi.scopeItems[i].name = "Url Shortener">
        <cfset application.googleApi.scopeItems[i].status = "Enabled">
		<cfset i++>
       <!--- Youtube Data API --->
        <cfset application.googleApi.scopeItems[i] = structNew()>
        <cfset application.googleApi.scopeItems[i].url = "https://gdata.youtube.com">
        <cfset application.googleApi.scopeItems[i].name = "Youtube Data API">
        <cfset application.googleApi.scopeItems[i].status = "Enabled">
		<cfset i++>
        <!--- Gmail Atom Feed --->
        <cfset application.googleApi.scopeItems[i] = structNew()>
        <cfset application.googleApi.scopeItems[i].url = "https://mail.google.com/mail/feed/atom">
        <cfset application.googleApi.scopeItems[i].name = "Gmail Atom Feed">
        <cfset application.googleApi.scopeItems[i].status = "Enabled">
		<cfset i++>
        <!--- Maps Data API --->
        <cfset application.googleApi.scopeItems[i] = structNew()>
        <cfset application.googleApi.scopeItems[i].url = "http://maps.google.com/maps/feeds/">
        <cfset application.googleApi.scopeItems[i].name = "Maps Data API">
        <cfset application.googleApi.scopeItems[i].status = "Enabled">
		<cfset i++>
		<!_-- Coordinate Maps API --->
		 <cfset application.googleApi.scopeItems[i] = structNew()>
        <cfset application.googleApi.scopeItems[i].url = "https://www.googleapis.com/auth/coordinate">
        <cfset application.googleApi.scopeItems[i].name = "Maps Coordinate API">
        <cfset application.googleApi.scopeItems[i].status = "Enabled">
		<cfset i++>
		<!--- Shopping Content API --->
        <cfset application.googleApi.scopeItems[i] = structNew()>
        <cfset application.googleApi.scopeItems[i].url = " https://www.googleapis.com/auth/structuredcontent">
        <cfset application.googleApi.scopeItems[i].name = "Shopping Content API">
        <cfset application.googleApi.scopeItems[i].status = "Enabled">
		<cfset i++>
		<!--- Web Master Tools API --->
		<cfset application.googleApi.scopeItems[i] = structNew()>
        <cfset application.googleApi.scopeItems[i].url = "http://www.google.com/webmasters/tools/feeds/">
        <cfset application.googleApi.scopeItems[i].name = "Web Master Tools API">
        <cfset application.googleApi.scopeItems[i].status = "Enabled">
       <cfset i++>
       	<!--- Admin Reports API Browse --->
		<cfset application.googleApi.scopeItems[i] = structNew()>
        <cfset application.googleApi.scopeItems[i].url = "http://www.google.com/webmasters/tools/feeds/">
        <cfset application.googleApi.scopeItems[i].name = "Web Master Tools API">
        <cfset application.googleApi.scopeItems[i].status = "Enabled">
        <cfset i++>
        <!--- Admin Reports API Audit User Usage --->
		<cfset application.googleApi.scopeItems[i] = structNew()>
		<cfset application.googleApi.scopeItems[i].url = "http://www.google.com/webmasters/tools/feeds/">
		<cfset application.googleApi.scopeItems[i].name = "Web Master Tools API">
		<cfset application.googleApi.scopeItems[i].status = "Enabled">
		<cfset i++>
       <!--- Create Scope String From Enabled APIs --->
 		<cfloop collection="#application.googleApi.scopeItems#" item="x">
		 	<cfif application.googleApi.scopeItems[x].status EQ "enabled">
		 		<cfset application.googleApi.enabled_scopes = "#application.googleApi.enabled_scopes# #application.googleApi.scopeItems[x].url#">
			</cfif>
		 </cfloop>

 		<cfreturn application.googleApi.enabled_scopes>
	 </cffunction>

 	<!--- Generate Auth Login URL --->
 	<cffunction name="generateAuthURL" access="public" hint="Generates Authorize Login URL" returntype="string">
		<cfargument name="redirectURL" type="string" required="true" hint="Url Google Redirects users after selecting account">
		<cfargument name="state" type="string" default="" hint="Custom Variables That google returns on success. Usually containing sessionInfo">
		<cfargument name="scope" type="string" default="" hint="Scope of permission Request">
		<cfargument name="getRefresh" type="string" default="true" hint="If true, requests refresh Token for user">
		<cfargument name="loginHint" type="string" default="">

		<cfset authURl ="https://accounts.google.com/o/oauth2/auth?hd=materialflow.com&" &
				 "client_id=#urlEncodedFormat(application.googleApi.clientid)#" &
     			 "&redirect_uri=#urlEncodedFormat(arguments.redirecturl)#" &
				 "&scope=#application.googleApi.enabled_scopes#&response_type=code" &
				 "&state=#urlEncodedFormat(arguments.state)#&access_type=offline&approval_prompt=force">

		<!--- If we are requesting Refresh Token --->
		<cfif arguments.getRefresh EQ "true">
			<cfset authURL = authURL & "">
		</cfif>

		<!--- If we are supplying user login account --->
		<cfif arguments.loginHint NEQ "">
			<cfset authURL = authURL & "&login_hint=#arguments.loginHint#">
		</cfif>

		<cfreturn authURL>

	 </cffunction>

	<!--- Validate Auth Login Results --->
	<cffunction name="validateResult" access="public" returntype="struct" hint="Validates Returned Results from Auth Login">
		<cfargument name="code" type="string" required="true" hint="Refresh Token Returned from Google Aps API">
		<cfargument name="error" type="string" default="">
		<cfargument name="remoteState" type="string" required="true" hint="session Info submitted back from Google">
		<cfargument name="clientState" type="string" required="true" hint="session info sent to google">

		<!--- If  Errors --->
		<cfif error NEQ "">
			<cfset result = structNew()>
			<cfset result.status = "false">
			<cfset result.message = error>
			<cfreturn result>
		</cfif>

		<!--- If we have uses API token appended --->
		<cfif arguments.remoteState contains "&applicationToken=">
			<cfset myLoginToken = right(arguments.remoteState, len(arguments.remoteState) - len(session.urlToken) )>
			<cfset arguments.remoteState = replace(arguments.remoteState, myLoginToken, "")>
			<cfset myLoginToken = replace(myLoginToken, "&applicationToken=", "", "all")>

			<cfset session.urlToken = arguments.remoteState>
			<cfset arguments.clientState = arguments.remoteState>
			<cfset result.loginToken = myLoginToken>
		</cfif>

		<!--- if we have username in remote state --->
		<cfif arguments.remoteState contains "&temporaryToken=">


		</cfif>


		<!--- If States dont match, return fail --->
		<cfif arguments.remoteState NEQ arguments.clientState>
			<cfset session.urlToken = arguments.remoteState>
			<cfset arguments.clientState = arguments.remoteState>
		</cfif>

		<!--- Hit Token Grab Function with Returned Code --->
		<cfset token = getGoogleRefreshToken(arguments.code)>


		<!--- If we failed to grab token --->
		<cfif structKeyExists(token, "error")>
			<cfset result = structNew()>
			<cfset result.status = "false">
			<cfset result.message = token.error>
			<cfreturn result>
		</cfif>

		<!--- Create Return Struct if we passed checks --->
		<cfset result = structNew()>
		<cfset result.status = "true">
		<Cfset result.token = token>

		<!--- If we have refresh token in response --->
		<cfif structKeyExists(token, "refresh_token")>
			<Cfset result.token.refreshToken = token.refresh_token>
		</cfif>


		<cfreturn result>
	</cffunction>


 	<!--- Get Google Refresh Token --->
 	<cffunction name="getGoogleRefreshToken" access="private" hint="Gets oAuth user refresh token from Google. This token lets you get session tokens that are good for access to the users content">
 		<cfargument name="code" type="any" required="true" hint="returned google user session auth code. lasts 60 minutes">

		<!--- Fetch Refresh Token --->
		<cfhttp url="https://accounts.google.com/o/oauth2/token" method="post" resolveurl="true" result="result">
			<cfhttpparam name="code" type="formfield" value="#arguments.code#">
			<cfhttpparam name="client_id" type="formfield" value="#application.googleApi.clientid#">
			<cfhttpparam name="client_secret" type="formfield" value="#application.googleApi.clientsecret#">
			<cfhttpparam name="redirect_uri" type="formfield" value="#application.googleApi.callback#">
			<cfhttpparam name="grant_type" type="formfield" value="authorization_code">
		</cfhttp>

		<!--- Return Token String --->
		<cfreturn deserializeJSON(result.filecontent.toString())>
	</cffunction>


	<!--- Get New Session Token --->
	<cffunction name="getGoogleSessionToken" access="public" hint="gets new session access token using refresh token">
		<cfargument name="userRefreshToken" type="string" required="true">


		<!--- Fetch Auth Token --->
		<cfhttp url="https://accounts.google.com/o/oauth2/token" method="post" resolveurl="true" result="result">
			<cfhttpparam name="Content-Type" type="header" value="application/x-www-form-urlencoded">
			<cfhttpparam name="client_id" type="formfield" value="#application.googleApi.clientid#">
			<cfhttpparam name="client_secret" type="formfield" value="#application.googleApi.clientsecret#">
			<cfhttpparam name="refresh_token" type="formfield" value="#arguments.userRefreshToken#">
			<cfhttpparam name="grant_type" type="formfield" value="refresh_token">
		</cfhttp>

		<cfset result = deserializeJSON(result.filecontent.toString())>


		<!--- Store in Session --->
		<cfif isDefined("session")>
			<cfinvoke component="cfc.google.authorize" method="createSessionTokenStore">
				<cfinvokeargument name="token" value="#result#">
			</cfinvoke>
		</cfif>

		<!--- Return Token --->
		<cfreturn result>
	</cffunction>


	<!--- Create New Session Access Token --->
	<cffunction name="createSessionTokenStore" access="public" hint="Stores Returned Google Token information in session">
		<cfargument name="token" type="struct" required="true">

		<cfif isDefined("session") and !structKeyExists(session, "googleToken")>
			 <cfset session.googleToken = structNew()>
		</cfif>

		<cftry>
		<cfset session.googleToken["access_token"] = arguments.token.access_token>
		<cfset session.googleToken["issued"] = now()>
		<cfset session.googleToken["expires"] = dateadd('s' , arguments.token.expires_in, session.googleToken.issued)>
		<cfset session.googleToken["id"] = arguments.token.id_token>
		<cfset session.googleToken["type"] = arguments.token.token_type>

		<!---  If we have refresh token --->
		<cfif structKeyExists(arguments.token, "refreshToken") and !structKeyExists(session.googleToken, "refreshToken")>
 		  <cfset session.googleToken["refreshToken"] = arguments.token.refreshToken>
		</cfif>

		<cfif structKeyExists(arguments.token, "refresh_Token") and !structKeyExists(session.googleToken, "refresh_Token")>
 			<cfset session.googleToken["refreshToken"] = arguments.token.refreshToken>
		</cfif>
		<cfcatch>

		</cfcatch>
		</cftry>
	</cffunction>



	<!--- Check Refresh Token against Returned --->
	<cffunction name="checkRefreshToken" access="public" returnType="string" hint="Checks if returned RefreshID matches database value, if not, updates database value">
		<cfargument name="userID" type="numeric" required="true">
		<cfargument name="refreshToken" type="string" required="true">

		<!--- Check That Token Exists --->
		<cfquery name="checkToken" datasource="cms_users">
			select googleApiTokenValue from users
			where userID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#">
			and googleApiTokenValue = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.refreshToken#">
		</cfquery>

		<cfif checkToken.recordCount EQ 0>
			<cfquery name="updateToken" datasource="cms_users">
				update users
				set googleApiTokenValue = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.refreshToken#">
				where userID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userID#">
			</cfquery>
			<cfset message = "Updated Token Value">
		<cfelse>
			<cfset message = "Token Value Matches Database">
		</cfif>
			<cfreturn message>
	</cffunction>


	<!--- Selected Google Account Authorize Call Back
		 When user authenticates with an account, they are submitted to the function below
		 --->
	<cffunction name="authCallBack" access="remote" hint="Handles Auth Submission Back from Google">
			<cfargument name="code" type="string" required="true">
			<cfargument name="state" type="string" required="true">
			<cfargument name="error" type="string" default="">

			<!--- Validate Returned Response --->
			<cfinvoke component="cfc.google.authorize" method="validateResult" returnvariable="result">
				<cfinvokeargument name="code" value="#arguments.code#">
				<cfinvokeargument name="error" value="#arguments.error#">
				<cfinvokeargument name="remoteState" value="#arguments.state#">
				<cfinvokeargument name="clientState" value="#session.urltoken#">
			</cfinvoke>

		  <!--- If we got back a successfull token Store in user Session--->
		  <cfif result.status EQ "true">

	  	 <!---- Make Request for Profile Info --->
	  	<cfinvoke component="cfc.google.user" method="getProfile" returnvariable="googleProfile" >
				<cfinvokeargument name="accesstoken" value="#result.token.access_token#">
			</cfinvoke>



			<!--- Create Username of FirstName Last Initial --->
		  	<cfset variables.shortUserName = lcase(googleProfile.given_name)
			  								 & lcase(left(googleProfile.family_name, 1))>

			<!--- Lookup userID by username --->
			<Cfinvoke component="cfc.user.userFunctions" method="getUserInfoByUserName" returnVariable="getID">
				<cfinvokeargument name="username" value="#lcase(variables.shortUserName)#">
			</cfinvoke>



	  	 <!--- Create New Google Account User --->
	     <cfinvoke component="cfc.user.userFunctions" method="createNewGoogleUser" returnvariable="newUser">
			 		<cfinvokeargument name="email" value="#googleProfile.email#">
			 		<cfinvokeargument name="groupID" value="1">
					<cfinvokeargument name="adminLevel" value="2">
					<cfinvokeargument name="googleProfile" value="#googleProfile#">
					<cfinvokeargument name="token" value="#result.token#">
			 </cfinvoke>

				<!--- If no creating new user, login user--->
				<cfif !structKeyExists(newUser, "error") or !structKeyExists(session, "loggedIn") or session.loggedIn EQ "false">
					<cfset session.userID = newUser.userID>
					<cfset session.userName = newUser.userName>
					<cfset session.loginTime = now()>
					<cfset session.loggedIn = "true">
					<cfset session.failedLogins = 0>
					<cfset session.googleToken = structNew()>
					<cfset session.googleToken.refreshToken = newUser.googleApiTokenValue>


					<!--- Add User to currently Logged in Users --->
					<cfif structKeyExists(application, "liveUsers")>
						<cfif !structKeyExists(APPLICATION.liveUsers, newUser.userID)>
							<cfset application.liveUsers[newUser.userID] = structNew()>
						</cfif>
						<cfset APPLICATION.liveUsers[newUser.userID].status = "online">
						<cfset APPLICATION.liveUsers[newUser.userID].LastLoginTime = now()>
					</cfif>

					<!--- Log User into Application --->
					<cfloginuser name="#newUser.userName#"
								 password="#newUser.password#"
								 roles = "#session.userGroupName#" >

					<cflocation url="/#session.homePage#">

				<!--- If errors, Couldnt Login User --->
				<cfelse>
					<cflocation url="index.cfm?mf=login.login&message=error creating google account sync&error=#newUser.error#">
				</cfif>

			 <!--- If we have user in db, save google info so app is synced --->
			  <cfelseif getID.recordCount GT 0>





			  	  	<cfif arguments.state contains "&applicationToken=">
						<cfset myLoginToken = right(arguments.State, len(arguments.State) - len(session.urlToken) )>
						<cfset myLoginToken = replace(myLoginToken, "&applicationToken=", "", "all")>
					</cfif>



			  	  <!--- Update User Token Value --->
			  	  <cfinvoke component="cfc.user.userFunctions" method="updateStoredGoogleUserData" returnVariable="updatedInfo">
			  	  		<cfinvokeargument name="email" value="#googleProfile.email#">
						<cfinvokeargument name="token" value="#result.token#">
						<cfinvokeargument name="userID" value="#getID.userID#">
			  	  		<cfinvokeargument name="googleProfile" value="#googleProfile#">
			  	  </cfinvoke>


			  	  <!--- If not logged in yet --->
				  <cfif !structKeyExists(session, "loggedIN") or session.loggedIn EQ "false">

					<cfset session.userID = updatedInfo.userID>
					<cfset session.userName = updatedInfo.userName>
					<cfset session.loginTime = now()>
					<cfset session.loggedIn = "true">
					<cfset session.failedLogins = 0>
					<cfset session.googleToken = structNew()>
					<cfset session.googleToken.refreshToken = updatedInfo.googleApiTokenValue>


					<!--- Add User to currently Logged in Users if exists --->
					<cfif structKeyExists(application, "liveUsers")>
						<cfif !structKeyExists(APPLICATION.liveUsers, updatedInfo.userID)>
							<cfset application.liveUsers[updatedInfo.userID] = structNew()>
						</cfif>
						<cfset APPLICATION.liveUsers[updatedInfo.userID].status = "online">
						<cfset APPLICATION.liveUsers[updatedInfo.userID].LastLoginTime = now()>
					</cfif>

					<!--- Log User into Application --->
					<cfloginuser name="#updatedInfo.userName#"
								 password="#updatedInfo.password#"
								 roles = "#session.userGroupName#" >

					<cflocation url="/#session.homePage#">

				  </cfif>


			  </cfif>




			<!--- If we are logged in --->
		   	<cfif !structKeyExists(session, "loggedIN") or session.loggedIn EQ "true">

			 	<!--- Save To Google Post Results to Session   --->
				<cfset session.googleProfile = structCopy(googleProfile)>

				<cfinvoke component="cfc.google.authorize" method="createSessionTokenStore">
					<cfinvokeargument name="token" value="#result.token#">
				</cfinvoke>


				  <!--- Redirect  to login page --->
			 	  <cflocation url="/index.cfm?mf=login.login" addtoken="false">



			 <!--- If we Failed To Login --->
		 	<cfelse>
			 	<!---Redirect to Login page --->
			 	<cflocation url="/index.cfm?mf=login.login&message=Failed To Login">
			</cfif>

		  <!--- If Submit Result failed and we couldnt get a successful token from google --->
		  <cfelse>
		  	<cfoutput>
				<h1>Error Authorizing Application</h1>
				<cfif result.message EQ "invalid_grant">
					<p>Invalid Grant Token. Usually Solved by Hitting Back and trying again.</p>
				</cfif>
					#result.message#
			</cfoutput>
		</cfif>


	</cffunction>

</cfcomponent>
