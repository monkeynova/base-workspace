load("@aspect_bazel_lib//lib:write_source_files.bzl", "write_source_file")

def default_rules():
  native.alias(
      name = "cleanup",
      actual = "@com_monkeynova_base_workspace//:cleanup",
  )
  
  native.genrule(
    name = "new_workspace_file",
    outs = ["WORKSPACE.new"],
    srcs = [":WORKSPACE"],
    tools = ["@com_monkeynova_base_workspace//:update_workspace_tool"],
    cmd = "perl $(location @com_monkeynova_base_workspace//:update_workspace_tool) $(location :WORKSPACE) $@",
  )

  write_source_file(
    name = "update_workspace",
    in_file = ":new_workspace_file",
    out_file = "WORKSPACE",
    diff_test = False,
  )
  
  write_source_file(
      name = "write_base-bazelrc",
      in_file = "@com_monkeynova_base_workspace//:base-bazelrc-file",
      out_file = "base-bazelrc",
  )