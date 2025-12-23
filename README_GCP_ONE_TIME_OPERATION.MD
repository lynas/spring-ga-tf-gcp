# GCP resource setup

- This is one time operation only to create gcp resource and allow permission for github action
- `cd` into `config\one-time-config\terraformConfig` directory
- Run following command one time to set up `Workload Identity Federation`

```shell

terrafom init
terrafom plan
terrafom apply

```

- This allows github action to provision terraform commands