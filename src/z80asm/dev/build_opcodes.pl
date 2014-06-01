#!/usr/bin/perl

#     ZZZZZZZZZZZZZZZZZZZZ    8888888888888       00000000000
#   ZZZZZZZZZZZZZZZZZZZZ    88888888888888888    0000000000000
#                ZZZZZ      888           888  0000         0000
#              ZZZZZ        88888888888888888  0000         0000
#            ZZZZZ            8888888888888    0000         0000       AAAAAA         SSSSSSSSSSS   MMMM       MMMM
#          ZZZZZ            88888888888888888  0000         0000      AAAAAAAA      SSSS            MMMMMM   MMMMMM
#        ZZZZZ              8888         8888  0000         0000     AAAA  AAAA     SSSSSSSSSSS     MMMMMMMMMMMMMMM
#      ZZZZZ                8888         8888  0000         0000    AAAAAAAAAAAA      SSSSSSSSSSS   MMMM MMMMM MMMM
#    ZZZZZZZZZZZZZZZZZZZZZ  88888888888888888    0000000000000     AAAA      AAAA           SSSSS   MMMM       MMMM
#  ZZZZZZZZZZZZZZZZZZZZZ      8888888888888       00000000000     AAAA        AAAA  SSSSSSSSSSS     MMMM       MMMM
#
# Copyright (C) Paulo Custodio, 2011-2014
#
# Build opcodes.t test code, using Udo Munk's z80pack assembler as a reference implementation
#
# $Header: /home/dom/z88dk-git/cvs/z88dk/src/z80asm/dev/build_opcodes.pl,v 1.3 2014-06-01 22:16:50 pauloscustodio Exp $

use Modern::Perl;
use File::Basename;
use File::Slurp;
use Iterator::Array::Jagged;
use Iterator::Simple::Lookahead;
use List::Util qw( max );

our $KEEP_FILES;
$KEEP_FILES	 = grep {/-keep/} @ARGV; 

my $UDOMUNK_ASM = "dev/z80pack-1.21/z80asm/z80asm.exe";
my $Z80EMU_SRCDIR = '../../libsrc/z80_crt0s/z80_emu';
my @Z80EMU = qw(
		rcmx_cpd
		rcmx_cpdr
		rcmx_cpi
		rcmx_cpir
		rcmx_rld
		rcmx_rrd
);
my $OUTPUT = "t/opcodes.t";
my @OUTPUT = <<"END_HEADER";
#!/usr/bin/perl

# generated by $0, do not edit

use Modern::Perl;
use t::TestZ80asm;

END_HEADER

my $asm1 = <<'END_ASM';
        public ZERO
        defc ZERO    = 0
END_ASM

my $INPUT = read_file(dirname($0).'/'.basename($0, '.pl').'.asm');

#------------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------------
for my $rabbit (0, 1) {
	for my $error (0, 1) {
		my $iter = 	filter_error_iter( $error, 
					compute_if_iter( {RABBIT => $rabbit}, 
					expand_iter( 
					filter_rcs_kw( read_iter($INPUT) ) ) ) );
		unless ($error) {
			$iter = add_hex_iter($iter);
		}
		$iter = format_iter($iter);
		my @asm; push @asm, $_ while <$iter>;

		# write test code
		if (@asm) {
			push @OUTPUT, "z80asm(\n";
			push @OUTPUT, "    options => \"-l -b".
						  ($rabbit ? " -RCMX000 -i\".z80emu()" : "\"").",\n";
			unless ($error) {
				push @OUTPUT, "    asm1 => <<'END_ASM',\n";
				push @OUTPUT, $asm1;
				push @OUTPUT, "END_ASM\n";
			}
			push @OUTPUT, "    asm  => <<'END_ASM',\n";		
			push @OUTPUT, @asm;
			push @OUTPUT, "END_ASM\n);\n\n";
		}
	}
}
write_file($OUTPUT, @OUTPUT);

#------------------------------------------------------------------------------
# Iterator to read input
#------------------------------------------------------------------------------
sub read_iter {
	my($input) = join("\n", @_);
	my @input = split(/\n/, $input);
	return Iterator::Simple::Lookahead->new( sub {
		my $line = shift(@input);
		defined $line or return;
		return "$line\n";
	} );
}

#------------------------------------------------------------------------------
# Iterator to filter lines with RCS keywords
#------------------------------------------------------------------------------
sub filter_rcs_kw {
	my($in) = @_;
	return Iterator::Simple::Lookahead->new( sub {
		while (1) {
			my $line = $in->next or return;
			next if $line =~ /\$(Header|Id|Log).*?\$/;
			return "$line\n";
		}
	} );
}

#------------------------------------------------------------------------------
# Iterator to expand sequences of {a b c} into lines with a,b,c
#------------------------------------------------------------------------------
sub expand_iter {
	my($in) = @_;
	my %neg_flag = qw(  z  nz  nz z
						c  nc  nc c
						po pe  pe po
						p  m   m  p
					);
	my %prefix =   qw(  ix 0DDh
						iy 0FDh
					);

	return Iterator::Simple::Lookahead->new( sub {
		while (1) {
			my $line = $in->next or return;

			my @args = split(/ ( \{ [^\}]+ \} ) /x, $line);		# separate lists
			if (@args == 1) {
				return $line;					# no lists
			}
			else {
				my @out;
				
				# expand each {a b c} into [a,b,c] and {1} into @item_ref
				my @item_ref = (undef);		# $item_ref[1] = item-1-pos
				my $i = 0;
				for (@args) {
					if (/ \{ (.*) \} /x) {
						my @items = split(' ', $1);
						if (@items == 1 && $items[0] =~ /^\d+/) {		# {1}
							$_ = [$_];
						}
						else {
							$_ = \@items;
							push @item_ref, $i;
						}
					}
					else {
						$_ = [$_];
					}
					$i++;
				}
				
				# iterate through lists
				my $iter = Iterator::Array::Jagged->new(data => \@args);
				while (my @set = $iter->next) {
					# expand {1}, {2}, ...
					for (@set) {
						if (/ \{ (\d+) (.*) \} /x) {
							$_ = $set[ $item_ref[ $1 ] ];
							if ($2) {
								# transformations: -XXX -> remove XXX
								my $transf = $2;
								if ($transf =~ /-(.*)/) {
									my $remove = $1;
									s/\Q$remove\E//g;
								}
								# transformations: ! -> negate flag
								elsif ($transf eq '!') {
									defined $neg_flag{$_} or die "flag '$_' not found";
									$_ = $neg_flag{$_};
								}
								# transformations: @ ix -> DD; iy -> FD
								elsif ($transf eq '@') {
									defined $prefix{$_} or die "prefix '$_' not found";
									$_ = $prefix{$_};
								}
								else {
									die "unknown transformation '$transf'";
								}
							}
						}
					}
					push @out, join("", @set);
				}
				
				# push lines to input stream
				$in->unget( @out );
			}
		}
	} );
}

#------------------------------------------------------------------------------
# Iterator to handle IF/ELSE/ENDIF based on \%options
# IF must be on column 1 and in upper case
#------------------------------------------------------------------------------
sub compute_if_iter {
	my($options, $in) = @_;

	my @state = (1);
	return Iterator::Simple::Lookahead->new( sub {
		while (1) {
			my $line = $in->next or return;
			if ($line =~ /^IF\s+(.*)/) {
				my $expr = $1;
				my $not = $expr =~ s/^\s*!\s*//;
				$expr =~ /^(\w+)\s*(;.*)?$/ or die "IF expression must be identifier";
				push @state, $options->{uc($1)} || 0;
				$state[-1] = ! $state[-1] if $not;
			}
			elsif ($line =~ /^ELSE/) {
				$state[-1] = ! $state[-1];
			}
			elsif ($line =~ /^ENDIF/) {
				@state > 1 or die "ENDIF without IF";
				pop @state;
			}
			else {
				return $line if $state[-1];
			}
		}		
	} );
}

#------------------------------------------------------------------------------
# Iterator to extract only error lines
#------------------------------------------------------------------------------
sub filter_error_iter {
	my($error, $in) = @_;

	return Iterator::Simple::Lookahead->new( sub {
		while (1) {
			my $line = $in->next or return;
			if ($line =~ /;;\s+error\s*\d*: /) {
				return $line if $error;
			}
			else {
				return $line unless $error;
			}
		}
	} );
}

#------------------------------------------------------------------------------
# Call Udo Munk's assembler to compute hex
#------------------------------------------------------------------------------
sub add_hex_iter {
	my($in) = @_;
	
	my @asm;
	push @asm, $_ while (defined($_ = $in->()));
	my @hex = assemble(@asm);
	my @out = merge_asm_hex(\@asm, \@hex);
	
	return read_iter(@out);
}
	
#------------------------------------------------------------------------------
# use z80pack to assemble the code after ;; and return the hex bytes per line
#------------------------------------------------------------------------------
sub assemble {
	my(@asm_code) = @_;
	our $label_n;
	
	my @pack_code = build_pack_code(@asm_code);
	
	# Append used libraries
	my %used_libs; for (@Z80EMU) { $used_libs{$_} = 0; }
	for (@pack_code) {
		my $line = $_;
		$line =~ s/;.*//;
		if ($line =~ /call\s+(\w+)/i && exists $used_libs{$1}) {
			$used_libs{$1} = 1;
		}
	}
	for my $lib (@Z80EMU) {
		if ($used_libs{$lib}) {
			my $lib_asm = read_file($Z80EMU_SRCDIR.'/'.$lib.'.asm');
			$label_n++;
			
			# remove invalid asm, make labels local
			for ($lib_asm) {
				s/^\s*(PUBLIC|EXTERN|XDEF|XREF|LIB|XLIB).*//igm;
				while (/^\.(\w+)/im) {
					my $label = $1;
					my $new_label = (uc($label) eq uc($lib)) ? $label : $label.$label_n;
					s/^\.$label\b/$new_label:/igm;
					s/\b$label\b/$new_label/igm;
				}
			}
			push @pack_code, $lib_asm;
		}
	}
	write_file("test.asm", @pack_code);
	call_assembler("test");
	my @hex = read_hex("test");
	
	unlink('test.asm', 'test.lis', 'test.bin') unless $KEEP_FILES;
	
	return @hex;
}

# add LINE markers, followed by code after ;;
sub build_pack_code {
	my(@asm_code) = @_;
	my @pack_code;
	
	for my $i (0 .. $#asm_code) {
		my $line = $asm_code[$i];
		push @pack_code, ";;LINE $i\n";
		
		$line =~ s/;;\s+warn.*//;		# remove warnings
		
		if ($line !~ /^;/ && $line =~ /;;(.*)/) {
			for (split(/;;/, $1)) {
				push @pack_code, "$_\n";
			}
		}
		else {
			push @pack_code, $line;
		}
	}
	
	return @pack_code;
}
		
sub call_assembler {
	my($file) = @_;
	
	my $args = "-fb -l -o$file.bin $file.asm";
	
	-f $UDOMUNK_ASM && -x _ or die "cannot find assembler $UDOMUNK_ASM";
	print "$UDOMUNK_ASM $args\n";
	system "$UDOMUNK_ASM $args" and die "$UDOMUNK_ASM $args failed";
}

# read hex between LINE markers
sub read_hex {
	my($file) = @_;
	my @hex;
	
	open(my $in, "<", "$file.lis") or die $!;
	while(<$in>) {
		next if /^\f/;
		next if /^Source file:/;
		next if /^Title:/;
		next if /^LOC/;
		next unless /\S/;
		
		if (/^[0-9a-f]{4} (( [0-9a-f]{2}){1,4})/i) {
			@hex or die;
			$hex[-1]  = "" unless $hex[-1];
			$hex[-1] .= uc($1);
		}
		elsif (/;;LINE (\d+)/) {
			$hex[$1] ||= "";
		}
	}
	return @hex;
}

#------------------------------------------------------------------------------
# merge asm code with hex code
#------------------------------------------------------------------------------
sub merge_asm_hex {
	my($asm, $hex) = @_;
	my @out;
	
	for my $i (0 .. max( $#$asm, $#$hex ) ) {
		local $_ = $asm->[$i];
		s/\s+$//;
		
		if (! defined $_) {
			if ($hex->[$i]) {
				push @out, "\t;; ".$hex->[$i];
			}
		}
		elsif (/^\s*;/) {
			push @out, $_;
			if ($hex->[$i]) {
				push @out, "\t;; ".$hex->[$i];
			}
		}
		else {
			my $warn;
			if (/\s*;;\s+(warn\s*\d*: .*)/) {
				$warn = $1;
				$_ = $`;
			}

			s/;.*//;		# remove old comments
			
			if ($hex->[$i]) {
				$_ .= "\t;;".$hex->[$i];
			}
			$_ .= "\t;; $warn" if $warn;
			push @out, $_;
		}
	}
	return @out;
}

#------------------------------------------------------------------------------
# format the assembly language code
#------------------------------------------------------------------------------
sub format_iter {
	my($in) = @_;
	
	my $indent = 8;
	return Iterator::Simple::Lookahead->new( sub {
		while (1) {
			my @lines;
			defined( local $_ = $in->next ) or return;
			s/\s+$//;
			
			return "\n" unless /\S/;
			
			# only comment
			if (/^;/) {
				return "$_\n";
			}
			else {
				# extract warning / error
				my $warn;
				/(;;\s*(warn|error)\s*\d*:\s+(.*))$/ and $warn = $1;
				s/\s*(;;\s*(warn|error)\s*\d*:\s+(.*))$//;
				
				# extract comment
				my $comment;
				/(;.*)$/ and $comment = $1;
				s/\s*;.*$//;
				
				# extract label
				my $label;
				/^(\w+:?|\.\w+)/ and $label = $1;
				s/^(\w+:?|\.\w+)\s*//;
				
				# remove blanks
				s/^\s+//; s/\s+$//;
				
				# format opcode
				s/(\w+)\s+/ sprintf("%-4s ", $1) /e;
				
				# indent
				my $this_indent = $indent;
				if (/^if\b|^\{/) {			$indent += 2; }
				elsif (/^else\b/) {			$this_indent -= 2; }
				elsif (/^endif\b|^\}/) {	$indent -= 2; $this_indent = $indent; }
				else {}				
				
				my $line = sprintf("%-*s ", $this_indent-1, $label || "");
				$line   .= $_;	# opcode
				
				# format warning - must be on same line as opcode
				if ($warn) {
					$line = sprintf("%-39s %s", $line, $warn);
					push @lines, $line;
					$line = "";
				}
				
				# format comments
				if ($comment) {
					if (length($line) > 39) {
						push @lines, $line;
						$line = sprintf("%-39s %s", "", $comment);
					}
					else {
						$line = sprintf("%-39s %s", $line, $comment);
					}
				}
				
				if (@lines) {
					push @lines, $line if $line ne "";
					$line = shift(@lines);
					$in->unget(@lines);
					return "$line\n";
				}
				else {
					return "$line\n";
				}
			}
		}
	} );
}

	

# $Log: build_opcodes.pl,v $
# Revision 1.3  2014-06-01 22:16:50  pauloscustodio
# Write expressions to object file only in pass 2, to remove dupplicate code
# and allow simplification of object file writing code. All expression
# error messages are now output only during pass 2.
#
# Revision 1.2  2014/05/14 21:30:28  pauloscustodio
# Indent {} blocks
#
# Revision 1.1  2014/05/13 23:42:49  pauloscustodio
# Move opcode testing to t/opcodes.t, add errors and warnings checks, build it by dev/build_opcodes.pl and dev/build_opcodes.asm.
# Remove opcode errors and warnings from t/errors.t.
# Remove t/cpu-opcodes.t, it was too slow - calling z80asm for every single Z80 opcode.
# Remove t/data/z80opcodes*, too complex to maintain.
#
#
