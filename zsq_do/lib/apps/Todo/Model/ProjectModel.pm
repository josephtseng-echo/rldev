package Todo::Model::ProjectModel;
use Todo::Model::BaseModel;
use Text::Trim qw(trim);

@ISA = qw(Todo::Model::BaseModel);

sub new {
	my $this = shift;
	my $class = ref($this) || $this;
	my $self = $class->SUPER::new(@_);	
	$self->{'table_name'} = '`todo_project_base`';
	$self->{'table_field'} = '*';
	bless $self, $class;
	return $self;
}

sub search {
	my ($self, $args) = @_;
	my $search = $args->{'search'} || 'all';
    my $user_id = $args->{'user_id'} || 0;
    my $where = ' 1=1 ';
    if($user_id) {
        $where = ' b.ub_id = '.$user_id.' ';
    }
	if($search eq 'all'){
		my $pagesize = $args->{'pagesize'} || 20;
		my $page = $args->{'page'} || 0;
	    my $sql = 'SELECT a.*, b.* 
                   FROM '.$self->{'table_name'}.' AS a INNER JOIN `todo_project_user` AS b ON a.pb_id = b.pb_id 
                   WHERE '.$where.' 
                   ORDER BY a.pb_id DESC
                   LIMIT '.$page.', '.$pagesize.' ';
		return $self->db()->getInterface()->fetchAll($sql);
	}else{
		return 0;
	}
}

sub count {
	my ($self, $args) = @_;
	my $where = $args->{'where'} || '1=1';
	my $sql = 'SELECT COUNT(*) AS nums FROM '.$self->{'table_name'}.' AS a INNER JOIN `todo_project_user` AS b ON a.pb_id = b.pb_id 
               WHERE '.$where;
    my $row = $self->db()->getInterface()->fetchRow($sql);
	return $row->{'nums'};
}

sub create {
	my ($self, $params) = @_;
	my $project_name = $params->{'project_name'};
	my $start_time = $params->{'start_time'};
	my $end_time = $params->{'end_time'};
	my $project_level = $params->{'project_level'};
	my $now_time = $params->{'now_time'};
	my $user_id = $params->{'user_id'};
	my $end_time_timestamp = $params->{'end_time_timestamp'};
	my $start_time_timestamp = $params->{'start_time_timestamp'};
	
	my $dbh = $self->db()->getInterface()->fetchDb();
	eval{
		#insert into project_base
		my $project_base_insert_sql = 'INSERT INTO `todo_project_base`(pb_name, pb_start_time, pb_end_time, pb_create_time) VALUES(?,?,?,?)';
		my $sth = $dbh->prepare($project_base_insert_sql);
		$sth->execute($project_name, $start_time_timestamp, $end_time_timestamp,  $now_time);
		my $last_insertid = $sth->{mysql_insertid};

		my $project_user_insert_sql = 'INSERT INTO `todo_project_user`(pb_id, ub_id, pu_is_author, pu_is_admin, pu_operate_time, pu_operate_userid, from_ub_id) VALUES(?,?,?,?,?,?,?)';
		$sth = $dbh->prepare($project_user_insert_sql);
		$sth->execute($last_insertid, $user_id, 1, 1, $now_time, $user_id, $user_id);
		
		my $project_level_insert_sql_new;
		if(ref($project_level) eq 'ARRAY'){
			my $project_level_insert_sql = 'INSERT INTO `todo_project_level`(pb_id, pl_name, pl_create_time) VALUES';
			foreach my $item (@{$project_level}) {
				my $new_item = trim($item);
				if($new_item ne "") {
					$project_level_insert_sql .= "('$last_insertid', '$new_item', '$now_time'),";
				}
			}
			$project_level_insert_sql_new = substr($project_level_insert_sql, 0, -1);
		}else{
			$project_level_insert_sql_new = "INSERT INTO `todo_project_level`(pb_id, pl_name, pl_create_time) VALUES('$last_insertid', '$project_level', '$now_time')";
		}
		$sth = $dbh->prepare($project_level_insert_sql_new);
		$sth->execute();
		# commit
		$dbh->commit();
	};
	if( $@ ){
		# rollback
		$dbh->rollback();
		return 0;
	}else {
		return 1;
	}
}

1;
