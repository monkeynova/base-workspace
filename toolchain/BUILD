load("@rules_cc//cc:defs.bzl", "cc_toolchain", "cc_toolchain_suite")
load(
    ":cc_toolchain_config_llvm_10_debian.bzl",
    "cc_toolchain_config_llvm_10_debian",
)

package(default_visibility = ["//visibility:public"])

filegroup(name = "empty")

cc_toolchain_suite(
    name = "llvm_10_debian_suite",
    toolchains = {
        "k8": ":k8_toolchain_debian",
    },
)

cc_toolchain(
    name = "k8_toolchain_debian",
    all_files = ":empty",
    compiler_files = ":empty",
    dwp_files = ":empty",
    linker_files = ":empty",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 0,
    toolchain_config = ":k8_toolchain_debian_config",
    toolchain_identifier = "k8-toolchain-debian",
)

cc_toolchain_config_llvm_10_debian(name = "k8_toolchain_debian_config")
