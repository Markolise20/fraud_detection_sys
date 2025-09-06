part of 'example.dart';

class GetUserReportsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  GetUserReportsVariablesBuilder(this._dataConnect, );
  Deserializer<GetUserReportsData> dataDeserializer = (dynamic json)  => GetUserReportsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<GetUserReportsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<GetUserReportsData, void> ref() {
    
    return _dataConnect.query("GetUserReports", dataDeserializer, emptySerializer, null);
  }
}

class GetUserReportsReports {
  String id;
  String? category;
  String content;
  GetUserReportsReports.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  category = json['category'] == null ? null : nativeFromJson<String>(json['category']),
  content = nativeFromJson<String>(json['content']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    if (category != null) {
      json['category'] = nativeToJson<String?>(category);
    }
    json['content'] = nativeToJson<String>(content);
    return json;
  }

  GetUserReportsReports({
    required this.id,
    this.category,
    required this.content,
  });
}

class GetUserReportsData {
  List<GetUserReportsReports> reports;
  GetUserReportsData.fromJson(dynamic json):
  
  reports = (json['reports'] as List<dynamic>)
        .map((e) => GetUserReportsReports.fromJson(e))
        .toList();

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['reports'] = reports.map((e) => e.toJson()).toList();
    return json;
  }

  GetUserReportsData({
    required this.reports,
  });
}

