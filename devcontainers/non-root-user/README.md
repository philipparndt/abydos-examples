# non-root-user

The two user fields, doing the two different things they mean.

```jsonc
"containerUser": "root",   // docker run -u  — what the container is
"remoteUser": "vscode"     // docker exec -u — what your shell is
```

Open this folder as a project, choose **View ▸ New Terminal in Container**, and:

```sh
whoami          # vscode
id -u           # 1000
touch owned-by-me && ls -l owned-by-me
```

That last one is the interesting line. The checkout is bind-mounted from this
machine, so who owns a file written inside the container is a question with two
answers, and `updateRemoteUserUID` is the spec's answer to it. Abydos does not
honour that field yet — on macOS the runtime papers over it, on Linux it does
not — so this file does not claim it does.
