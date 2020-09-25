# nicethings

A program for shared Unix servers, specifically [tilde.town](https://tilde.town), to cheer people up.

# Table of Contents

- [How it works](#how-it-works)
    - [How it works in detail](#how-it-works-in-detail)
- [Disclaimer](#disclaimer)
- [Conventions used in this document](#conventions-used-in-this-document)
- [Requirements](#requirements)
- [Quick start](#quick-start)
- [Downloading nicethings](#downloading-nicethings)
    - [Downloading nicethings using git](#downloading-nicethings-using-git)
        - [To download nicethings using git](#to-download-nicethings-using-git)
- [Installing nicethings](#installing-nicethings)
    - [Installing nicethings globally](#installing-nicethings-globally)
        - [To install nicethings globally](#to-install-nicethings-globally)
    - [Installing nicethings locally](#installing-nicethings-locally)
        - [To install nicethings locally](#to-install-nicethings-locally)
    - [Installing nicethings to a custom directory](#installing-nicethings-to-a-custom-directory)
        - [To install nicethings to a custom directory](#to-install-nicethings-to-a-custom-directory)
- [Uninstalling nicethings](#uninstalling-nicethings)
    - [Uninstalling nicethings globally](#uninstalling-nicethings-globally)
        - [To uninstall nicethings globally](#to-uninstall-nicethings-globally)
    - [Uninstalling nicethings locally](#uninstalling-nicethings-locally)
        - [To uninstall nicethings locally](#to-uninstall-nicethings-locally)
- [Using nicethings](#using-nicethings)
    - [Showing the help message](#showing-the-help-message)
        - [To show the help message](#to-show-the-help-message)
    - [Displaying your list](#displaying-your-list)
        - [To display your list](#to-display-your-list)
    - [Adding an item to your list](#adding-an-item-to-your-list)
        - [To add an item to your list](#to-add-an-item-to-your-list)
    - [Removing an item from your list](#removing-an-item-from-your-list)
        - [To remove an item from your list](#to-remove-an-item-from-your-list)
- [List of commands](#list-of-commands)
- [Usage examples](#usage-examples)

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

# Disclaimer

This is a hobby project I built for [tilde.town](tilde.town).

I take no responsibility for anything that nicethings deletes.

Backup anything you don't want deleted.

# Conventions used in this document

* **Note**: Notes signify additional information
* **Tip**: Tips signify an alternate procedure for completing a step
* **Warning**: Warnings signify that damage may occur
* **Example**: Examples provide a visual reference of how a procedure would be carried out in the real world
* `Inline code`: Inline code signifies package names, filenames, or commands
* ```Code block```: Code blocks signify file contents

# Platforms

Below is a list of platforms that nicethings can run on:

* GNU/Linux
* Windows (Using Windows Subsystem for Linux)
* macOS (Using [Homebrew](https://brew.sh/))

# Requirements

The following items must be downloaded and installed before you can use nicethings:

* Racket: [https://racket-lang.org/](https://racket-lang.org/)
* nicethings's source code: [https://git.m455.casa/m455/nicethings](https://git.m455.casa/m455/nicethings)

# Quick start

This section is for users who are familiar with git, a Unix-like command line environment, or
scripting.

1. Make sure [Racket](https://racket-lang.org/) is installed
2. `git clone git://git.m455.casa/nicethings.git`
3. `cd nicethings`
4. `sudo make install-global`
5. `nicethings`

**Note**: To uninstall, run `sudo make uninstall-global`

* `nicethings help` - Displays the help message
* `nicethings add "your nice message here"` - Adds the message inside of quotation marks to your list of nice things
* `nicethings ls` - Displays your list of nice things
* `nicethings rm 2` - Removes the third item from your list. (The list starts at 0)

**Note**: You may need to run `nicethings ls` to see which number corresponds to which item in your list before running `nicethings rm <number>`

# Downloading nicethings

nicethings's source code exists in a public git repository. This makes
accessing the code convenient, because you don't need to sign in or
register for an account to download it.

## Downloading nicethings using git

You can use tools such as `git` to download nicethings's source code. You
will need the source code to install nicethings.

### To download nicethings using git

1. Run `git clone git://git.m455.casa/nicethings.git`

**Note**: This will create a `nicethings` directory in your current directory.

# Installing nicethings

You can either install nicethings globally or locally on your system. A global installation allows all users on a machine to use nicethings, while a local installation only allows one user to use nicethings.

See the options below for installing nicethings:

* [Installing nicethings globally](#installing-nicethings-globally)
* [Installing nicethings locally](#installing-nicethings-locally)
* [Installing nicethings to a custom directory](#installing-nicethings-to-a-custom-directory)

## Installing nicethings globally

This option will install nicethings into `/usr/local/bin/`.

This section assumes you have [downloaded nicethings](#downloading-nicethings).

### To install nicethings globally

1. Run `cd nicethings`
2. Run `sudo make install-global`

## Installing nicethings locally

This option will install nicethings into `~/.local/bin/`.

This section assumes you have [downloaded nicethings](#downloading-nicethings).

### To install nicethings locally

1. Run `cd nicethings`
2. Run `sudo make install-local`

## Installing nicethings to a custom directory

If you wish to have nicethings exist elsewhere on your system, you can also
build a single-file executable. Building a single-file executable
allows you to place the executable in convenient places on your
system, such as a directory on your `$PATH`.

This section assumes you have [downloaded nicethings](#downloading-nicethings).

### To install nicethings to a custom directory

**Warning**: You will have to manually uninstall custom installations

1. Run `cd nicethings`
2. Run `make install-custom location=~/path/to/custom/location`

**Example**: In step 2., you could run `make install-custom location=~/bin/`

# Uninstalling nicethings

Depending on your installation method, you can uninstall a global or local installation of nicethings.

See the options below for uninstalling nicethings:

* [Uninstalling nicethings globally](#uninstalling-nicethings-globally)
* [Uninstalling nicethings locally](#uninstalling-nicethings-locally)

## Uninstalling nicethings globally

This option will remove the `nicethings` executable from `/usr/local/bin/`.

This section assumes you have [downloaded nicethings](#downloading-nicethings).

### To uninstall nicethings globally

1. Run `cd nicethings`
2. Run `sudo make uninstall-global`

## Uninstalling nicethings locally

This option will remove the `nicethings` executable from `~/.local/bin/`.

This section assumes you have [downloaded nicethings](#downloading-nicethings).

### To uninstall nicethings locally

1. Run `cd nicethings`
2. Run `sudo make uninstall-local`

# Using nicethings

This section will teach you how to use nicethings's commands.

This section assumes you have [installed nicethings](#installing-nicethings).

## Showing the help message

The help message will provide a list of available commands. This is list useful in case you forget
the name of a command or how to use a command.

### To show the help message

1. Run `nicethings help`

## Displaying your list

Displaying your list will allow you to view items you have added to your list.
You will notice numbers beside the items in your list.

**Note**: These numbers are useful references for when you want to remove items from your list. For
more information, see the [Removing an Item from Your List](#removing-an-item-from-your-list) topic.

### To display your list

1. Run `nicethings ls`

## Adding an item to your list

Adding an item to your list will save it to a text file to access later.

### To add an item to your list

1. Run `nicethings add "this is an example of an item using double quotation marks"`

**Note**: The double quotation marks are optional, but recommended

## Removing an item from your list

When removing an item from your list, you can reference the numbers beside each
item when [Displaying Your List](#displaying-your-list). You can use these
numbers when removing an item from your list.

### To remove an item from your list

1. Run `nicethings rm 1`

**Note 1**: The "1" in the procedure above will remove the first item in your
list.

**Note 2**: You may need to run `nicethings ls` first to see which numbers correspond
with which item in your list.

# List of commands

This section lists and describes nicethings's commands.

* `help` displays the help message
* `ls` displays your list
* `add` adds an item to your list
* `rm` removes an item from your list

# Usage examples

The examples below assume that you have [added nicethings to your $PATH](#adding-nicethings-to-your-path).

`nicethings help`

`nicethings ls`

`nicethings add "this is a nice message"`

`nicethings rm 1`

**Note**: You may have to run `nicethings ls` to see which number corresponds to which item in your list.
