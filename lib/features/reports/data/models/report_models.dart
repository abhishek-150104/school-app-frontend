class ReportModel {
  final String schoolId;
  final String reportType;
  final Map<String, dynamic> data;
  final String generatedAt;

  ReportModel({
    required this.schoolId,
    required this.reportType,
    required this.data,
    required this.generatedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      schoolId: json['schoolId'] ?? '',
      reportType: json['reportType'] ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      generatedAt: json['generatedAt'] ?? '',
    );
  }
}
