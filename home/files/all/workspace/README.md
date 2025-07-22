# Stefans workspace

Contains code

## requirements.txt

The workspace has a global venv for things which are related to the vscode ide in order to be able to have a fixed cross-machine vscode config.

Create it, activate and install:

```sh
$ cd <here>
$ python -m venv --prompt wsenv .venv
$ . .venv/bin/activate
(wsenv) $ pip install --upgrade pip
(wsenv) $ pip install -r requirements.txt
```
