# Issuebot

## features

- get system test issues from TMP(test manage platform)

- push st issues to gieta server includes id,title,content,status,defect description,primary reason,subsystem name(id is primary key)

- bot supports multiple projects, every project has a single thread for its task

- bot can filter effective issue from TMP, inclues 'open','new create','assign' three enumerated value, and persist related data to disk

## how to use

- issue.ini
issue.ini is config file for bot, there are several sections that need to attention.

```ini
[Status]
status means which status need to be pushed gitea server

[Organazations]
organazations means which organazation is watched by bot, count means number of watched by bot
org0,org1,...means nane of organazation.

[Ocpopus]
name of section related to [Organazations] part
repo means gitea's api interface
database means gitea repository, stissue is best practice(system test issue)
```

- project db file
db file's name is usual Organazation's name, it persist st issues that have been pushed to gitea server, so you can update data manually according to your special case. One organazation may have multiple database in TMP, so db file may have multiple section in it.

```ini
[db1]
id = 1, 2, 3
[db2]
id = 1, 2, 3
```

db1, db2 is name of TMP system
