#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
BEGIN { 
	unshift @INC, "$FindBin::Bin/lib/apps",
	unshift @INC, "$FindBin::Bin/lib/vendor",
};

use Plack::Builder;

builder {
    #enable "Debug";
	enable "Static", path => sub { s!^/static/!! }, root => './public/static';
	mount "/todo" => builder {
		require Mojolicious::Commands;
		Mojolicious::Commands->start_app('Todo');
	};
};
