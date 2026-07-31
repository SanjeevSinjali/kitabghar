import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kitabghar/features/purchases/domain/entities/purchase_entity.dart';
import 'package:kitabghar/features/purchases/domain/usecases/buy_book_usecase.dart';
import 'package:kitabghar/features/purchases/domain/usecases/get_purchases_usecase.dart';
import 'package:kitabghar/features/purchases/domain/usecases/initiate_khalti_payment_usecase.dart';
import 'package:kitabghar/features/purchases/domain/usecases/verify_khalti_payment_usecase.dart';

import '../../../../mocktail_mocks.dart';

void main() {
  late MockPurchaseRepository mockRepository;
  late BuyBookUseCase buyBookUseCase;
  late GetPurchasesUseCase getPurchasesUseCase;
  late InitiateKhaltiPaymentUseCase initiateKhaltiPaymentUseCase;
  late VerifyKhaltiPaymentUseCase verifyKhaltiPaymentUseCase;

  const tToken = 'sample-token';

  setUpAll(() {
    registerAllFallbackValues();
    registerFallbackValue(tPurchaseEntity);
  });

  setUp(() {
    mockRepository = MockPurchaseRepository();
    buyBookUseCase = BuyBookUseCase(repository: mockRepository);
    getPurchasesUseCase = GetPurchasesUseCase(repository: mockRepository);
    initiateKhaltiPaymentUseCase =
        InitiateKhaltiPaymentUseCase(repository: mockRepository);
    verifyKhaltiPaymentUseCase =
        VerifyKhaltiPaymentUseCase(repository: mockRepository);
  });

  group('BuyBookUseCase', () {
    final params = BuyBookParams(token: tToken, item: tPurchaseEntity);

    test('returns Right(PurchaseEntity) when the purchase succeeds', () async {
      when(() => mockRepository.buyBook(
              token: any(named: 'token'), item: any(named: 'item')))
          .thenAnswer((_) async => const Right(tPurchaseEntity));

      final result = await buyBookUseCase(params);

      expect(result, const Right(tPurchaseEntity));
    });

    test('returns Left(Failure) when the purchase fails', () async {
      when(() => mockRepository.buyBook(
              token: any(named: 'token'), item: any(named: 'item')))
          .thenAnswer((_) async => const Left(tApiFailure));

      final result = await buyBookUseCase(params);

      expect(result, const Left(tApiFailure));
    });

    test('forwards the exact token and item to the repository', () async {
      when(() => mockRepository.buyBook(
              token: any(named: 'token'), item: any(named: 'item')))
          .thenAnswer((_) async => const Right(tPurchaseEntity));

      await buyBookUseCase(params);

      verify(() => mockRepository.buyBook(token: tToken, item: tPurchaseEntity))
          .called(1);
    });
  });

  group('GetPurchasesUseCase', () {
    test('returns Right(List<PurchaseEntity>) with purchase history',
        () async {
      when(() => mockRepository.getPurchases(token: any(named: 'token')))
          .thenAnswer((_) async => const Right([tPurchaseEntity]));

      final result = await getPurchasesUseCase(tToken);

      expect(result, const Right([tPurchaseEntity]));
    });

    test('returns Right(empty list) when there is no purchase history',
        () async {
      when(() => mockRepository.getPurchases(token: any(named: 'token')))
          .thenAnswer((_) async => const Right(<PurchaseEntity>[]));

      final result = await getPurchasesUseCase(tToken);

      result.fold((_) => fail('expected Right'), (items) => expect(items, isEmpty));
    });

    test('returns Left(Failure) when fetching purchase history fails',
        () async {
      when(() => mockRepository.getPurchases(token: any(named: 'token')))
          .thenAnswer((_) async => const Left(tApiFailure));

      final result = await getPurchasesUseCase(tToken);

      expect(result, const Left(tApiFailure));
    });

    test('calls repository.getPurchases with the exact token', () async {
      when(() => mockRepository.getPurchases(token: any(named: 'token')))
          .thenAnswer((_) async => const Right([tPurchaseEntity]));

      await getPurchasesUseCase(tToken);

      verify(() => mockRepository.getPurchases(token: tToken)).called(1);
    });
  });

  group('InitiateKhaltiPaymentUseCase', () {
    final params =
        InitiateKhaltiPaymentParams(token: tToken, item: tPurchaseEntity);

    test('returns Right(KhaltiSession) with a payment URL and pidx',
        () async {
      when(() => mockRepository.initiateKhaltiPayment(
              token: any(named: 'token'), item: any(named: 'item')))
          .thenAnswer((_) async => const Right(tKhaltiSession));

      final result = await initiateKhaltiPaymentUseCase(params);

      expect(result, const Right(tKhaltiSession));
    });

    test('returns Left(Failure) when Khalti session initiation fails',
        () async {
      when(() => mockRepository.initiateKhaltiPayment(
              token: any(named: 'token'), item: any(named: 'item')))
          .thenAnswer((_) async => const Left(tApiFailure));

      final result = await initiateKhaltiPaymentUseCase(params);

      expect(result, const Left(tApiFailure));
    });

    test('forwards the exact token and item to the repository', () async {
      when(() => mockRepository.initiateKhaltiPayment(
              token: any(named: 'token'), item: any(named: 'item')))
          .thenAnswer((_) async => const Right(tKhaltiSession));

      await initiateKhaltiPaymentUseCase(params);

      verify(() => mockRepository.initiateKhaltiPayment(
          token: tToken, item: tPurchaseEntity)).called(1);
    });
  });

  group('VerifyKhaltiPaymentUseCase', () {
    final params = VerifyKhaltiPaymentParams(
        token: tToken, pidx: 'pidx-123', item: tPurchaseEntity);

    test('returns Right(PurchaseEntity) once payment is verified as complete',
        () async {
      when(() => mockRepository.verifyKhaltiPayment(
              token: any(named: 'token'),
              pidx: any(named: 'pidx'),
              item: any(named: 'item')))
          .thenAnswer((_) async => const Right(tPurchaseEntity));

      final result = await verifyKhaltiPaymentUseCase(params);

      expect(result, const Right(tPurchaseEntity));
    });

    test('returns Left(Failure) when the payment was not actually completed',
        () async {
      const notCompleted = ApiFailure(message: 'Payment not completed');
      when(() => mockRepository.verifyKhaltiPayment(
              token: any(named: 'token'),
              pidx: any(named: 'pidx'),
              item: any(named: 'item')))
          .thenAnswer((_) async => const Left(notCompleted));

      final result = await verifyKhaltiPaymentUseCase(params);

      expect(result.isLeft(), true);
    });

    test('forwards the exact pidx to the repository', () async {
      when(() => mockRepository.verifyKhaltiPayment(
              token: any(named: 'token'),
              pidx: any(named: 'pidx'),
              item: any(named: 'item')))
          .thenAnswer((_) async => const Right(tPurchaseEntity));

      await verifyKhaltiPaymentUseCase(params);

      verify(() => mockRepository.verifyKhaltiPayment(
          token: tToken, pidx: 'pidx-123', item: tPurchaseEntity)).called(1);
    });
  });
}
