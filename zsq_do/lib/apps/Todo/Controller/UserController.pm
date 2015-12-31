package Todo::Controller::UserController;
use Mojo::Base 'Mojolicious::Controller';
use Text::Trim qw(trim);
use POSIX qw( strftime );
use DateTime::Format::Strptime;
use Mojo::UserAgent;
use Zsq::Auth;
use Todo::Model::UserModel;
use Data::Dumper;


#html login
sub user_login {
	my $c = shift;
	my $result;
	my $res;
	my $user_id;	
	my $auth = new Zsq::Auth();
	$auth->init($c);
	my $auth_check = $auth->login_check();
	my $var = {'msg' => '对不起，请登陆。'};
	if($auth_check){
        return 1;
	}
	
	my $params = $c->req->params->to_hash;
	my $kgLoginTicket = $params->{"kgLoginTicket"};			
	if($params && $kgLoginTicket){
		if($kgLoginTicket){
			my $check_opd = $auth->login_check_opd($kgLoginTicket);
			if($check_opd){
				my $db_configs = $c->config('db');
				my $db_interface = $db_configs->{'default'};				
				my $user_model = Todo::Model::UserModel->new($db_interface);
				my $user_data = {'name' => $check_opd->{'userName'}, 'email' => $check_opd->{'email'}};
				my $check_data = $user_model->add($user_data);				
				if(ref($check_data) eq 'HASH'){
					$auth->login_in($check_data->{'ub_id'}, $check_data);
					return 1;
				}
				if($check_data == -1){
                    $var->{'msg'} = '对不起，此帐号被封闭';
				}
			}
		}
	}
	$c->render(template => 'user/user_login', 'var' => $var);					
	return undef;
}

sub user_sign_out {
	my $c = shift;
	my $auth = new Zsq::Auth();
	$auth->init($c);
	$auth->sign_out();
    $c->render(text => Dumper $auth->get_user_data());
}

#api
sub api_user_pl_create {
	my $c = shift;
	my $c = shift;
	my $params  = $c->req->params->to_hash;
	my $plid = int($params->{'plid'});
	my $username = Trim($params->{'username'});
	if($plid && $username) {
		my $db_configs = $c->config('db');
		my $db_interface = $db_configs->{'default'};
		my $user_model = new Todo::Model::UserModel($db_interface);
		return $c->render(text => Dumper $user_model->user_pl_create($plid, $username));
	}
	return $c->render(text => 'ok');
}

sub api_user_lists {
	my $c = shift;
	my $params  = $c->req->params->to_hash;
	my $pbid = int($params->{'pbid'});

	my $result = {
		"status" => 500,
		"data" => {},
	};

	my $db_configs = $c->config('db');
	my $db_interface = $db_configs->{'default'};
	my $user_model = new Todo::Model::UserModel($db_interface);	
	my @array = $user_model->search({'pbid' => $pbid});
	if(@array && $array[0]){
		$result->{'status'} = 200;
		$result->{'data'} = \@array;
	}
	$c->render(json => $result, status => 200);
}

sub api_user_create {
	my $c = shift;
	my $params = $c->req->params->to_hash;
	my $user_name = $params->{'username'};
	my $pbid = $params->{'pbid'};
	my $user_id = 1;
	my $db_configs = $c->config('db');
	my $db_interface = $db_configs->{'default'};
	my $user_model = new Todo::Model::UserModel($db_interface);
	my $res = 0;
	my $result = {
		"status" => 500,
		"data" => {},
	};	
	if($params && $user_name && $pbid){
		my $res = $user_model->add({'pb_id' => $pbid, 'ub_id' => $user_id,
							  'pu_is_author' => 1, 'pu_is_admin' => 1,
							  'pu_operate_time' => self->now_time(),
									'pu_operate_userid' => $user_id,
									'from_ub_id' => $user_id});
		if($res){
			$result->{'status'} = 200;
		}
			
	}
	$c->render(json => $result, status => 200);
}

1;
