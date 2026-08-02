# multi-tier

What a real project's chart looks like: an application and a web front end in
one pod, a database and a cache beside them, and a values file per stage.
Neither half of the pod knows how it was deployed — which is what makes
replacing one container at a time work.

- **app in the cluster** installs the chart and puts *your build of the
  application* in the `app` container. The web half goes on running what the
  chart says, and both keep the environment the chart gave them: `DATABASE_URL`
  from a Secret, `VALKEY_ADDR` from a Service.
- **web in the cluster** does the same for the `web` container, and hands `app`
  back to the chart.
- **app here** runs the application on this machine, with its defaults.

`deploy/values-dev.yaml` is the stage. A real project would encrypt it with
helm-secrets and set `"secrets": true` in the configuration, which runs
`helm secrets upgrade` instead.

Try: run **app in the cluster**, open the forwarded link, then run **web in the
cluster** and watch the app container go back to the chart's image while the
web container becomes yours. Put a breakpoint in `orders` and load the page.
