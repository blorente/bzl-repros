load("@aspect_bazel_lib//lib:utils.bzl", "is_bzlmod_enabled")

def pprint(rctx):
  print("Debug Rule ran: {}".format(rctx.name))
  rctx.file("BUILD.bazel", "")

def _bad_repo_rule_impl(rctx):
  enabled = is_bzlmod_enabled()
  pprint(rctx)

bad_repo_rule = repository_rule(
  implementation = _bad_repo_rule_impl,
)

def _good_repo_rule_impl(rctx):
  pprint(rctx)

good_repo_rule = repository_rule(
  implementation = _good_repo_rule_impl,
)

