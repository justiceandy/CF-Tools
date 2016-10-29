<!--- Template Uses Freight TSI Freight Rate but since they dont have an API, we will spoof a logged In User through
session cookies
  Proof of Concept demo, not really usefull
--->


<!---- Log into TSI Website --->
<cfhttp url="http://tracking.carrierlogistics.com/scripts/trp.pol/web-login.htm" method="post">
  <cfhttpparam name="wlogin" type="formfield" value="TSI-LOGIN-USER" />
  <cfhttpparam name="wpword" type="formfield"  value="TSI-LOGIN-PASSWORD" />
</cfhttp>

<cfset sessionArray = cfhttp.responseHeader["Set-cookie"]>
<cfset sessionCookie = toString(sessionArray[1])>
<cfset userCookie = toString(sessionArray[2])>

<cfset firstPiece = listGetAt(sessionCookie, 1, ";")>
<cfset lastPiece = listGetAt(sessionCookie, 1, "=")>


<cfset str = userCookie>
<cfset pos = findNoCase(";", str)>
<cfset piece = (pos ? left(str, pos - 1) : str)>

<cfset str2 = sessionCookie>
<cfset pos2 = findNoCase(";", str)>
<cfset piece2 = (pos2 ? left(str2, pos2 - 1) : str2)>
<cfset userID = replace(piece2, "user-id=", "")>
<!--- set session Key --->
<cfset sessionKey = replace(piece, "seskey=", "")>
<cfset userID = replace(userID, "; path=/scr", "")>

<cfdump var="#sessionKey#">
<cfdump var="#userID#">


<style>
	#maintable{
		display:none;
	}
	#sidenavdiv{
		display:none;
	}
</style>

<!--- Get Rate Form --->
<cfhttp url="http://tracking.carrierlogistics.com/scripts/trp.pol/ratequote.htm" method="get" result="rateForm">
  <cfhttpparam name="wlogin" type="header" value="TSI-LOGIN-NAME" />
</cfhttp>

<!--- Get Side Bar Contents --->
<cfhttp url="http://tracking.carrierlogistics.com/scripts/trp.pol/main-frame.r?language=&seskey=#sessionKey#&startpage=&pronum=&ponum=&date=&nav=side"
        result="sideBar" method="get">

<!---
full String Properties for Rate Quote Template
http://localhost:8500/CFTools/TSI/ratequote.htm?shipdate=04%2F16%2F2013&vbterms=P&servtype=S&vozip=97020&vocity=%2C+OR&vdzip=&vdcity=%2C+&declval=0&wpieces%5B1%5D=&wpallets%5B1%5D=&wweight%5B1%5D=
&vclass%5B1%5D=&wlength%5B1%5D=&wwidth%5B1%5D=&wheight%5B1%5D=&wpieces%5B2%5D=&wpallets%5B2%5D=&wweight%5B2%5D=&vclass%5B2%5D=&wlength%5B2%5D=
&wwidth%5B2%5D=&wheight%5B2%5D=&wpieces%5B3%5D=&wpallets%5B3%5D=&wweight%5B3%5D=&vclass%5B3%5D=&wlength%5B3%5D=&wwidth%5B3%5D=&wheight%5B3%5D=
&wpieces%5B4%5D=&wpallets%5B4%5D=&wweight%5B4%5D=&vclass%5B4%5D=&wlength%5B4%5D=&wwidth%5B4%5D=&wheight%5B4%5D=&wpieces%5B5%5D=&wpallets%5B5%5D=
&wweight%5B5%5D=&vclass%5B5%5D=&wlength%5B5%5D=&wwidth%5B5%5D=&wheight%5B5%5D=&wpieces%5B6%5D=&wpallets%5B6%5D=&wweight%5B6%5D=&vclass%5B6%5D=
&wlength%5B6%5D=&wwidth%5B6%5D=&wheight%5B6%5D=&wpieces%5B7%5D=&wpallets%5B7%5D=&wweight%5B7%5D=&vclass%5B7%5D=&wlength%5B7%5D=&wwidth%5B7%5D=
&wheight%5B7%5D=&wpieces%5B8%5D=&wpallets%5B8%5D=&wweight%5B8%5D=&vclass%5B8%5D=&wlength%5B8%5D=&wwidth%5B8%5D=&wheight%5B8%5D=
&seskey=jbaBldUchIdiikLk&language=&nav=side&ConsZip=&ConsState=&ConsCity=&ShipZip=97020&ShipState=OR&ShipCity=&DeclValue=0&ConsCOD=0
&FromMod=ratequote&carrier=&custno=&qkwords=&PcsT=0&PltT=0&WgtT=0&searchcity=
--->

<!--- Request Rate from Carrier [append url properties, once all properties exist, template will process and return quote contents for pricing] --->
<cfhttp url="http://tracking.carrierlogistics.com/scripts/trp.pol/ratequote.htm?seskey=#sessionKey#&language=&nav=side" result="quoteForm" method="get">

<!---
<cfoutput>
<script type="text/javascript">
	var wrapper= document.createElement('div');
	wrapper.innerHTML= '#toString(trim(quoteForm.fileContent))#';
	var div= wrapper.firstChild;
</script>
</cfoutput>
--->
