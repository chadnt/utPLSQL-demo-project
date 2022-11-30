create user &1 identified by &2 quota unlimited on USERS default tablespace USERS;

grant create session, create procedure, create trigger, create type, create table, create sequence, create view to &1;
grant select any dictionary to &1;

exit
