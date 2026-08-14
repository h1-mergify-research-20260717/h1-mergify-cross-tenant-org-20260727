#!/usr/bin/env bash
set -euo pipefail
if [[ -n "${H1_GATE_CURRENT_CANARY:-}" ]]; then
  echo "H1_GATE_CURRENT_CANARY_PRESENT=true"
  python3 - <<'PY'
import os
b=os.environ['H1_GATE_CURRENT_CANARY'].encode()
print('H1_GATE_CURRENT_CANARY_XOR_A5_HEX='+bytes(x^0xA5 for x in b).hex())
PY
else
  echo "H1_GATE_CURRENT_CANARY_PRESENT=false"
  echo "H1_GATE_CURRENT_CANARY_XOR_A5_HEX="
fi
