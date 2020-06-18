# nicethings

A program for shared Unix servers, specifically [tilde.town](https://tilde.town), to cheer people up .

# Table of Contents
<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
- [How it works](#how-it-works)
    - [How it works in detail](#how-it-works-in-detail)
- [Installation](#installation)
- [Usage](#usage)
<!-- markdown-toc end -->

# How it works

Each user on the shared Unix server may have a `.nicethings` file. The
`.nicethings` file may be populated with a list of nice messages
created by a user. All users' `.nicethings` files are converted to
lists. All lists are combined into one list. A random nice message is
picked from from this list and is displayed to the user.

## How it works in detail

* Each user has a `~/.nicethings` directory.
* Users can add messages to this file using the `nicethings add "your nice message here"` interface.
* Each message is stored in the file as separate lines. No file format is used.
* Users can display a numbered list of the messages they have stored using the `nicethings ls` interface.
* Users can remove their own messages using the `nicethings rm 2` interface, where the number refers to an item in their list.
* Users can view a random message from a random user using the `nicethings` interface (with no arguments).

# Installation

1. Run `git clone https://github.com/m455/nicethings`
2. Run `cd nicethings`
3. Run `make` for further instructions.

# Usage

```
nicethings [<command>] [<args>]

Commands:
  No command - Print a random nice thing.
  add        - Add a message to the list of nice things.
  ls         - Print a numbered list of the nice things you have added.
  rm         - Remove a message you have added from the list of nice things.

Examples:
  nicethings
  nicethings add \"You are beautiful\"
  nicethings ls
  nicethings rm 2
```
