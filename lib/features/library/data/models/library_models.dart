class LibraryBookModel {
  final String id;
  final String schoolId;
  final String title;
  final String author;
  final String isbn;
  final String? category;
  final String? publisher;
  final int? publishYear;
  final int totalCopies;
  final int availableCopies;
  final String addedByName;

  LibraryBookModel({
    required this.id,
    required this.schoolId,
    required this.title,
    required this.author,
    required this.isbn,
    this.category,
    this.publisher,
    this.publishYear,
    required this.totalCopies,
    required this.availableCopies,
    required this.addedByName,
  });

  factory LibraryBookModel.fromJson(Map<String, dynamic> json) {
    return LibraryBookModel(
      id: json['id'] ?? '',
      schoolId: json['schoolId'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      isbn: json['isbn'] ?? '',
      category: json['category'],
      publisher: json['publisher'],
      publishYear: json['publishYear'],
      totalCopies: json['totalCopies'] ?? 0,
      availableCopies: json['availableCopies'] ?? 0,
      addedByName: json['addedByName'] ?? '',
    );
  }
}

class LibraryIssueModel {
  final String id;
  final String bookId;
  final String bookTitle;
  final String bookIsbn;
  final String memberId;
  final String memberRole;
  final String issuedDate;
  final String dueDate;
  final String? returnedDate;
  final String status;
  final String issuedByName;

  LibraryIssueModel({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.bookIsbn,
    required this.memberId,
    required this.memberRole,
    required this.issuedDate,
    required this.dueDate,
    this.returnedDate,
    required this.status,
    required this.issuedByName,
  });

  factory LibraryIssueModel.fromJson(Map<String, dynamic> json) {
    return LibraryIssueModel(
      id: json['id'] ?? '',
      bookId: json['bookId'] ?? '',
      bookTitle: json['bookTitle'] ?? '',
      bookIsbn: json['bookIsbn'] ?? '',
      memberId: json['memberId'] ?? '',
      memberRole: json['memberRole'] ?? '',
      issuedDate: json['issuedDate'] ?? '',
      dueDate: json['dueDate'] ?? '',
      returnedDate: json['returnedDate'],
      status: json['status'] ?? '',
      issuedByName: json['issuedByName'] ?? '',
    );
  }
}
