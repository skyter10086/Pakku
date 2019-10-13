use Terminal::ANSIColor;

unit role Pakku::Help;

method help ( Str:D :$cmd ) {

  given $cmd {

    when 'add'    { self!add    }
    when 'remove' { self!remove }
    when 'list'   { self!list   }
    when 'build'  { self!build  }
    when 'test'   { self!test   }
    when 'check'  { self!check  }


    default {
      (
        self!add,
        self!remove,
        self!list,
        self!build,
        self!test,
        self!check,
      )
      .join: "\n";
    }
  }
}

submethod !add ( ) {

  my %add;

  %add<cmd>     = 'Add';
  %add<desc>    = 'Add distribution';

  %add<example>.push: 'pakku add MyModule';
  %add<example>.push: 'pakku add nodeps MyModule';
  %add<example>.push: 'pakku add notest MyModule';
  %add<example>.push: 'pakku add into home MyModule Another::Module';

  %add<opt>.push: ( 'deps'            => 'add dependencies as well' );
  %add<opt>.push: ( 'nodeps'          => 'dont add dependencies' );
  %add<opt>.push: ( 'deps requires'   => 'add required dependencies' );
  %add<opt>.push: ( 'deps recommends' => 'add required and recommended dependencies' );
  %add<opt>.push: ( 'deps only'       => 'add dependencies only' );
  %add<opt>.push: ( 'build'           => 'build distribution' );
  %add<opt>.push: ( 'nobuild'         => 'bypass build' );
  %add<opt>.push: ( 'test'            => 'test distribution' );
  %add<opt>.push: ( 'notest'          => 'bypass test' );
  %add<opt>.push: ( 'force'           => 'force add distribution even if it is installed' );
  %add<opt>.push: ( 'noforce'         => 'no force' );
  %add<opt>.push: ( 'into <repo>'     => 'add distribution to specified repo <home site vendor core>' );

  help %add;

}

submethod !remove ( ) {

  my %remove;

  %remove<cmd>     = 'Remove';
  %remove<desc>    = 'Remove distribution';

  %remove<example>.push: 'pakku remove MyModule';

  help %remove;

}

submethod !list ( ) {

  my %list;

  %list<cmd>     = 'List';
  %list<desc>    = 'List distribution details';

  %list<example>.push: 'pakku list';
  %list<example>.push: 'pakku list MyModule';
  %list<example>.push: 'pakku list details MyModule';
  %list<example>.push: 'pakku list local  MyModule';
  %list<example>.push: 'pakku list remote MyModule';
  %list<example>.push: 'pakku list repo home';
  %list<example>.push: 'pakku list repo site MyModule';

  %list<opt>.push: ( 'local'       => 'local  distribution'  );
  %list<opt>.push: ( 'remote'      => 'remote distribution'  );
  %list<opt>.push: ( 'details'     => 'distribution details' );
  %list<opt>.push: ( 'repo <name>' => 'list distributions in specific repo' );

  help %list;

}


submethod !build ( ) {

  my %build;

  %build<cmd>     = 'Build';
  %build<desc>    = 'Build distribution';

  %build<example>.push: 'pakku build MyModule';
  %build<example>.push: 'pakku build .';

  help %build;


}

submethod !test ( ) {

  my %test;

  %test<cmd>     = 'Test';
  %test<desc>    = 'Test distribution';

  %test<example>.push: 'pakku test MyModule';
  %test<example>.push: 'pakku build .';

  help %test;

}

submethod !check ( ) {

  my %check;

  %check<cmd>     = 'Check';
  %check<desc>    = 'Download distribution';

  %check<example>.push: 'pakku check MyModule';

  help %check;

}

sub help ( %cmd --> Str:D ) {

  my $cmd     = %cmd<cmd>;
  my $desc    = %cmd<desc>;
  my @example = %cmd<example>.flat;
  my @opt     = %cmd<opt>.flat;

  q:s:f:c:to/END/
  {
    desc( $cmd, $desc ) ~
    example( @example ) ~
    opt( @opt )
  }
  END

}

sub desc ( $cmd, $desc ) {

  colored( "$cmd: \n", 'bold magenta' ) ~
  colored( $desc, 'cyan' ) ~ "\n";

}

sub example ( @example ) {

  return '' unless any @example;
  "\n" ~
  colored( "Example:\n", 'bold yellow' ) ~
  colored( @example.join( "\n" ), 'bold italic 177' ) ~ "\n";

}

sub opt ( @opt ) {

  return '' unless any @opt;
  my $indent  = @opt.map( *.key.chars ).max if @opt;
  "\n" ~
  colored( "Options:\n", 'bold yellow' ) ~ 
  @opt.map( {
    colored( .key, 'bold green' )  ~
    colored( ' → ', 'yellow' ).indent( $indent - .key.chars ) ~
    colored( .value, 'bold cyan' )
  } ).join( "\n" ) ~ "\n";
 

}
