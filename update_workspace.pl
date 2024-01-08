#!/usr/bin/env -S perl

use strict;
use warnings;

use JSON;

my ($in_file, $out_file) = @ARGV;
die "USAGE:\n$0 <infile> <outfile>" unless $out_file;

my $bcr_dir = "$ENV{HOME}/github/bazelbuild/bazel-central-registry";
if (!-d $bcr_dir) {
  warn "Bazel central registry not found at: $bcr_dir";
} else {
  warn "Pulling BCR updates";
  system("cd $bcr_dir; git pull > /dev/null");
}

open my $in_fh, '<', $in_file or die "Cannot open $in_file: $!";

my $workspace = join '', <$in_fh>;
if (-d $bcr_dir) {
  $workspace =~ s{bazel_dep\(([^)]+version[^)]+)\)}{"bazel_dep(" . fix_bazel_dep($1) . ")"}sge;
}
$workspace =~ s{git_override\(([^)]+)\)}{"git_override(" . fix_git_override($1) . ")"}sge;

close $in_fh or die "Cannot close $in_file: $!";

open my $out_fh, '>', $out_file or die "Cannot open $out_file: $!";
print {$out_fh} $workspace;

close $out_fh or die "Cannot close $out_file: $!";

sub fix_bazel_dep {
  my ($repository) = @_;

  my %args = $repository =~ /([a-z_]+)\s*=\s*\"(.*?)(?!<\")\"/g;
  if ($args{no_update}) {
    warn "Not updating $args{name}: $args{no_update}\n";
    return $repository;
  }
  if (!$args{version}) {
    warn "Not updating $args{name}: no version specified\n";
    warn JSON::to_json(\%args);
    return $repository;
  }

  my $json_file = "$bcr_dir/modules/$args{name}/metadata.json";
  open my $json_fh, '<', $json_file or do { warn "Cannot open $json_file: $!"; return $repository; };
  my $json_str = join '', <$json_fh>;
  close $json_fh;
  my $json = JSON::from_json($json_str);
  my $latest_version = $json->{versions}->[-1];
  if ($args{version} eq $latest_version) {
    warn "unchanged $args{name}\n";
  } else {
    warn "updating $args{name} => $latest_version\n";
    $repository =~ s{$args{version}}{$latest_version}g;
  }

  return $repository;
}

sub fix_git_override {
  my ($repository) = @_;
  my %args = $repository =~ /([a-z_]+)\s*=\s*\"(.*?)(?!<\")\"/g;
  if ($args{no_update}) {
    warn "Not updating $args{remote}: $args{no_update}\n";
    return $repository;
  }

  if ($args{remote} =~ m{https://github.com/(.*)\.git}) {
    my $github_name = $1;
    my $branch = ($args{branch} && "/$args{branch}") // "/master";
    my $auth = $ENV{"GH_AUTH"} ? "-u $ENV{GH_AUTH} " : "";
    my $json_str = `curl $auth -s https://api.github.com/repos/$github_name/commits$branch`;
    my $json = JSON::from_json($json_str);
    if (ref($json) ne 'HASH') {
      warn "Cannot find commit for ", $github_name, ": ", $json_str;
    } else {
      my $post_sha = $json->{sha};
      if ($post_sha) {
        my $pre_sha = $args{commit};
        if ($pre_sha ne $post_sha) {
          warn "updating $args{module_name} ($github_name) => $post_sha\n";
          $repository =~ s{$pre_sha}{$post_sha}g;
        } else {
          warn "unchanged $args{module_name}\n";
        }
      } else {
        warn "cannot update $args{module_name} ($github_name)!\n$json_str\n";
      }
    }
  }

  return $repository;
}