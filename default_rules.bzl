load("@aspect_bazel_lib//lib:write_source_files.bzl", "write_source_file")

def default_rules():
  native.alias(
      name = "cleanup",
      actual = "@com_monkeynova_base_workspace//:cleanup",
  )
  
  native.alias(
      name = "update_workspace",
      actual = "@com_monkeynova_base_workspace//:update_workspace",
  )
  
  write_source_file(
      name = "write_base-bazelrc",
      in_file = "@com_monkeynova_base_workspace//:base-bazelrc-file",
      out_file = "base-bazelrc",
  )