import 'package:mockito/annotations.dart';

import 'package:kitabghar/features/auth/domain/repositories/auth_reposity.dart';
import 'package:kitabghar/features/auth/domain/usecases/login_usercase.dart';
import 'package:kitabghar/features/auth/domain/usecases/register_usecase.dart';
import 'package:kitabghar/features/auth/domain/usecases/logout_usecase.dart';

import 'package:kitabghar/features/books/domain/repositories/books_repository.dart';
import 'package:kitabghar/features/books/domain/usecases/create_books_usecase.dart';
import 'package:kitabghar/features/books/domain/usecases/get_all_books_usecase.dart';
import 'package:kitabghar/features/books/domain/usecases/delete_books_usecase.dart';

@GenerateMocks([
  IAuthRepository,
  IBooksRepository,
  LoginUseCase,
  RegisterUseCase,
  LogoutUseCase,
  GetAllBooksUseCase,
  CreateBooksUseCase,
  DeleteBooksUseCase,
])
void main() {}