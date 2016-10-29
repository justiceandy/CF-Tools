<cfcomponent hint="Handles Paypal Interaction">
  <!--- Example Paypal Payment Submission --->

  <!--- Submit Payment --->
  <cffunction name="submitPayment" access="public" hint="Submits payment response to paypal">
    <cfargument name="account" required="true" type="struct" hint="Paypal Application Info">
    <cfargument name="payment" required="true" type="struct" hint="Customer Payment Info">
    <cfargument name="verbosity" default="MEDIUM" type="string" hint="Debug Value">
    <cfargument name="log" default="true" type="boolean" hint="Boolean. Send to Logstash">
    <cfargument name="returnType" type="string" default="struct" hint="Struct/JSON">
    <cfargument name="validate" type="boolean" default="false">

    <cfset street = payment.customer.billing.address1 & " " & payment.customer.billing.address2>

    <cfset requestBody = account.body &
      "TRXTYPE[#len(payment.method.type)#]=#payment.method.type#&"&
      "TENDER[#len(payment.method.tender)#]=#payment.method.tender#&"&
      "AMT[#len(payment.total.decimal)#]=#payment.total.decimal#&"&
      "EXPDATE[#len(payment.card.exp.full)#]=#payment.card.exp.full#&"&
      "ACCT[#len(payment.card.number)#]=#payment.card.number#&"&
      "VERBOSITY[#len(arguments.verbosity)#]=#arguments.verbosity#&"&
      "street[#len(street)#]=#urlEncodedFormat(street)#&"&
      "zip[#len(payment.customer.billing.zip)#]=#payment.customer.billing.zip#&"&
      "cvv2[#len(payment.card.cvc)#]=#payment.card.cvc#&"&
      "custIP[#len(payment.customer.ip)#]=#payment.customer.ip#&"&
      "REQUEST_ID[#len(payment.requestID)#]=#payment.requestID#">

    <!--- Log Payment Request in Logstash --->

    <!--- Submit to Paypal --->
    <cfhttp url="#application.PayflowURL#" result="paypalResponse" method="post" resolveurl="yes" timeout="30">
     <cfhttpparam type="header" name="Connection" value="close">
     <cfhttpparam type="header" name="Content-Type" value="text/namevalue">
     <cfhttpparam type="header" name="Content-Length" value="#Len(requestBody)#">
     <cfhttpparam type="header" name="Host" value="#application.PayflowURL#">
     <cfhttpparam type="header" name="X-VPS-REQUEST-ID" value="#payment.requestID#">
     <cfhttpparam type="header" name="X-VPS-CLIENT-TIMEOUT" value="30">
     <cfhttpparam type="header" name="X-VPS-VIT-Integration-Product" value="Coldfusion">
     <cfhttpparam type="header" name="X-VPS-VIT-Integration-Version" value="11.0">
     <cfhttpparam type="body" encoded="no" value="#requestBody#">
    </cfhttp>

    <!--- Process Response --->
    <cfinvoke component="paypal" method="processResponse" returnVariable="processedResponse">
      <cfinvokeargument name="response" value="#paypalResponse.filecontent#">
      <cfinvokeargument name="payment" value="#arguments.payment#">
      <cfinvokeargument name="log" value="#arguments.log#">
    </cfinvoke>

    <!--- Construct Response --->
    <cfset response = {
      paypalResponse: processedResponse,
      status: 200,
      message: "success",
      submission: paypalResponse.filecontent,
      payment: arguments.payment
    }>

    <!--- Save Order --->
    <cfinvoke component="cfc.orders" method="savePayment" returnVariable="savedresponse">
      <cfinvokeargument name="order" value="#response#" />
    </cfinvoke>

    <!--- Remove CC from Response Data --->
    <cfset structDelete(response.payment, "card")>
    <cfset response.savedResult = savedResponse>

    <cfif arguments.returnType EQ "json">
      <cfreturn serializeJson(response)>
    <cfelse>
      <cfreturn response>
    </cfif>
  </cffunction>

  <!--- Process Response --->
  <cffunction name="processResponse" access="public" hint="process payment response">
    <cfargument name="returnType" default="struct" type="string">
    <cfargument name="response" required="true" type="string">
    <cfargument name="payment" required="true" type="struct">

    <cfset responseStruct = structNew()>
      <!--- loop each param returned in encoded contents, break at each '&' char --->
    <cfloop list="#arguments.response#" delimiters="&" index="line">
      <!--- find = sign, everything to left is formFieldName, everything to right is value --->
      <cfset break = Find("=", line)>
      <cfset leftBreak = break - 1>
      <cfset rightBreak = len(line) - break>
      <!--- break values at points to parse --->
      <cfset formField = left(line, leftBreak)>
      <cfset value = right(line, rightBreak)>
      <!--- put results into a structure --->
      <cfset responseStruct["#formField#"] = value>
    </cfloop>
    <cfreturn responseStruct>
  </cffunction>

</cfcomponent>
