/*
import 'dart:convert';

import 'package:inject_generator/src/source/injected_type.dart';
import 'package:inject_generator/src/source/lookup_key.dart';
import 'package:inject_generator/src/source/symbol_path.dart';
import 'package:quiver/testing/equality.dart';
import 'package:test/test.dart';

import '../injector/providers_injector_test.dart';

final lookupKey1 = new LookupKey(new SymbolPath.global('1'), qualifier: SymbolPath.qualifier);
final lookupKey2 = new LookupKey(new SymbolPath.global('2'), qualifier: SymbolPath.qualifier);

void main() {
  group(LookupKey, () {
    test('serialization', () async {
      final type = new InjectedType(lookupKey1, isProvider: true);

      final deserialized = deserialize(type);

      expect(deserialized, type);
    });

   */
/* test('equality', () {
      expect({
        'only lookupKey': [
          new InjectedType(lookupKey1),
          new InjectedType(lookupKey1)
        ],
        'different lookupKey': [
          new InjectedType(lookupKey2),
          new InjectedType(lookupKey2)
        ],
        'with isProvider': [
          new InjectedType(lookupKey1, isProvider: true),
          new InjectedType(lookupKey1, isProvider: true)
        ],
      }, areEqualityGroups);
    });*//*

  }, skip: '');
}

InjectedType deserialize(InjectedType type) {
  final json = const JsonEncoder().convert(type);
  return new InjectedType.fromJson(const JsonDecoder().convert(json));
}
*/
