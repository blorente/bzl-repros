load("@rules_rust//rust:defs.bzl", "rust_clippy_aspect")
load("@rules_rust//rust:rust_common.bzl", "ClippyInfo")

ClippyOutputsTransitive = provider(
    doc = "Provides information on a clippy run.",
    fields = {
        "outputs": "Depset of clippy output files.",
    },
)

def _process_output_aspect_impl(target, ctx):
    output_files_depsets = []
    if OutputGroupInfo in target:
        print("BL: _process_output_aspect_impl::output_group::provider(target={}, og={})".format(target.label, target[OutputGroupInfo]))
        if hasattr(target[OutputGroupInfo], "clippy_checks"):
            clippy_files = getattr(target[OutputGroupInfo], "clippy_checks")
            print("BL: _process_output_aspect_impl::output_group(target={}, og={})".format(target.label, clippy_files))
            output_files_depsets.append(clippy_files)

    print("BL: _process_output_aspect_impl::after_direct(target={}, outputs={})".format(target.label, output_files_depsets))

    transitive = []
    for dep in ctx.rule.attr.deps:
        transitive.append(dep[ClippyOutputsTransitive].outputs)

    ret = ClippyOutputsTransitive(outputs = depset(
        output_files_depsets,
        transitive = transitive,
    ))

    print("BL: _process_output_aspect_impl::ret(target={}, ret={})".format(target.label, ret))
    return [ret]

process_output_aspect = aspect(
    implementation = _process_output_aspect_impl,
    attr_aspects = ["deps"],
    provides = [ClippyOutputsTransitive],
    required_aspect_providers = [
        ClippyInfo,
    ],
)

def _process_output_impl(ctx):
    transitive = [target[ClippyOutputsTransitive] for target in ctx.attr.deps]
    print("BL: _process_output_impl(target={}, transitive={})".format(ctx.label, transitive))

    all_files = []
    for dep in transitive:
        files = dep.outputs.to_list()
        print("BL: _process_output_impl::all_files::files(target={}, files={})".format(ctx.label, files))
        if files[0] == None:
            continue
        all_files += files

    all_files_depset = depset([], transitive = all_files)

    out = ctx.actions.declare_file(ctx.label.name + "_processed")
    print("BL: _process_output_impl::all_files(target={}, all_files={}, all_files_depset={}, out={})".format(ctx.label, all_files, all_files_depset, out))
    ctx.actions.write(
        output = out,
        content = "\n".join([
            file.path
            for file in all_files_depset.to_list()
        ]),
    )

    return [
        DefaultInfo(files = depset([out])),
    ]

process_output = rule(
    _process_output_impl,
    attrs = {
        "deps": attr.label_list(
            mandatory = True,
            aspects = [
                rust_clippy_aspect,
                process_output_aspect,
            ],
        ),
    },
)
