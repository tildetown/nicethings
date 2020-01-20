# nicethings

A Python program to be used on shared unix servers to cheer people up (A little program for [tilde.town](https://tilde.town))

# To-dos

- [ ] Decentralize by adding to and pulling from a text file in a user's home directory

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
# Table of Contents

- [How it works](#how-it-works)
- [Usage](#usage)
    - [Adding a message to the file:](#adding-a-message-to-the-file)
    - [Outputting a random line from list.txt:](#outputting-a-random-line-from-listtxt)

<!-- markdown-toc end -->

# How it works

nicethings stores the user's input into a `list.txt` file if an argument is
given in quotes. If no arguments are given, then a random line from the
`list.txt` file will be displayed.

# Usage

Currently, a user can only add and output nice things to and from a list.txt located in m455's directory

## Adding a message to the file:

`$ nicethings "insert your message here"`

## Outputting a random line from list.txt:

`$ nicethings`
