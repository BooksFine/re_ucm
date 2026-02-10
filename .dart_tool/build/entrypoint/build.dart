// @dart=3.6
// ignore_for_file: directives_ordering
// build_runner >=2.4.16
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:build_runner/src/build_plan/builder_factories.dart' as _i1;
import 'dart:io' as _i2;
import 'package:build_runner/src/bootstrap/processes.dart' as _i3;

final _builderFactories = _i1.BuilderFactories(
  {},
  postProcessBuilderFactories: {},
);
void main(List<String> args) async {
  _i2.exitCode = await _i3.ChildProcess.run(
    args,
    _builderFactories,
  )!;
}
