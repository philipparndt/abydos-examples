# git-scenarios

Nine repositories, each stuck in a state worth looking at. They are made by a
script rather than committed, because a repository inside a repository is a
submodule or a mess:

```sh
./make-scenarios.sh          # or: make scenarios
```

| repository | what it is for |
|---|---|
| `history` | commits, a tag, a merge and a branch — the history view with something in it |
| `uncommitted` | staged, unstaged and untracked changes at once — the changes pane, partial staging, per-line staging |
| `conflict` | a merge stopped in the middle, `UU` on one file |
| `unpushed` | three commits the remote has not seen — the arrow in the history, the push button |
| `behind` | a commit waiting on the remote |
| `detached` | HEAD on a commit rather than a branch |
| `branches` | five branches to switch between |
| `stashed` | two stashes, which are easy to forget |
| `large` | 300 commits, for paging and for speed |

Open one of them as a project. They are throwaway: run the script again and
they are all as they started.
