class Age {
  late final int value;

  Age({required DateTime birthDate, DateTime? referenceDate}) {
    value = _calculateAge(birthDate, referenceDate ?? DateTime.now());
  }

  int _calculateAge(DateTime birthDate, DateTime referenceDate) {
    if (referenceDate.isBefore(birthDate)) {
      throw Exception('The birthDate is invalid because it is after the $referenceDate}');
    }
    if (referenceDate.year == birthDate.year) {
      return 0;
    } else {
      return referenceDate.year - birthDate.year;
    }
  }
}
