# Base workspace

Contains a suite of personal tools to include with all my bazel workspaces.

### Usage

Add the following to the BUILD file

```
load("@com_monkeynova_base_workspace//:default_rules.bzl", "default_rules")

default_rules(workspace_dep = "update_workspace.date")
```

Adds the rules

* ```bazel run :write_base-bazelrc```
* ```bazel run :write_gitignore```
* ```bazel run :cleanup```
* ```bazel run :update_workspace```

### :write_base-bazelrc

Updates base-bazelrc to match @com_monkeynova_base_workspace//:base_bazelrc

```bazel test :write_base-bazelrc_test``` will fail if the files have different
contents

### :write_gitignore-bazelrc

Updates .gitignore to match @com_monkeynova_base_workspace//:.gitignore

```bazel test :write_gitignore_test``` will fail if the files have different
contents

### :cleanup

Runs style conformance updates on all files in the git respoitory. Specifically
this runs ```buildifier``` on all BUILD files and ```clang-tidy``` on all .cc
and .h files.

### :update_workspace

Updates MODULES.bazel so that git_override references use to the latest commit
on github and bazel_dep references use the latest version in the
[bazel central repository](https://github.com/bazelbuild/bazel-central-registry)
on github.

The :update_workspace target has as a dependency the file listed in workspace_dep,
so to force an update, you should also do something like the following.

```
date > update_workspace.date
```


