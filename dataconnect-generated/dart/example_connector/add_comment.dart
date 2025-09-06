part of 'example.dart';

class AddCommentVariablesBuilder {
  String reportId;
  String commentText;

  final FirebaseDataConnect _dataConnect;
  AddCommentVariablesBuilder(this._dataConnect, {required  this.reportId,required  this.commentText,});
  Deserializer<AddCommentData> dataDeserializer = (dynamic json)  => AddCommentData.fromJson(jsonDecode(json));
  Serializer<AddCommentVariables> varsSerializer = (AddCommentVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AddCommentData, AddCommentVariables>> execute() {
    return ref().execute();
  }

  MutationRef<AddCommentData, AddCommentVariables> ref() {
    AddCommentVariables vars= AddCommentVariables(reportId: reportId,commentText: commentText,);
    return _dataConnect.mutation("AddComment", dataDeserializer, varsSerializer, vars);
  }
}

class AddCommentCommentInsert {
  String id;
  AddCommentCommentInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  AddCommentCommentInsert({
    required this.id,
  });
}

class AddCommentData {
  AddCommentCommentInsert comment_insert;
  AddCommentData.fromJson(dynamic json):
  
  comment_insert = AddCommentCommentInsert.fromJson(json['comment_insert']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['comment_insert'] = comment_insert.toJson();
    return json;
  }

  AddCommentData({
    required this.comment_insert,
  });
}

class AddCommentVariables {
  String reportId;
  String commentText;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AddCommentVariables.fromJson(Map<String, dynamic> json):
  
  reportId = nativeFromJson<String>(json['reportId']),
  commentText = nativeFromJson<String>(json['commentText']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['reportId'] = nativeToJson<String>(reportId);
    json['commentText'] = nativeToJson<String>(commentText);
    return json;
  }

  AddCommentVariables({
    required this.reportId,
    required this.commentText,
  });
}

