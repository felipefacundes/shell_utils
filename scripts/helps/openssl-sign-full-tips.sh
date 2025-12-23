openssl_sign()
{
(
cat <<'EOF'
# Openssl tips

If you need to sign and verify a file you can use the OpenSSL command line tool. 
OpenSSL is a common library used by many operating systems (I tested the code using Ubuntu Linux).

I was working on a prototype to sign the source code of open source projects in order to release it including the signature. 
More or less the same idea implemented in Git to sign tag or a commit. Git uses GnuPG, I wanted to do the same using OpenSSL 
to be more general.

Sign a file
To sign a file using OpenSSL you need to use a private key. 
If you don't have an OpenSSL key pair you can create it using the following commands:

openssl genrsa -aes128 -passout pass:<phrase> -out private.pem 4096
openssl rsa -in private.pem -passin pass:<phrase> -pubout -out public.pem

where <phrase> is the passphrase used to encrypt the private key stored in private.pem file. 
The private key is stored in private.pem file and the public key in the public.pem file.

For security reason, I suggest to use 4096 bits for the keys, you can read the reason in this blog post.

When you have the private and public key you can use OpenSSL to sign the file. The default output format of the 
OpenSSL signature is binary. If you need to share the signature over internet you cannot use a binary format. 
You can use for instance Base64 format for file exchange.

You can use the following commands to generate the signature of a file and convert it in Base64 format:

openssl dgst -sha256 -sign <private-key> -out /tmp/sign.sha256 <file>
openssl base64 -in /tmp/sign.sha256 -out <signature>

where <private-key> is the file containing the private key, <file> is the file to sign and <signature> is the file name 
for the digital signature in Base64 format. I used the temporary folder (/tmp) to store the binary format of the 
digital signature. Remember, when you sign a file using the private key, OpenSSL will ask for the passphrase.

The <signature> file can now be shared over internet without encoding issue.

Verify the signature
To verify the signature you need to convert the signature in binary and after apply the verification process of OpenSSL. 
You can achieve this using the following commands:

openssl base64 -d -in <signature> -out /tmp/sign.sha256
openssl dgst -sha256 -verify <pub-key> -signature /tmp/sign.sha256 <file>

where <signature> is the file containing the signature in Base64, <pub-key> is the file containing the public key, 
and <file> is the file to verify.

If the verification is successful, the OpenSSL command will print "Verified OK" message, otherwise it will print "Verification Failure".

I created a gist containing two bash scripts to facilitate the signature and verification tasks. 
The sign.sh script is able to generate the signature of a file using the following command syntax:

sign.sh <file> <private_key>
where <file> is the file to sign and <private_key> is the file containing the private key to use for the signature. 
The signature will be stored in the signature.sha256 file using the Base64 format.

To verify a signature you can use the verify.sh script with the following syntax:

verify.sh <file> <signature> <public_key>
where <file> is the file to verify, <signature> is the file containing the signature (in Base64), 
and <public_key> is the file containing the public key to be used to verify the digital signature.

Font: https://www.zimuel.it/blog/sign-and-verify-a-file-using-openssl
EOF
) | less
}