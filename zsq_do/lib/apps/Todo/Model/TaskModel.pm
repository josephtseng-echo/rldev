package Todo::Model::TaskModel;
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

sub search {
	my ($self, $args) = @_;
	my $search = $args->{'search'} || 'all';
	my $pagesize = $args->{'pagesize'} || 10;
	my $page = $args->{'page'} || 0;
	if($search eq 'all'){
	    my $sql = 'SELECT '.$self->{'table_field'}.'
                   FROM '.$self->{'table_name'}.'
                   ORDER BY tb_id DESC
                   LIMIT '.$page.', '.$pagesize.' ';
		return $self->db()->getInterface()->fetchAll($sql);
	}else{
		return 0;
	}
}

sub status_reset {
	my ($self, $args) = @_;
	my $tb_id = $args->{'tb_id'} || 0;
	my $tb_status = $args->{'tb_status'} || 0;
	my $ub_id = $args->{'ub_id'} || 0;
	if ($tb_id && $ub_id) {
		my $sql = 'SELECT tu_id FROM `todo_task_user` WHERE tb_id = ? AND ub_id = ? LIMIT 0, 1';
		my $row = $self->db()->getInterface()->fetchRow($sql, $tb_id, $ub_id);
		if($row){
			$sql = 'UPDATE `todo_task_base` SET tb_status = ? WHERE tb_id = ? ';
			return $self->db()->getInterface()->update($sql, $tb_status, $tb_id);
		}else{
			return 0;
		}
	}else{
		return 0;
	}
}


sub add {
	my ($self, $args) = @_;
	my $tb_name = $args->{'tb_name'} || "";
	my $ub_id = $args->{'ub_id'} || 0;
	my $pb_id = $args->{'pb_id'} || 0;
	my $tb_level = $args->{'tb_level'} || 0;
	my $tb_post = $args->{'tb_post'} || 0;
	if($tb_name ne ""){
		my $dbh = $self->db()->getInterface()->fetchDb();
		eval{
			my $sql = 'INSERT INTO '.$self->{'table_name'}.'(tb_name, tb_level, tb_post, tb_create_time, tb_update_time) VALUES(?, ?, ?, ?, ?)';
			my $sth = $dbh->prepare($sql);
			my $now_time = $self->now_time();
			$sth->execute(qq\$tb_name\, $tb_level, qq\$tb_post\, $now_time, $now_time);
			my $last_insertid = $sth->{mysql_insertid};

			$sql = 'INSERT INTO `todo_task_user`(ub_id, tb_id, pb_id) VALUES(?, ?, ?)';
			$sth = $dbh->prepare($sql);
			$sth->execute($ub_id, $last_insertid, $pb_id);

			$dbh->commit();
		};	
		if($@){
			$dbh->rollback();
			$self->db()->close();
			return 0;
		}else{
			$self->db()->close();
			return 1;
		}
	}else{
		return 0;
	}
}

1;
