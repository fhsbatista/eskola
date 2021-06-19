import 'package:eskola/enrollment.dart';
import 'package:eskola/enrollment_output_dto.dart';
import 'package:eskola/enrollment_repository.dart';

class GetEnrollmentUsecase {
  final EnrollmentRepository repository;

  GetEnrollmentUsecase(this.repository);

  Future<EnrollmentOutputDto> call(String code) async {
    final enrollment = await repository.findByCode(code);
    final balance = _getBalance(enrollment!);
    final dto = EnrollmentOutputDto(code: enrollment.code, balance: balance);
    return dto;
  }

  double _getBalance(Enrollment enrollment) {
    final notPaidInvoices = enrollment.invoices.where((element) => !element.isPaid);
    final notPaidTotalValue = notPaidInvoices.map((e) {
      return e.amount;
    }).reduce((value, element) {
      return value + element;
      //TODO find a way to handle cases when all invoices are paid. For now, the method crashes on such ocasion.
    });
    return notPaidTotalValue;
  }
}
