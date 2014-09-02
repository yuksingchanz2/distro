# See bottom of file for license and copyright information
package Foswiki::Configure::Checkers::Htpasswd::Encoding;

use strict;
use warnings;

use Foswiki::Configure::Checker ();
our @ISA = ('Foswiki::Configure::Checker');

use Foswiki::Configure::Dependency ();

my %methods = (
    'htdigest-md5' => [ 
        { name => 'Digest::MD5',
          usage => 'use or auto-detection of htdigest-md5' } ],
    'sha1' => [
        { name => 'Digest::SHA',
          usage => 'use or auto-detection of sha1' } ],
    'apache-md5' => [
        { name => 'Crypt::PasswdMD5',
          usage => 'use or auto-detection of apache-md5' } ],
    'crypt-md5' => [
        { name => 'Crypt::PasswdMD5',
          usage => 'use or auto-detection of crypt-md5' } ],
    'bcrypt' => [
        { name => 'Crypt::Eksblowfish::Bcrypt',
          usage => 'use or auto-detection of bcrypt' } ]
    );
 
sub check_current_value {
    my ($this, $reporter) = @_;
    my $e    = '';

    if ( $Foswiki::cfg{Htpasswd}{Encoding} eq 'md5' ) {
        $Foswiki::cfg{Htpasswd}{Encoding} = 'htdigest-md5';
        $reporter->WARN(
            Foswiki::Configure::Checker::GUESSED_MESSAGE .
            'Encoding has been changed from the deprecated =md5= setting to =htdigest-md5=.  Please save your configuration. Note that this does not change how your passwords are stored.'
          );
    }

    my $enc = $Foswiki::cfg{Htpasswd}{Encoding};
    if ( $Foswiki::cfg{Htpasswd}{AutoDetect} || $enc eq 'crypt' ) {
        my $f = $Foswiki::cfg{Htpasswd}{FileName};
        Foswiki::Configure::Load::expandValue($f);

        if ( $enc eq 'crypt' ) {
            if ( $Foswiki::cfg{Htpasswd}{AutoDetect} && -f $f ) {
                $reporter->WARN(
'<b>Not recommended</b> crypt encoding only uses the first 8 characters of the password and silently ignores the rest.  ={AutoDetect}= is enabled.  Consider changing this to stronger encoding. Passwords will migrate to the new encoding as users change their passwords.'
                );
            }
            elsif ( -f $f ) {
                $reporter->WARN(
'<b>Not Recommended:</b> crypt encoding only uses the first 8 characters of the password and silently ignores the rest.  However changing Encoding will invalidate existing passwords unless =AutoDetect= is enabled. See <a href="http://foswiki.org/Support/HtPasswdEncodingSupplement">HtPasswdEncodingSupplement</a> for more information'
                );
            }
            else {
                $reporter->ERROR(
'crypt encoding only uses the first 8 characters of the password and silently ignores the rest.  No password file exists, so now is a good time choose a different encoding. See <a href="http://foswiki.org/Support/HtPasswdEncodingSupplement">HtPasswdEncodingSupplement</a> for more information'
                );
            }
        }
    }

    my @check;
    if ($Foswiki::cfg{Htpasswd}{AutoDetect}) {
        foreach my $method (sort keys %methods) {
            push(@check, @{$methods{$method}});
        }
    } elsif ($Foswiki::cfg{Htpasswd}{Encoding} &&
             $methods{$Foswiki::cfg{Htpasswd}{Encoding}}) {
        push(@check, @{$methods{$Foswiki::cfg{Htpasswd}{Encoding}}});
    }
    Foswiki::Configure::Dependency::checkPerlModules( @check );
    foreach my $mod (@check) {
        if (!$mod->{ok}) {
            $reporter->ERROR($mod->{check_result});
        } else {
            $reporter->NOTE($mod->{check_result});
        }
    }

    if ( $Foswiki::cfg{Htpasswd}{AutoDetect} || $enc eq 'crypt-md5' ) {
        use Config;
        if ( $Config{myuname} =~ /strawberry/i ) {
            my %mod = (
                name => 'Crypt::PasswdMD5',
                usage => 'Required for crypt-md5 encoding on Windows with Strawberry perl',
                minimumVersion => 0
            );
            Foswiki::Configure::Dependency::checkPerlModules( \%mod );
            if (!$mod{ok}) {
                $reporter->ERROR($mod{check_result});
            } else {
                $reporter->NOTE($mod{check_result});
            }
        }
    }

    if (   $enc ne 'crypt'
        && $enc ne 'apache-md5'
        && $Foswiki::cfg{PasswordManager} eq
        'Foswiki::Users::ApacheHtpasswdUser' )
    {
        $reporter->ERROR(
"PasswordManager ApacheHtpasswdUser only supports crypt and apache-md5 encryption.  Use HtPasswdUser for other Encoding types."
        );
    }
}

1;
__END__
Foswiki - The Free and Open Source Wiki, http://foswiki.org/

Copyright (C) 2008-2014 Foswiki Contributors. Foswiki Contributors
are listed in the AUTHORS file in the root of this distribution.
NOTE: Please extend that file, not this notice.

Additional copyrights apply to some or all of the code in this
file as follows:

Copyright (C) 2000-2006 TWiki Contributors. All Rights Reserved.
TWiki Contributors are listed in the AUTHORS file in the root
of this distribution. NOTE: Please extend that file, not this notice.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version. For
more details read LICENSE in the root of this distribution.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

As per the GPL, removal of this notice is prohibited.