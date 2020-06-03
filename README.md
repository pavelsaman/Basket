# Basket

Basket - keep track of your shopping lists

## Description

The **basket** application takes care of your shopping lists in a text form. You 
can add items to categories, you can delete them, and of course list them at 
your will.

The app provides three main verbs that represent three actions that you can 
perform with your shopping lists:

```
--list
--add
--delete
--rename
```

This application requires you set up an environment variable **BASKET_DIR** with 
a path to a directory where shopping lists will be stored. If not set, the app 
will inform you upon startup and exit with an error code 1.

## Instalation

First get the current version - either clone this repository and use actual master branch, or download the last release.

```
$ perl Makefile.PL
$ make
$ make test
# make install
```

Use `bin/basket` as the frontend for this app, so it's useful to copy this script into `$PATH` or use `$ make INST_SCRIPT=<dir from $PATH>`

## Usage

```
Usage: basket [-l [-c category --before date --after date --dates]
               | -a -c category -i item
               | -d <-c category [ -i item ] | -i item>
               | --rename old:new ]
```

## Options

```
Options:
    -l|--list       Lists all items, could be combined with:
                     -c|--category, --before, --after, --dates
    -a|--add        Adds a new item into a specified category
    -d|--delete     Deletes either the whole category (and therefore
                     all its items) or one item within a specified
                     category.
    --rename        Renames a category, argument is given in the following
                     format: old_category_name:new_category_name

    -c|--category   Specifies a category name, could be used with --list,
                     has to be used with --add and --delete. Could be repeated
                     when used with --list and --delete without --item.
    -i|--item       Specifies an item, has to be used with --add and
                     with --delete when no --category is specified. Could be 
                     used (even mroe times) with --delete when --category
                     is specified.
    --before        Filters only items added before a certain date. Could 
                     be used with --list.
    --after         Filters only items added after a certain date. Could 
                     be used with --list.
    --dates         Prints when items were added along with their names. Could 
                     be used with --list.

    --usage         Prints the usage line.
    --help          Prints this message.
    --man           Prints the whole man page.
    --version       Prints the current version.
```

## Examples

To add a new item to category electronics:

```
$ basket --add --category electronics --item keyboard
$ basket -a -c electronics -i keyboard
```

To see every item in every category:

```
$ basket --list
$ basket
```

To see every item in category electronics:

```
$ basket -l -c electronics
```

To see every item added between 1st of March and 1st of April 
in category electronics:
```
$ basket -l -c electronics --after 2020-03-01 --before 2020-04-01
```

To see everything after 1st of March:

```
$ basket -l --after 2020-03-01
```

To add dates (of when items were added) to the previous output:

```
$ basket -l -c electronics --after 2020-03-01 --before 2020-04-01 --dates
```

To delete one item from one category:

```
$ basket --delete -i keyboard -c electronics
$ basket -d -i keyboard -c electronics
```

To delete more items from all categories:

```
$ bsket -d -i keyboard -i "cisco router"
```

To delete one category (and therefore all items from it):
```
$ basket -d -c electronics
```

To delete more categories (and all items in them):

```
$ basket -d -c electronics -c kitchen
```

You can add more same items, if you print out your shopping list then, 
it will show up in the output like so:

```
$ basket -l
electronics:
 2x RJ-45 cable
```

The quantity shows up only if you have more items on your shopping list.
If you delete such an item:

```
$ basket -d -c electronics -i "RJ-45 cable"
```

it will wipe it out completely, _NOT_ descrease the quantity.

## More information

Read more information in `doc/` folder, see the man page, help, or usage line.