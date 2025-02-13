dns_adguard() {
cat <<'EOF' | less -i -R
# dns adguard

Default servers
Use these servers to block ads, trackers and phishing websites.

Servidores padrão
Use esses servidores para bloquear anúncios, rastreadores e sites de phishing.

IPv4:

94.140.14.14
94.140.15.15

IPv6:

2a10:50c0::ad1:ff
2a10:50c0::ad2:ff

================================================================================================================
Family servers
Use these servers to block ads, trackers, phishing and adult websites, and to enforce safe search in your browser.

Servidores familiares
Use esses servidores para bloquear anúncios, rastreadores, sites de phishing e adultos e para impor uma pesquisa 
segura em seu navegador.

IPv4:

94.140.14.15
94.140.15.16

IPv6:

2a10:50c0::bad1:ff
2a10:50c0::bad2:ff

================================================================================================================
Non-filtering servers
"Non-filtering" DNS servers provide a secure and reliable connection, but they don't filter anything 
like the "Default" and "Family protection" servers do.

Servidores sem filtragem
Os servidores DNS "sem filtragem" fornecem uma conexão segura e confiável, mas não filtram nada como 
os servidores "Padrão" e "Proteção familiar".

IPv4:

94.140.14.140
94.140.14.141

IPv6:

2a10:50c0::1:ff
2a10:50c0::2:ff

Font:
    https://adguard-dns.io/en/blog/adguard-dns-new-addresses.html
    https://adguard-dns.io/en/public-dns.html

EOF
}

dns_cloudflare()
{
cat <<'EOF' | less -i -R
# dns cloudflare

IPv4: 1.1.1.1 and 1.0.0.1
IPv6: 2606:4700:4700::1111 and 2606:4700:4700::1001

Font:
    https://1.1.1.1/dns/

EOF
}

dns_google()
{
cat <<'EOF' | less -i -R
# dns google

IPv4: 8.8.8.8 and 8.8.4.4
IPv6: 2001:4860:4860::8888 and 2001:4860:4860::8844

Font:
    https://developers.google.com/speed/public-dns/docs/using

EOF
}
