<cfcomponent>

      <cffunction name="startLogStash" access="remote" returnFormat="plain">
        <cfset logStashLocation = "G:\Code\ElasticSearch\logstash-1.5.0.rc2\bin">
        <cfexecute name="#logStashLocation#\exec.bat" arguments="-f configs" variable="logStashStatus" timeout="1" />
      </cffunction>


</cfcomponent>
