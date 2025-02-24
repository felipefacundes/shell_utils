#!/usr/bin/env bash

sudo wg-quick up wgcf-profile
echo -e "\nTo disconnect:\nwg-quick down wgcf-profile"