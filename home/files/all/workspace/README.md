# Stefans workspace

Contains code. The structure is as flat as possible and contains experimentation snippets as well as code created in professional projects. Such projects have a single topmost dir with everything related residing below.

## Code Organization

- `3rdparty` - Other peoples code, mostly cloned from github
- `learn_*` - Experimentation with stuff. Might contain a `3rdparty` subdir for clones related to that stuff.

## `requirements.txt`

The workspace has a global venv for things which are related to the vscode ide in order to be able to have a fixed cross-machine vscode config.

Create it, activate and install:

```sh
$ cd <here>
$ python -m venv --prompt wsenv .venv
$ . .venv/bin/activate
(wsenv) $ pip install --upgrade pip
(wsenv) $ pip install -r requirements.txt
```
