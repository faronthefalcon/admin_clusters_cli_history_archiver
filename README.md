# admin_clusters_cli_history_archiver

# Zsh Cluster History Manager

**Automate, archive, and search your shell command history across multiple Linux servers!**

## Features

- 🔗 **Collects and merges `.zsh_history`** from all servers in your cluster
- 📦 **Deduplicates and chronologically sorts** all command history
- 🗂️ **Archives history files** in an organized, timestamped format
- 📤 **Distributes/synchronizes history archives** back to all servers
- 🔍 **Full-text search** across all command history archives
- 💾 **Rotates your `.zsh_history`** to keep it responsive (last 400 commands)
- 🛡️ **Safe for repeated use**—never lose history!

## Requirements

- access to your servers via public ssh-keys
- **zsh** shell on all servers
- **ssh public key authentication** set up between your primary ("master") server and all other servers/hosts in the cluster
- Utilities: `uuidgen`, `sort`, `uniq`, `xargs`, `rsync`, `scp` (all standard on modern Linux)
- All servers must be addressable by SSH hostname (see [Server Setup](#server-setup))

## Installation

1. **Clone this repository on your primary (master) server into your root of your account.**
2. ** source the file in your .bashrc or .zshrc **
3. (Recommended) **Add the `fs.history.evaluate` function** to the end of your `.zshrc` to automate on every terminal open.
4. Set your HISTSIZE to 10000 and HISTSIZEFILE to 100000
5. Script will montior numbers lines in your terminal history and when it hit the trigger number, it will launch the script and it will do the work on its own.
6. Fast process.

## Server Setup

- Define your servers and hosts at the top of the script:
    ```zsh
    servers=(srv1 srv2 srv3 srv4) [external remote ]
    hosts=(f7 f9)  [local network and private network]
    domainset="example.com"
    ```
- This script will generate hostnames like `srv1.example.com`, `srv2.example.com`, etc.
- **You must have SSH key-based authentication set up from the primary server (`f5`) to all listed servers and hosts.**
- You should be able to run `ssh srv1.signavision.ca` **without entering a password** for this to work unattended.

## Usage

**Manually trigger a full sync/cleanup:**
```sh
fs.collect.history
```

** set your preference in triggering the clean up when your history hit above X line **
