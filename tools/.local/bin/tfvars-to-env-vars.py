#!/usr/bin/env python3
import sys

import hcl2

vars = hcl2.load(sys.stdin)
for k, v in vars.items():
    print(f'export TF_VAR_{k}="{v}"')
