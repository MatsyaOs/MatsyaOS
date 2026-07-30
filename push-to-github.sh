#!/bin/bash
cd /home/mister/matsyaos-repo
git lfs push origin main 2>&1
git push origin main 2>&1
echo "DONE"
