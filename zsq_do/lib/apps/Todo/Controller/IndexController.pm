package Todo::Controller::IndexController;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;
use Zsq::Auth;
use Zsq::Db;

# This action will render a template
sub welcome {
	my $c = shift;
	#my $db = Zsq::Db->new($c->config('db'));
    #my $model = new Zsq::Model();
	#$model->setDbConfig($c->config('db'));
  # Render template "example/welcome.html.ep" with message
  #$c->render(template => 'front/index_welcome');
  #$c->res->body($c);
  #$c->rendered(200);
  #my $model = new Zsq::Model();
  #$model->setDbConfig($c->config('db'));
  #my $dbh = $model->getDb();
  #$c->respond_to(any  => {data => $dbh, status => 200});
  $c->render(template => 'todo/index_welcome');
}

sub test {
	my $c = shift;


    #my $any = Text::FromAny->new(file => '/home/josephzeng/jzwork/todo/zsq_do/public/upload/1444963118_1073009.pdf');
    #my $text = $any->text;

    #my $t2h  = HTML::FromText->new({ paras  => 1 });
    #my $html = $t2h->parse( $text );
	#print $html;  
    #$c->render(template => 'front/upload', 'html' => $html);
	#my $auth = new Zsq::Auth();
	#$auth->init($c);
	#$auth->login_in(1, {'id' => 1, 'loginname' => 'admin'});
	#$auth->login_out();
	#my $result = $auth->login_check();
	#my $str = '';
	#if($result){
	#	$str = 'yes';
	#}else{
	#		$str = 'no';
	#}
    #my $db_configs = $c->config('db');
	#my $db_interface = $db_configs->{'default'};
	#my $testaa = Front::Model::UserModel->new($db_interface);
	#my $res = $testaa->searchByPbid(29);
	##my $db = Zsq::Db->new($db_interface);
	#my @data = $db->getInterface($db_interface)->fetchAll('select * from project_user where ub_id = ? and pu_is_author = ? limit 0, 5',1, 1);	
	$c->render(text => "yes");
}

sub upload {
	my $c = shift;
#	my $uploadFileDirectory = '/home/josephzeng/jzwork/todo/zsq_do/public/upload';
#	mkdir $uploadFileDirectory if ( !-d $uploadFileDirectory );
#	my $c = shift;
#	
#	my @filename;
#	my $file_ext;
#    my $files = $c->req->every_upload('files');
#    for my $file ( @{$files} ) {
#		my $time = time();
#        my $filename = $file->filename =~ s/[^\w\d\.]+/_/gr;
#		($file_ext) = $filename =~ /((\.[^.\s]+)+)$/;
#		my $random = int( rand(100000)) + 999999;
#		$filename = $time."_".$random.$file_ext;
#        $file->move_to("$uploadFileDirectory/$filename");
#        push @filename, $filename;
#    }
#    $c->render( text => $file_ext );
	#
	$c->render( text => 'abc');
}

1;
