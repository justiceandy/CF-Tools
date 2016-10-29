<cfcomponent hint="Handles Interaction with Google Contacts. Contact API Uses XML Feeds">


	<!--- Fetch All Contact Info --->
	<cffunction name="FetchAllContactInfo" access="remote" hint="Fetches All User Contact Info">
		<cfinvoke component="cfc.google.contacts" method="getContactGroups" returnVariable="contactGroups">
		<cfinvoke component="cfc.google.contacts" method="getContacts" returnVariable="contacts">
		<cfset session.contacts.initialized = "true">
	</cffunction>


	<!--- Get Contacts --->
	<cffunction name="getContacts" access="remote" hint="Fetches Users Contacts">
		<!--- Initial Post ---->
		<cfhttp url="https://www.google.com/m8/feeds/contacts/default/full/?max-results=500" method="get" resolveurl="yes" result="httpResult">
			<cfhttpparam type="header" name="Authorization" value="Bearer #session.googleToken.access_token#">
			<cfhttpparam type="header" name="GData-Version" value="3">
		</cfhttp>

		<!--- If invalid credentials from timed out auth token --->
		<cfif structKeyExists(httpResult.responseHeader, "status_code")
			and httpResult.responseHeader.status_code EQ "401">
			<cfinvoke component="cfc.google.authorize" method="getGoogleSessionToken" returnVariable="authToken">
				<cfinvokeargument name="userRefreshToken" value="#session.googleToken.refreshToken#">
			</cfinvoke>
			<cfhttp url="https://www.google.com/m8/feeds/contacts/default/full/?max-results=500" method="get" resolveurl="yes" result="httpResult">
				<cfhttpparam type="header" name="Authorization" value="Bearer #session.googleToken.access_token#">
				<cfhttpparam type="header" name="GData-Version" value="3">
			</cfhttp>
		</cfif>

		<!--- Store Contents in Session --->
		<cfinvoke component="cfc.user.session" method="storeSessionContacts">
			<cfinvokeargument name="xmlNode" value="#httpResult.fileContent#">
		</cfinvoke>

		<cfreturn httpResult>
	</cffunction>


	<!--- Get Contact Groups ---->
	<cffunction name="getContactGroups" access="remote" hint="Fetches User Contact Groups">
		<!--- Initial Post ---->
		<cfhttp url="https://www.google.com/m8/feeds/groups/default/full/?max-results=500" method="get" resolveurl="yes" result="httpResult">
			<cfhttpparam type="header" name="Authorization" value="Bearer #session.googleToken.access_token#">
			<cfhttpparam type="header" name="GData-Version" value="3">
		</cfhttp>
		<!--- If invalid credentials from timed out auth token --->
		<cfif structKeyExists(httpResult.responseHeader, "status_code")
			and httpResult.responseHeader.status_code EQ "401">
			<cfinvoke component="cfc.google.authorize" method="getGoogleSessionToken" returnVariable="authToken">
				<cfinvokeargument name="userRefreshToken" value="#session.googleToken.refreshToken#">
			</cfinvoke>
			<cfhttp url="https://www.google.com/m8/feeds/groups/default/full/?max-results=500" method="get" resolveurl="yes" result="httpResult">
				<cfhttpparam type="header" name="Authorization" value="Bearer #session.googleToken.access_token#">
				<cfhttpparam type="header" name="GData-Version" value="3">
			</cfhttp>
		</cfif>
		<!--- Store Group In Session --->
		<cfinvoke component="cfc.user.session" method="storeSessionContactGroups">
			<cfinvokeargument name="xmlNode" value="#httpResult.fileContent#">
		</cfinvoke>
		<cfreturn true>
	</cffunction>



	<!--- Get Single Contact Info --->
	<cffunction name="getContactInfo" access="remote" hint="Gets a single contact">
		<cfargument name="contactID" type="string" default="1bfdd960d435cbc">
		<cfhttp url="https://www.google.com/m8/feeds/contacts/default/full/#arguments.contactID#" method="get" resolveurl="yes" result="httpResult">
				<cfhttpparam type="header" name="Authorization" value="OAuth #session.googleToken.access_token#">
				<cfhttpparam type="header" name="GData-Version" value="3">
		</cfhttp>
		<cfreturn httpResult>
	</cffunction>



</cfcomponent>
