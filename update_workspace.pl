#!/usr/bin/env -S perl

use strict;
use warnings;

use JSON;

my ($in_file, $out_file) = @ARGV;
die "USAGE:\n$0 <infile> <outfile>" unless $out_file;

open my $in_fh, '<', $in_file or die "Cannot open $in_file: $!";
open my $out_fh, '>', $out_file or die "Cannot open $out_file: $!";

my %commit_map;
my $workspace = "";
while (<$in_fh>) {
  $workspace .= $_;
  next if !eof;

  while ($workspace =~ m{git_override\(([^)]+)\)}sg) {
    my $repository = $1;
    my %args = $repository =~ /([a-z_]+)\s*=\s*\"(.*?)(?!<\")\"/g;
    next if $commit_map{$args{commit}};
    if ($args{no_update}) {
      warn "Not updating $args{remote}: $args{no_update}\n";
      next;
    }
    
    if ($args{remote} =~ m{https://github.com/(.*)\.git}) {
      my $github_name = $1;
  	my $branch = ($args{branch} && "/$args{branch}") // "/master";
      my $auth = $ENV{"GH_AUTH"} ? "-u $ENV{GH_AUTH} " : "";
      my $json_str = `curl $auth -s https://api.github.com/repos/$github_name/commits$branch`;
      my $json = JSON::from_json($json_str);
      if (ref($json) ne 'HASH') {
          warn "Cannot find commit for ", $github_name, ": ", $json_str;
          next;
      }
      my $sha = $json->{sha};
      if ($sha) {
          if ($args{commit} ne $sha) {
            warn "updating $args{module_name} ($github_name) => $sha\n";
            $commit_map{$args{commit}} = $sha;
          } else {
            warn "unchanged $args{module_name}\n";
          }
      } else {
          warn "cannot update $args{module_name} ($github_name)!\n$json_str\n";
      }
    }
  }
  
  while (my ($pre_sha, $post_sha) = each %commit_map) {
      $workspace =~ s{$pre_sha}{$post_sha}g;
  }
  
  print {$out_fh} $workspace;
  $workspace = "";
}

close $in_fh or die "Cannot close $in_file: $!";
close $out_fh or die "Cannot close $out_file: $!";
