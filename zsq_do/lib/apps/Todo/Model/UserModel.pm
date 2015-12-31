package Todo::Model::UserModel;
use Todo::Model::BaseModel;
use Data::Dumper;


@ISA = qw(Todo::Model::BaseModel);

sub new {
	my $this = shift;
	my $class = ref($this) || $this;
	my $self = $class->SUPER::new(@_);	
	$self->{'table_name'} = '`todo_task_base`';
	$self->{'table_field'} = '*';
	bless $self, $class;
	return $self;	
}

sub user_pl_create {
	my ($self, $args) = @_;
	$plid = $args->{'plid'} || 0;
	$username = $args->{'username'} || '';
	my $sql = under;
	if($plid && $username) {
		$sql = 'SELECT ub_id FROM `sq_user_base` WHERE ub_status = 1 AND ub_loginname = ? LIMIT 0,1 ';
		my $row = $self->db()->getInterface()->fetchRow($sql, $username);
		if($row && $row->{'ub_id'}){
			$sql = 'SELECT lu_id FROM `todo_level_user` WHERE pl_id = ? AND ub_id = ? AND lu_is_follow = 1 LIMIT 0, 1';
			$r = $self->db()->getInterface()->fetchRow($sql, $plid,
													   $row->{'ub_id'});
			if($r && $r->{'lu_id'}){
				return 1;
			}
		}
	}
}

sub search {
	my ($self, $args) = @_;
	$pbid = $args->{'pbid'} || 0;
	$plid = $args->{'plid'} || 0;
		my $sql = 'SELECT a.*, b.* FROM `todo_level_user` AS a INNER JOIN `sq_user_base` AS
	b ON a.ub_id = b.ub_id WHERE a.lu_is_follow = 1 ';
	if($plid){
		$sql .= ' AND a.pl_id = '.$plid;
	}
	return $self->db()->getInterface()->fetchAll($sql);
}

sub getOne {
	my ($self, $args) = @_;
	my $name = $args->{'name'} || 0;
	if($name){
		my $sql = 'SELECT * FROM `sq_user_base` WHERE ub_loginname = ? LIMIT 0, 1';
		my $row = $self->db()->getInterface->fetchRow($sql, $name);
		return $row;
	}else{
		return 0;
	}
}

sub add {
	my ($self, $args) = @_;
	my $name = $args->{'name'} || 0;
	my $email = $args->{'email'} || 0;
	my $sql = 'UPDATE `sq_user_base` SET ub_login_datetime = ?
               WHERE ub_loginname = ?';
	if($name && $email) {
		my $now_time = $self->now_time();		
		my $res = $self->db()->getInterface()->update($sql, $now_time, $name);
		if(!$res){
			# create new user
			$sql = 'INSERT INTO `sq_user_base`(ub_loginname, ub_email,ub_create_datetime, ub_update_datetime, ub_status, ub_login_datetime)
                    VALUES(?,?,?,?,?,?)';
			my $check_insert = $self->db()->getInterface->insert($sql, $name, $email,$now_time, $now_time, 1, $now_time);
            if($check_insert){
                return $self->getOne({'name' => $name});
            }else{
                return 0;
            }
		}else{
			my $row = $self->getOne({'name' => $name});
			if($row && $row->{'ub_status'} == 1) {			
				return $row;
			}else{
				return -1;
			}
		}
	}else{
		return 0;
	}
}

1;
