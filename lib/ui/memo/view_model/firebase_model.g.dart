// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getUserCollectionHash() => r'ed424cc6ab5736987c24bfba2a578ce462a61329';

/// See also [getUserCollection].
@ProviderFor(getUserCollection)
final getUserCollectionProvider = AutoDisposeFutureProvider<
    Stream<QuerySnapshot<Map<String, dynamic>>>>.internal(
  getUserCollection,
  name: r'getUserCollectionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getUserCollectionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetUserCollectionRef
    = AutoDisposeFutureProviderRef<Stream<QuerySnapshot<Map<String, dynamic>>>>;
String _$firebaseModelHash() => r'0435b7de73a0cddbc27c82cea83a4cda9cddfdb4';

/// See also [FirebaseModel].
@ProviderFor(FirebaseModel)
final firebaseModelProvider = AutoDisposeStreamNotifierProvider<FirebaseModel,
    QuerySnapshot<Map<String, dynamic>>>.internal(
  FirebaseModel.new,
  name: r'firebaseModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FirebaseModel
    = AutoDisposeStreamNotifier<QuerySnapshot<Map<String, dynamic>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
