package App::rsynccolor;

# DATE
# VERSION

use strict;
use warnings;

sub postprocess {
    my $fh = shift;

    local $Text::WordDiff::Unified::ANSIColor::colors{delete_line} = $Colors{delete_line};
    local $Text::WordDiff::Unified::ANSIColor::colors{insert_line} = $Colors{insert_line};
    local $Text::WordDiff::Unified::ANSIColor::colors{delete_word} = $Colors{delete_word};
    local $Text::WordDiff::Unified::ANSIColor::colors{insert_word} = $Colors{insert_word};

    my (@inslines, @dellines);
    my $code_print_ins_del_lines = sub {
        return unless @inslines || @dellines;
        if (@inslines != @dellines || @inslines > 5) {
            for (@dellines) {
                print $Colors{delete_line}, $_, "\e[0m\n";
            }
            for (@inslines) {
                print $Colors{insert_line}, $_, "\e[0m\n";
            }
        } else {
            my $lines1 = "";
            for (@dellines) { s/^-//; $lines1 .= "$_\n" }
            my $lines2 = "";
            for (@inslines) { s/^[+]//; $lines2 .= "$_\n" }
            print Text::WordDiff::Unified::ANSIColor::word_diff(
                $lines1, $lines2);
        }
        @inslines = (); @dellines = ();
    };
    while (defined(my $line = <$fh>)) {
        chomp $line;
        if ($line =~ /^(\+\+\+|---) /) {
            $code_print_ins_del_lines->();
            print $Colors{path_line}, $line, "\e[0m\n";
        } elsif ($line =~ /^\@/) {
            $code_print_ins_del_lines->();
            print $Colors{linum_line}, $line, "\e[0m\n";
        } elsif ($line =~ /^[+]/) {
            push @inslines, $line;
        } elsif ($line =~ /^[-]/) {
            push @dellines, $line;
        } else {
            $code_print_ins_del_lines->();
            print $line, "\n";
        }
    }
    $code_print_ins_del_lines->();
}

1;
# ABSTRACT: Add some color to rsync output

=for Pod::Coverage ^(.+)$

=head1 SYNOPSIS

See the command-line script L<rsynccolor>.

=cut
