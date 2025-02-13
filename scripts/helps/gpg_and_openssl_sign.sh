sign_document()
{
(
cat <<'EOF'
# Sign document tips

1. Create key and cert with Openssl

$ openssl req -x509 -newkey rsa:2048 -keyout mykey.pem -out cert.pem -days 365 
or
$ openssl req -x509 -newkey rsa:2048 -keyout mykey.pem -out cert.pem -days 365 -nodes

2. make .p12 from key and cert

$ openssl pkcs12 -export -out identity.p12 -inkey mykey.pem -in cert.pem

3. Import to Firefox (or chrome, any browser)
more : https://askubuntu.com/questions/122058/how-do-i-make-a-digital-certificate-available-to-libreoffice-writer-for-digital
Import .p12 to firefox certificate 

Or use: kleopatra

4. Certificate ready to use in LibreOffice

================================================================

Generating a key with gpg
The next step is to generate a gpg key that will be used for the signing. 
The command for this will be run by the user that will do the signing of the files. To do this, issue the command:

$ gpg --gen-key
Or
$ gpg --full-generate-key

Check:
$ gpg --list-keys
$ gpg --list-secret-keys --keyid-format=long

Signing the file
The signing of a file is quite simple. From terminal window, change into the directory containing the file to be signed. 
I’ll demonstrate with the file ~/Downloads/gpg.docx. From the terminal window, issue the command:

$ gpg --sign gpg.docx

You will be prompted for the passphrase you used when generating your gpg key. 
If you have multiple gpg keys on your system, you can specify which key via associated email address, like so:

$ gpg --sign --default-key email@address gpg.docx

Where email@address is the address associated with the key to use. If you’re not sure what keys you have on your system, 
issue the command:

$ gpg --list-keys

Once you’ve entered they passphrase for the key, the file will be signed and a new file generated with the .gpg extension. 
With that file signed, you can verify the signature with the command:

$ gpg --verify gpg.docx.gpg

Font: https://www.techrepublic.com/article/how-to-sign-a-file-on-linux-with-gpg/

=========================================================================================================================

Making and verifying signatures
A digital signature certifies and timestamps a document. If the document is subsequently modified in any way, 
a verification of the signature will fail. A digital signature can serve the same purpose as a hand-written signature 
with the additional benefit of being tamper-resistant. The GnuPG source distribution, for example, is signed so that users 
can verify that the source code has not been modified since it was packaged.

Creating and verifying signatures uses the public/private keypair in an operation different from encryption and decryption. 
A signature is created using the private key of the signer. The signature is verified using the corresponding public key. 
For example, Alice would use her own private key to digitally sign her latest submission to the Journal of Inorganic Chemistry. 
The associate editor handling her submission would use Alice's public key to check the signature to verify that the submission 
indeed came from Alice and that it had not been modified since Alice sent it. A consequence of using digital signatures 
is that it is difficult to deny that you made a digital signature since that would imply your private key had been compromised.

The command-line option --sign is used to make a digital signature. The document to sign is input, and the signed document is output.

$ gpg --output doc.sig --sign doc

You need a passphrase to unlock the private key for
user: "Alice (Judge) <alice@cyb.org>"
1024-bit DSA key, ID BB7576AC, created 1999-06-04

Enter passphrase: 
The document is compressed before signed, and the output is in binary format.
Given a signed document, you can either check the signature or check the signature and recover the original document. 
To check the signature use the --verify option. To verify the signature and extract the document use the --decrypt option. 
The signed document to verify and recover is input and the recovered document is output.

$ gpg --output doc --decrypt doc.sig
gpg: Signature made Fri Jun  4 12:02:38 1999 CDT using DSA key ID BB7576AC
gpg: Good signature from "Alice (Judge) <alice@cyb.org>"
Clearsigned documents
A common use of digital signatures is to sign usenet postings or email messages. 
In such situations it is undesirable to compress the document while signing it. 
The option --clearsign causes the document to be wrapped in an ASCII-armored signature but otherwise does not modify the document.

$ gpg --clearsign doc

You need a passphrase to unlock the secret key for
user: "Alice (Judge) <alice@cyb.org>"
1024-bit DSA key, ID BB7576AC, created 1999-06-04

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

[...]
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v0.9.7 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iEYEARECAAYFAjdYCQoACgkQJ9S6ULt1dqz6IwCfQ7wP6i/i8HhbcOSKF4ELyQB1
oCoAoOuqpRqEzr4kOkQqHRLE/b8/Rw2k
=y6kj
-----END PGP SIGNATURE-----
Detached signatures
A signed document has limited usefulness. Other users must recover the original document from the signed version, 
and even with clearsigned documents, the signed document must be edited to recover the original. 
Therefore, there is a third method for signing a document that creates a detached signature. 
A detached signature is created using the --detach-sig option.

$ gpg --output doc.sig --detach-sig doc

You need a passphrase to unlock the secret key for
user: "Alice (Judge) <alice@cyb.org>"
1024-bit DSA key, ID BB7576AC, created 1999-06-04

Enter passphrase: 
Both the document and detached signature are needed to verify the signature. The --verify option can be to check the signature.

blake% gpg --verify doc.sig doc
gpg: Signature made Fri Jun  4 12:38:46 1999 CDT using DSA key ID BB7576AC
gpg: Good signature from "Alice (Judge) <alice@cyb.org>"

Font: https://www.gnupg.org/gph/en/manual/x135.html
EOF
) | less -i -R
}

tls_sign()
{
(
cat <<'EOF'
# sign with TLS

12.1 Creating a TLS server certificate
Here is a brief run up on how to create a server certificate. It has actually been done this way to get a certificate 
from CAcert to be used on a real server. It has only been tested with this CA, but there shouldn’t be any problem 
to run this against any other CA.

We start by generating an X.509 certificate signing request. As there is no need for a configuration file, you may simply enter:

  $ gpgsm --generate-key >example.com.cert-req.pem
  Please select what kind of key you want:
     (1) RSA
     (2) Existing key
     (3) Existing key from card
  Your selection? 1
I opted for creating a new RSA key. The other option is to use an already existing key, by selecting 2 and entering the so-called keygrip. 
Running the command ‘gpgsm --dump-secret-key USERID’ shows you this keygrip. Using 3 offers another menu to create a certificate directly 
from a smart card based key.

Let’s continue:

  What keysize do you want? (3072)
  Requested keysize is 3072 bits
Hitting enter chooses the default RSA key size of 3072 bits. Keys smaller than 2048 bits are too weak on the modern Internet. 
If you choose a larger (stronger) key, your server will need to do more work.

  Possible actions for a RSA key:
     (1) sign, encrypt
     (2) sign
     (3) encrypt
  Your selection? 1
Selecting “sign” enables use of the key for Diffie-Hellman key exchange mechanisms (DHE and ECDHE) in TLS, 
which are preferred because they offer forward secrecy. Selecting “encrypt” enables RSA key exchange mechanisms, 
which are still common in some places. Selecting both enables both key exchange mechanisms.

Now for some real data:

  Enter the X.509 subject name: CN=example.com
This is the most important value for a server certificate. Enter here the canonical name of your server machine. 
You may add other virtual server names later.

  E-Mail addresses (end with an empty line):
  > 
We don’t need email addresses in a TLS server certificate and CAcert would anyway ignore such a request. Thus just hit enter.

If you want to create a client certificate for email encryption, this would be the place to enter your mail address (e.g. joe@example.org). 
You may enter as many addresses as you like, however the CA may not accept them all or reject the entire request.

  Enter DNS names (optional; end with an empty line):
  > example.com
  > www.example.com
  > 
Here I entered the names of the services which the machine actually provides. You almost always want to include the canonical name here too. 
The browser will accept a certificate for any of these names. As usual the CA must approve all of these names.

  URIs (optional; end with an empty line):
  >
It is possible to insert arbitrary URIs into a certificate; for a server certificate this does not make sense.

  Create self-signed certificate? (y/N)
Since we are creating a certificate signing request, and not a full certificate, we answer no here, or just hit enter for the default.

We have now entered all required information and gpgsm will display what it has gathered and ask whether to create the certificate request:

  These parameters are used:
      Key-Type: RSA
      Key-Length: 3072
      Key-Usage: sign, encrypt
      Name-DN: CN=example.com
      Name-DNS: example.com
      Name-DNS: www.example.com

  Proceed with creation? (y/N) y
gpgsm will now start working on creating the request. As this includes the creation of an RSA key it may take a while. 
During this time you will be asked 3 times for a passphrase to protect the created private key on your system. A pop up window will 
appear to ask for it. The first two prompts are for the new passphrase and for re-entering it; the third one is required to actually 
create the certificate signing request.

When it is ready, you should see the final notice:

  Ready.  You should now send this request to your CA.
Now, you may look at the created request:

  $ cat example.com.cert-req.pem
  -----BEGIN CERTIFICATE REQUEST-----
  MIIClTCCAX0CAQAwFjEUMBIGA1UEAxMLZXhhbXBsZS5jb20wggEiMA0GCSqGSIb3
  DQEBAQUAA4IBDwAwggEKAoIBAQDP1QEcbTvOLLCX4gAoOzH9AW7jNOMj7OSOL0uW
  h2bCdkK5YVpnX212Z6COTC3ZG0pJiCeGt1TbbDJUlTa4syQ6JXavjK66N8ASZsyC
  Rwcl0m6hbXp541t1dbgt2VgeGk25okWw3j+brw6zxLD2TnthJxOatID0lDIG47HW
  GqzZmA6WHbIBIONmGnReIHTpPAPCDm92vUkpKG1xLPszuRmsQbwEl870W/FHrsvm
  DPvVUUSdIvTV9NuRt7/WY6G4nPp9QlIuTf1ESPzIuIE91gKPdrRCAx0yuT708S1n
  xCv3ETQ/bKPoAQ67eE3mPBqkcVwv9SE/2/36Lz06kAizRgs5AgMBAAGgOjA4Bgkq
  hkiG9w0BCQ4xKzApMCcGA1UdEQQgMB6CC2V4YW1wbGUuY29tgg93d3cuZXhhbXBs
  ZS5jb20wDQYJKoZIhvcNAQELBQADggEBAEWD0Qqz4OENLYp6yyO/KqF0ig9FDsLN
  b5/R+qhms5qlhdB5+Dh+j693Sj0UgbcNKc6JT86IuBqEBZmRCJuXRoKoo5aMS1cJ
  hXga7N9IA3qb4VBUzBWvlL92U2Iptr/cEbikFlYZF2Zv3PBv8RfopVlI3OLbKV9D
  bJJTt/6kuoydXKo/Vx4G0DFzIKNdFdJk86o/Ziz8NOs9JjZxw9H9VY5sHKFM5LKk
  VcLwnnLRlNjBGB+9VK/Tze575eG0cJomTp7UGIB+1xzIQVAhUZOizRDv9tHDeaK3
  k+tUhV0kuJcYHucpJycDSrP/uAY5zuVJ0rs2QSjdnav62YrRgEsxJrU=
  -----END CERTIFICATE REQUEST-----
  $
You may now proceed by logging into your account at the CAcert website, choose Server Certificates - New, 
check sign by class 3 root certificate, paste the above request block into the text field and click on Submit.

If everything works out fine, a certificate will be shown. Now run

$ gpgsm --import
and paste the certificate from the CAcert page into your terminal followed by a Ctrl-D

  -----BEGIN CERTIFICATE-----
  MIIEIjCCAgqgAwIBAgIBTDANBgkqhkiG9w0BAQQFADBUMRQwEgYDVQQKEwtDQWNl
   [...]
  rUTFlNElRXCwIl0YcJkIaYYqWf7+A/aqYJCi8+51usZwMy3Jsq3hJ6MA3h1BgwZs
  Rtct3tIX
  -----END CERTIFICATE-----
  gpgsm: issuer certificate (#/CN=CAcert Class 3 Ro[...]) not found
  gpgsm: certificate imported
  
  gpgsm: total number processed: 1
  gpgsm:               imported: 1
gpgsm tells you that it has imported the certificate. It is now associated with the key you used when creating the request. 
The root certificate has not been found, so you may want to import it from the CACert website.

To see the content of your certificate, you may now enter:

  $ gpgsm -K example.com
  /home/foo/.gnupg/pubring.kbx
  ---------------------------
  Serial number: 4C
         Issuer: /CN=CAcert Class 3 Root/OU=http:\x2f\x2fwww.[...]
        Subject: /CN=example.com
            aka: (dns-name example.com)
            aka: (dns-name www.example.com)
       validity: 2015-07-01 16:20:51 through 2016-07-01 16:20:51
       key type: 3072 bit RSA
      key usage: digitalSignature keyEncipherment
  ext key usage: clientAuth (suggested), serverAuth (suggested), [...]
    fingerprint: 0F:9C:27:B2:DA:05:5F:CB:33:D8:19:E9:65:B9:4F:BD:B1:98:CC:57
I used -K above because this will only list certificates for which a private key is available. To see more details, 
you may use --dump-secret-keys instead of -K.

To make actual use of the certificate you need to install it on your server. Server software usually expects 
a PKCS\#12 file with key and certificate. To create such a file, run:

  $ gpgsm --export-secret-key-p12 -a >example.com-cert.pem
You will be asked for the passphrase as well as for a new passphrase to be used to protect the PKCS\#12 file. 
The file now contains the certificate as well as the private key:

  $ cat example-cert.pem
  Issuer ...: /CN=CAcert Class 3 Root/OU=http:\x2f\x2fwww.CA[...]
  Serial ...: 4C
  Subject ..: /CN=example.com
      aka ..: (dns-name example.com)
      aka ..: (dns-name www.example.com)
  
  -----BEGIN PKCS12-----
  MIIHlwIBAzCCB5AGCSqGSIb37QdHAaCCB4EEggd9MIIHeTk1BJ8GCSqGSIb3DQEu
  [...many more lines...]
  -----END PKCS12-----
  $
Copy this file in a secure way to the server, install it there and delete the file then. You may export the file again 
at any time as long as it is available in GnuPG’s private key database.

Font: https://www.gnupg.org/documentation/manuals/gnupg/Howto-Create-a-Server-Cert.html
EOF
) | less -i -R
}

create_gpg_key()
{
(
cat <<'EOF'
# How to create GPG keypairs
Susan Lauber

Previously, in Getting Started with GnuPG, I explained how to import a public key to encrypt a file and verify a signature. 
Now learn how to create your own GPG key pair, add an email address, and export the public key.

Creating a GPG keypair

To receive an encrypted file that only you can open, you first need to create a key pair and then share your public key. 
Creating the key pair is similar to creating ssh keys in that you choose a key size, specify an identifier, and set a passphrase.

The gpg command has three options for creating a key pair:

The --quick-generate-key option requires you to specify the USER-ID field on the command line and optionally an algorithm, usage, 
and expire date. It implements defaults for all other options.
The --generate-key option prompts for the real name and email fields before asking for a confirmation to proceed. 
In addition to creating the key, it also stores a revocation certificate.
The --full-generate-key option, demonstrated below, provides a dialog for all options.
The quick and full generate options can also be used in a batch mode as documented in the man page.

Let's describe the options on the full generate option:

$ gpg --full-generate-key
Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
Your selection?
The first question is what kind of key algorithm you want. Defaults are that for a reason. 
Unless you have a company policy that specifies otherwise, choose the default of RSA and RSA for your multi-use or email exchange key pair.

RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (2048)
Next is the key size. Longer is not always better, but I would definitely go with 2048 or 4096. 
The Fedora and Red Hat security keys we imported in the last article are both 4096 in length.

Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0)
Check company policies for how long the key should be valid. Then consider your security habits as well. 
Notice the default is "does not expire." I usually go with years for an email key. 
For signing keys, I think about the expected lifetime of the objects I am signing. 
If you don't expire the key, it is never automatically revoked even if the private key is compromised. 
If you do expire the key, you need a plan to update and rotate keys before the expiration. 
You are asked to confirm your selection before continuing.

The next set of prompts constructs the identity.

GnuPG needs to construct a user ID to identify your key.

Real name: Best User
Email address: bestuser@example.com
Comment: Best Company
You selected this USER-ID:
    "Best User (Best Company) <bestuser@example.com>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit?
The Real name is the name of a person, company, or product. Email address is the contact email for the key, 
and the optional Comment can identify a company, use, or version. You can use the gpg --list-keys command 
to view some of the identities for imported keys. Here are a few examples:

Red Hat, Inc. (Product Security) <secalert@redhat.com>
Fedora (32) <fedora-32-primary@fedoraproject.org>
Fedora (iot 2019) <fedora-iot-2019@fedoraproject.org>
Fedora EPEL (8) <epel@fedoraproject.org>
Susan Lauber (Lauber System Solutions, Inc.) <sml@laubersolutions.com>
After confirming the settings, you are prompted for a passphrase for the private key. 
The gpg command requires an agent for this, so you may find that you need to be logged in directly as the user. 
If you are on a graphical desktop such as GNOME, the agent may be a graphical pop-up box. Once completed, 
the key information is displayed on the screen.

Additionally, a lot of random bytes are needed to generate the key. A newly installed virtual machine may not have enough entropy. 
You can check the available entropy on a system by viewing a proc file:

$ cat /proc/sys/kernel/random/entropy_avail
3859
If the value is less than 3000, you may need to generate more entropy. Besides the keyboard and mouse activity that is suggested 
in the output of the gpg command, additional entropy sources can be configured with the rng-tools package. 
A Red Hat knowledge article explains how to configure rngd to use the /dev/urandom device for additional entropy.

Editing a GPG key

Occasionally you need to edit a key. You can change expiration dates and passwords, sign or revoke keys, 
and add and remove emails and photos.

$ gpg --edit-key bestuser@example.com
gpg>
At the subprompt, help or a ? lists the available edit commands.

To add an email address, you will actually add a USER-ID value.

gpg> adduid
Real name: Best User
Email address: bestuser@someschool.edu
Comment: Student account
You selected this USER-ID:
    "Best User (Student account) <bestuser@someschool.edu>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O
You can use list to show the identities, uid to select an identity, and deluid to delete an identity. 
The quit command exits the edit utility and prompts you to save your changes.

After adding a new USER-ID, both identities are shown when listing the key.

$ gpg --list-keys
gpg: checking the trustdb
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
gpg: next trustdb check due at 2021-04-23
/home/bestuser/.gnupg/pubring.kbx
---------------------------------
pub   rsa2048 2020-04-23 [SC] [expires: 2021-04-23]
      CC1795E6F83B091A7B813A6D94F45C144CD3559D
uid           [ultimate] Best User (Student account) <bestuser@someschool.edu>
uid           [ultimate] Best User (Best Company) <bestuser@example.com>
sub   rsa2048 2020-04-23 [E] [expires: 2021-04-23]
Export the public key to share with others

For others to send you encrypted messages that can only be decrypted with your private key, you must first share your public key. 
Use the --export option to export the key from the keyring to a file. In most cases, you will want to make sure the key file does 
not contain any binary characters so it can be displayed on a web page. The -a or --armor option encodes the output to plain text. 
The -o or --output option saves the output to a specified file instead of displaying it to standard out on the screen.

$ gpg --export --armor --output bestuser-gpg.pub
To allow other people a method of verifying the public key, also share the fingerprint of the public key in email signatures and even on business cards. 
The more places it appears, the more likely others will have a copy of the correct fingerprint to use for verification.

$ gpg --fingerprint
Publishing your exported GPG public key and fingerprint on your web site is a simple way to share the key. 
The key can also be shared on public keyservers, which also work with email program plugins.

Wrap up

GnuPG can help you better secure your communications and ensure that files originate from where you believe they should. 
Consider using it the next time you are sharing important files.

EOF
) | less -i -R
}

simple_pki() {
(
cat <<'EOF'
# PKI tips
See complete tutorial: https://pki-tutorial.readthedocs.io/en/latest/simple/

To construct the PKI, we first create the Simple Root CA and its CA certificate. We then use the root CA to create the Simple Signing CA. 
Once the CAs are in place, we issue an email-protection certificate to employee Fred Flintstone and a TLS-server certificate 
to the webserver at www.simple.org. Finally, we look at the output formats the CA needs to support and show how to view 
the contents of files we have created.

All commands are ready to be copy/pasted into a terminal session. When you have reached the end of this page, 
you will have performed all operations you are likely to encounter in a PKI.

To get started, fetch the Simple PKI example files and change into the new directory:

git clone https://bitbucket.org/stefanholek/pki-example-1
cd pki-example-1
Configuration Files
We use one configuration file per CA:

Root CA Configuration File
Signing CA Configuration File
And one configuration file per CSR type:

Email Certificate Request Configuration File
TLS Server Certificate Request Configuration File
Please familiarize yourself with the configuration files before you continue.

1. Create Root CA
1.1 Create directories
mkdir -p ca/root-ca/private ca/root-ca/db crl certs
chmod 700 ca/root-ca/private
The ca directory holds CA resources, the crl directory holds CRLs, and the certs directory holds user certificates.

1.2 Create database
cp /dev/null ca/root-ca/db/root-ca.db
cp /dev/null ca/root-ca/db/root-ca.db.attr
echo 01 > ca/root-ca/db/root-ca.crt.srl
echo 01 > ca/root-ca/db/root-ca.crl.srl
The database files must exist before the openssl ca command can be used. The file contents are described in Appendix B: CA Database.

1.3 Create CA request
openssl req -new \
    -config etc/root-ca.conf \
    -out ca/root-ca.csr \
    -keyout ca/root-ca/private/root-ca.key
With the openssl req -new command we create a private key and a certificate signing request (CSR) for the root CA. 
You will be asked for a passphrase to protect the private key. The openssl req command takes its configuration from the [req] 
section of the configuration file.

1.4 Create CA certificate
openssl ca -selfsign \
    -config etc/root-ca.conf \
    -in ca/root-ca.csr \
    -out ca/root-ca.crt \
    -extensions root_ca_ext
With the openssl ca command we issue a root CA certificate based on the CSR. The root certificate is self-signed and serves as the starting 
point for all trust relationships in the PKI. The openssl ca command takes its configuration from the [ca] section of the configuration file.

2. Create Signing CA
2.1 Create directories
mkdir -p ca/signing-ca/private ca/signing-ca/db crl certs
chmod 700 ca/signing-ca/private
The ca directory holds CA resources, the crl directory holds CRLs, and the certs directory holds user certificates. 
We will use this layout for all CAs in this tutorial.

2.2 Create database
cp /dev/null ca/signing-ca/db/signing-ca.db
cp /dev/null ca/signing-ca/db/signing-ca.db.attr
echo 01 > ca/signing-ca/db/signing-ca.crt.srl
echo 01 > ca/signing-ca/db/signing-ca.crl.srl
The contents of these files are described in Appendix B: CA Database.

2.3 Create CA request
openssl req -new \
    -config etc/signing-ca.conf \
    -out ca/signing-ca.csr \
    -keyout ca/signing-ca/private/signing-ca.key
With the openssl req -new command we create a private key and a CSR for the signing CA. You will be asked for a passphrase to protect the 
private key. The openssl req command takes its configuration from the [req] section of the configuration file.

2.4 Create CA certificate
openssl ca \
    -config etc/root-ca.conf \
    -in ca/signing-ca.csr \
    -out ca/signing-ca.crt \
    -extensions signing_ca_ext
With the openssl ca command we issue a certificate based on the CSR. The command takes its configuration from the [ca] section of the 
configuration file. Note that it is the root CA that issues the signing CA certificate! Note also that we attach a different set of extensions.

3. Operate Signing CA
3.1 Create email request
openssl req -new \
    -config etc/email.conf \
    -out certs/fred.csr \
    -keyout certs/fred.key
With the openssl req -new command we create the private key and CSR for an email-protection certificate. We use a request configuration file 
specifically prepared for the task. When prompted enter these DN components: DC=org, DC=simple, O=Simple Inc, CN=Fred Flintstone, 
emailAddress=fred@simple.org. Leave other fields empty.

3.2 Create email certificate
openssl ca \
    -config etc/signing-ca.conf \
    -in certs/fred.csr \
    -out certs/fred.crt \
    -extensions email_ext
We use the signing CA to issue the email-protection certificate. The certificate type is defined by the extensions we attach. 
A copy of the certificate is saved in the certificate archive under the name ca/signing-ca/01.pem (01 being the certificate serial number in hex.)

3.3 Create TLS server request
SAN=DNS:www.simple.org \
openssl req -new \
    -config etc/server.conf \
    -out certs/simple.org.csr \
    -keyout certs/simple.org.key
Next we create the private key and CSR for a TLS-server certificate using another request configuration file. 
When prompted enter these DN components: DC=org, DC=simple, O=Simple Inc, CN=www.simple.org. Note that the subjectAltName must 
be specified as environment variable. Note also that server keys typically have no passphrase.

3.4 Create TLS server certificate
openssl ca \
    -config etc/signing-ca.conf \
    -in certs/simple.org.csr \
    -out certs/simple.org.crt \
    -extensions server_ext
We use the signing CA to issue the server certificate. The certificate type is defined by the extensions we attach. 
A copy of the certificate is saved in the certificate archive under the name ca/signing-ca/02.pem.

3.5 Revoke certificate
openssl ca \
    -config etc/signing-ca.conf \
    -revoke ca/signing-ca/01.pem \
    -crl_reason superseded
Certain events, like certificate replacement or loss of private key, require a certificate to be revoked before its scheduled expiration date. 
The openssl ca -revoke command marks a certificate as revoked in the CA database. It will from then on be included in CRLs issued by the CA. 
The above command revokes the certificate with serial number 01 (hex).

3.6 Create CRL
openssl ca -gencrl \
    -config etc/signing-ca.conf \
    -out crl/signing-ca.crl
The openssl ca -gencrl command creates a certificate revocation list (CRL). The CRL contains all revoked, not-yet-expired certificates 
from the CA database. A new CRL must be issued at regular intervals.

4. Output Formats
4.1 Create DER certificate
openssl x509 \
    -in certs/fred.crt \
    -out certs/fred.cer \
    -outform der
All published certificates must be in DER format [RFC 2585#section-3]. Also see Appendix A: MIME Types.

4.2 Create DER CRL
openssl crl \
    -in crl/signing-ca.crl \
    -out crl/signing-ca.crl \
    -outform der
All published CRLs must be in DER format [RFC 2585#section-3]. Also see Appendix A: MIME Types.

4.3 Create PKCS#7 bundle
openssl crl2pkcs7 -nocrl \
    -certfile ca/signing-ca.crt \
    -certfile ca/root-ca.crt \
    -out ca/signing-ca-chain.p7c \
    -outform der
PKCS#7 is used to bundle two or more certificates. The format would also allow for CRLs but they are not used in practice.

4.4 Create PKCS#12 bundle
openssl pkcs12 -export \
    -name "Fred Flintstone" \
    -inkey certs/fred.key \
    -in certs/fred.crt \
    -out certs/fred.p12
PKCS#12 is used to bundle a certificate and its private key. Additional certificates may be added, typically the certificates 
comprising the chain up to the Root CA.

4.5 Create PEM bundle
cat ca/signing-ca.crt ca/root-ca.crt > \
    ca/signing-ca-chain.pem

cat certs/fred.key certs/fred.crt > \
    certs/fred.pem
PEM bundles are created by concatenating other PEM-formatted files. The most common forms are “cert chain”, “key + cert”, and “key + cert chain”. 
PEM bundles are supported by OpenSSL and most software based on it (e.g. Apache mod_ssl and stunnel.)

5. View Results
5.1 View request
openssl req \
    -in certs/fred.csr \
    -noout \
    -text
The openssl req command can be used to display the contents of CSR files. The -noout and -text options select a human-readable output format.

5.2 View certificate
openssl x509 \
    -in certs/fred.crt \
    -noout \
    -text
The openssl x509 command can be used to display the contents of certificate files. The -noout and -text options have the same purpose as before.

5.3 View CRL
openssl crl \
    -in crl/signing-ca.crl \
    -inform der \
    -noout \
    -text
The openssl crl command can be used to view the contents of CRL files. Note that we specify -inform der because we have already 
converted the CRL in step 4.2.

5.4 View PKCS#7 bundle
openssl pkcs7 \
    -in ca/signing-ca-chain.p7c \
    -inform der \
    -noout \
    -text \
    -print_certs
The openssl pkcs7 command can be used to display the contents of PKCS#7 bundles.

5.5 View PKCS#12 bundle
openssl pkcs12 \
    -in certs/fred.p12 \
    -nodes \
    -info
The openssl pkcs12 command can be used to display the contents of PKCS#12 bundles.

References
http://www.openssl.org/docs/apps/req.html
http://www.openssl.org/docs/apps/ca.html
http://www.openssl.org/docs/apps/x509.html
http://www.openssl.org/docs/apps/crl.html
http://www.openssl.org/docs/apps/crl2pkcs7.html
http://www.openssl.org/docs/apps/pkcs7.html
http://www.openssl.org/docs/apps/pkcs12.html

EOF
) | less -i -R
}

chromium_certificate_method1() {
(
    cat <<'EOF'
# Certificate chromium method 1

See: https://chromium.googlesource.com/chromium/src/+/master/docs/linux/cert_management.md

$ certutil -d sql:$HOME/.pki/nssdb -A -t P -n <certificate nickname> -i <certificate filename>
$ certutil -d sql:$HOME/.pki/nssdb -A -t "CP,CP," -n CertNickName -i cert_file.crt

Details
Get the tools
Debian/Ubuntu: sudo apt install libnss3-tools
Fedora: sudo dnf install nss-tools
Gentoo: su -c "echo 'dev-libs/nss utils' >> /etc/portage/package.use && emerge dev-libs/nss" 

(You need to launch all commands below with the nss prefix, e.g., nsscertutil.)
Opensuse: sudo zypper install mozilla-nss-tools

List all certificates
$ certutil -d sql:$HOME/.pki/nssdb -L

List details of a certificate
$ certutil -d sql:$HOME/.pki/nssdb -L -n <certificate nickname>

Add a certificate
$ certutil -d sql:$HOME/.pki/nssdb -A -t <TRUSTARGS> -n <certificate nickname> -i <certificate filename>

The TRUSTARGS are three strings of zero or more alphabetic characters, separated by commas. 
They define how the certificate should be trusted for SSL, email, and object signing, 
and are explained in the certutil docs or Meena's blog post on trust flags.

For example, to trust a root CA certificate for issuing SSL server certificates, use

certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n <certificate nickname> \
-i <certificate filename>
To import an intermediate CA certificate, use

certutil -d sql:$HOME/.pki/nssdb -A -t ",," -n <certificate nickname> \
-i <certificate filename>
Note: to trust a self-signed server certificate, we should use

certutil -d sql:$HOME/.pki/nssdb -A -t "P,," -n <certificate nickname> \
-i <certificate filename>
Add a personal certificate and private key for SSL client authentication
Use the command:

pk12util -d sql:$HOME/.pki/nssdb -i PKCS12_file.p12
to import a personal certificate and private key stored in a PKCS #12 file. The TRUSTARGS of the personal certificate will be set to “u,u,u”.

Delete a certificate
certutil -d sql:$HOME/.pki/nssdb -D -n <certificate nickname>

EOF
) | less -i -R

}

chromium_certificate_method2() {

(
    cat <<'EOF'
# Certificate chromium method 2

See: https://gist.github.com/ThomasTJdev/14fafc6069a8779b76344c033ec47926

Make Chromium accept self-signed certificates on localhost server.

* Arch
* Nginx

# Navigate to folder
cd /etc/nginx/ssl

# Become a Certificate Authority
# Generate private key
sudo openssl genrsa -des3 -out myCA.key 2048
# Generate root certificate
sudo openssl req -x509 -new -nodes -key myCA.key -sha256 -days 825 -out myCA.pem

# Create CA-signed certs
# Set global variable
NAME=mydomain.com # Use your own domain name
# Generate a private key
sudo openssl genrsa -out $NAME.key 2048
# Create a certificate-signing request
sudo openssl req -new -key $NAME.key -out $NAME.csr

# Generate cert
# Create a config file for the extensions
sudo nano $NAME.ext
# Insert (change $NAME to value manually) >>
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $NAME # Be sure to include the domain name here because Common Name is not so commonly honoured by itself
DNS.2 = app.$NAME # Optionally, add additional domains (I've added a subdomain here)
IP.1 = 192.168.0.13 # Optionally, add an IP address (if the connection which you have planned requires it)
# End <<<

# Create the signed certificate
sudo openssl x509 -req -in $NAME.csr -CA myCA.pem -CAkey myCA.key -CAcreateserial -out $NAME.crt -days 825 -sha256 -extfile $NAME.ext

# Validate cert
openssl verify -CAfile myCA.pem -verify_hostname app.mydomain.com mydomain.com.crt

# Chromium -> SSL -> Manage certificates -> Authorities -> Import (myCA.pem) -> Trust all

EOF
) | less -i -R

}
chromium_certificate_method3() {

(
cat <<'EOF'
# Certificate chromium method 3

See: https://dgu2000.medium.com/working-with-self-signed-certificates-in-chrome-walkthrough-edition-a238486e6858

Self-signed certificates save time and money from purchasing a certificate from a certificate authority (CA). 
They are very popular in development/test environments. But certificates that are not issued by a CA recognized by Chrome can cause users 
to see warnings and error pages. In this post, I will show how to make a self-signed trusted in Chrome, I will walk you through the steps 
with Kyma — an open-source project that provides a Kubernetes cluster for developing cloud-native applications.

Kyma provides a good example for illustration. You will get the error code NET::ERR_CERT_AUTHORITY_INVALID along with the message 
Your connection is not private when accessing the console URL in Chrome. This is because the domain console.kyma.local is not protected by 
a CA trusted by Chrome.


The NET::ERR_CERT_AUTHORITY_INVALID error in Chrome
To get Chrome to accept the self-signed SSL certificate, we need to create a wildcard (*.kyma.local) root certificate and import it into 
the Google Chrome Admin console as a Certificate Authority (CA). We also need to replace the existing certificate/private key stored in 
Kyma TLS secrets with the ones signed by our CA.


Environment:

Linux: Linux Mint 20.2 Cinnamon (Kernel: 5.11.0–25-generic)
Kubernetes version: 1.16.15
Kyma: Installed from main
Chrome: 92.0.4515.131
Step 1: Becoming your own CA
If you own CA, you are authorized to sign certificate requests for yourself. To become your own CA involves creating a private key (.key) 
and a Root Certificate Authority certificate (.pem).

Generate an RSA private key of size 2048:

openssl genrsa -des3 -out rootCA.key 2048
Generate a root certificate valid for two years:

openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 730 -out rootCA.pem
To check just created root certificate:

openssl x509 -in rootCA.pem -text -noout
Tip: Alternatively you can use KeyStore Explorer to verify the certificate generated.

Step 2: Creating a certificate request
Next, we need to generate a certificate signing request (CSR).

First, create a private key to be used during the certificate signing process:

openssl genrsa -out tls.key 2048
Use the private key to create a certificate signing request:

openssl req -new -key tls.key -out tls.csr
Create a config file openssl.cnf with a list of domain names associated with the certificate. 
Edit the domain(s) listed under the [alt_names] section, be sure they match the domain name you want to use.

# Extensions to add to a certificate request
basicConstraints       = CA:FALSE
authorityKeyIdentifier = keyid:always, issuer:always
keyUsage               = nonRepudiation, digitalSignature, keyEncipherment, dataEncipherment
subjectAltName         = @alt_names
[ alt_names ]
DNS.1 = *.kyma.local
Step 3: Signing the certificate request using CA
To sign the CSR using openssl.cnf:

openssl x509 -req \
    -in tls.csr \
    -CA rootCA.pem \
    -CAkey rootCA.key \
    -CAcreateserial \
    -out tls.crt \
    -days 730 \
    -sha256 \
    -extfile openssl.cnf
This will generate a public certificate (tls.crt) signed by our own CA that we can use on the web server later.

To verify that the certificate is built correctly:

openssl verify -CAfile rootCA.pem -verify_hostname console.kyma.local tls.crt
Step 4: Adding CA as trusted to Chrome
Note that with self-signed certificates your browser will warn you that the certificate is not “trusted” because it hasn’t been 
signed by a certification authority that is in the trust list of your browser. To gain Chrome’s trust, follow the instruction:

Open Chrome settings, select Security > Manage Certificates.
Click the Authorities tab, then click the Import… button. This opens the Certificate Import Wizard. Click Next to get to the File to Import screen.
Click Browse… and select rootCA.pem then click Next.
Check Trust this certificate for identifying websites then click OK to finish the process.

The imported certificate will appear in the list of Authorities.

Step 5: Configuring certificate in web server
After we have validated the certificate, we can use it to replace the existing certificate in the Kyma web server.

Downloading and installing Kyma is very straightforward, you just simply follow the documentation here. 
Instead of installing directly from running kyma install command, we are going to install it from GitHub.

Clone the repo and locate the file installation/resources/installer-config-local.yaml.tpl. In Kyma, 
the certificate and its associated key used for TLS are stored in a ConfigMap file in Base64 format.


To convert our certificate and key to Base64:

cat tls.crt | base64 -w0
cat tls.key | base64 -w0
Once it is done, replace both tlsCrt and tlsKey properties with the value above and install Kyma from local sources:

kyma install — source local — src-path <my-sources>
The following message informs that installation is completed successfully.

Kyma is installed in version: 408cb6a6
Kyma installation took:       0 hours 3 minutes
Kyma is running at:           https://192.168.49.2:8443
Kyma console:                 https://console.kyma.local
Kyma admin email:             admin@kyma.cx
Kyma admin password:          ...
Now access the Kyma console URL in Google Chrome, you should see the browser padlock icon in the address bar that indicates 
a secure connection has been established between the browser and the web server.

Google Chrome — No warnings for our self-signed SSL certificate
Conclusion
A Self-signed certificate offers some advantages when used in internal networks and software development phases. 
They are free and save time for verification. By getting Chrome to accept a self-signed certificate, we can establish secure 
browser-to-website connections.

https://dgu2000.medium.com/working-with-self-signed-certificates-in-chrome-walkthrough-edition-a238486e6858
EOF
) | less -i -R

}

chromium_certificate_method4() {

(
cat <<'EOF'
# Certificate chromium method 4

See: https://www.digitalocean.com/community/tutorials/how-to-set-up-and-configure-a-certificate-authority-ca-on-ubuntu-20-04

Prerequisites
To complete this tutorial, you will need access to an Ubuntu 20.04 server to host your CA server. You will need to configure a non-root user 
with sudo privileges before you start this guide. You can follow our Ubuntu 20.04 initial server setup guide to set up a user with appropriate 
permissions. The linked tutorial will also set up a firewall, which is assumed to be in place throughout this guide.

This server will be referred to as the CA Server in this tutorial.

Ensure that the CA Server is a standalone system. It will only be used to import, sign, and revoke certificate requests. 
It should not run any other services, and ideally it will be offline or completely shut down when you are not actively working with your CA.

Note: The last section of this tutorial is optional if you would like to learn about signing and revoking certificates. If you choose 
to complete those practice steps, you will need a second Ubuntu 20.04 server or you can also use your own local Linux computer running 
Ubuntu or Debian, or distributions derived from either of those.

Step 1 — Installing Easy-RSA
The first task in this tutorial is to install the easy-rsa set of scripts on your CA Server. easy-rsa is a Certificate Authority management 
tool that you will use to generate a private key, and public root certificate, which you will then use to sign requests from clients and servers 
that will rely on your CA.

Login to your CA Server as the non-root sudo user that you created during the initial setup steps and run the following:

sudo apt update
sudo apt install easy-rsa
You will be prompted to download the package and install it. Press y to confirm you want to install the package.

At this point you have everything you need set up and ready to use Easy-RSA. In the next step you will create a Public Key Infrastructure, 
and then start building your Certificate Authority.

Step 2 — Preparing a Public Key Infrastructure Directory
Now that you have installed easy-rsa, it is time to create a skeleton Public Key Infrastructure (PKI) on the CA Server. 
Ensure that you are still logged in as your non-root user and create an easy-rsa directory. Make sure that you do not use sudo to run any of 
the following commands, since your normal user should manage and interact with the CA without elevated privileges.

mkdir ~/easy-rsa
This will create a new directory called easy-rsa in your home folder. We’ll use this directory to create symbolic links pointing to the 
easy-rsa package files that we’ve installed in the previous step. These files are located in the /usr/share/easy-rsa folder on the CA Server.

Create the symlinks with the ln command:

ln -s /usr/share/easy-rsa/* ~/easy-rsa/
Note: While other guides might instruct you to copy the easy-rsa package files into your PKI directory, this tutorial adopts a symlink approach. 
As a result, any updates to the easy-rsa package will be automatically reflected in your PKI’s scripts.

To restrict access to your new PKI directory, ensure that only the owner can access it using the chmod command:

chmod 700 /home/sammy/easy-rsa
Finally, initialize the PKI inside the easy-rsa directory:

cd ~/easy-rsa
./easyrsa init-pki
Output
init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: /home/sammy/easy-rsa/pki
After completing this section you have a directory that contains all the files that are needed to create a Certificate Authority. 
In the next section you will create the private key and public certificate for your CA.

Step 3 — Creating a Certificate Authority
Before you can create your CA’s private key and certificate, you need to create and populate a file called vars with some default values. 
First you will cd into the easy-rsa directory, then you will create and edit the vars file with nano or your preferred text editor:

cd ~/easy-rsa
nano vars
Once the file is opened, paste in the following lines and edit each highlighted value to reflect your own organization info. 
The important part here is to ensure that you do not leave any of the values blank:

~/easy-rsa/vars
set_var EASYRSA_REQ_COUNTRY    "US"
set_var EASYRSA_REQ_PROVINCE   "NewYork"
set_var EASYRSA_REQ_CITY       "New York City"
set_var EASYRSA_REQ_ORG        "DigitalOcean"
set_var EASYRSA_REQ_EMAIL      "admin@example.com"
set_var EASYRSA_REQ_OU         "Community"
set_var EASYRSA_ALGO           "ec"
set_var EASYRSA_DIGEST         "sha512"
When you are finished, save and close the file. If you are using nano, you can do so by pressing CTRL+X, then Y and ENTER to confirm. 
You are now ready to build your CA.

To create the root public and private key pair for your Certificate Authority, run the ./easy-rsa command again, this time with the build-ca option:

./easyrsa build-ca
In the output, you’ll see some lines about the OpenSSL version and you will be prompted to enter a passphrase for your key pair. 
Be sure to choose a strong passphrase, and note it down somewhere safe. You will need to input the passphrase any time that you 
need to interact with your CA, for example to sign or revoke a certificate.

You will also be asked to confirm the Common Name (CN) for your CA. The CN is the name used to refer to this machine in the context 
of the Certificate Authority. You can enter any string of characters for the CA’s Common Name but for simplicity’s sake, press ENTER 
to accept the default name.

Output
. . .
Enter New CA Key Passphrase:
Re-Enter New CA Key Passphrase:
. . .
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:

CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/home/sammy/easy-rsa/pki/ca.crt
Note: If you don’t want to be prompted for a password every time you interact with your CA, you can run the build-ca command with the nopass option, 
like this:

./easyrsa build-ca nopass
You now have two important files — ~/easy-rsa/pki/ca.crt and ~/easy-rsa/pki/private/ca.key — which make up the public and private components of 
a Certificate Authority.

ca.crt is the CA’s public certificate file. Users, servers, and clients will use this certificate to verify that they are part 
of the same web of trust. Every user and server that uses your CA will need to have a copy of this file. 
All parties will rely on the public certificate to ensure that someone is not impersonating a system and performing a Man-in-the-middle attack.

ca.key is the private key that the CA uses to sign certificates for servers and clients. If an attacker gains access to your CA and, 
in turn, your ca.key file, you will need to destroy your CA. This is why your ca.key file should only be on your CA machine and that, 
ideally, your CA machine should be kept offline when not signing certificate requests as an extra security measure.

With that, your CA is in place and it is ready to be used to sign certificate requests, and to revoke certificates.

Step 4 — Distributing your Certificate Authority’s Public Certificate
Now your CA is configured and ready to act as a root of trust for any systems that you want to configure to use it. You can add the CA’s certificate 
to your OpenVPN servers, web servers, mail servers, and so on. Any user or server that needs to verify the identity of another user or server in your 
network should have a copy of the ca.crt file imported into their operating system’s certificate store.

To import the CA’s public certificate into a second Linux system like another server or a local computer, first obtain a copy of the ca.crt file 
from your CA server. You can use the cat command to output it in a terminal, and then copy and paste it into a file on the second computer that 
is importing the certificate. You can also use tools like scp, rsync to transfer the file between systems. However we’ll use copy and paste with 
nano in this step since it will work on all systems.

As your non-root user on the CA Server, run the following command:

cat ~/easy-rsa/pki/ca.crt
There will be output in your terminal that is similar to the following:

Output
-----BEGIN CERTIFICATE-----
MIIDSzCCAjOgAwIBAgIUcR9Crsv3FBEujrPZnZnU4nSb5TMwDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAwwLRWFzeS1SU0EgQ0EwHhcNMjAwMzE4MDMxNjI2WhcNMzAw
. . .
. . .
-----END CERTIFICATE-----
Copy everything, including the -----BEGIN CERTIFICATE----- and -----END CERTIFICATE----- lines and the dashes.

On your second Linux system use nano or your preferred text editor to open a file called /tmp/ca.crt:

nano /tmp/ca.crt
Paste the contents that you just copied from the CA Server into the editor. When you are finished, save and close the file. 
If you are using nano, you can do so by pressing CTRL+X, then Y and ENTER to confirm.

Now that you have a copy of the ca.crt file on your second Linux system, it is time to import the certificate into its 
operating system certificate store.

On Ubuntu and Debian based systems, run the following commands as your non-root user to import the certificate:

Ubuntu and Debian derived distributions
sudo cp /tmp/ca.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
To import the CA Server’s certificate on CentOS, Fedora, or RedHat based system, copy and paste the file contents onto the system 
just like in the previous example in a file called /tmp/ca.crt. Next, you’ll copy the certificate into /etc/pki/ca-trust/source/anchors/, 
then run the update-ca-trust command.

CentOS, Fedora, RedHat distributions
sudo cp /tmp/ca.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust
Now your second Linux system will trust any certificate that has been signed by the CA server.

Note: If you are using your CA with web servers and use Firefox as a browser you will need to import the public ca.crt 
certificate into Firefox directly. Firefox does not use the local operating system’s certificate store. For details on how to add 
your CA’s certificate to Firefox please see this support article from Mozilla on Setting Up Certificate Authorities (CAs) in Firefox.

If you are using your CA to integrate with a Windows environment or desktop computers, please see the documentation on how to use certutil.exe 
to install a CA certificate.

If you are using this tutorial as a prerequisite for another tutorial, or are familiar with how to sign and revoke certificates you can stop here. 
If you would like to learn more about how to sign and revoke certificates, then the following optional section will explain each process in detail.

(Optional) — Creating Certificate Signing Requests and Revoking Certificates
The following sections of the tutorial are optional. If you have completed all the previous steps then you have a fully configured and working 
Certificate Authority that you can use as a prerequisite for other tutorials. You can import your CA’s ca.crt file and verify certificates in 
your network that have been signed by your CA.

If you would like to practice and learn more about how to sign certificate requests, and how to revoke certificates, then these optional sections 
will explain how both processes work.

(Optional) — Creating and Signing a Practice Certificate Request
Now that you have a CA ready to use, you can practice generating a private key and certificate request to get familiar with the signing and 
distribution process.

A Certificate Signing Request (CSR) consists of three parts: a public key, identifying information about the requesting system, 
and a signature of the request itself, which is created using the requesting party’s private key. The private key will be kept secret, 
and will be used to encrypt information that anyone with the signed public certificate can then decrypt.

The following steps will be run on your second Ubuntu or Debian system, or distribution that is derived from either of those. 
It can be another remote server, or a local Linux machine like a laptop or a desktop computer. Since easy-rsa is not available by default 
on all systems, we’ll use the openssl tool to create a practice private key and certificate.

openssl is usually installed by default on most Linux distributions, but just to be certain, run the following on your system:

sudo apt update
sudo apt install openssl
When you are prompted to install openssl enter y to continue with the installation steps. Now you are ready to create a practice CSR with openssl.

The first step that you need to complete to create a CSR is generating a private key. To create a private key using openssl, 
create a practice-csr directory and then generate a key inside it. We will make this request for a fictional server called sammy-server, 
as opposed to creating a certificate that is used to identify a user or another CA.

mkdir ~/practice-csr
cd ~/practice-csr
openssl genrsa -out sammy-server.key
Output
Generating RSA private key, 2048 bit long modulus (2 primes)
. . .
. . .
e is 65537 (0x010001)
Now that you have a private key you can create a corresponding CSR, again using the openssl utility. You will be prompted to fill out a number of fields like Country, State, and City. You can enter a . if you’d like to leave a field blank, but be aware that if this were a real CSR, it is best to use the correct values for your location and organization:

openssl req -new -key sammy-server.key -out sammy-server.req
Output
. . .
-----
Country Name (2 letter code) [XX]:US
State or Province Name (full name) []:New York
Locality Name (eg, city) [Default City]:New York City
Organization Name (eg, company) [Default Company Ltd]:DigitalOcean
Organizational Unit Name (eg, section) []:Community
Common Name (eg, your name or your server's hostname) []:sammy-server
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
If you would like to automatically add those values as part of the openssl invocation instead of via the interactive prompt, you can pass the -subj argument to OpenSSL. Be sure to edit the highlighted values to match your practice location, organization, and server name:

openssl req -new -key sammy-server.key -out server.req -subj \
/C=US/ST=New\ York/L=New\ York\ City/O=DigitalOcean/OU=Community/CN=sammy-server
To verify the contents of a CSR, you can read in a request file with openssl and examine the fields inside:

openssl req -in sammy-server.req -noout -subject
Output
subject=C = US, ST = New York, L = New York City, O = DigitalOcean, OU = Community, CN = sammy-server
Once you’re happy with the subject of your practice certificate request, copy the sammy-server.req file to your CA server using scp:

scp sammy-server.req sammy@your_ca_server_ip:/tmp/sammy-server.req
In this step you generated a Certificate Signing Request for a fictional server called sammy-server. In a real-world scenario, the request could be from something like a staging or development web server that needs a TLS certificate for testing; or it could come from an OpenVPN server that is requesting a certificate so that users can connect to a VPN. In the next step, we’ll proceed to signing the certificate signing request using the CA Server’s private key.

(Optional) — Signing a CSR
In the previous step, you created a practice certificate request and key for a fictional server. You copied it to the /tmp directory on your CA server, emulating the process that you would use if you had real clients or servers sending you CSR requests that need to be signed.

Continuing with the fictional scenario, now the CA Server needs to import the practice certificate and sign it. Once a certificate request is validated by the CA and relayed back to a server, clients that trust the Certificate Authority will also be able to trust the newly issued certificate.

Since we will be operating inside the CA’s PKI where the easy-rsa utility is available, the signing steps will use the easy-rsa utility to make things easier, as opposed to using the openssl directly like we did in the previous example.

The first step to sign the fictional CSR is to import the certificate request using the easy-rsa script:

cd ~/easy-rsa
./easyrsa import-req /tmp/sammy-server.req sammy-server
Output
. . .
The request has been successfully imported with a short name of: sammy-server
You may now use this name to perform signing operations on this request.
Now you can sign the request by running the easyrsa script with the sign-req option, followed by the request type and the Common Name that is included in the CSR. The request type can either be one of client, server, or ca. Since we’re practicing with a certificate for a fictional server, be sure to use the server request type:

./easyrsa sign-req server sammy-server
In the output, you’ll be asked to verify that the request comes from a trusted source. Type yes then press ENTER to confirm this:

Output
You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a server certificate for 3650 days:

subject=
    commonName                = sammy-server


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
. . .
Certificate created at: /home/sammy/easy-rsa/pki/issued/sammy-server.crt
If you encrypted your CA key, you’ll be prompted for your password at this point.

With those steps complete, you have signed the sammy-server.req CSR using the CA Server’s private key in /home/sammy/easy-rsa/pki/private/ca.key. The resulting sammy-server.crt file contains the practice server’s public encryption key, as well as a new signature from the CA Server. The point of the signature is to tell anyone who trusts the CA that they can also trust the sammy-server certificate.

If this request was for a real server like a web server or VPN server, the last step on the CA Server would be to distribute the new sammy-server.crt and ca.crt files from the CA Server to the remote server that made the CSR request:

scp pki/issued/sammy-server.crt sammy@your_server_ip:/tmp
scp pki/ca.crt sammy@your_server_ip:/tmp
At this point, you would be able to use the issued certificate with something like a web server, a VPN, configuration management tool, database system, or for client authentication purposes.

(Optional) — Revoking a Certificate
Occasionally, you may need to revoke a certificate to prevent a user or server from using it. Perhaps someone’s laptop was stolen, a web server was compromised, or an employee or contractor has left your organization.

To revoke a certificate, the general process follows these steps:

Revoke the certificate with the ./easyrsa revoke client_name command.
Generate a new CRL with the ./easyrsa gen-crl command.
Transfer the updated crl.pem file to the server or servers that rely on your CA, and on those systems copy it to the required directory or directories for programs that refer to it.
Restart any services that use your CA and the CRL file.
You can use this process to revoke any certificates that you’ve previously issued at any time. We’ll go over each step in detail in the following sections, starting with the revoke command.

Revoking a Certificate
To revoke a certificate, navigate to the easy-rsa directory on your CA server:

cd ~/easy-rsa
Next, run the easyrsa script with the revoke option, followed by the client name you wish to revoke. Following the practice example above, the Common Name of the certificate is sammy-server:

./easyrsa revoke sammy-server
This will ask you to confirm the revocation by entering yes:

Output
Please confirm you wish to revoke the certificate with the following subject:

subject=
    commonName                = sammy-server


Type the word 'yes' to continue, or any other input to abort.
  Continue with revocation: yes
. . .
Revoking Certificate 8348B3F146A765581946040D5C4D590A
. . .
Note the highlighted value on the Revoking Certificate line. This value is the unique serial number of the certificate that is being revoked. If you want to examine the revocation list in the last step of this section to verify that the certificate is in it, you’ll need this value.

After confirming the action, the CA will revoke the certificate. However, remote systems that rely on the CA have no way to check whether any certificates have been revoked. Users and servers will still be able to use the certificate until the CA’s Certificate Revocation List (CRL) is distributed to all systems that rely on the CA.

In the next step you’ll generate a CRL or update an existing crl.pem file.

Generating a Certificate Revocation List
Now that you have revoked a certificate, it is important to update the list of revoked certificates on your CA server. Once you have an updated revocation list you will be able to tell which users and systems have valid certificates in your CA.

To generate a CRL, run the easy-rsa command with the gen-crl option while still inside the ~/easy-rsa directory:

./easyrsa gen-crl
If you have used a passphrase when creating your ca.key file, you will be prompted to enter it. The gen-crl command will generate a file called crl.pem, containing the updated list of revoked certificates for that CA.

Next you’ll need to transfer the updated crl.pem file to all servers and clients that rely on this CA each time you run the gen-crl command. Otherwise, clients and systems will still be able to access services and systems that use your CA, since those services need to know about the revoked status of the certificate.

Transferring a Certificate Revocation List
Now that you have generated a CRL on your CA server, you need to transfer it to remote systems that rely on your CA. To transfer this file to your servers, you can use the scp command.

Note: This tutorial explains how to generate and distribute a CRL manually. While there are more robust and automated methods to distribute and check revocation lists like OCSP-Stapling, configuring those methods is beyond the scope of this article.

Ensure you are logged into your CA server as your non-root user and run the following, substituting in your own server IP or DNS name in place of your_server_ip:

scp ~/easy-rsa/pki/crl.pem sammy@your_server_ip:/tmp
Now that the file is on the remote system, the last step is to update any services with the new copy of the revocation list.

Updating Services that Support a CRL
Listing the steps that you need to use to update services that use the crl.pem file is beyond the scope of this tutorial. In general you will need to copy the crl.pem file into the location that the service expects and then restart it using systemctl.

Once you have updated your services with the new crl.pem file, your services will be able to reject connections from clients or servers that are using a revoked certificate.

Examining and Verifying the Contents of a CRL
If you would like to examine a CRL file, for example to confirm a list of revoked certificates, use the following openssl command from within your easy-rsa directory on your CA server:

cd ~/easy-rsa
openssl crl -in pki/crl.pem -noout -text
You can also run this command on any server or system that has the openssl tool installed with a copy of the crl.pem file. For example, if you transferred the crl.pem file to your second system and want to verify that the sammy-server certificate is revoked, you can use an openssl command like the following, substituting the serial number that you noted earlier when you revoked the certificate in place of the highlighted one here:

openssl crl -in /tmp/crl.pem -noout -text |grep -A 1 8348B3F146A765581946040D5C4D590A
Output
    Serial Number: 8348B3F146A765581946040D5C4D590A
        Revocation Date: Apr  1 20:48:02 2020 GMT
Notice how the grep command is used to check for the unique serial number that you noted in the revocation step. Now you can verify the contents of your Certificate Revocation List on any system that relies on it to restrict access to users and services.

https://www.digitalocean.com/community/tutorials/how-to-set-up-and-configure-a-certificate-authority-ca-on-ubuntu-20-04
EOF
) | less -i -R
}
create_certificate() {
    
    cat <<'EOF'
# Create certificate help commands
See Faqs commnads:

1. help sign_document
2. help tls_sign
3. help create_gpg_key
4. help simple_pki
5. help chromium_certificate_method1
6. help chromium_certificate_method2 #Nginx
7. help chromium_certificate_method3
8. help chromium_certificate_method4

EOF
}
