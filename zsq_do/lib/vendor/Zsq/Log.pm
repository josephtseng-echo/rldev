package Zsq::Log;
use DBI;
use Log::Log4perl::Level;
use Log::Log4perl qw(:easy);

sub new {
	my $this = shift;
	my $class = ref($this) || $this;
	my $self = {};
	bless $self, $class;
	return $self;
}

sub error {
	my ($self, $package_name, $str) = @_;
	my $log = Log::Log4perl::get_logger($package_name);
	$log->error($str);	
}

1;
