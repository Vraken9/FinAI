// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$upcomingRecurringHash() => r'c9dc5872552f631052e8e4227e096cab61ab814d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [upcomingRecurring].
@ProviderFor(upcomingRecurring)
const upcomingRecurringProvider = UpcomingRecurringFamily();

/// See also [upcomingRecurring].
class UpcomingRecurringFamily extends Family<AsyncValue<List<RecurringRule>>> {
  /// See also [upcomingRecurring].
  const UpcomingRecurringFamily();

  /// See also [upcomingRecurring].
  UpcomingRecurringProvider call(
    int days,
  ) {
    return UpcomingRecurringProvider(
      days,
    );
  }

  @override
  UpcomingRecurringProvider getProviderOverride(
    covariant UpcomingRecurringProvider provider,
  ) {
    return call(
      provider.days,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'upcomingRecurringProvider';
}

/// See also [upcomingRecurring].
class UpcomingRecurringProvider
    extends AutoDisposeFutureProvider<List<RecurringRule>> {
  /// See also [upcomingRecurring].
  UpcomingRecurringProvider(
    int days,
  ) : this._internal(
          (ref) => upcomingRecurring(
            ref as UpcomingRecurringRef,
            days,
          ),
          from: upcomingRecurringProvider,
          name: r'upcomingRecurringProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$upcomingRecurringHash,
          dependencies: UpcomingRecurringFamily._dependencies,
          allTransitiveDependencies:
              UpcomingRecurringFamily._allTransitiveDependencies,
          days: days,
        );

  UpcomingRecurringProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.days,
  }) : super.internal();

  final int days;

  @override
  Override overrideWith(
    FutureOr<List<RecurringRule>> Function(UpcomingRecurringRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UpcomingRecurringProvider._internal(
        (ref) => create(ref as UpcomingRecurringRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        days: days,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<RecurringRule>> createElement() {
    return _UpcomingRecurringProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpcomingRecurringProvider && other.days == days;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, days.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UpcomingRecurringRef
    on AutoDisposeFutureProviderRef<List<RecurringRule>> {
  /// The parameter `days` of this provider.
  int get days;
}

class _UpcomingRecurringProviderElement
    extends AutoDisposeFutureProviderElement<List<RecurringRule>>
    with UpcomingRecurringRef {
  _UpcomingRecurringProviderElement(super.provider);

  @override
  int get days => (origin as UpcomingRecurringProvider).days;
}

String _$recurringRulesNotifierHash() =>
    r'98aeb02cfad26373de0bd0de7f3dc89930840e01';

/// See also [RecurringRulesNotifier].
@ProviderFor(RecurringRulesNotifier)
final recurringRulesNotifierProvider = AutoDisposeAsyncNotifierProvider<
    RecurringRulesNotifier, List<RecurringRule>>.internal(
  RecurringRulesNotifier.new,
  name: r'recurringRulesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recurringRulesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RecurringRulesNotifier
    = AutoDisposeAsyncNotifier<List<RecurringRule>>;
String _$draftTransactionsNotifierHash() =>
    r'f3730733e54e6a77a046745fde7dec3d6ea45f12';

/// See also [DraftTransactionsNotifier].
@ProviderFor(DraftTransactionsNotifier)
final draftTransactionsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    DraftTransactionsNotifier, List<model_transaction.Transaction>>.internal(
  DraftTransactionsNotifier.new,
  name: r'draftTransactionsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$draftTransactionsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DraftTransactionsNotifier
    = AutoDisposeAsyncNotifier<List<model_transaction.Transaction>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
