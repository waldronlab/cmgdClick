
# `cMDClick`

Package with experiemental functions for fetching curatedMetagenomicData v4
hosted on ClickHouse.

## Installation

```r
BiocManager::install("waldronlab/cMDClick", dependencies = TRUE)
```

## config file

Currently, you'll need a **config.yml** file in the home or parent directory of
this project with your credentials.

Make sure that the **config.yml** has been added to the .gitignore file if you
decide to place the **config.yml** file in the home directory.

Example of the contents of the **config.yml** file:

```
default:
  host: "hostAddress"
  user: "yourUserName"
  password: "yourPassword"
  db: "databaseName"
```

