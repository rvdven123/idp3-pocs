kubectl patch installplan install-v8t5q \
  -n default \
  --type merge \
  -p '{"spec":{"approved":true}}'