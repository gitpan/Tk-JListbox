# Copyright (c) 2000 Daniel J. Berger. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package JListbox;
use vars qw($VERSION);
$VERSION = '.01';

use warnings;

require Tk::Derived;
require Tk::Listbox;
@ISA = qw(Tk::Derived Tk::Listbox);

Construct Tk::Widget 'JListbox';
    
sub Populate{
	my ($jlb,$args) = @_;
   $jlb->SUPER::Populate($args);
 
   $jlb->ConfigSpecs(
      -justify => [qw/METHOD justify Justify left/],
      DEFAULT  => [$jlb],
   );
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Use the appropriate subroutine based on whether the user selected the '-left'
# or '-center' option, and on the type of font (proportional vs. fixed).
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub justify{
    my ($jlb,$flag) = @_;
    
    my $font = $jlb->cget(-font);
    my $fontVal = $jlb->fontMetrics($font, -fixed);
    if($flag eq 'center'){     
      if($fontVal == 1){ justifyCenter_fixed($jlb) }
      else{ justifyCenter_variable($jlb) }
    }
    if($flag eq 'right'){ 
      if($fontVal == 1){ justifyRight_fixed($jlb) }
      else{ justifyRight_variable($jlb) }
    }
  
    return;
}

# Center the text for variable width fonts
sub justifyCenter_variable{
   my $jlb = shift;
   my $fontref = $jlb->cget(-font);                     # Get the font name
   my @textArray = $jlb->get(0, 'end');                 # Get the text
   my $blank = ' ';                                     # Set a blank
   my $blanksize = $jlb->fontMeasure($$fontref,$blank); # Measure a blank space
   my $pixelwidth = $jlb->width;                        # Get width of Listbox
   $jlb->delete(0,'end');                               # Delete text
   
   foreach my $word(@textArray){
      $word =~ s/^\s+//;                                 # Remove whitespace
      $word =~ s/\s+$//;
      my $textsize = $jlb->fontMeasure($$fontref,$word); # Measure the text
      my $pixelsleft = $pixelwidth - $textsize;          # Total pixels left
      my $pixelhalf  = $pixelsleft/2;                    # Pixels left per side
      my $spaceequiv = int($pixelhalf/$blanksize);       # Fixed space equiv.
      my $spaces = ' ' x $spaceequiv;                    # Build whitespace
   
      $word =~ s/$word/$spaces$word/;                    # Prepend spaces
           
      $jlb->insert('end',$word);                         # Finally re-insert
   } 
   $jlb->bind("<Configure>", \&justifyCenter_variable);  # Stay centered
}

# Center the text for a fixed width font
sub justifyCenter_fixed{
   my $jlb = shift;
   my @textArray = $jlb->get(0,'end');
   my $width = $jlb->width;
   $jlb->delete(0,'end');
   
   foreach my $word(@textArray){
      $word =~ s/^\s+//;
      $word =~ s/\s+$//;
      my $spaces = ($width - (length($word))) / 2;
      $word =~ s/$word/$spaces$word/;
      
      $jlb->insert('end',$word);
   }
   $jlb->bind("<Configure>", \&justifyCenter_fixed);
}

# Right justify the text for a variable width font
sub justifyRight_variable{
   my $jlb = shift;
   my $fontref = $jlb->cget(-font);                     # Get the font name
   my @textArray = $jlb->get(0, 'end');                 # Get the text
   my $blank = ' ';                                     # Set a blank
   my $blanksize = $jlb->fontMeasure($$fontref,$blank); # Measure a blank space
   my $pixelwidth = $jlb->width;                        # Get width of Listbox
   $jlb->delete(0,'end');                               # Delete text
   
   foreach my $word(@textArray){
      $word =~ s/^\s+//;
      $word =~ s/\s+$//;
      my $textsize = $jlb->fontMeasure($$fontref,$word); # Measure the text
      my $pixelsleft = $pixelwidth - $textsize;          # Total pixels left
      my $spaceequiv = int($pixelsleft/$blanksize);      # Fixed space equiv.
      $spaceequiv = ($spaceequiv - $blanksize);          # Drop one char back
      my $spaces = ' ' x $spaceequiv;                    # Build whitespace
      
      $word =~ s/$word/$spaces$word/;                    # Prepend spaces
      $jlb->insert('end',$word);                         # Finally re-insert
   }
   $jlb->bind("<Configure>", \&justifyRight_variable);   # Stay right justified
} 

# Right justify the text for a fixed width font
sub justifyRight_fixed{
   my $jlb = shift;
   my @textArray = $jlb->get(0,'end');
   my $width = $jlb->width;
   $jlb->delete(0,'end');
   
   foreach my $word(@textArray){
      $word =~ s/^\s+//;
      $word =~ s/\s+$//;
      my $spaces = $width - (length($word));
      $word =~ s/$word/$spaces$word/;
      
      $jlb->insert('end',$word);
   }
   $jlb->bind("<Configure>", \&justifyRight_fixed);
}

1;
__END__

=head1 JListbox

JListbox - justify text within a Listbox

=head1 SYNOPSIS

  use JListbox;
  $jlb = $parent->JListbox(-justify=>'center');
  $jlb->pack;

=head1 DESCRIPTION

JListbox is identical to a Listbox, but with one added option: -justify.

Possible values are 'left', 'center' and 'right'.  The default is 'left'.
All text within the Listbox will be justified according to the option you set.

The widget automatically checks for variable or fixed width fonts 
and adjusts accordingly.

You cannot justify individual entries separately (as of version .01).

Your text will remain justified appropriately, even if you 
set the '-expand' and '-fill' options.

The justification ability is provided via plain old pixel and 
character counting (depending on whether you are using a variable or 
fixed width font).  There have been no underlying changes in the C code
to the Tcl Listbox.

=head1 KNOWN BUGS

If using a variable width font, you may encounter a problem with the last 
character disappearing off the right side of the listbox when you use
right justify.  I think I fixed this, so let me know if you have any problems.

If the text you insert into the listbox includes characters that have 
special meaning in regular expressions (e.g. '*', '?'), you will need to 
escape them using the '\' character or your app may crash.

I'll fix this in the next release.

e.g. $jlb->insert('end', "What did you say\?");

=head1 PLANNED CHANGES

Fix the regular expression issue mentioned above.

Allow individual entries to be justified.

=head1 AUTHOR

Daniel J. Berger
djberg96@hotmail.com

Thanks goes to Damion K. Wilson for his help with creating widgets.

=head1 SEE ALSO

Listbox

=cut

