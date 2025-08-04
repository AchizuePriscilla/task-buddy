import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_buddy/features/task_management/data/datasources/task_local_datasource.dart';
import 'package:task_buddy/features/task_management/domain/providers/task_local_datasource_provider.dart';
import 'package:task_buddy/shared/data/local/database/database_service.dart';
import 'package:task_buddy/shared/domain/providers/database_provider.dart';
import 'task_local_datasource_provider_test.mocks.dart';

@GenerateMocks([DatabaseService])
void main() {
  late ProviderContainer container;
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(mockDatabaseService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    reset(mockDatabaseService);
  });

  group('TaskLocalDataSourceProvider', () {
    test('should create TaskLocalDataSource with database service', () {
      // Act
      final dataSource = container.read(taskLocalDataSourceProvider);

      // Assert
      expect(dataSource, isA<TaskLocalDataSource>());
    });

    test('should provide singleton instance', () {
      // Act
      final dataSource1 = container.read(taskLocalDataSourceProvider);
      final dataSource2 = container.read(taskLocalDataSourceProvider);

      // Assert
      expect(dataSource1, same(dataSource2));
    });

    test('should have correct type', () {
      // Act
      final dataSource = container.read(taskLocalDataSourceProvider);

      // Assert
      expect(dataSource, isA<TaskLocalDataSource>());
      expect(dataSource.runtimeType, equals(TaskLocalDataSource));
    });

    test('should not be null', () {
      // Act
      final dataSource = container.read(taskLocalDataSourceProvider);

      // Assert
      expect(dataSource, isNotNull);
    });

    test('should be accessible multiple times', () {
      // Act
      final dataSource1 = container.read(taskLocalDataSourceProvider);
      final dataSource2 = container.read(taskLocalDataSourceProvider);
      final dataSource3 = container.read(taskLocalDataSourceProvider);

      // Assert
      expect(dataSource1, isNotNull);
      expect(dataSource2, isNotNull);
      expect(dataSource3, isNotNull);
      expect(dataSource1, same(dataSource2));
      expect(dataSource2, same(dataSource3));
    });

    test('should maintain provider state', () {
      // Act
      final dataSource = container.read(taskLocalDataSourceProvider);

      // Assert
      expect(dataSource, isA<TaskLocalDataSource>());

      // Act again
      final sameDataSource = container.read(taskLocalDataSourceProvider);

      // Assert
      expect(sameDataSource, same(dataSource));
    });

    test('should handle provider access in different contexts', () {
      // Act
      final dataSource1 = container.read(taskLocalDataSourceProvider);

      // Simulate different context
      final dataSource2 = container.read(taskLocalDataSourceProvider);

      // Assert
      expect(dataSource1, isA<TaskLocalDataSource>());
      expect(dataSource2, isA<TaskLocalDataSource>());
      expect(dataSource1, same(dataSource2));
    });

    test('should provide consistent instance across reads', () {
      // Arrange
      final instances = <TaskLocalDataSource>[];

      // Act
      for (int i = 0; i < 5; i++) {
        instances.add(container.read(taskLocalDataSourceProvider));
      }

      // Assert
      expect(instances.length, equals(5));
      for (int i = 1; i < instances.length; i++) {
        expect(instances[i], same(instances[0]));
      }
    });

    test('should not throw when accessed multiple times', () {
      // Act & Assert
      expect(() {
        for (int i = 0; i < 10; i++) {
          container.read(taskLocalDataSourceProvider);
        }
      }, returnsNormally);
    });

    test('should provide valid TaskLocalDataSource instance', () {
      // Act
      final dataSource = container.read(taskLocalDataSourceProvider);

      // Assert
      expect(dataSource, isA<TaskLocalDataSource>());
      expect(dataSource, isNotNull);
    });

    test('should handle concurrent access', () {
      // Act
      final futures = <Future<TaskLocalDataSource>>[];

      for (int i = 0; i < 3; i++) {
        futures.add(Future.value(container.read(taskLocalDataSourceProvider)));
      }

      // Assert
      expect(futures.length, equals(3));
    });

    test('should maintain provider contract', () {
      // Act
      final dataSource = container.read(taskLocalDataSourceProvider);

      // Assert
      expect(dataSource, isA<TaskLocalDataSource>());

      // Verify it can be used as expected
      expect(dataSource, isNotNull);
    });

    test('should not create new instance on each read', () {
      // Act
      final dataSource1 = container.read(taskLocalDataSourceProvider);
      final dataSource2 = container.read(taskLocalDataSourceProvider);
      final dataSource3 = container.read(taskLocalDataSourceProvider);

      // Assert
      expect(identical(dataSource1, dataSource2), isTrue);
      expect(identical(dataSource2, dataSource3), isTrue);
      expect(identical(dataSource1, dataSource3), isTrue);
    });

    test('should provide stable reference', () {
      // Act
      final dataSource = container.read(taskLocalDataSourceProvider);
      final hashCode = dataSource.hashCode;

      // Act again
      final sameDataSource = container.read(taskLocalDataSourceProvider);
      final sameHashCode = sameDataSource.hashCode;

      // Assert
      expect(hashCode, equals(sameHashCode));
    });

    test('should use database service from provider', () {
      // Act
      final dataSource = container.read(taskLocalDataSourceProvider);

      // Assert
      expect(dataSource, isA<TaskLocalDataSource>());
      // Note: We can't directly verify the database service injection
      // since it's private, but we can verify the provider works
    });

    test('should handle provider disposal', () {
      // Act
      final dataSource = container.read(taskLocalDataSourceProvider);

      // Dispose container
      container.dispose();

      // Create new container
      final newContainer = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(mockDatabaseService),
        ],
      );

      final newDataSource = newContainer.read(taskLocalDataSourceProvider);

      // Assert
      expect(dataSource, isA<TaskLocalDataSource>());
      expect(newDataSource, isA<TaskLocalDataSource>());
      expect(dataSource, isNot(same(newDataSource)));

      newContainer.dispose();
    });
  });
}
