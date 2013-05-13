Assign random pairs from a google docs spreadsheet

Install
=======

    gem install pairing_shuffler

Usage
=====

Send out emails to random pairs from a google docs spreadsheet:
```Bash
cp config.example.yml config.yml
fill it out
rake assign_pairs
```

### via Ruby

```Ruby
PairingShuffler.shuffle(
  :username => "xyz@gmail.com",
  :password => "123456",
  :doc => "document-id-copied-from-url"
)
```

Spreadsheet should have continuous emails in the first cell starting from cell 3
```
1: don't care
2: don't care
3: email1
4: email2
5: email3
...
```

Author
======
[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
License: MIT<br/>
[![Build Status](https://travis-ci.org/grosser/pairing_shuffler.png)](https://travis-ci.org/grosser/pairing_shuffler)
