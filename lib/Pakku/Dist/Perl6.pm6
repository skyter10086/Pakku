use Pakku::Dist;
use Pakku::DepSpec;
use Distribution::Builder::MakeFromJSON;

unit class Pakku::Dist::Perl6;
  also is Pakku::Dist;

has $.meta;

# This long list of attributes were copied
# from `Zef` The perl6 module manager
# because I'm lazy to write them all
#
has $.meta-version;
has $.name;
has $.auth;
has $.author;
has $.authority;
has $.api;
has $.ver;
has $.description;
has %.provides;
has $.source-url;
has $.license;
has @.build-depends;
has @.test-depends;
has %.depends;
has @.resources;
has %.support;
has $.builder;
has %!emulates;
has %!superseded-by;
has %!excludes;


method Str ( Pakku::Dist::Perl6:D: --> Str:D ) {

  $!name ~ ":ver<$!ver>:auth<$!auth>:api<$!api>"

}

method deps (

  Pakku::Dist::Perl6:D:

  Bool:D :$runtime    = True,
  Bool:D :$test       = True,
  Bool:D :$build      = True,
  Bool:D :$requires   = True,
  Bool:D :$recommends = True,

) {

  my @deps = flat gather {

    if $build {

      %!depends<build><requires>   .grep( *.defined ).map( *.take ) if $requires;
      %!depends<build><recommends> .grep( *.defined ).map( *.take ) if $recommends;

    }

    if $test {

      %!depends<test><requires>   .grep( *.defined ).map( *.take ) if $requires;
      %!depends<test><recommends> .grep( *.defined ).map( *.take ) if $recommends;

    }

    if $runtime {

      %!depends<runtime><requires>   .grep( *.defined ).map( *.take ) if $requires;
      %!depends<runtime><recommends> .grep( *.defined ).map( *.take ) if $recommends;

    }
  }

}

multi method gist ( Pakku::Dist::Perl6:D: :$details where not *.so --> Str:D ) {

  ~self;

}

multi method gist ( Pakku::Dist::Perl6:D: :$details where *.so --> Str:D ) {

  (
    (           self          ),
    ( gist-name $!name        ),
    ( gist-ver  $!ver         ),
    ( gist-auth $!auth        ),
    ( gist-api  $!api         ),
    ( gist-desc $!description ),
    ( gist-bldr $!builder     ),
    ( gist-surl $!source-url  ),
    ( gist-deps self.deps     ),
    ( gist-prov %!provides    ),
    (           ''            ),
  ).join( "\n" );
}

sub gist-name ( $name ) { "name → $name" .indent( 2 ) if $name }
sub gist-ver  ( $ver  ) { "ver  → $ver"  .indent( 2 ) if $ver  }
sub gist-auth ( $auth ) { "auth → $auth" .indent( 2 ) if $auth }
sub gist-api  ( $api  ) { "api  → $api"  .indent( 2 ) if $api  }
sub gist-desc ( $desc ) { "desc → $desc" .indent( 2 ) if $desc }
sub gist-surl ( $surl ) { "surl → $surl" .indent( 2 ) if $surl  }

sub gist-bldr ( $bldr ) { "bldr → { $bldr // $bldr.^name }" .indent( 2 ) if $bldr }

sub gist-deps ( @deps ) {

  my $label = 'deps';

  ( @deps
    ?? "$label\n" ~
        @deps.map( -> $dep {
          "↳ $dep"
        } ).join("\n").indent( 5 )
    !! "$label →";
  ).indent( 2 ) if @deps;
}

sub gist-prov ( %prov --> Str:D ) {

  my $label = 'prov';

  ( %prov
    ?? "$label \n" ~
        %prov.kv.map( -> $mod, $path {
          $path ~~ Hash
            ?? "↳ $mod → { $path.keys }\n" ~
                  $path.kv.map( -> $path, $info {
                     $info.kv.map( -> $k, $v {
                      "↳ $k → { $v // '' }"
                     } ).join("\n").indent( 2 )
                  })
            !! "↳ $mod";
        }).join( "\n" ).indent( 5 )
    !! "$label →";
  ).indent( 2 ) if %prov;
}

submethod TWEAK ( ) {

  $!meta-version  = $!meta<meta-version>  // '';
  $!name          = $!meta<name>          // '';
  $!auth          = $!meta<auth>          // '';
  $!api           = $!meta<api>           // '';
  $!author        = $!meta<author>        // '';
  $!authority     = $!meta<authority>     // '';
  $!description   = $!meta<description>   // '';
  $!source-url    = $!meta<source-url>    // '';
  $!license       = $!meta<license>       // '';
  $!builder       = $!meta<builder>       // '';
  $!ver           = Version.new( $!meta<ver> // $!meta<version> ) if $!meta<ver> // $!meta<version>;
  %!provides      = $!meta<provides>      if $!meta<provides>;
  %!support       = $!meta<support>       if $!meta<support>;
  %!emulates      = $!meta<emulates>      if $!meta<emulates>;
  %!superseded-by = $!meta<superseded-by> if $!meta<superseded-by>;
  %!excludes      = $!meta<excludes>      if $!meta<excludes>;

  @!resources     = flat $!meta<resources> if $!meta<resources>;

 given $!meta<builder> {

    $!builder = Distribution::Builder::MakeFromJSON when 'MakeFromJSON';

  }

  %!depends =
    $!meta<depends> ~~ Array
      ??  runtime => %( requires => $!meta<depends> )
      !!  none($!meta<depends><runtime test build>:exists)
            ?? runtime => none($!meta<depends><requires recommends>:exists)
              ?? requires => $!meta<depends>
              !! $!meta<depends>
            !! $!meta<depends>.map({
                none(.value<requires runtime>:exists) ?? ( .key => %(requires => .value) ) !! .self;
               }) if $!meta<depends>;

  %!depends<build><requires>.append: flat $!meta<build-depends> if $!meta<build-depends>;
  %!depends<test><requires>.append:  flat $!meta<test-depends>  if $!meta<test-depends>;

  %!depends = %!depends.kv.map( -> $k, $v {
    $k => $v.kv.map( -> $k, $v {
      $k => $v.map( -> $depspec {
        $depspec ~~ Array
          ?? $depspec.map( -> $depspec { Pakku::DepSpec.new: $depspec } ).Array
          !! Pakku::DepSpec.new: $depspec;
      }).Array
    }).hash
  });


}

