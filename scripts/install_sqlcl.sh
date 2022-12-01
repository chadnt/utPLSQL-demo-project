#! /bin/sh

BIN=$HOME/.local/bin
SQLCL_DIR=$BIN/sqlcl
SCRIPTS_DIR=$HOME/scripts

export JAVA_TOOL_OPTIONS=-Dorg.jline.terminal.dumb=true

# Create bin folder
mkdir -p $BIN
cd $BIN

# Install java
sudo apt install openjdk-17-jdk-headless

# Install unzip
sudo apt install unzip

# Download sqlcl
curl --location --remote-name \
    https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-latest.zip
unzip -o sqlcl-latest.zip -d $BIN
rm sqlcl-latest.zip

# Download utplsql-cli
curl --location --remote-name \
    https://github.com/utPLSQL/utPLSQL-cli/releases/download/3.1.9/utPLSQL-cli.zip
unzip -o utPLSQL-cli.zip -d $BIN
rm utPLSQL-cli.zip

# Download utPLSQL
git clone --depth=1 --branch=v3.1.12 https://github.com/utPLSQL/utPLSQL.git $BIN/utplsql
chmod -R go+w $BIN/utplsql

# Install utPLSQL
$SQLCL_DIR/bin/sql \
    sys/nucor@//localhost/xepdb1?oracle.net.disableOob=true as sysdba \
    @$BIN/utplsql/source/install_headless.sql

# Create test user
$SQLCL_DIR/bin/sql \
    sys/nucor@//localhost/xepdb1?oracle.net.disableOob=true as sysdba \
    @$SCRIPTS_DIR/create_user.sql test test
