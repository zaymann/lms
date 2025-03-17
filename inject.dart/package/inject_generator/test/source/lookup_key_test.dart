/*
import 'dart:convert';

import 'package:inject_generator/src/source/lookup_key.dart';
import 'package:inject_generator/src/source/symbol_path.dart';
import 'package:quiver/testing/equality.dart';
import 'package:test/test.dart';

import '../injector/providers_injector_test.dart';

final typeName1 = 'TypeName1';
final typeSymbolPath1 = new SymbolPath.global(typeName1);

final typeName2 = 'TypeName2';
final typeSymbolPath2 = new SymbolPath.global(typeName2);

final qualifierName = 'fakeQualifier';
final qualifier = new SymbolPath.global(qualifierName);

void main() {
  group(LookupKey, () {
    group('toPrettyString', () {
      test('only root', () async {
        final type = new LookupKey(typeSymbolPath1, qualifier: qualifier);

        final prettyString = type.toPrettyString();

        expect(prettyString, typeName1);
      });

      test('qualified type', ()async {
        final type = new LookupKey(typeSymbolPath1, qualifier: qualifier);

        final prettyString = type.toPrettyString();

        expect(prettyString, '@$qualifierName $typeName1');
      });
    }, skip: null);

    group('serialization', () {
      test('with all fields', () async {
        final type = new LookupKey(typeSymbolPath1, qualifier: qualifier);

        final deserialized = deserialize(type);

        expect(deserialized, type);
      });

      test('without qualifier', () async {
        final type = new LookupKey(typeSymbolPath1, qualifier: qualifier);

        final deserialized = deserialize(type);

        expect(deserialized, type);
      });
    }, skip: null);

    test('equality', () async {
     */
/* expect({
        'only root': [
          new LookupKey(typeSymbolPath1, qualifier: qualifier),
          new LookupKey(typeSymbolPath1, qualifier: qualifier)
        ],
        'with qualifier': [
          new LookupKey(typeSymbolPath1, qualifier: qualifier),
          new LookupKey(typeSymbolPath1, qualifier: qualifier)
        ],
      });*//*

    });
  }, skip: null);
}

LookupKey deserialize(LookupKey type) {
  final json = const JsonEncoder().convert(type);
  return new LookupKey.fromJson(const JsonDecoder().convert(json));
}
*/
