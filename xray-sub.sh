#!/bin/bash
while getopts ":u:o:" opt; do
  case $opt in
    u)
      url="$OPTARG"
      ;;
    o)
      output_file="$OPTARG"
      ;;
    \?)
      echo "usage: [-u url] [-o output_file]"
      exit 1
      ;;
  esac
done
if [ ! -n "$url" ]; then
  echo "please enter the json subscribtion url:"
  read url
fi
full_sub=$(curl -s $url)
echo "please select the number of config:"
echo $full_sub | jq '.[].remarks' | nl -s' - ' -w1 -nln
read config_number
config_number=$config_number-1
echo $full_sub | jq ".[${config_number}]" > $output_file
