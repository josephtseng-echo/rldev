package Zsq::Auth;


sub new {
	my $class = shift;
	my $self = {
		_user_id => 'user_id',
		_user_data => 'user_data',
		_mojo_c => '',
	};
	bless $self, $class;
	return $self;
}

sub init {
	my ($self, $mojo_c) = @_;
	$self->{_mojo_c} = $mojo_c;
}

sub login_check {
	my ($self) = @_;
	if($self->{_mojo_c}->session($self->{_user_id}) && $self->{_mojo_c}->session($self->{_user_data})){
		return $self->{_mojo_c}->session($self->{_user_id});
	}else{
		return 0;
	}
}

sub login_in {
	my ($self, $user_id, $user_data) = @_;
	$self->{_mojo_c}->session($self->{_user_id}, $user_id);
	$self->{_mojo_c}->session($self->{_user_data}, $user_data);
}

sub sign_out {
	my ($self) = @_;
	$self->{_user_id} = '';
	$self->{_user_data} = '';
	$self->{_mojo_c}->session($self->{_user_id}, '');
	$self->{_mojo_c}->session($self->{_user_data}, '');	
}

sub get_user_id {
	my ($self) = @_;
	return $self->{_mojo_c}->session($self->{_user_id});
}

sub get_user_data {
	my ($self) = @_;
	return $self->{_mojo_c}->session($self->{_user_data});	
}

sub login_check_opd {
	my ($self, $kgLoginTicket) = @_;
	if($kgLoginTicket){
		my $url = "";
		my $ua = Mojo::UserAgent->new;
		$result = $ua->get($url)->res->json();
		if(($result->{'returnCode'} eq 0) && ($result->{'userInfo'}) ne ""){
			$res = $result->{'userInfo'};
			return $res;
		}else{
			return 0;
		}
	}else{
		return 0;
	}	
}
1;
