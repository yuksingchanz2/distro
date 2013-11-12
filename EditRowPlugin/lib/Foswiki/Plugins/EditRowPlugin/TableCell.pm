# See bottom of file for copyright and license information
package Foswiki::Plugins::EditRowPlugin::TableCell;

use strict;
use Assert;

use Foswiki::Func                           ();
use JSON                                    ();
use Foswiki::Plugins::EditRowPlugin::Editor ();

use Foswiki::Tables::Cell ();
our @ISA = ('Foswiki::Tables::Cell');

# Default format if no other format is defined for a cell
my $defCol ||= { type => 'text', size => 20, values => [] };

sub new {
    my ( $class, $row, $precruft, $text, $postcruft, $ish ) = @_;

    return $class->SUPER::new( $row, $precruft, $text, $postcruft, $ish );
}

# Row index offset by size in the columnn definition
# Used in Editor.pm to determine the (uneditable) row index label
sub rowIndex {
    my ( $this, $colDef ) = @_;
    if ( $this->{row}->{index} ) {
        my $i = $this->{row}->{index} || 0;
        $i += $colDef->{size} - 1 if ( $colDef->{size} =~ /^\d+$/ );
        $this->{text} = $i;
    }
    else {
        $this->{text} = '';
    }
}

# Get the unique DOM element name for this cell
sub getElementName {
    my $this = shift;
    return 'erp_cell_' . $this->getID();
}

# Render the cell based on options. A cell can be rendered in different
# states depending on whether JS is available or not, if the cell is
# enabled for edit, or if it is a header or footer.
sub render {
    my ( $this, $opts, $render_opts ) = @_;

    my $colDef = $opts->{col_defs}->[ $this->{number} ] || $defCol;

    my $text = $this->{text};
    if ( $text =~ s/%EDITCELL{(.*?)}%// ) {
        my %p  = Foswiki::Func::extractParameters($1);
        my $cd = $this->{row}->{table}->parseFormat( $p{_DEFAULT} );
        $colDef = $cd->[0];
    }

    my $editor = Foswiki::Plugins::EditRowPlugin::Table::getEditor($colDef);

    if ( $opts->{for_edit} && $opts->{js} ne 'assumed' ) {

        # JS is ignored or preferred, need manual edit controls
        $text =
          $editor->htmlEditor( $this, $colDef, $opts->{in_row},
            defined $text ? $text : '' );
        $text = Foswiki::Plugins::EditRowPlugin::defend($text);
    }
    else {

        # Not for edit, or JS is assumed
        $text = '-' unless defined($text);

        unless ( $this->{isHeader} || $this->{isFooter} ) {
            if ( $colDef->{type} eq 'row' ) {

               # Special case for our "row" type - text is always the row number
                $text = $this->rowIndex($colDef);
            }
            else {

                # Chop out meta-text
                $text =~ s/%EDITCELL{(.*?)}%\s*$//;
            }
        }

        if ( $this->{isHeader} ) {

            # Headers are never editable
            my $attrs = {};
            unless ( $opts->{js} eq 'ignored' ) {

                # head and foot sizes passed in metadata
                $attrs->{class} =
                    'erpJS_sort {headrows: '
                  . $this->{row}->{table}->getHeaderRows()
                  . ',footrows:'
                  . $this->{row}->{table}->getFooterRows() . '}';
            }
            $text = CGI::span( $attrs, $text );
        }
        else {

            my $sopts   = {};
            my $trigger = '';
            if ( $this->can_edit() ) {

                # For edit
                my $data = $editor->jQueryMetadata( $this, $colDef, $text );

                # Editors can set "uneditable" if the cell is not to
                # have an editor
                unless ( $data->{uneditable} ) {

                    #if ($opts->{js} ne 'ignored') {
                    # add any edit-specific HTML here
                    #}
                    my @css_classes = ('erpJS_cell');

                    # Because we generate a TML table, we have no way
                    # to attach table meta-data and row meta-data. So
                    # we attach it to the first cell in the table/row, and
                    # move it to the right place when JS loads.
                    if ( $render_opts->{need_tabledata} ) {
                        my $tabledata = $this->{row}->{table}->getURLParams();
                        $data->{tabledata} = $tabledata;
                        push( @css_classes, 'erpJS_tabledata' );
                        $render_opts->{need_tabledata} = 0;
                    }
                    if ( $render_opts->{need_trdata} ) {
                        $data->{trdata} = $this->{row}->getURLParams();
                        push( @css_classes, 'erpJS_trdata' );
                        $render_opts->{need_trdata} = 0;
                    }

                    # Add the cell data
                    # Note: Any table row that has a cell with erpJS_cell
                    # will be made draggable
                    if ( $opts->{js} ne 'ignored' ) {
                        $data = JSON::to_json( $this->getURLParams(%$data) );
                        $sopts->{class} =
                          join( ' ', @css_classes ) . ' ' . $data;
                    }
                }
            }
            $text = CGI::span( $sopts, " $text " );
        }
    }
    $text =~ s/%/&#37;/g;    # prevent further macro expansion Item10770
    return $this->{precruft} . $text . $this->{postcruft};
}

sub can_edit {
    my $this = shift;
    return $this->{row}->can_edit();
}

# add URL params needed to address this cell
sub getURLParams {
    my ( $this, %more ) = @_;
    return { %more, erp_col => $this->{number} };
}

1;
__END__

Author: Crawford Currie http://c-dot.co.uk

Copyright (c) 2009-2011 Foswiki Contributors
Copyright (C) 2007 WindRiver Inc. and TWiki Contributors.
All Rights Reserved. Foswiki Contributors are listed in the
AUTHORS file in the root of this distribution.
NOTE: Please extend that file, not this notice.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version. For
more details read LICENSE in the root of this distribution.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

Do not remove this copyright notice.

This is an object that represents a single cell in a table.
