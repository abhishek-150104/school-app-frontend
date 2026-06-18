class FeeStructureModel {
  final String id;
  final String academicYearId;
  final String academicYearName;
  final String classRoomId;
  final String classRoomName;
  final double tuitionFee;
  final double examFee;
  final double libraryFee;
  final double sportsFee;
  final double miscFee;
  final double totalFee;

  const FeeStructureModel({
    required this.id,
    required this.academicYearId,
    required this.academicYearName,
    required this.classRoomId,
    required this.classRoomName,
    required this.tuitionFee,
    required this.examFee,
    required this.libraryFee,
    required this.sportsFee,
    required this.miscFee,
    required this.totalFee,
  });

  factory FeeStructureModel.fromJson(Map<String, dynamic> j) => FeeStructureModel(
    id: j['id'] ?? '',
    academicYearId: j['academicYearId'] ?? '',
    academicYearName: j['academicYearName'] ?? '',
    classRoomId: j['classRoomId'] ?? '',
    classRoomName: j['classRoomName'] ?? '',
    tuitionFee: (j['tuitionFee'] ?? 0).toDouble(),
    examFee: (j['examFee'] ?? 0).toDouble(),
    libraryFee: (j['libraryFee'] ?? 0).toDouble(),
    sportsFee: (j['sportsFee'] ?? 0).toDouble(),
    miscFee: (j['miscFee'] ?? 0).toDouble(),
    totalFee: (j['totalFee'] ?? 0).toDouble(),
  );
}

class FeeInvoiceModel {
  final String id;
  final String studentId;
  final String studentFullName;
  final String admissionNumber;
  final String classRoomName;
  final String sectionName;
  final String academicYearName;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final String status;
  final String? dueDate;

  const FeeInvoiceModel({
    required this.id,
    required this.studentId,
    required this.studentFullName,
    required this.admissionNumber,
    required this.classRoomName,
    required this.sectionName,
    required this.academicYearName,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.status,
    this.dueDate,
  });

  factory FeeInvoiceModel.fromJson(Map<String, dynamic> j) => FeeInvoiceModel(
    id: j['id'] ?? '',
    studentId: j['studentId'] ?? '',
    studentFullName: j['studentFullName'] ?? '',
    admissionNumber: j['admissionNumber'] ?? '',
    classRoomName: j['classRoomName'] ?? '',
    sectionName: j['sectionName'] ?? '',
    academicYearName: j['academicYearName'] ?? '',
    totalAmount: (j['totalAmount'] ?? 0).toDouble(),
    paidAmount: (j['paidAmount'] ?? 0).toDouble(),
    dueAmount: (j['dueAmount'] ?? 0).toDouble(),
    status: j['status'] ?? 'PENDING',
    dueDate: j['dueDate'],
  );
}

class FeePaymentModel {
  final String id;
  final String invoiceId;
  final String studentFullName;
  final double amount;
  final String paymentMode;
  final String? transactionId;
  final String? collectedByName;

  const FeePaymentModel({
    required this.id,
    required this.invoiceId,
    required this.studentFullName,
    required this.amount,
    required this.paymentMode,
    this.transactionId,
    this.collectedByName,
  });

  factory FeePaymentModel.fromJson(Map<String, dynamic> j) => FeePaymentModel(
    id: j['id'] ?? '',
    invoiceId: j['invoiceId'] ?? '',
    studentFullName: j['studentFullName'] ?? '',
    amount: (j['amount'] ?? 0).toDouble(),
    paymentMode: j['paymentMode'] ?? '',
    transactionId: j['transactionId'],
    collectedByName: j['collectedByName'],
  );
}
