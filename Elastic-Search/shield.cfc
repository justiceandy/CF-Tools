<cfcomponent>

      <cffunction name="createShieldUser" access="remote" returnFormat="plain">
            <cfargument name="user" type="string" required="true">
            <cfset application.elastic.dailyKey = hash(createUUID())>
            <cfhttp method="post" url="https://esproxy:553/actions/createuser">
                  <cfhttpparam type="Formfield" name="dailyApiKey" value="#application.elastic.dailyKey#">
                  <cfhttpparam type="Formfield" name="credentials" value="base64Admin">
                  <cfhttpparam type="Formfield" name="user" value="#arguments.user#">
            </cfhttp>
      </cffunction>

</cfcomponent>
