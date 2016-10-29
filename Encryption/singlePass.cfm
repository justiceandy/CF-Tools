<cfset original = "This is a block of text we will encrypt"> 
<cfset myPlainText = URLEncodedFormat(original) />
<cfset myKey = "VpugAocKZVP8BZfamx96Yw==" />
<cfset myCipherText = Encrypt(myPlainText,myKey,'AES/CBC/PKCS5Padding','HEX') />
<cfset myDecPlainText = URLDecode( Decrypt(myCipherText,myKey,'AES/CBC/PKCS5Padding','HEX') ) />

<ul>
	<cfoutput>
	<li>Text: #original#</li>
	<li>Cipher: #myCipherText#</li>
	<li>Key: #myKey# </li>
	<li>Dec: #myDecPlainText#</li>
</ul>
</cfoutput>

