#!/bin/bash

domain=$1

mkdir $domain
mkdir $domain/subdomains

echo subfinder -d $domain -o $domain/subdomains/subfinder
subfinder -d $domain -o $domain/subdomains/subfinder

echo sublist3r -d $domain -o $domain/subdomains/sublist3r
sublist3r -d $domain -o $domain/subdomains/sublist3r

echo findomain -t $domain -u $domain/subdomains/findomain
findomain -t $domain -u $domain/subdomains/findomain

echo amass enum -d $domain -o $domain/subdomains/amass-active
amass enum -d $domain -o $domain/subdomains/amass-active

echo amass enum -d $domain -passive -o $domain/subdomains/amass-passive
amass enum -d $domain -passive -o $domain/subdomains/amass-passive

cat $domain/subdomains/subfinder $domain/subdomains/sublist3r $domain/subdomains/findomain $domain/subdomains/amass-active $domain/subdomains/amass-passive > $domain/subdomains/.all.txt

awk '!x[$0]++' $domain/subdomains/.all.txt > $domain/subdomains/$domain

massdns -r ~/Tools/massdns/lists/myresolvers.txt -o L $domain/subdomains/$domain -w $domain/subdomains/$domain.resolved

cat $domain/subdomains/$domain.resolved | httprobe -p http:8443 https:8443 -prefer-https | tee $domain/subdomains/$domain.http
