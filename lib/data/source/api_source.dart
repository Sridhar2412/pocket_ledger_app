import 'package:dio/dio.dart';
import 'package:pocket_ledger_app/core/constants/constants.dart';
import 'package:retrofit/retrofit.dart';

import '../dto/transaction_dto.dart';

part 'api_source.g.dart';

@RestApi(baseUrl: Constants.baseUrl)
abstract class ApiSource {
  factory ApiSource(Dio dio, {String baseUrl}) = _ApiSource;

  @GET("/transactions")
  Future<List<TransactionDTO>> getTransactions();

  @POST("/transactions/save")
  Future<void> addTransaction(@Body() TransactionDTO txn);

  @PUT("/transactions/{id}")
  Future<void> updateTransaction(
      @Path("id") String id, @Body() TransactionDTO txn);

  @DELETE("/transactions/{id}")
  Future<void> deleteTransaction(@Path("id") String id);
}
