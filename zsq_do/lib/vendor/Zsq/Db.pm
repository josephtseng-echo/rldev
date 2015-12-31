package Zsq::Db;
use DBI;
use Zsq::Log;

sub new {
	my $invocant = shift;
	my $class = ref($invocant) || $invocant;
	my $self = {
		'_dsn' => 'DBI:mysql:database=rldev;host=127.0.0.1',
		'_login' => 'root',
		'_pass' => '123456',
		'_interface' => {},
		'_key' => 'default',
	};
	bless $self, $class;
	$self->_init(@_);
	return $self;
}

sub _init {
	my($self, $args) = @_;
	$self->{'_dsn'} = $args->{'dsn'} || $self->{'_dsn'};
	$self->{'_login'} = $args->{'login'} || $self->{'_login'};
	$self->{'_pass'} = $args->{'pass'} || $self->{'_pass'};
	$self->{'_key'} = $args->{'key'} || $self->{'_key'};
}

sub _initDb {
	my($self) = @_;
	$self->{'_interface'}{$self->{'_key'}} = $self->_initMysql();
}

sub _initMysql {
	my($self) = @_;
	my $dbh = DBI->connect($self->{'_dsn'}, $self->{'_login'}, $self->{'_pass'},
	{'mysql_enable_utf8'=>1, 'AutoCommit'=> 0, 'PrintError' => 0});
	if(!$dbh) {
		return -1;
	}
	$dbh->do('SET NAMES utf8');
	$dbh->{mysql_auto_reconnect} = 1;
	$dbh->{InactiveDestroy} = 1;
	return $dbh;
}

sub close {
	my($self) = @_;
	foreach my $key (keys %{$self->{'_interface'}}) {
		$self->{'_interface'}{$key}->disconnect;
		delete $self->{'_interface'}{$key};
	}
}

sub DESTROY {
	#
}

sub getInterface {
	my($self) = @_;
	if(!exists($self->{'_interface'}{$self->{'_key'}})){
		$self->_initDb();
	}
	return $self;
}

sub fetchDb {
	my($self) = @_;
	return $self->{'_interface'}{$self->{'_key'}};
}

sub fetchAll {
	my($self, $sql, @args) = @_;
	my $sth;
	my @array = ();
	if($self->{'_interface'}{$self->{'_key'}}) {
		$sth = $self->{'_interface'}{$self->{'_key'}}->prepare($sql);
		if($sth){
			if($sth->execute(@args)){
				while (my $row_ref = $sth->fetchrow_hashref()) {
					push @array, $row_ref;
				}
			}else{
				return $self->error("Couldn't execute statement", $sql, @args);
			}
		}else{
			return $self->error("Couldn't prepare statement", $sql, @args);
		}
	}
	return @array;
}

sub fetchRow {
	my($self, $sql, @args) = @_;
	my $sth;
	if($self->{'_interface'}{$self->{'_key'}}) {
		$sth = $self->{'_interface'}{$self->{'_key'}}->prepare($sql);
		if($sth){
			if($sth->execute(@args)){
				my $row_ref = $sth->fetchrow_hashref();
				$sth->finish;
				return $row_ref;
			}else{
				return $self->error("Couldn't execute statement", $sql, @args);
			}
		}else{
			return $self->error("Couldn't prepare statement", $sql, @args);
		}
	}else{
		return {};
	}	
}

sub insert {
	my($self, $sql, @args) = @_;
	my $sth;
	if($self->{'_interface'}{$self->{'_key'}}) {
		$sth = $self->{'_interface'}{$self->{'_key'}}->prepare($sql);
		if($sth){
			if($sth->execute(@args)){
				$self->{'_interface'}{$self->{'_key'}}->commit();
				return $sth->{mysql_insertid};
			}else{
				return $self->error("Couldn't execute statement", $sql, @args);
			}
		}else{
			return $self->error("Couldn't prepare statement", $sql, @args);
		}
	}else{
		return 0;
	}		
}

sub update {
	my($self, $sql, @args) = @_;
	my $sth;
	if($self->{'_interface'}{$self->{'_key'}}) {
		$sth = $self->{'_interface'}{$self->{'_key'}}->prepare($sql);
		if($sth){
			if($sth->execute(@args)){
				$self->{'_interface'}{$self->{'_key'}}->commit();
				return $sth->rows;	
			}else{
				return $self->error("Couldn't execute statement", $sql, @args);
			}
		}else{
			return $self->error("Couldn't prepare statement", $sql, @args);
		}
	}else{
		return 0;
	}	
	
}

sub delete {
	my($self, $sql, @args) = @_;
	my $sth;
	if($self->{'_interface'}{$self->{'_key'}}) {
		$sth = $self->{'_interface'}{$self->{'_key'}}->prepare($sql);
		if($sth){
			if($sth->execute(@args)){
				$self->{'_interface'}{$self->{'_key'}}->commit();
				return $sth->rows;	
			}else{
				return $self->error("Couldn't execute statement", $sql, @args);
			}
		}else{
			return $self->error("Couldn't prepare statement", $sql, @args);
		}
	}else{
		return 0;
	}	
}

sub error {
	my($self, $msg, $sql, @args) = @_;
	my $str;
	$str = $msg.":".$self->{'_interface'}{$self->{'_key'}}->errstr;
	$str = $str."  sql:".$sql." args:qw(@args)";
	Zsq::Log->error("Zsq::Db", $str);
	return 0;
}

1;
