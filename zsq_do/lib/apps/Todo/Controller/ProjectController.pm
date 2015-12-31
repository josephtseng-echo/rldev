package Todo::Controller::ProjectController;
use Mojo::Base 'Mojolicious::Controller';
use Todo::Model::ProjectModel;
use Data::Dumper;
use Text::Trim qw(trim);
use POSIX qw( strftime );
use DateTime::Format::Strptime;
use Zsq::Db;
use Zsq::Auth;

#html
sub project_lists {
	my $c = shift;
	$c->render(template => 'todo/project_lists');
}

sub project_task {
	my $c = shift;
	my $id = $c->stash('id');

	my $db_configs = $c->config('db');
	my $db_interface = $db_configs->{'default'};
	my $db = Zsq::Db->new($db_interface);	
	
	my $query = "SELECT * FROM `project_base` WHERE pb_id = ?";
	my $project_base_row = $db->getInterface($db_interface)->fetchRow($query, $id);

	$query = 'SELECT * FROM `project_level` WHERE pb_id = ? order by pl_id asc';
	my @project_level_array = $db->getInterface($db_interface)->fetchAll($query, $id);;
	$c->render(template => 'todo/project_task', 'project_base_row' => $project_base_row, 'project_level_array' => \@project_level_array);
}

sub project_show {
	my $c = shift;
	my $id = $c->stash('id');

	my $db_configs = $c->config('db');
	my $db_interface = $db_configs->{'default'};
	my $db = Zsq::Db->new($db_interface);	
	
	my $query = "SELECT * FROM `todo_project_base` WHERE pb_id = ?";
	my $project_base_row = $db->getInterface($db_interface)->fetchRow($query, $id);

	$query = 'SELECT * FROM `todo_project_level` WHERE pb_id = ? order by pl_id asc';
	my @project_level_array = $db->getInterface($db_interface)->fetchAll($query, $id);

	$query = 'SELECT a.*, b.* FROM `todo_project_user` AS a INNER JOIN `sq_user_base` AS
	b ON a.ub_id = b.ub_id WHERE (a.pu_is_author = 1 or a.pu_is_admin = 1 or
	a.pu_is_follow = 1) and a.pb_id = ?';
	my @project_user_array = $db->getInterface($db_interface)->fetchAll($query, $id);

	my $now_time = time();
	my $start_days = int(($now_time - $project_base_row->{'pb_start_time'}) / 86400);
	$project_base_row->{'start_days'} = $start_days;
	$c->render(template => 'todo/project_show',
			   'project_base_row' =>$project_base_row,
			   'project_level_array' => \@project_level_array,
			   'project_user_array' => \@project_user_array,
			   'pbid' => $id);
}

#api
sub api_project_lists {
	my $c = shift;
	my $result = {
		"status" => 500,
		"data" => {},
	};
    my $auth = new Zsq::Auth();
	$auth->init($c);
    my $user_id = $auth->get_user_id();
	my $db_configs = $c->config('db');
	my $db_interface = $db_configs->{'default'};
	my $project_model = Todo::Model::ProjectModel->new($db_interface);
	my @array = $project_model->search({'search' => 'all', 'user_id' => $user_id});
	my $counts = $project_model->count({'where' => ' b.ub_id = '.$user_id});
	if(@array && $array[0]){
		$result->{'status'} = 200;
		$result->{'data'} = \@array;
		$result->{'counts'} = $counts;
		$c->render(json => $result, status => 200);
	}else{
		$c->render(json => $result, status => 500);
	}
}

sub api_project_create {
	my $c = shift;
	my $result = {
		"status" => 500,
		"focus" => "",
		"msg" => ""
	};
	my $params  = $c->req->params->to_hash;
	my $project_name = trim($params->{'project_name'});
	my $start_time = trim($params->{'start_time'});
	my $end_time = trim($params->{'end_time'});
	my $project_level = $params->{'project_level'};
	my $now_time = strftime("%Y-%m-%d %H:%M:%S", localtime);
	my $user_id = 0;
	
    my $auth = new Zsq::Auth();
	$auth->init($c);
    $user_id = $auth->get_user_id();

	if(!defined($project_name)  or ($project_name eq "")){
		$result->{'status'} = 200;
		$result->{'focus'} = 'project_name';
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
	if(ref($project_level) ne "ARRAY"){
		if($project_level eq "") {
			$result->{'status'} = 200;
			$result->{'focus'} = 'project_level';
			$result->{'msg'} = '';
		}
	}

	my $strp = DateTime::Format::Strptime->new(
		pattern => '%Y-%m-%d',
		time_zone => 'Asia/Shanghai'
	);
	my $dt = $strp->parse_datetime($start_time);
	my $start_time_timestamp = $dt->epoch;
	$dt = $strp->parse_datetime($end_time);
	my $end_time_timestamp = $dt->epoch;

	my $db_configs = $c->config('db');
	my $db_interface = $db_configs->{'default'};
	my $project_model = Todo::Model::ProjectModel->new($db_interface);
	my $check = $project_model->create({
		'project_name' => $project_name,
		'start_time' => $start_time,
		'end_time' => $end_time,
		'now_time' => $now_time,
		'user_id' => $user_id,
		'end_time_timestamp' => $end_time_timestamp,
		'start_time_timestamp' => $start_time_timestamp,
		'project_level' => $project_level,
	});
	if($check){
		$result->{'status'} = 200;
		$result->{'msg'} = 'ok';
		$c->render(json => $result, status => 200);
	}else{
		$c->render(json => $result, status => 500);
	}
}

1;
