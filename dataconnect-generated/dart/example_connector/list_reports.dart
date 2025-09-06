part of 'example.dart';

class ListReportsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListReportsVariablesBuilder(this._dataConnect, );
  Deserializer<ListReportsData> dataDeserializer = (dynamic json)  => ListReportsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListReportsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListReportsData, void> ref() {
    
    return _dataConnect.query("ListReports", dataDeserializer, emptySerializer, null);
  }
}

class ListReportsReports {
  String id;
  String? category;
  String content;
  String? notes;
  String reportType;
  String status;
  Timestamp submissionDate;
  ListReportsReportsSubmittedBy submittedBy;
  List<ListReportsReportsAnalysisResultsOnReport> analysisResults_on_report;
  List<ListReportsReportsCommentsOnReport> comments_on_report;
  ListReportsReports.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  category = json['category'] == null ? null : nativeFromJson<String>(json['category']),
  content = nativeFromJson<String>(json['content']),
  notes = json['notes'] == null ? null : nativeFromJson<String>(json['notes']),
  reportType = nativeFromJson<String>(json['reportType']),
  status = nativeFromJson<String>(json['status']),
  submissionDate = Timestamp.fromJson(json['submissionDate']),
  submittedBy = ListReportsReportsSubmittedBy.fromJson(json['submittedBy']),
  analysisResults_on_report = (json['analysisResults_on_report'] as List<dynamic>)
        .map((e) => ListReportsReportsAnalysisResultsOnReport.fromJson(e))
        .toList(),
  comments_on_report = (json['comments_on_report'] as List<dynamic>)
        .map((e) => ListReportsReportsCommentsOnReport.fromJson(e))
        .toList();

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    if (category != null) {
      json['category'] = nativeToJson<String?>(category);
    }
    json['content'] = nativeToJson<String>(content);
    if (notes != null) {
      json['notes'] = nativeToJson<String?>(notes);
    }
    json['reportType'] = nativeToJson<String>(reportType);
    json['status'] = nativeToJson<String>(status);
    json['submissionDate'] = submissionDate.toJson();
    json['submittedBy'] = submittedBy.toJson();
    json['analysisResults_on_report'] = analysisResults_on_report.map((e) => e.toJson()).toList();
    json['comments_on_report'] = comments_on_report.map((e) => e.toJson()).toList();
    return json;
  }

  ListReportsReports({
    required this.id,
    this.category,
    required this.content,
    this.notes,
    required this.reportType,
    required this.status,
    required this.submissionDate,
    required this.submittedBy,
    required this.analysisResults_on_report,
    required this.comments_on_report,
  });
}

class ListReportsReportsSubmittedBy {
  String id;
  String displayName;
  ListReportsReportsSubmittedBy.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  displayName = nativeFromJson<String>(json['displayName']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['displayName'] = nativeToJson<String>(displayName);
    return json;
  }

  ListReportsReportsSubmittedBy({
    required this.id,
    required this.displayName,
  });
}

class ListReportsReportsAnalysisResultsOnReport {
  String id;
  int safetyScore;
  ListReportsReportsAnalysisResultsOnReport.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  safetyScore = nativeFromJson<int>(json['safetyScore']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['safetyScore'] = nativeToJson<int>(safetyScore);
    return json;
  }

  ListReportsReportsAnalysisResultsOnReport({
    required this.id,
    required this.safetyScore,
  });
}

class ListReportsReportsCommentsOnReport {
  String id;
  String commentText;
  ListReportsReportsCommentsOnReport.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  commentText = nativeFromJson<String>(json['commentText']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['commentText'] = nativeToJson<String>(commentText);
    return json;
  }

  ListReportsReportsCommentsOnReport({
    required this.id,
    required this.commentText,
  });
}

class ListReportsData {
  List<ListReportsReports> reports;
  ListReportsData.fromJson(dynamic json):
  
  reports = (json['reports'] as List<dynamic>)
        .map((e) => ListReportsReports.fromJson(e))
        .toList();

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['reports'] = reports.map((e) => e.toJson()).toList();
    return json;
  }

  ListReportsData({
    required this.reports,
  });
}

