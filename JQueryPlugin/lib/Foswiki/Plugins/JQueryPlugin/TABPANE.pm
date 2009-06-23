# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
# 
# Copyright (C) 2006-2009 Michael Daum, http://michaeldaumconsulting.com
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version. 
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details, published at
# http://www.gnu.org/copyleft/gpl.html

package Foswiki::Plugins::JQueryPlugin::TABPANE;
use strict;

use base 'Foswiki::Plugins::JQueryPlugin::Plugin';

=begin TML

---+ package Foswiki::Plugins::JQueryPlugin::TABPABNE

This is the perl stub for the jquery.tabpane plugin.

=cut

=begin TML

---++ ClassMethod new( $class, $session, ... )

Constructor

=cut

sub new {
  my $class = shift;
  my $session = shift || $Foswiki::Plugins::SESSION;

  my $this = bless($class->SUPER::new( 
    $session,
    name => 'Tabpane',
    version => '1.0',
    author => 'Michael Daum',
    homepage => 'http://michaeldaumconsutling.com',
    tags => 'TABPABNE, ENDTABPANE, TAB, ENDTAB',
    css => ['jquery.tabpane.css'],
    javascript => ['jquery.tabpane.js'],
    #dependencies => ['debug'], # DEBUG
  ), $class);

  $this->{summary} = <<'HERE';
This implements an alternative tabpane widget. There _is_ already one in
jquery-ui, however as long as jquery-ui is still in flux, this alternative
offers a safe substitute well integrated into Foswiki. 

Individual tabs can be loaded on demand using a REST call. Installing
Foswiki:Extensions/RenderPlugin is recommended for that. 

Tabpanes can be nested. Tabs can be extended in height automatically.
Heights can be auto-updated to follow windows resize events. Tabpanes
can be established as part of reloaded content via ajax.

Note that this widget does _not_ participate in jquery-ui themerolling.
It does match jquery.button in terms of look & feel.
HERE

  return $this;
}

=begin TML

---++ ClassMethod handleTabPane( $this, $params, $topic, $web ) -> $result

Tag handler for =%<nop>TABPANE%=. 

=cut

sub handleTabPane {
  my ($this, $params, $theTopic, $theWeb) = @_;

  my $tpId = 'jqTabPane'.Foswiki::Plugins::JQueryPlugin::Plugins::getRandom();
  my $select = $params->{select} || 1;
  my $autoMaxExpand = $params->{automaxexpand} || 'off';
  my $minHeight = $params->{minheight} || 230;
  my $animate = $params->{animate} || 'off';

  $autoMaxExpand = ($autoMaxExpand eq 'on')?'true':'false';
  $animate = ($animate eq 'on')?'true':'false';


  my $script = <<"EOS";
<script type="text/javascript">
jQuery(document).ready(function() {
  jQuery("#$tpId").tabpane({select:'$select', autoMaxExpand:$autoMaxExpand, animate:$animate, minHeight:$minHeight});
});
</script>
EOS

  return "<!-- TABPANE -->".$script."<div class='jqTabPane' id='$tpId'>";
}

=begin TML

---++ ClassMethod handleTab( $this, $params, $topic, $web ) -> $result

Tag handler for =%<nop>TAB%=. 

=cut

sub handleTab {
  my ($this, $params, $theTopic, $theWeb) = @_;

  my $theName = $params->{_DEFAULT} || $params->{name} || 'Tab';
  my $beforeHandler = $params->{before} || '';
  my $afterHandler = $params->{after} || '';
  my $afterLoadHandler = $params->{afterload} || '';
  my $url = $params->{url} || '';
  my $container = $params->{container} || '';
  my $tabId = $params->{id};
  my $height = $params->{height};
  my $width = $params->{width};
  $tabId = 'jqTab'.Foswiki::Plugins::JQueryPlugin::Plugins::getRandom();

  my @metaData = ();
  if ($beforeHandler) {
#    $beforeHandler =~ s/'/\\'/go;
    push @metaData,  "beforeHandler: function() {$beforeHandler}";
  }
  if ($afterHandler) {
#    $afterHandler =~ s/'/\\'/go;
    push @metaData,  "afterHandler: function() {$afterHandler}";
  }
  if ($afterLoadHandler) {
#    $afterLoadHandler =~ s/'/\\'/go;
    push @metaData,  "afterLoadHandler: function() {$afterLoadHandler}";
  }
  if ($url) {
    push @metaData , "url: '$url'";
  }
  if ($container) {
    push @metaData , "container: '$container'";
  }
  my $metaData = scalar(@metaData)?' {'.join(',', @metaData).'}':'';

  my $style = '';
  $style .= "height:$height;" if defined $height;
  $style .= "width:$width;" if defined $width;
  $style = "style='$style'" if $style;
 

  return "<!-- TAB --><div id='$tabId' class=\"jqTab$metaData\">\n<h2 >$theName</h2>\n<div class='jqTabContents' $style>";
}

=begin TML

---++ ClassMethod handleEndTab( $this, $params, $topic, $web ) -> $result

Tag handler for =%<nop>ENDTAB%=. 

=cut

sub handleEndTab {
  return "</div></div><!-- //ENDTAB -->";
}

=begin TML

---++ ClassMethod handleEndTabPan ( $this, $params, $topic, $web ) -> $result

Tag handler for =%<nop>ENDTABPANE%=. 

=cut

sub handleEndTabPane {
  return "</div><!-- //ENDTABPANE -->";
}

1;

