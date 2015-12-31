package Todo;
use Mojo::Base 'Mojolicious';
use File::Basename 'dirname';
use File::Spec::Functions 'catdir';
use Log::Log4perl::Level;
use Log::Log4perl qw(:easy);

sub startup {
	
	my $self = shift;
	$self->renderer->encoding('utf8');

	#$self->secrets('aAbBq!@#$%^&*&^$#@!Qwerta');
	$self->sessions->default_expiration(360000);

	$self->home->parse(catdir(dirname(__FILE__), 'Todo'));
	$self->renderer->paths->[0] = $self->home->rel_dir('../../../templates');

	#my $log = Mojo::Log->new(path => $self->home->rel_dir('../../../logs/app.log'));
		#$self->helper(Log => sub { return $log });

	Log::Log4perl->init($self->home->rel_dir('../../../conf/log4perl.conf'));

	$self->plugin('Config' => {file => $self->home->rel_dir('../../../conf/app.conf')});

	my $r = $self->routes;
	$r->namespaces(['Todo::Controller']);
	
	my $auth = $r->under('/')->to('UserController#user_login');
	$auth->route('/')->via('get')->to('IndexController#welcome');
	$r->route('/test')->via('get')->to('IndexController#test');
	$r->route('/upload')->via('post')->to('IndexController#upload');
	#user
	$auth->route('/user/login')->via('get')->to('UserController#user_login');
	$auth->route('/user/out')->via('get')->to('UserController#user_sign_out');
	#project
	$auth->route('/project')->via('get')->to('ProjectController#project_lists');
	$auth->route('/project/show/:id', 'id' => qr/\d+/)->via('get')->to('ProjectController#project_show');
	$auth->route('/project/task/:id', 'id' => qr/\d+/)->via('get')->to('ProjectController#project_task');
	$auth->route('/task')->via('get')->to('TaskController#task_lists');
	#api
	$auth->route('/api/project')->via('get')->to('ProjectController#api_project_lists');
	$auth->route('/api/project')->via('post')->to('ProjectController#api_project_create');
	$auth->route('/api/user')->via('get')->to('UserController#api_user_lists');
	$auth->route('/api/user')->via('post')->to('UserController#api_user_create');
	$auth->route('/api/task')->via('get')->to('TaskController#api_task_lists');
	$auth->route('/api/task')->via('post')->to('TaskController#api_task_create');
	$auth->route('/api/task/status')->via('post')->to('TaskController#api_task_status');
	$auth->route('/todo/api/user/pl/create')->via('post')->to('UserController#api_user_pl_create');
}

1;
