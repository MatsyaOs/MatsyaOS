#!/bin/bash
cd /home/mister/MatsyaOS
echo mister | sudo -S mkarchiso -v -w /tmp/iso-work -o /home/mister/MatsyaOS/out matsya-iso/profiles/matsya
