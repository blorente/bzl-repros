load("@rules_rust//rust:defs.bzl", "rust_clippy_aspect")

def _process_output_impl(ctx):
    outputs = ctx.attr.target_to_process[OutputGroupInfo]
    clippy = getattr(outputs, "clippy_checks")
    print("BL: _process_output_impl(outputs={}, clippy={})".format(outputs, clippy))

    out = ctx.actions.declare_file(ctx.label.name + "_processed")
    ctx.actions.expand_template(
        template = clippy.to_list()[0],
        output = out,
    )

    return [DefaultInfo(files = depset([out]))]

process_output = rule(
    _process_output_impl,
    attrs = {
        "target_to_process": attr.label(
            mandatory = True,
            providers = [
                OutputGroupInfo,
            ],
            aspects = [rust_clippy_aspect],
        ),
    },
)
