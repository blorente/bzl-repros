load("@rules_rust//rust:defs.bzl", "rust_binary")
load("//:process_output.bzl", "process_output")

rust_binary(
    name = "bin_with_warnings_and_errors",
    srcs = [":warnings_and_errors.rs"],
    edition = "2021",
)

process_output(
    name = "processed",
    deps = [":bin_with_warnings_and_errors"],
)
