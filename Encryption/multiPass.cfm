<cfset myPlainText = URLEncodedFormat("So sorry NSA - this will take a *lot* of money and time to read if you don't have the keys below!") />
<cfset myKeyA = "VpugAocKZVP8BZfamx96Yw==" />
<cfset myKeyB = "d9Q7BQSj0kSUi8SAk4Yyuw==" />
<cfset myKeyC = "nbyDHAbVd7phDAsCHaQFRw==" />
<cfset myKeyD = "+MMCUM2ky1R5+NLBPMQtGA==" />
<cfset myKeyE = "88aI0pHXxXct764aya7Cag==" />
<cfset myKeyF = "79UX4qPVEVe8EoXPhh0HGA==" />
<cfset myCipherText = ToBase64( Encrypt(myPlainText,myKeyA,'AES/CBC/PKCS5Padding','HEX') ) />
<cfset myCipherText = URLEncodedFormat( Encrypt(ToBase64(myCipherText),myKeyB,'AES/CBC/PKCS5Padding','HEX') ) />
<cfset myCipherText = ToBase64( Encrypt( ToBase64(myCipherText),myKeyC,'BLOWFISH/CBC/PKCS5Padding','Base64') ) />
<cfset myCipherText = ToBase64( Encrypt( URLEncodedFormat(myCipherText),myKeyD,'AES/CBC/PKCS5Padding','HEX') ) />
<cfset myCipherText = Encrypt( ToBase64(myCipherText),myKeyE,'BLOWFISH/CBC/PKCS5Padding','Base64') />
<cfset myCipherText = Encrypt( URLEncodedFormat(myCipherText),myKeyF,'AES/CBC/PKCS5Padding','HEX') />
<cfoutput>#myCipherText#</cfoutput>