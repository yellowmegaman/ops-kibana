# ops-kibana

Allows you to deploy kibana via Nomad

Expects "DC" env variable.

Example:

```
levant deploy -address=http://your-nomad-installation-or-cluster:4646 -var-file=vars.yaml ops-kibana.nomad
```
