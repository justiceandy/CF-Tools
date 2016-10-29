<!--- encrypt String --->

<!--- Define a top-secret message! --->
<cfset manCrush = "Jason Dean of 12robots.com fame." />
 
<!---
Generate a secret key. The default encryption algorithm
(CFMX_COMPAT) can take any key; however, for all other
algorithms supported by ColdFusion, we have to use the
generateSecretKey() method to get a key of proper byte
length.
 
For this demo, I am using AES (Advanced Encryption Standard),
aka "Rijndael". This is the one Jason Dean has told me to use,
to memorize, to love.
--->
<cfset encryptionKey = generateSecretKey( "AES" ) />
 <cfdump var="E Key = #encryptionKey# "><br />
<!---
Now, let's encrypt our secret message.
 
NOTE: I am using the "hex" encoding because I think it makes
for nicer characters (for printing).
--->
<cfset secret = encrypt(
manCrush,
encryptionKey,
"AES",
"hex"
) />
 
 
<!---
Now, let's decode our secret using AES and our secret key.
 
NOTE: Since the generateSecretKey() algorithm produces a new
secret key each time, if you are persisted your encrypted data,
you ALSO have to persist your encryption key.
--->
<cfset decoded = decrypt(
secret,
encryptionKey,
"AES",
"hex"
) />
 
 
<cfoutput>
 
Original: #manCrush#<br />
 
<br />
 
Secret: #secret#<br />
 
<br />
 
Decoded: #decoded#<br />
 
</cfoutput>