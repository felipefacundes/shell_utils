cloudflare_warp_tips()
{
( cat <<'EOF'
# cloudflare warp tips

Method 1 - This is the best method using wgcf

WGCF is an unofficial, cross-platform CLI for Cloudflare Warp. It works with Wireguard. 
So before installing WGCF make sure you’ve installed

Install the dependencies:

$ yay -S wireguard-dkms
$ sudo pacman -S openresolv
$ sudo pacman -S wireguard-tools
$ sudo pacman -S wgcf

Restart System... (You’ve to restart your system if you install wireguard-dkms.)

Now we will create a Warp account
$ wgcf register

And generate a Wireguard configuration using that account information
$ cd /tmp && wgcf generate && cd -
$ sudo cp /tmp/wgcf-profile.conf /etc/wireguard/

Let’s connect now
$ wg-quick up wgcf-profile

Verify that warp=on
$ curl https://www.cloudflare.com/cdn-cgi/trace/

Probably you’d like to run Warp every time when your system boots. You can do that with help of systemd
$ sudo systemctl enable --now wg-quick@wgcf-profile 
Or
$ sudo systemctl enable --now wireguard@wgcf-profile

If you want to disconnect, run
$ wg-quick down wgcf-profile

Troubleshoot
$ sudo rm /etc/resolv.conf; echo -e "nameserver 94.140.14.15\nnameserver 94.140.15.16" | sudo tee -a /etc/resolv.conf
$ sudo rm /etc/resolvconf.conf
$ echo -e "resolv_conf=/etc/resolv.conf\nname_servers=94.140.14.15\nname_servers=94.140.15.16" | sudo tee -a /etc/resolvconf.conf
$ sudo rm -f /etc/wireguard/wgcf-profile.conf; cd /tmp; wgcf generate && sudo cp /tmp/wgcf-profile.conf /etc/wireguard/; cd -

Your secondary DNS can be your gateway
See with:
$ ip r

Font:
    https://scirex.me/bits/setup-cloudflare-warp/
    https://bobcares.com/blog/install-cloudflare-warp-on-linux/

================================================================================================================

Method 2 - for me it's not very functional, using warp-cli

$ yay -S cloudflare-warp-bin
$ sudo systemctl start warp-svc.service
$ sudo systemctl enable --now warp-svc.service
$ systemctl --user enable --now warp-taskbar

$ warp-cli register
Or
$ warp-cli delete && warp-cli register

$ warp-cli connect
$ warp-cli enable-always-on

This command makes my internet stop unfortunately. That's why I prefer the first method.
$ warp-cli set-mode warp+doh   

Verify that warp=on
$ curl https://www.cloudflare.com/cdn-cgi/trace/

DNS only mode via DoH: 
$ warp-cli set-mode doh

Optional
$ warp-cli set-families-mode full

Font:
    https://developers.cloudflare.com/warp-client/get-started/linux/
    https://blog.cloudflare.com/announcing-warp-for-linux-and-proxy-mode/

================================================================================================================
https://1.1.1.1/help
EOF
) | less -i -R
}
