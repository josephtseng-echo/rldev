package Todo::Model::BaseModel;
use Zsq::Db;
use Data::Dumper;
use DateTime::Format::Strptime;
use POSIX qw( strftime );


sub new {
	my $invocant = shift;
	my $class = ref($invocant) || $invocant;
	my $self = {};
	$self->{'args'} = @_;
	bless $self, $class;
	return $self;
}

sub db {
	my ($self) = @_;
	if(!defined($self->{'db'}) && !$self->{'db'}){
		$self->{'db'} = Zsq::Db->new($self->{'args'});
	}	
	return $self->{'db'};
}

sub now_time{
	my $now_time = strftime("%Y-%m-%d %H:%M:%S", localtime);
	return $now_time;
}

1;
