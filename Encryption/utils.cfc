<cfcomponent output="no">
	
	
	<!--- Encrypt ---->
	<cffunction name="enc" access="public" returntype="string">
		<cfargument name="info" type="string" required="yes">
        <cfargument name="userSessionID" type="string">
		<cfargument name="info2" type="string">
		
		<cfif structKeyExists(arguments, "userSessionID")>
			<cfset output = toBase64(encrypt(arguments.info, arguments.userSessionID, 'CFMX_COMPAT'))>
      	<cfelse>
			<cfset output = toBase64(encrypt(arguments.info, arguments.info2, 'CFMX_COMPAT'))>
		</cfif>
		
		<cfreturn output>
	</cffunction>
    
    
    <!--- Decrypt --->
    <cffunction name="dec" access="public" returntype="string">
		<cfargument name="info" type="string" required="yes">
        <cfargument name="userSessionID" type="string">
		<cfargument name="info2" type="string">
		
		<cfif structKeyExists(arguments, "userSessionID")>
			<cfset output = decrypt(toString(toBinary(arguments.info)), arguments.userSessionID, 'CFMX_COMPAT')>
        <cfelse>
			<cfset output = decrypt(toString(toBinary(arguments.info)), arguments.info2, 'CFMX_COMPAT')>
		</cfif>
		
		<cfreturn output>
	</cffunction>
	
	
	<!--- Compute Hash --->
	<cffunction name="computeHash" access="public" returntype="String">
	  <cfargument name="password" type="string" />
	  <cfargument name="salt" type="string" />
	  <cfargument name="iterations" type="numeric" required="false" default="1024" />
	  <cfargument name="algorithm" type="string" required="false" default="SHA-512" />
	  <cfscript>
	    var hashed = '';
	    var i = 1;
	    hashed = hash( password & salt, arguments.algorithm, 'UTF-8' );
	    for (i = 1; i <= iterations; i++) {
	      hashed = hash( hashed & salt, arguments.algorithm, 'UTF-8' );
	    }
	    return hashed;
	  </cfscript>
	</cffunction>
	
	<!--- Generate Salt --->
	<cffunction name="genSalt" access="public" returnType="string">
	    <cfargument name="size" type="numeric" required="false" default="16" />
	    <cfscript>
	     var byteType = createObject('java', 'java.lang.Byte').TYPE;
	     var bytes = createObject('java','java.lang.reflect.Array').newInstance( byteType , size);
	     var rand = createObject('java', 'java.security.SecureRandom').nextBytes(bytes);
	     return toBase64(bytes);
	    </cfscript>
	</cffunction>
	
	
	

	<!---  Get CC Type
		The code below may NOT be up to date. 
		See:
		http://en.wikipedia.org/wiki/Credit_card_number
		http://www.beachnet.com/~hstiles/cardtype.html
		Etc
	--->
	<cffunction name="getCCType" access="remote" description="Checks the CC Number Type" output="false" returntype="Any">
		<cfargument name="ccNumber" type="Any" required="true" default="">
		
		<cfset local = StructNew()/>
		<cfset local.ccNumber = _numbersOnly(trim(arguments.ccNumber)) />
		
		<!--- Unknown By Default --->
		<cfset local.type = "Unknown" />
		
		<!--- AMERICAN_EXPRESS / Starts with: 34, 37 / Length: 15 --->
		<cfif (left(local.ccNumber, 2) EQ 34 OR left(local.ccNumber, 2) EQ 37) AND len(local.ccNumber) EQ 15>
			<cfset local.type = "AMERICAN_EXPRESS" />
		
		<!--- MASTERCARD / Starts with: Inclusive Between 51 to 55 / Length: 16 --->
		<cfelseif (left(local.ccNumber, 2) LTE 55 AND left(local.ccNumber, 2) GTE 51) AND len(local.ccNumber) EQ 16>
			<cfset local.type = "MASTERCARD" />		
		
		<!--- VISA / Starts with: 4 / Length: 13, 16 --->
		<cfelseif left(local.ccNumber, 1) EQ 4 AND (len(local.ccNumber) EQ 13 OR len(local.ccNumber) EQ 16)>
			<cfset local.type = "VISA" />		
					
		<!--- DISCOVER / Starts with: 6011, 65 / Length: 16 --->
		<cfelseif (left(local.ccNumber, 4) EQ 6011 OR left(local.ccNumber, 2) EQ 65) AND len(local.ccNumber) EQ 16>
			<cfset local.type = "DISCOVER" />		
		
		<!--- Need to Add More - Diners Club, JCB, etc --->
		
		</cfif>
		
		<cfreturn local.type />
	</cffunction>
	
	
	<cffunction name="_numbersOnly" access="private" returntype="any">
		<cfreturn reReplace(arguments[1], "[^[:digit:]]", "", "ALL") />
	</cffunction>
	
	<cfscript>
		
		
	//http://cflib.org/udf/isMod10
	/**
	* Checks to see whether a string passed to it passes the Luhn algorithm (also known as the Mod10 algorithm)
	* V2 update by Christopher Jordan cjordan@placs.net
	* V3 update by Peter J. Farrell (cjordan@placs.netpjf@maestropublishing.com)
	*
	* @param number      String to check. (Required)
	* @return Returns a boolean.
	* @author Scott Glassbrook (cjordan@placs.netpjf@maestropublishing.comcflib@vox.phydiux.com)
	* @version 3, March 2, 2006
	*/
	function _isMod10(number) {
	var nDigits = Len(arguments.number);
	var parity = nDigits MOD 2;
	var digit = "";
	var sum = 0;
	
	for (i=0; i LTE nDigits - 1; i=i+1) {
	digit = Mid(arguments.number, i+1, 1);
	if ((i MOD 2) EQ parity) {
	digit = digit * 2;
	if (digit GT 9) {
	digit = digit - 9;
	}
	}
	sum = sum + digit;
	}
	
	if (NOT sum MOD 10) return TRUE;
	else return FALSE;
	}
	</cfscript>
	

	
</cfcomponent>