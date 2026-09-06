# secrets

A folder of files the editor is careful with. Two features meet here and they
are not the same one: **the covers**, which are about what is on the screen,
and **SOPS**, which is about what is on the disk. A file can have either, both,
or neither, and all four cases are below.

Open this folder as a project — right-click it and **Open as Subproject** —
because the offer to encrypt is read from the `.sops.yaml` at the *project*
root, and from the top of the repository this folder's rules are not it.

```sh
./install-key.sh      # put the throwaway key where sops looks
./make-fixtures.sh    # write the three files git cannot carry
```

## The files

| file | chip | lock | what it is for |
|---|---|---|---|
| `secrets-dev.yaml` | ● | ● | the ordinary case: decrypt from the bar, edit, ⌘S encrypts it back. Holds a block scalar, so the covers have the hard case to draw |
| `secrets-dev.json` | ● | ● | the same in JSON |
| `secrets-dev.env` | ● | ● | the same in dotenv — encrypted *and* dotenv-shaped, so the chip and the lock stand side by side, chip first |
| `secrets-dev.ini` | ● | ● | the same in INI |
| `secrets-new.yaml` | ● | | plaintext that `.sops.yaml` matches: nothing to decrypt, and the chip offers to encrypt it |
| `config.yaml` | | | the control. No rule matches it and there is nothing in it to hide, so the bar says nothing |
| `.env` | | ● | committed, so the bar reads *Committed to git* |
| `.env.staging` | | ● | written by the script, untracked and unignored: *Not in .gitignore*, and the notice offers the line that fixes it |
| `.env.local` | | ● | written by the script, ignored: covers and no notice — what a real project looks like |
| `secrets.yaml.dec` | | ● | written by the script, ignored: concealed by its name, with no sops anywhere near it |

> **`.env.staging` must stay untracked.** It is the only fixture here defined
> by git *not* having it, so `git add secrets/` — or a `git add .` from the top
> — turns it into the *Committed to git* case and the *Not in .gitignore* one
> stops existing. It will sit in `git status` as an untracked file for as long
> as it is there, and that is not untidiness, it is the fixture.
> `./make-fixtures.sh --clean` takes it away, and running the script again
> brings it back.

## The key

**The project names it, so there is nothing to install.**
`.abydos/tools.json` here says:

```json
{ "sops": { "ageKeyFile": "age-key.txt" } }
```

and the editor hands that file to `sops` as `SOPS_AGE_KEY_FILE` when it
decrypts anything in this project. The path is relative to the project and has
to stay inside it — no absolute path, no `~`, no `..`, no symlink pointing away
— and naming it only ever *adds* a key: `sops` consults the default location
too, so this cannot get in the way of a key you already have.

It is named twice, for the same reason the PlantUML image is: `.abydos` is read
from whichever project is open, so the copy at the top of the repository says
`secrets/age-key.txt` and this one says `age-key.txt`. Either way it resolves.

> `age-key.txt` is committed on purpose. It guards ten invented values and
> nothing else, and it is here so this example can be opened and decrypted
> without generating a key first. **A real project commits its key exactly
> never.** The ciphertext belongs in the repository; the key belongs wherever
> that project keeps its keys — named here, and kept out by `.gitignore`.

### If the editor does not know about that yet

Older builds read no key from the project, and `sops` then looks in the one
place it looks by itself: `~/Library/Application Support/sops/age/keys.txt` —
`os.UserConfigDir()`, not `~/.config`, whatever the same tool does on Linux. A
`SOPS_AGE_KEY_FILE` exported in a shell profile is not seen by an app started
from the Finder, so pointing at the key from a profile works in a terminal and
fails in the editor.

`./install-key.sh` appends the key to that file and says so; `--remove` takes
it out again. It appends rather than replaces, because the file is a list of
identities and `sops` tries all of them.

Without the key by either route, the example is still worth opening: the chip
appears, says *SOPS · encrypted*, and pressing it fails with what `sops` said —
which is the case a machine that has the key can never show you.

## What to try

1. **Open `secrets-dev.yaml`.** The chip at the left edge of the status bar
   reads *SOPS · encrypted*. Press it: the values arrive revealed, the lock
   open beside the chip, and the chip now reads *SOPS · decrypted*. Nothing
   was written anywhere — no `.dec`, no temporary file.
2. **Press the lock.** The values go under covers, the chip does not move.
   The two are different questions and neither answers the other.
3. **Change a password and press ⌘S.** The file on disk is ciphertext again,
   the tab is clean, and the chip reads *encrypted*. Press it once more and
   the edit is there.
4. **Decrypt and save without changing anything.** Nothing is written: `sops`
   encrypts with a fresh key every run, so an encrypt over unchanged text
   would be a new version of a file nobody edited.
5. **Open `secrets-new.yaml`.** Plaintext, and `.sops.yaml` matches its name,
   so the chip offers to encrypt it. `git checkout` puts it back.
6. **Open `.env` and `.env.staging` side by side.** Same covers, different
   notices: one is in the history already, the other is one commit away from
   being. Press the second notice and it offers the `.gitignore` line, after
   which the notice goes on its own.
7. **Open `secrets.yaml.dec`.** Covered by its name alone, block scalar and
   all, with no chip: this is what `helmsec` leaves beside a chart.

## From a terminal

`sops` needs pointing at the key unless it was installed:

```sh
SOPS_AGE_KEY_FILE=age-key.txt sops --decrypt secrets-dev.yaml
SOPS_AGE_KEY_FILE=age-key.txt sops secrets-dev.yaml   # edit in place
```

If a decrypt fails with *failed to parse* rather than *no identity matched*,
the keys file has a line in it that is not an age key. `age` gives up on the
whole file for one bad line, and the fix is in that file rather than here.
