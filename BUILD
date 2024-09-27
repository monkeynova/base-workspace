load("//:default_rules.bzl", "update_workspace_rule")

update_workspace_rule(workspace_dep = "update_workspace.date")

sh_binary(
    name = "cleanup",
    srcs = ["cleanup.sh"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "update_workspace_tool",
    srcs = ["update_workspace.pl"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "base-bazelrc-file",
    srcs = ["base-bazelrc"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "gitignore",
    srcs = [".gitignore"],
    visibility = ["//visibility:public"],
)
