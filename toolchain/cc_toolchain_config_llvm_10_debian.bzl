"""LLVM-based build configuration for LLVM 10 on Debian."""

load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "feature",
    "flag_group",
    "flag_set",
    "tool_path",
)

all_link_actions = [
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
]

def _impl(ctx):
    tool_paths = [
        tool_path(
            name = "gcc",
            path = "/usr/lib/llvm-10/bin/clang",
        ),
        tool_path(
            name = "ld",
            path = "/usr/lib/llvm-10/bin/ld.lld",
        ),
        tool_path(
            name = "ar",
            path = "/usr/lib/llvm-10/bin/llvm-ar",
        ),
        tool_path(
            name = "cpp",
            path = "/usr/lib/llvm-10/bin/clang-cpp",
        ),
        tool_path(
            name = "gcov",
            path = "/bin/false",
        ),
        tool_path(
            name = "nm",
            path = "/usr/lib/llvm-10/bin/llvm-nm",
        ),
        tool_path(
            name = "objdump",
            path = "/usr/lib/llvm-10/bin/llvm-objdump",
        ),
        tool_path(
            name = "strip",
            path = "/usr/lib/llvm-10/bin/llvm-strip",
        ),
    ]

    features = [
        feature(
            name = "default_cpp_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = [ACTION_NAMES.cpp_compile],
                    flag_groups = ([
                        flag_group(
                            flags = [
                                "-march=native",
                                "-std=c++17",
                                "-stdlib=libc++",
                            ],
                        ),
                    ]),
                ),
            ],
        ),
        feature(
            name = "default_linker_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = all_link_actions,
                    flag_groups = ([
                        flag_group(
                            flags = [
                                "-fuse-ld=lld",
                                "-lc++",
                                "-lm",
                            ],
                        ),
                    ]),
                ),
            ],
        ),
    ]

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        features = features,
        cxx_builtin_include_directories = [
            "/usr/include",
            "/usr/lib/llvm-10/include/c++/v1/",
            "/usr/lib/llvm-10/lib/clang/10.0.0/include",
        ],
        toolchain_identifier = "local",
        host_system_name = "local",
        target_system_name = "local",
        target_cpu = "k8",
        target_libc = "unknown",
        compiler = "clang",
        abi_version = "unknown",
        abi_libc_version = "unknown",
        tool_paths = tool_paths,
    )

cc_toolchain_config_llvm_10_debian = rule(
    implementation = _impl,
    attrs = {},
    provides = [CcToolchainConfigInfo],
)
