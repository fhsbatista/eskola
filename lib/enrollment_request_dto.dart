class EnrollmentRequestDTO {
  final String studentName;
  final String studentCpf;
  final String studentBirthDate;
  final String levelCode;
  final String moduleCode;
  final String classroomCode;

  EnrollmentRequestDTO({
    required this.studentName,
    required this.studentCpf,
    required this.studentBirthDate,
    required this.levelCode,
    required this.moduleCode,
    required this.classroomCode,
  });
}
