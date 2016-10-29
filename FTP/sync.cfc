<cfcomponent>
	<!---
		CF Component Handles FTP'ing Site Map Files
	--->

	<!--- Sync Local Site Maps to FTP Server--->
	<cffunction name="syncSiteMaps" access="remote" returnFormat="plain" hint="Synces Sitemaps to Live Fileserver">
		<!--- Please do not plain text your passwords if you are using this function as a reference
			Encrypt it when storing and Decrypt it at runtime and pass along the decrypted password
		 --->
		<cfset ftp = {password = "FTP-PASSWORD", username = "FTP-USERNAME", port="FTP-PORT", server = "FTP-SERVER"} />

		<cfset application.siteMapSaveLocation = "LOCAL-DISK-SITEMAPS">

		<cfftp action = "open"
		   username = "#ftp.username#"
		   connection = "SiteMapConnection"
		   password = "#ftp.password#"
		   port="#ftp.port#"
		   directory="/sitemaps"
		   server = "#ftp.server#"
		   passive="true"
		   transferMode="ASCII"
		   stopOnError = "Yes">

		<!--- Get the current directory name. --->
		<cfftp connection="SiteMapConnection" action="GetCurrentDir" stoponerror="Yes">
		<cfftp connection = "SiteMapConnection" action = "LISTDIR" stopOnError = "Yes" name = "ListDirs" directory="/sitemaps">
		<cfsavecontent variable="ftpContent">
			<cfoutput>
			<h4>Started Site Map Sync At: #timeformat(now())#</h4>
			<ul>
			 <!--- Loop Each Directory and put Site Map --->
			 <cfloop query="listDirs">
			 	 <cfif fileExists("#application.siteMapSaveLocation#\domains\#name#\sitemap.xml.gz")>
				  	  <li>Domain: #name# </li>
					 <cfftp connection="SiteMapConnection" action="putfile"
						 localfile="#application.siteMapSaveLocation#\domains\#name#\sitemap.xml.gz"
						 remoteFile="/sitemaps/#name#/sitemap.xml.gz" >
				  </cfif>
			 </cfloop>
			 </ul>
			 <h4>Finished Site Map Sync At: #timeformat(now())#</h4>
			</cfoutput>
		</cfsavecontent>
 		<cfftp action = "close" connection = "SiteMapConnection" stopOnError = "Yes">
	</cffunction>



</cfcomponent>
