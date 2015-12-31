package Zsq::Model;
use DBI;

sub new {
	my $class = shift;
	my $self = {
		_dbconfig => shift,
		_dbh => {},
	};
	bless $self, $class;
	return $self;
}

sub setDbConfig {
	my ($self, $config ) = @_;
	if($config){
		$self->{_dbconfig} = $config;
	}
}

sub getDbConfig {
	my ($self) = @_;
	return $self->{_dbconfig};
}

sub initDb {
	my($self, $key) = @_;
	if(!$key){
		$key = 'default';
	}	
	if(exists($self->{_dbconfig}{$key})){
		if(!exists($self->{_dbh}{$key})){
			my $config = $self->{_dbconfig}{$key};
			my $dbh = DBI->connect($config->{'dsn'}, $config->{'login'}, $config->{'pass'},
			{'mysql_enable_utf8' => 1, 'AutoCommit' => 0});
			if (!$dbh) {
				return -1;
			}
			$dbh->do("SET NAMES utf8");
			$dbh->{mysql_auto_reconnect} = 1;
			$self->{_dbh}{$key} = $dbh;
		}
		return $self->{_dbh}{$key};
	}else{
		return 0;
	}
}

sub getDb {
	my($self, $key) = @_;
	if(!$key){
		$key = 'default';
	}
	if(exists($self->{_dbh}{$key})){
		return $self->{_dbh}{$key};
	}else{
		return $self->initDb($key);
	}
}

sub closeDb {
	my($self, $key) = @_;
	if(!$key){
		$key = 'default';
	}
	if(exists($self->{_dbh}{$key})){
		if($self->{_dbh}{$key}){
			$self->{_dbh}{$key}->disconnect();
		}
		delete $self->{_dbh}{$key};
	}
}

1;
