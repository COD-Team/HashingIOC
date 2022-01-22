Create Table mastermd5
(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    hash nvarchar(32) not null collate nocase, 
    source nvarchar(256), 
    CDDid int
);

Create Table mastersha1
(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    hash nvarchar(40) not null collate nocase, 
    source nvarchar(256), 
    CDDid int
);

Create Table mastersha5
(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    hash nvarchar(64) not null collate nocase, 
    source nvarchar(256), 
    CDDid int
);

Create Table importedmd5
(
    hash nvarchar(32) not null collate nocase, 
    path text 
);

Create Table importedsha1
(
    hash nvarchar(40) not null collate nocase, 
    path text 
);

Create Table importedsha5
(
    hash nvarchar(64) not null collate nocase, 
    path text 
);

Create Table tempmaster 
(
    hash nvarchar(256) not null
);

Create Table templocal 
(
    hash nvarchar(256) not null, path text
);

Create View v_md5 as
    Select importedmd5.hash, importedmd5.path 
    from importedmd5 
        join mastermd5 on mastermd5.hash = importedmd5.hash;

Create View v_sha1 as 
    Select importedsha1.hash, importedsha1.path 
    from importedsha1 
        join mastersha1 on mastersha1.hash = importedsha1.hash;

Create View v_sha5 as 
    Select importedsha5.hash, importedsha5.path 
    from importedsha5 
        join mastersha5 on mastersha5.hash = importedsha5.hash;

Create Unique Index idx_md5 on mastermd5 (hash);
Create Unique Index idx_sha1 on mastersha1 (hash);
Create Unique Index idx_sha5 on mastersha5 (hash);
Create Unique Index idx_imd5 on importedmd5 (hash);
Create Unique Index idx_isha1 on importedsha1 (hash);
Create Unique Index idx_isha5 on importedsha5 (hash);



/*
Select tempmaster.hash from tempmaster join mastermd5 on mastermd5.hash = tempmaster.hash;
drop table mastermd5;
drop table mastersha1;
drop table mastersha5;
drop table importedmd5;
drop table importedSHA1;
drop table importedsha5;
drop table tempmaster;
drop table templocal;
drop table mastertemp;
drop view v_md5;
drop view v_sha1;
drop view v_sha5;
*/
