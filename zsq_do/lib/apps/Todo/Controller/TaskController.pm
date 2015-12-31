package Todo::Controller::TaskController;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;
use Text::Trim qw(trim);
use POSIX qw( strftime );
use DateTime::Format::Strptime;
use Mojo::UserAgent;
use Zsq::Auth;

use Todo::Model::TaskModel;

#html view
sub task_lists {
	my $c = shift;
	$c->render(template => 'todo/task_lists');
}


#api json
sub api_task_lists {
	my $c = shift;
	my $result = {
				  "status" => 500,
				  "data" => {},
				 };
	my $db_configs = $c->config('db');
	my $db_interface = $db_configs->{'default'};
	my $task_model = Todo::Model::TaskModel->new($db_interface);
	my @array = $task_model->search({'search' => 'all'});
	$result->{'data'} = \@array;
	$c->render(json => $result, status => 200);
}

sub api_task_status {
	my $c = shift;
	my $params = $c->req->params->to_hash;
	my $id = $params->{'id'} || 0;
	my $status = $params->{'status'} || 0;
	my $user_id = 0;
	my $result = {
		"status" => 500
	};
	my $auth = new Zsq::Auth();
	$auth->init($c);
    $user_id = $auth->get_user_id();
	if($id && $user_id){
		my $db_configs = $c->config('db');
		my $db_interface = $db_configs->{'default'};
		my $task_model = Todo::Model::TaskModel->new($db_interface);
		my $in_status = $task_model->status_reset({'tb_id' => $id, 'tb_status'=>
													   $status, 'ub_id' => $user_id});
		if($in_status){
			$result->{'status'} = 200;
		}
	}
	$c->render(json => $result, status => 200);
}

sub api_task_create {
	my $c = shift;
	my $result = {
		"status" => 500,
		"focus" => "",
		"msg" => ""
	};
	my $params  = $c->req->params->to_hash;
	my $task_name = trim($params->{'task_name'}) || '';
	my $start_time = trim($params->{'start_time'}) || '';
	my $tb_level = $params->{'tb_level'} || 0;
	my $pb_id = $params->{'pb_id'} || 0;
	my $tb_post = $params->{'pb_post'} || '';
	my $end_time = trim($params->{'end_time'});
	my $now_time = strftime("%Y-%m-%d %H:%M:%S", localtime);
	my $user_id = 1;

	if(!defined($task_name)  or ($task_name eq "")){
		$result->{'status'} = 200;
		$result->{'focus'} = 'task_name';
		$result->{'msg'} = '';
	}
	if(!defined($start_time)  or ($start_time eq "")){
		$result->{'status'} = 200;
		$result->{'focus'} = 'start_time';
		$result->{'msg'} = '';
	}
	if(!defined($end_time)  or ($end_time eq "")){
		$result->{'status'} = 200;
		$result->{'focus'} = 'end_time';
		$result->{'msg'} = '';
	}

	my $db_configs = $c->config('db');
	my $db_interface = $db_configs->{'default'};
	my $task_model = Todo::Model::TaskModel->new($db_interface);
	my $in_status = $task_model->add({'ub_id' => $user_id, 'pb_id' => $pb_id,
									  'tb_name' => $task_name, 'tb_level' =>
										  $tb_level, 'tb_post' => $tb_post});
	if($in_status){
		$result->{'status'} = 200;
		$result->{'msg'} = 'ok';
	}
	$c->render(json => $result, status => 200);	
}
1;
