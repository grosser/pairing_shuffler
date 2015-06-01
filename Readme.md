Assign random pairs from a google docs spreadsheet

Install
=======

    gem install pairing_shuffler

Usage
=====

Send out emails to random pairs from a google docs spreadsheet:

### via Rake

```Bash
git clone git://github.com/grosser/pairing_shuffler.git && cd pairing_shuffler
cp credentials.example.yml credentials.yml
# fill it out by following instructions on https://github.com/gimite/google-drive-ruby with an oauth 'installed application' token
rake token
# store token in credentials.yml
rake assign_pairs
```

### via Ruby

```Ruby
PairingShuffler.shuffle(
  client_id: "foo",
  client_secrect: "bar",
  access_token: "baz"
  doc: "document-id-copied-from-url"
)
```

Spreadsheet must have emails in the first column [example](https://docs.google.com/spreadsheet/ccc?key=0Aj3Q63sKeQFodHVWSGs1MjFOeFhQV0lEYnVVbUVUYXc#gid=0)
and possibly a `Away until` column for people that are away (`2013-01-01` format)
```
1: Random text
2: Custom header, Away until
3: email@1.com,
4: email@2.com, 2013-01-01
5: email@3.com,
...
```

Author
======
[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
License: MIT
