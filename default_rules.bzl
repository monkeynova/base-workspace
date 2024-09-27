load("@aspect_bazel_lib//lib:write_source_files.bzl", "write_source_file")

def update_workspace_rule(workspace_dep):
  native.genrule(
    name = "new_workspace_file",
    outs = ["MODULE.bazel.new"],
    srcs = [":MODULE.bazel"] + [workspace_dep],
    tools = ["@com_monkeynova_base_workspace//:update_workspace_tool"],
    cmd = "perl $(location @com_monkeynova_base_workspace//:update_workspace_tool) $(location :MODULE.bazel) $@",
  )

  write_source_file(
    name = "update_workspace",
    in_file = ":new_workspace_file",
    out_file = "MODULE.bazel",
    diff_test = False,
  )

def default_rules(workspace_dep):
  update_workspace_rule(workspace_dep)

  native.alias(
      name = "cleanup",
      actual = "@com_monkeynova_base_workspace//:cleanup",
  )

  write_source_file(
      name = "write_base-bazelrc",
      in_file = "@com_monkeynova_base_workspace//:base-bazelrc-file",
      out_file = "base-bazelrc",
  )

  write_source_file(
      name = "write_gitignore",
      in_file = "@com_monkeynova_base_workspace//:gitignore",
      out_file = ".gitignore",
  )
